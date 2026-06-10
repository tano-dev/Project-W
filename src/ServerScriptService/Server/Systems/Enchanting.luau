-- File: Server/Systems/EnchantSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local InventorySystem = require(game.ServerScriptService.Server.Systems.Inventory)
local PlayerStatSystem = require(game.ServerScriptService.Server.Systems.PlayerStatSystem) -- [MỚI]
local LevelingCalculator = require(game.ReplicatedStorage.Shared.Utilities.LevelingCalculator) -- [MỚI]
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local EnchantData = require(game.ReplicatedStorage.Shared.Constants.EnchantData)
local Players = game:GetService("Players")

local EnchantSystem = {}

local ENCHANT_BALANCING = {
	MaxEnchantLines = 5,
	NewEnchantChances = { [0] = 1.00, [1] = 0.50, [2] = 0.30, [3] = 0.15, [4] = 0.05 },
	RarityUpgradeWeights = { Common = 100, Uncommon = 70, Rare = 40, Epic = 15, Legendary = 5, Mythic = 1 },
	RarityExpMultipliers = { Common = 1.0, Uncommon = 1.5, Rare = 2.5, Epic = 5.0, Legendary = 10.0, Mythic = 25.0 },
	ReqLevelExpPower = 1.3,
	EnableLevelCatchup = true,
}

local ITEM_CATEGORIES = {
	Weapon = { "Sword", "Rapier", "Katana", "Dagger", "Staff", "Axe", "Hoe", "Fishing Rod", "Pickaxe" },
	Armor = { "Headgear", "Chestplate", "Boots" },
}

local function IsItemTypeAccepted(itemType: string, acceptTypes: table)
	if table.find(acceptTypes, "All") then
		return true
	end
	if table.find(acceptTypes, itemType) then
		return true
	end
	for _, acceptRule in ipairs(acceptTypes) do
		local categoryList = ITEM_CATEGORIES[acceptRule]
		if categoryList and table.find(categoryList, itemType) then
			return true
		end
	end
	return false
end

local function GetNewEnchantPool(
	enchantingLevel: number,
	itemType: string,
	runeAttribute: string?,
	currentEnchants: table
)
	local pool = {}
	local filteredEnchants = EnchantData.GetByAttribute(runeAttribute)
	local existingMap = {}
	for _, enc in ipairs(currentEnchants) do
		existingMap[enc.Id] = true
	end

	for enchantId, enchantDef in pairs(filteredEnchants) do
		if not existingMap[enchantId] and IsItemTypeAccepted(itemType, enchantDef.AcceptTypes) then
			local reqLevel = enchantDef.Conditions and enchantDef.Conditions.Enchanting or 0
			if enchantingLevel >= reqLevel then
				table.insert(pool, { Id = enchantId, Weight = enchantDef.BaseWeight })
			end
		end
	end
	return pool
end

local function GetUpgradeEnchantPool(currentEnchants: table)
	local pool = {}
	local allEnchants = EnchantData.GetAll()
	for _, existing in ipairs(currentEnchants) do
		local enchantDef = allEnchants[existing.Id]
		if enchantDef and existing.Level < enchantDef.MaxLevel then
			local rarityWeight = ENCHANT_BALANCING.RarityUpgradeWeights[enchantDef.Rarity or "Common"] or 10
			local finalWeight = rarityWeight
			if ENCHANT_BALANCING.EnableLevelCatchup then
				local levelFactor = enchantDef.MaxLevel / existing.Level
				finalWeight = math.floor(finalWeight * levelFactor)
			end
			table.insert(pool, { Id = existing.Id, Weight = finalWeight, CurrentLevel = existing.Level })
		end
	end
	return pool
end

local function RollFromPool(pool: table)
	if #pool == 0 then
		return nil
	end
	local totalWeight = 0
	for _, entry in ipairs(pool) do
		totalWeight += entry.Weight
	end
	local roll = math.random() * totalWeight
	local currentWeight = 0
	for _, entry in ipairs(pool) do
		currentWeight += entry.Weight
		if roll <= currentWeight then
			return entry.Id
		end
	end
	return nil
