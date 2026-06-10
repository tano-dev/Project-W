-- File: Server/Systems/CraftingSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local InventorySystem = require(game.ServerScriptService.Server.Systems.Inventory)
local PlayerStatSystem = require(game.ServerScriptService.Server.Systems.PlayerStatSystem) -- [MỚI]
local LevelingCalculator = require(game.ReplicatedStorage.Shared.Utilities.LevelingCalculator) -- [MỚI]
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local CraftingRecipes = require(game.ReplicatedStorage.Shared.Constants.CraftingRecipes)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local CraftingSystem = {}

local function DeepCopyData(data)
	if type(data) ~= "table" then
		return data
	end
	return HttpService:JSONDecode(HttpService:JSONEncode(data))
end

-- ==========================================
-- TÍCH HỢP BỘ TÍNH LEVEL VÀO ĐIỀU KIỆN
-- ==========================================
local function MeetRequirements(profile: table, recipe: table)
	if not recipe.Requirements then
		return true
	end
	local req = recipe.Requirements

	if req.Professions then
		for profName, minLevel in pairs(req.Professions) do
			-- 1. Lấy tổng EXP hiện tại
			local playerProfExp = profile.Data.Professions and profile.Data.Professions[profName] or 0

			-- 2. Dùng Calculator để dịch EXP thành Level thực tế
			local playerProfLevel = LevelingCalculator.CalculateLevel(playerProfExp)

			if playerProfLevel < minLevel then
				return false,
					string.format(
						"Yêu cầu %s đạt cấp %d! (Hiện tại: Cấp %d)",
						profName,
						minLevel,
						playerProfLevel
					)
			end
		end
	end
	return true
end

function CraftingSystem:ProcessCraft(player: Player, recipeId: string, mainItemIndex: number?, craftAmount: number?)
	local profile = DataManager:GetProfile(player)
	local recipe = CraftingRecipes[recipeId]

	if not profile or not recipe then
		return false
	end
	craftAmount = craftAmount or 1

	if recipe.MainIngredient and craftAmount > 1 then
		return {
			Success = false,
			Message = "Công thức nâng cấp trang bị chỉ có thể chế tạo từng món một!",
		}
	end

	local canCraft, errorMsg = MeetRequirements(profile, recipe)
	if not canCraft then
		return { Success = false, Message = errorMsg }
	end

	local mainItemData = nil
	if recipe.MainIngredient then
		if not mainItemIndex then
			return { Success = false, Message = "Vui lòng chọn phôi nâng cấp!" }
		end
		mainItemData = profile.Data.Inventories.Items[mainItemIndex]
		if not mainItemData or mainItemData.Id ~= recipe.MainIngredient then
			return { Success = false, Message = "Vật phẩm chọn làm phôi không hợp lệ!" }
		end
	end

	local requiredIngredients = {}
	for _, ingredient in ipairs(recipe.Inputs) do
		local totalHas = 0
		local neededAmount = ingredient.BaseAmount * craftAmount
		local targetId = ingredient.Id

		for _, stack in ipairs(profile.Data.Inventories.Materials) do
			if stack.Id == targetId then
				totalHas += stack.Amount
			end
		end
		for _, stack in ipairs(profile.Data.Inventories.Consumables) do
			if stack.Id == targetId then
				totalHas += stack.Amount
			end
		end

		if totalHas < neededAmount then
			return {
				Success = false,
				Message = string.format(
					"Không đủ nguyên liệu: %s (Cần: %d, Có: %d)",
					targetId,
					neededAmount,
					totalHas
				),
			}
		end
		table.insert(requiredIngredients, { Id = targetId, AmountToDeduct = neededAmount })
	end

	for _, reqMat in ipairs(requiredIngredients) do
		local successMat = InventorySystem:RemoveStackable(player, "Materials", reqMat.Id, reqMat.AmountToDeduct)
		if not successMat then
			InventorySystem:RemoveStackable(player, "Consumables", reqMat.Id, reqMat.AmountToDeduct)
		end
	end

	if mainItemData then
		InventorySystem:RemoveItemByUUID(player, mainItemData.UUID)
	end

	for _, outputDefData in ipairs(recipe.Outputs) do
		local targetId = outputDefData.Id
		local outputDef = ItemDatabase.Registry[targetId]
		local amountToReceive = (outputDefData.Amount or 1) * craftAmount

		if outputDef and outputDef.ItemType == "Material" then
			InventorySystem:GiveStackable(player, "Materials", targetId, amountToReceive)
		elseif outputDef and outputDef.ItemType == "Consumable" then
			InventorySystem:GiveStackable(player, "Consumables", targetId, amountToReceive)
		else
			for _ = 1, amountToReceive do
				local craftedItem = {
					UUID = HttpService:GenerateGUID(false),
					Id = targetId,
					BindState = (mainItemData and mainItemData.BindState) or "Unlocked",
					UpgradeCount = mainItemData and mainItemData.UpgradeCount,
					Purity = mainItemData and mainItemData.Purity,
					Corruption = mainItemData and mainItemData.Corruption,
					Aura = mainItemData and mainItemData.Aura,
					CustomName = mainItemData and mainItemData.CustomName,
					UpgradeHistory = mainItemData and mainItemData.UpgradeHistory and DeepCopyData(
						mainItemData.UpgradeHistory
					),
					State = mainItemData and mainItemData.State and DeepCopyData(mainItemData.State),
					NBT = mainItemData and mainItemData.NBT and DeepCopyData(mainItemData.NBT),
					Enchants = mainItemData and mainItemData.Enchants and DeepCopyData(mainItemData.Enchants),
					Gems = mainItemData and mainItemData.Gems and DeepCopyData(mainItemData.Gems),
				}
				InventorySystem:GiveCustomItem(player, craftedItem)
			end
		end
	end

	-- ==========================================
	-- TÍCH HỢP PLAYER STAT SYSTEM ĐỂ CỘNG EXP
	-- ==========================================
	if recipe.ExpGains then
		for profName, baseExpAmount in pairs(recipe.ExpGains) do
			local totalExp = baseExpAmount * craftAmount
			PlayerStatSystem:AddProfessionExp(player, profName, totalExp)
		end
	end

	local successMessage = craftAmount > 1
			and string.format("Chế tạo thành công %d lô vật phẩm!", craftAmount)
		or "Chế tạo thành công vật phẩm!"
	return { Success = true, Message = successMessage }
end

function CraftingSystem:Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			if command == "/craft" then
				local recipeId = args[1]
				if not recipeId then
					return
				end
				local recipe = CraftingRecipes[recipeId]
				if not recipe then
					return
				end

				local mainItemIndex = nil
				local craftAmount = 1

				if recipe.MainIngredient then
					mainItemIndex = tonumber(args[2])
					craftAmount = 1
				else
					craftAmount = tonumber(args[2]) or 1
				end

				local result = self:ProcessCraft(player, recipeId, mainItemIndex, craftAmount)
				if result then
					print("👉 " .. result.Message)
				end
			end
		end)
	end)
end
return CraftingSystem