end

function EnchantSystem:ProcessEnchant(player: Player, targetItemIndex: number, runeIndex: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	local targetItem = profile.Data.Inventories.Items[targetItemIndex]
	local runeStack = profile.Data.Inventories.Materials and profile.Data.Inventories.Materials[runeIndex]

	if not targetItem then
		return { Success = false, Message = "Không tìm thấy trang bị!" }
	end
	if not runeStack or runeStack.Amount < 1 then
		return { Success = false, Message = "Không tìm thấy Rune!" }
	end

	local baseItemDef = ItemDatabase.Registry[targetItem.Id]
	local runeDef = ItemDatabase.Registry[runeStack.Id]

	if not baseItemDef or not runeDef or not runeDef.RuneLogic then
		return { Success = false, Message = "Dữ liệu không hợp lệ!" }
	end

	local maxEnchantUses = baseItemDef.MaxEnchants or 0
	if maxEnchantUses <= 0 then
		return { Success = false, Message = "Trang bị này không có độ bền để Enchant!" }
	end

	local currentUses = targetItem.EnchantCounts or 0
	if currentUses >= maxEnchantUses then
		return {
			Success = false,
			Message = string.format(
				"Đã hết số lần Enchant (%d/%d)! Hãy tẩy bùa để làm lại.",
				currentUses,
				maxEnchantUses
			),
		}
	end

	local newItemData = table.clone(targetItem)
	newItemData.Enchants = newItemData.Enchants or {}

	-- ==========================================
	-- TÍCH HỢP TÍNH LEVEL ĐỘNG (DYNAMIC CALCULATION)
	-- ==========================================
	local enchantingExp = profile.Data.Professions and profile.Data.Professions.Enchanting or 0
	local enchantingLevel = LevelingCalculator.CalculateLevel(enchantingExp)

	local itemType = baseItemDef.Type or "Unknown"
	local tokensLeft = runeDef.RuneLogic.Tokens

	local testNewPool = GetNewEnchantPool(enchantingLevel, itemType, runeDef.RuneLogic.Attribute, newItemData.Enchants)
	local testUpgradePool = GetUpgradeEnchantPool(newItemData.Enchants)

	if #testNewPool == 0 and #testUpgradePool == 0 then
		return {
			Success = false,
			Message = "Trang bị này đã tối đa sức mạnh của Hệ này, không thể đập thêm!",
		}
	end

	local enchantsGainedLog = {}

	while tokensLeft > 0 do
		local currentEnchantsCount = #newItemData.Enchants
		local chanceForNew = ENCHANT_BALANCING.NewEnchantChances[currentEnchantsCount] or 0
		if currentEnchantsCount >= ENCHANT_BALANCING.MaxEnchantLines then
			chanceForNew = 0
		end

		local newPool = GetNewEnchantPool(enchantingLevel, itemType, runeDef.RuneLogic.Attribute, newItemData.Enchants)
		local upgradePool = GetUpgradeEnchantPool(newItemData.Enchants)

		if #newPool == 0 then
			chanceForNew = 0
		end
		if #upgradePool == 0 then
			chanceForNew = 1
		end
		if #newPool == 0 and #upgradePool == 0 then
			break
		end

		local isRollingNew = math.random() <= chanceForNew
		local pickedEnchantId = nil

		if isRollingNew then
			pickedEnchantId = RollFromPool(newPool)
			if pickedEnchantId then
				table.insert(newItemData.Enchants, { Id = pickedEnchantId, Level = 1 })
				table.insert(enchantsGainedLog, string.format("✨ Mới: %s", pickedEnchantId))
			end
		else
			pickedEnchantId = RollFromPool(upgradePool)
			if pickedEnchantId then
				for _, existing in ipairs(newItemData.Enchants) do
					if existing.Id == pickedEnchantId then
						existing.Level += 1
						table.insert(
							enchantsGainedLog,
							string.format("⬆️ Cấp %d: %s", existing.Level, pickedEnchantId)
						)
						break
					end
				end
			end
		end
		tokensLeft -= 1
	end

	newItemData.EnchantCounts = currentUses + 1

	local successRemove = InventorySystem:RemoveStackable(player, "Materials", runeStack.Id, 1)
	if not successRemove then
		return { Success = false, Message = "Lỗi khi trừ Rune!" }
	end

	local expToGive = runeDef.RuneLogic.EnchantingExp or 0
	if expToGive > 0 then
		-- Gọi PlayerStatSystem để cập nhật tập trung
		PlayerStatSystem:AddProfessionExp(player, "Enchanting", expToGive)
		table.insert(enchantsGainedLog, string.format("⭐ Nhận %d Exp nghề", expToGive))
	end

	InventorySystem:UpdateItemData(player, targetItem.UUID, newItemData)

	local msg = "Enchant thất bại (Lỗi kịch bản Gacha)!"
	if #enchantsGainedLog > 0 then
		msg = string.format("Enchant thành công! (Số lần: %d/%d)\n", newItemData.EnchantCounts, maxEnchantUses)
			.. table.concat(enchantsGainedLog, "\n")
	end
	return { Success = true, Message = msg }
end

function EnchantSystem:DisenchantItem(player: Player, targetItemIndex: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	local targetItem = profile.Data.Inventories.Items[targetItemIndex]
	if not targetItem then
		return { Success = false, Message = "Không tìm thấy trang bị!" }
	end

	if not targetItem.Enchants or #targetItem.Enchants == 0 then
		return { Success = false, Message = "Trang bị này không có Enchant nào để tẩy!" }
	end

	local totalExpReward = 0
	local allEnchants = EnchantData.GetAll()

	for _, existing in ipairs(targetItem.Enchants) do
		local enchantDef = allEnchants[existing.Id]
		if enchantDef then
			local rarityMult = ENCHANT_BALANCING.RarityExpMultipliers[enchantDef.Rarity or "Common"] or 1.0
			local baseWeight = math.max(1, enchantDef.BaseWeight or 100)
			local reqLevel = enchantDef.Conditions and enchantDef.Conditions.Enchanting or 1
			local reqLevelScaling = math.pow(math.max(1, reqLevel), ENCHANT_BALANCING.ReqLevelExpPower)

			local expValue = math.floor((10 * existing.Level * rarityMult * reqLevelScaling) / (baseWeight / 100))
			totalExpReward += expValue
		end
	end

	local newItemData = table.clone(targetItem)
	newItemData.Enchants = nil
	newItemData.EnchantCounts = nil

	InventorySystem:UpdateItemData(player, targetItem.UUID, newItemData)

	-- Gọi PlayerStatSystem xử lý thưởng EXP
	PlayerStatSystem:AddProfessionExp(player, "Enchanting", totalExpReward)

	return {
		Success = true,
		Message = string.format(
			"Tẩy bùa thành công! Trang bị đã khôi phục độ bền Rune. Bạn nhận được %d Exp Nghề Enchanting!",
			totalExpReward
		),
	}
end

EnchantSystem.Start = function()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			if command == "/enchant" then
				local targetItemIndex = tonumber(args[1])
				local runeIndex = tonumber(args[2])
				if not targetItemIndex or not runeIndex then
					return
				end

				local result = EnchantSystem:ProcessEnchant(player, targetItemIndex, runeIndex)
				if result then
					print("👉 " .. result.Message)
				end
			elseif command == "/disenchant" then
				local targetItemIndex = tonumber(args[1])
				if not targetItemIndex then
					return
				end

				local result = EnchantSystem:DisenchantItem(player, targetItemIndex)
				if result then
					print("👉 " .. result.Message)
				end
			end
		end)
	end)
end

return EnchantSystem
