-- File: Server/Systems/UpgradeSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local InventorySystem = require(game.ServerScriptService.Server.Systems.Inventory)
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local UpgradeTemplates = require(game.ReplicatedStorage.Shared.Components.UpgradeTemplate)
local Players = game:GetService("Players")

local UpgradeSystem = {}

-- ==========================================
-- TỪ ĐIỂN PHÂN LOẠI VẬT PHẨM (ITEM CATEGORIES)
-- ==========================================
local ITEM_CATEGORIES = {
	Weapon = { "Sword", "Rapier", "Katana", "Dagger", "Staff", "Axe", "Hoe", "Fishing Rod", "Pickaxe" },
	Armor = { "Headgear", "Chestplate", "Boots" },
	Tool = { "Axe", "Hoe", "Fishing Rod", "Pickaxe" },
	-- Consumable = {"Upgrader","Float","Reel","Bait","Consumable","Arrow"},
}
-- ==========================================
-- BẢNG PHIÊN DỊCH PHẨM CHẤT (RARITY MAPPING)
-- ==========================================
local RARITY_TO_NUM = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
}

local NUM_TO_RARITY = {
	[1] = "Common",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Epic",
	[5] = "Legendary",
	[6] = "Mythic",
}
-- ==========================================
-- 1. TỪ ĐIỂN TRẠNG THÁI (ITEM STATES)
-- Chuyển số thành chuỗi để dễ đọc khi lưu vào DataStore
-- ==========================================
local ITEM_STATES = {
	AntiNuke = "AntiNuke", -- Chống vỡ đồ VĨNH VIỄN (Giữ lại sau khi xịt)
	NukeProtection = "NukeProtection", -- Chống vỡ đồ 1 LẦN (Mất đi sau khi xịt)
	AntiSlotGone = "AntiSlotGone",
	AntiPurity = "AntiPurity",
	AntiCorruption = "AntiCorruption",
	AlwaysSuccess = "AlwaysSuccess",
	SayNoWithHolies = "SayNoWithHolies",
	SayNoWithUpgrades = "SayNoWithUpgrades",
	RarityAscended = "RarityAscended", -- State đánh dấu: "Đồ này đã từng được thăng bậc"
	RarityDescended = "RarityDescended", -- State đánh dấu: "Đồ này đã từng bị rớt bậc"
	-- States mở rộng Slot
	UpgradeExtended = "UpgradeExtended",
	GreatUpgradeExtended = "GreatUpgradeExtended",
	UltimateUpgradeExtended = "UltimateUpgradeExtended",
}

-- ==========================================
-- HÀM HỖ TRỢ: XỬ LÝ TRẠNG THÁI (STATES)
-- ==========================================
local function HasState(itemData: table, stateName: string)
	if not itemData.State then
		return false
	end
	return table.find(itemData.State, stateName) ~= nil
end

local function ConsumeState(itemData: table, stateName: string)
	if not itemData.State then
		return false
	end
	local index = table.find(itemData.State, stateName)
	if index then
		table.remove(itemData.State, index)
		-- Nếu xóa xong mà mảng rỗng thì gán nil để dọn rác RAM
		if #itemData.State == 0 then
			itemData.State = nil
		end
		return true
	end
	return false
end

local function AddState(itemData: table, stateName: string)
	if not itemData.State then
		itemData.State = {}
	end
	if not table.find(itemData.State, stateName) then
		table.insert(itemData.State, stateName)
	end
end

-- ==========================================
-- HÀM HỖ TRỢ: RANDOM TRỌNG SỐ
-- ==========================================
local function RollByWeight(poolArray)
	if not poolArray or #poolArray == 0 then
		return nil
	end
	local totalWeight = 0
	for _, entry in ipairs(poolArray) do
		totalWeight += (entry.Weight or 1)
	end
	local roll = math.random() * totalWeight
	local currentWeight = 0
	for _, entry in ipairs(poolArray) do
		currentWeight += (entry.Weight or 1)
		if roll <= currentWeight then
			return entry
		end
	end
	return poolArray[#poolArray]
end
-- ==========================================
-- HÀM HỖ TRỢ: LOGIC ĐA DẠNG HÓA CHỈ SỐ (MULTI-ROLL STATS)
-- ==========================================
local function ProcessStatRolls(poolOutcome, newItemData, statChangesLog)
	if not poolOutcome.StatPools or #poolOutcome.StatPools == 0 then
		return
	end

	local availableStats = {}
	local selectedStats = {}

	-- Tách riêng các chỉ số Weight = 0 (Bắt buộc trúng)
	for i, entry in ipairs(poolOutcome.StatPools) do
		if entry.Weight == 0 then
			table.insert(selectedStats, entry)
		else
			table.insert(availableStats, { Entry = entry, Index = i })
		end
	end

	local rolls = poolOutcome.Rolls or 0

	if rolls == 0 then
		-- Nếu Rolls = 0 hoặc nil: Lấy TẤT CẢ
		for _, wrapper in ipairs(availableStats) do
			table.insert(selectedStats, wrapper.Entry)
		end
	else
		-- Tính số lượt roll thực tế cần quay (Trừ đi các món Weight = 0 đã tự động nhận)
		local remainingRolls = rolls - #selectedStats

		while remainingRolls > 0 and #availableStats > 0 do
			-- Tính lại tổng Weight của các món còn lại
			local totalWeight = 0
			for _, wrapper in ipairs(availableStats) do
				totalWeight += (wrapper.Entry.Weight or 1)
			end

			-- Roll xí ngầu
			local roll = math.random() * totalWeight
			local currentWeight = 0
			local pickedIndex = nil

			for i, wrapper in ipairs(availableStats) do
				currentWeight += (wrapper.Entry.Weight or 1)
				if roll <= currentWeight then
					pickedIndex = i
					break
				end
			end

			-- Fallback an toàn
			if not pickedIndex then
				pickedIndex = #availableStats
			end

			-- Lấy món đồ trúng thưởng và loại nó khỏi danh sách để không bị trùng (Không lặp lại)
			table.insert(selectedStats, availableStats[pickedIndex].Entry)
			table.remove(availableStats, pickedIndex)

			remainingRolls -= 1
		end
	end

	-- Thực thi cộng chỉ số cho các mục đã chọn
    for _, statRoll in ipairs(selectedStats) do
        local rolledValue = math.random(statRoll.Min, statRoll.Max)

        -- Đặc quyền của Purity và Corruption: Chống âm chỉ số
        if statRoll.StatName == "Purity" and rolledValue < 0 and ConsumeState(newItemData, ITEM_STATES.AntiPurity) then
            rolledValue = 0
        end
        if statRoll.StatName == "Corruption" and rolledValue > 0 and ConsumeState(newItemData, ITEM_STATES.AntiCorruption) then
            rolledValue = 0
        end

        -- NGOẠI LỆ DUY NHẤT: Purity và Corruption VẪN PHẢI LƯU trực tiếp lên đồ.
        -- Lý do: Đây là "Trạng thái vật lý" của món đồ ảnh hưởng đến tỉ lệ nâng cấp của đá khác,
        -- chứ không phải là chỉ số chiến đấu (Combat Stats).
        if statRoll.StatName == "Purity" or statRoll.StatName == "Corruption" then
             newItemData[statRoll.StatName] = (newItemData[statRoll.StatName] or 0) + rolledValue
        end

        -- LƯU VÀO LOG: Mọi chỉ số (Damage, MagicDamage, Crit, Health...) sẽ CHỈ được lưu vào mảng Log
        statChangesLog[statRoll.StatName] = rolledValue
    end
end

-- ==========================================
-- HÀM HỖ TRỢ: TÍNH MAX UPGRADE SLOTS
-- ==========================================
local function GetMaxUpgrades(itemData, baseItemDef)
	local baseMax = baseItemDef.MaxUpgrades or 0

	-- Cộng dồn Slot từ các State Mở rộng
	if HasState(itemData, ITEM_STATES.UpgradeExtended) then
		baseMax += 1
	end
	if HasState(itemData, ITEM_STATES.GreatUpgradeExtended) then
		baseMax += 1
	end
	if HasState(itemData, ITEM_STATES.UltimateUpgradeExtended) then
		baseMax += 1
	end

	return baseMax
end
-- ==========================================
-- 2. TÍNH TOÁN TỈ LỆ THÀNH CÔNG ĐỘNG (CONDITIONS)
-- ==========================================
local function CalculateSuccessRate(itemData: table, baseItemDef: table, logicTemplate: table)
	-- BÙA HỘ MỆNH: Luôn thành công
	if HasState(itemData, ITEM_STATES.AlwaysSuccess) then
		return 1.0
	end

	local finalRate = logicTemplate.BaseSuccessRate

	if logicTemplate.Conditions then
		for _, condition in ipairs(logicTemplate.Conditions) do
			local rateChange = 0
			local condType = condition.Type

			-- Các điều kiện dựa trên chỉ số
			if condType == "Purity" then
				rateChange = (itemData.Purity or 0) * condition.RatePerPoint
			elseif condType == "Corruption" then
				rateChange = (itemData.Corruption or 0) * condition.RatePerPoint

			-- Các điều kiện dựa trên Template gốc (VD: Rarity)
			elseif condType == "Rarity" then
				-- Lấy giá trị gốc (Có thể đang là chữ "Epic" hoặc số 4)
				local rarityRaw = (itemData.NBT and itemData.NBT.Rarity) or baseItemDef.Rarity or "Common"

				-- Phiên dịch nó thành số để tính toán
				local rarityLevel = type(rarityRaw) == "string" and (RARITY_TO_NUM[rarityRaw] or 1) or rarityRaw

				rateChange = rarityLevel * condition.RatePerPoint
			-- Các điều kiện dựa trên số lần đã ép (UpgradeCount)
			elseif condType == "OnLessUpgradeAttempts" then
				if (itemData.UpgradeCount or 0) < condition.TargetValue then
					rateChange = condition.BonusRate
				end
			elseif condType == "OnMoreUpgradeAttempts" then
				if (itemData.UpgradeCount or 0) >= condition.TargetValue then
					rateChange = condition.BonusRate
				end
			elseif condType == "NotUpgraded" then
				if (itemData.UpgradeCount or 0) == 0 then
					rateChange = condition.BonusRate
				end
			end

			-- Ép khung MaxCap
			if condition.MaxCap then
				if condition.MaxCap > 0 then
					rateChange = math.min(rateChange, condition.MaxCap)
				elseif condition.MaxCap < 0 then
					rateChange = math.max(rateChange, condition.MaxCap)
				end
			end

			finalRate += rateChange
		end
	end

	return math.clamp(finalRate, 0.0, 1.0)
end
-- ==========================================
-- HÀM HỖ TRỢ: KIỂM TRA PHÂN LOẠI ĐỘNG
-- ==========================================
local function IsItemTypeAccepted(itemType: string, acceptTypes: table)
	-- Nếu cho phép tất cả
	if table.find(acceptTypes, "All") then
		return true
	end

	-- Nếu itemType trùng khớp chính xác với 1 trong các loại được phép (VD: item là Dagger, AcceptTypes có "Dagger")
	if table.find(acceptTypes, itemType) then
		return true
	end

	-- Nếu AcceptTypes chứa một Nhóm Cha (Category), ta phải kiểm tra xem itemType có nằm trong nhóm đó không.
	for _, acceptRule in ipairs(acceptTypes) do
		local categoryList = ITEM_CATEGORIES[acceptRule]
		-- Nếu acceptRule là một Nhóm Cha có tồn tại trong từ điển
		if categoryList then
			-- Và itemType của món đồ hiện tại nằm trong danh sách của Nhóm Cha đó
			if table.find(categoryList, itemType) then
				return true
			end
		end
	end

	return false
end
-- ==========================================
-- 3. LOGIC LÕI: NÂNG CẤP DỰA TRÊN VỊ TRÍ (INDEX)
-- ==========================================
function UpgradeSystem:ProcessUpgradeByIndex(
	player: Player,
	itemIndex: number,
	materialCategory: string,
	materialIndex: number
)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	-- 1. TRÍCH XUẤT VẬT PHẨM VÀ ĐÁ NÂNG CẤP
	local itemData = profile.Data.Inventories.Items[itemIndex]
	local inventoryCat = profile.Data.Inventories[materialCategory]
	local materialStack = inventoryCat and inventoryCat[materialIndex]

	if not itemData then
		return false
	end
	if not materialStack or materialStack.Amount < 1 then
		return false
	end

	local baseItemDef = ItemDatabase.Registry[itemData.ID]
	local materialDef = ItemDatabase.Registry[materialStack.Id]

	if not baseItemDef or not materialDef or not materialDef.UpgradeLogic then
		return false
	end
	local logicTemplate = materialDef.UpgradeLogic

	-- 2. KIỂM TRA ĐIỀU KIỆN ÉP ĐỒ
	local itemType = baseItemDef.Type or "Unknown"
	if not IsItemTypeAccepted(itemType, logicTemplate.AcceptTypes) then
		warn("⚠️ Đá nâng cấp không dùng được cho vật phẩm này!")
		return false
	end

	-- [BỔ SUNG MỚI]: KIỂM TRA GIỚI HẠN ÉP ĐỒ (MAX UPGRADES)
	local slotCost = logicTemplate.UpgradeCountCost or 1
	if slotCost > 0 then
		local currentUpgrades = itemData.UpgradeCount or 0
		local maxUpgrades = GetMaxUpgrades(itemData, baseItemDef)

		if currentUpgrades + slotCost > maxUpgrades then
			return {
				Success = false,
				Destroyed = false,
				Message = "Vật phẩm đã đạt giới hạn nâng cấp tối đa!",
				Color = Color3.fromRGB(255, 0, 0),
			}
		end
	end

	-- 3. TRỪ ĐÁ NÂNG CẤP
	local successRemoveMat = InventorySystem:RemoveStackable(player, materialCategory, materialStack.Id, 1)
	if not successRemoveMat then
		return false
	end

	-- 4. ĐỔ XÍ NGẦU (GACHA)
	local realSuccessRate = CalculateSuccessRate(itemData, baseItemDef, logicTemplate)
	local isSuccess = math.random() <= realSuccessRate
	local selectedOutcome = RollByWeight(isSuccess and logicTemplate.SuccessPool or logicTemplate.FailPool)

	if not selectedOutcome then
		return false
	end

	local isDestroyed = false
	local specialEffects = selectedOutcome.SpecialEffects or {}
	local newItemData = table.clone(itemData)

	-- 5. CƠ CHẾ BẢO HỘ (NẾU XỊT)
	if not isSuccess then
		if table.find(specialEffects, "DestroyItem") then
			-- [CẢI TIẾN]: Ưu tiên dùng NukeProtection (Bùa dùng 1 lần) trước
			if ConsumeState(newItemData, ITEM_STATES.NukeProtection) then
				print("🛡️ Bùa [NukeProtection] đã tiêu hao để cứu món đồ!")
				isDestroyed = false
				specialEffects = {}
			-- Nếu không có NukeProtection, kiểm tra xem có AntiNuke (Bùa vĩnh viễn) không
			elseif HasState(newItemData, ITEM_STATES.AntiNuke) then
				print("🛡️ Đặc tính [AntiNuke] đã cứu món đồ (Giữ lại đặc tính)!")
				isDestroyed = false
				specialEffects = {}
			else
				isDestroyed = true
			end
		end
	end

	-- 6. XỬ LÝ PHÁ HỦY
	if isDestroyed then
		InventorySystem:RemoveItemByUUID(player, itemData.UUID)
		return {
			Success = false,
			Destroyed = true,
			Message = selectedOutcome.Message,
			Color = selectedOutcome.MessageColor,
		}
	end

	-- 7. THỰC THI THAY ĐỔI CHỈ SỐ (EXECUTION)

	-- Trừ lượt ép (Ngay cả khi xịt vẫn tốn lượt, trừ phi có bùa)
	if not isSuccess and ConsumeState(newItemData, ITEM_STATES.AntiSlotGone) then
		print("🛡️ Bùa [AntiSlotGone] giúp bạn không bị mất lượt ép!")
	else
		newItemData.UpgradeCount = (newItemData.UpgradeCount or 0) + slotCost
	end

	-- Thực thi lệnh Reset/Special Effects
	for _, effect in ipairs(specialEffects) do
		if effect == "ResetUpgrades" then
			if newItemData.UpgradeHistory then
				for _, historyEntry in ipairs(newItemData.UpgradeHistory) do
					if historyEntry.StatChanges then
						for statName, addedValue in pairs(historyEntry.StatChanges) do
							if newItemData[statName] then
								newItemData[statName] = newItemData[statName] - addedValue
								if newItemData[statName] == 0 then
									newItemData[statName] = nil
								end
							end
						end
					end
				end
				newItemData.UpgradeHistory = nil
			end

		-- [CẢI TIẾN]: Xóa lịch sử xịt và tính lại UpgradeCount dựa trên log thành công
		elseif effect == "ClearAllFailedUpgrades" then
			-- Tẩy toàn bộ các lần ép xịt
			if newItemData.NBT and newItemData.NBT.FailedAttempts then
				-- Hoàn trả số lượt ép bằng cách lấy Tổng lượt trừ đi Số lượt xịt
				local newCount = (newItemData.UpgradeCount or 0) - newItemData.NBT.FailedAttempts
				newItemData.UpgradeCount = math.max(0, newCount) -- Dùng math.max để đảm bảo không bị âm

				-- Xóa bộ đếm xịt
				newItemData.NBT.FailedAttempts = nil
			end
		elseif effect == "ClearOneFailedUpgrade" then
			-- Chỉ tẩy 1 lần ép xịt duy nhất (Giống cuộn giấy Clean Slate Scroll trong Maplestory)
			if newItemData.NBT and newItemData.NBT.FailedAttempts and newItemData.NBT.FailedAttempts > 0 then
				-- Hoàn trả 1 lượt ép
				newItemData.UpgradeCount = math.max(0, (newItemData.UpgradeCount or 0) - 1)

				-- Trừ đi 1 lần xịt
				newItemData.NBT.FailedAttempts = newItemData.NBT.FailedAttempts - 1

				-- Nếu đã trừ hết sạch số lần xịt thì dọn rác RAM
				if newItemData.NBT.FailedAttempts <= 0 then
					newItemData.NBT.FailedAttempts = nil
				end
			end
		elseif effect == "ResetPurity" then
			newItemData.Purity = nil
		elseif effect == "ResetCorruption" then
			newItemData.Corruption = nil
		elseif effect == "UpRarity" then
			if not newItemData.NBT then
				newItemData.NBT = {}
			end

			local currentRarityRaw = newItemData.NBT.Rarity or baseItemDef.Rarity or "Common"
			local currentLevel = type(currentRarityRaw) == "string" and (RARITY_TO_NUM[currentRarityRaw] or 1)
				or currentRarityRaw

			-- Tăng 1 bậc nhưng không vượt quá Mythic (6)
			local newLevel = math.min(currentLevel + 1, 6)
			newItemData.NBT.Rarity = NUM_TO_RARITY[newLevel]
		elseif effect == "DownRarity" then
			if not newItemData.NBT then
				newItemData.NBT = {}
			end

			local currentRarityRaw = newItemData.NBT.Rarity or baseItemDef.Rarity or "Common"
			local currentLevel = type(currentRarityRaw) == "string" and (RARITY_TO_NUM[currentRarityRaw] or 1)
				or currentRarityRaw

			-- Giảm 1 bậc nhưng không tụt dưới Common (1)
			local newLevel = math.max(currentLevel - 1, 1)
			newItemData.NBT.Rarity = NUM_TO_RARITY[newLevel]
		end
	end

	-- Thêm States (Cải tiến Logic Slot Mở Rộng)
	if selectedOutcome.ApplyStates then
		for _, stateEnum in ipairs(selectedOutcome.ApplyStates) do
			-- Quy tắc phân cấp cho các viên đá mở rộng slot
			if
				stateEnum == ITEM_STATES.GreatUpgradeExtended and not HasState(newItemData, ITEM_STATES.UpgradeExtended)
			then
				warn("⚠️ Cần mở rộng cấp 1 (UpgradeExtended) trước khi dùng cấp 2!")
			elseif
				stateEnum == ITEM_STATES.UltimateUpgradeExtended
				and not HasState(newItemData, ITEM_STATES.GreatUpgradeExtended)
			then
				warn("⚠️ Cần mở rộng cấp 2 (GreatUpgradeExtended) trước khi dùng cấp 3!")
			else
				AddState(newItemData, stateEnum)
			end
		end
	end

	-- [CẢI TIẾN]: Quay chỉ số phụ đa mục tiêu
	local statChangesLog = {}
	if isSuccess then
		ProcessStatRolls(selectedOutcome, newItemData, statChangesLog)
	end

	-- 8. GHI LOG (Chỉ ghi khi thành công)
	if isSuccess then
		ConsumeState(newItemData, ITEM_STATES.AlwaysSuccess)

		-- CHỈ TIẾN HÀNH TẠO VÀ LƯU LOG NẾU CÓ CHỈ SỐ BỊ BIẾN ĐỔI
		if next(statChangesLog) ~= nil then
			-- Nếu chưa có mảng UpgradeHistory thì mới tạo
			if not newItemData.UpgradeHistory then
				newItemData.UpgradeHistory = {}
			end

			local historyEntry = {
				Material = materialStack.TemplateId,
				StatChanges = statChangesLog,
				Time = os.time(),
			}

			table.insert(newItemData.UpgradeHistory, historyEntry)
		end
	else
		-- Vẫn lưu FailedAttempts vào NBT để làm điều kiện cho đá khác (Pity System)
		if not newItemData.NBT then
			newItemData.NBT = {}
		end
		newItemData.NBT.FailedAttempts = (newItemData.NBT.FailedAttempts or 0) + 1
	end
	-- 9. LƯU DỮ LIỆU QUA INVENTORY SYSTEM
	InventorySystem:UpdateItemData(player, itemData.UUID, newItemData)

	return {
		Success = isSuccess,
		Destroyed = false,
		Message = selectedOutcome.Message,
		Color = selectedOutcome.MessageColor,
	}
end

-- ==========================================
-- LẮNG NGHE LỆNH CHAT ĐỂ TEST
-- ==========================================
function UpgradeSystem:Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			-- Bắt cờ auto-debug ở cuối câu
			local autoDebug = false
			if #args > 0 and string.lower(args[#args]) == "true" then
				autoDebug = true
				table.remove(args, #args)
			end

			if command == "/testupgrade" then
				local itemIndex = tonumber(args[1]) or 1
				local matIndex = tonumber(args[2]) or 1

				print(string.format("🖥️ Lệnh: Ép vũ khí ô [%d] bằng đá ô [%d]", itemIndex, matIndex))

				local result = self:ProcessUpgradeByIndex(player, itemIndex, "Materials", matIndex)

				if result then
					print("👉 Kết quả: " .. result.Message)
					if result.Destroyed then
						print("💥 Món đồ đã bốc hơi!")
					end
				end
			end

			-- Chạy bảng Debug nếu cờ được bật
			if autoDebug then
				print("🖥️ [Auto-Debug] In dữ liệu sau khi thực thi lệnh...")
				DataManager:DebugProfile(player)
			end
		end)
	end)
end

return UpgradeSystem

--[[
Hãy chỉnh lại hệ thống sao cho:
- Thêm state cái "NukeProtection" để thay chức năng "AntiNuke" cho dễ hiểu hơn và khi thất bại, mà vũ khị bị phá huỷ nếu có trạng thái NukeProtection thì sẽ không bị phá hủy mà chỉ xịt bình thường và bỏ luôn cái "NukeProtection".
- Khi thất bại, mà vũ khị bị phá huỷ nếu có trạng thái AntiNuke thì sẽ không bị phá hủy mà chỉ xịt bình thường mà vẫn giữ cái "AntiNuke" cho lần ép sau.
- Khi thất bại thì sẽ không ghi lại log mà StatChanges: {[string]: number} là rỗng (tức là {}), thay vào đó chỉ cộng UpgradeCount (nếu có)
- Thêm kiểm tra nếu tổng cộng nâng cấp vượt quá giới hạn MaxUpgrades của vật phẩm, nếu quá thì từ chối nâng cấp và trả về thông báo lỗi "Vật phẩm đã đạt giới hạn nâng cấp tối đa!".
- Chỉnh lại cái "ResetUpgradeSlots" thành "ClearFailedUpgrades" cho dễ hiểu hơn và sẽ tính lại UpgradeCount dựa trên số lần ép thành công thay vì trực tiếp xóa UpgradeCount để bù lại cho việc không ghi log khi thất bại nữa.
- Thêm cái state "UpgradeExtended", "GreatUpgradeExtended" và "UltimateUpgradeExtended" để khi có trạng thái này thì sẽ được cộng thêm 1 UpgradeSlot vĩnh viễn (ví dụ: MaxUpgrade +1) nhưng "GreatUpgradeExtended" chỉ thêm được khi có "UpgradeExtended" rồi và "UltimateUpgradeExtended" chỉ thêm được khi có "GreatUpgradeExtended" rồi.
- Thêm cái rolls trong PoolOutcome để có thể roll nhiều chỉ số cùng lúc nếu trúng kịch bản đó (VD: Rolls=2 thì sẽ roll 2 dòng chỉ số trong StatPools để cộng vào đồ, nếu Rolls=0 hoặc nil thì sẽ roll tất cả các dòng chỉ số trong StatPools) và trong StatRollEntry nếu weight = 0 thì chắc chắn sẽ có chỉ số đó trong n lần roll (không lặp lại).
export type StatRollEntry = {
    StatName: string,

    Min: number,
    Max: number,

    LevelScale: {
        Min: number,
        Max: number
    }?,

    Weight: number,
}

export type PoolOutcome = {
    Weight: number,

    Rolls: number?,

    StatPools: {StatRollEntry}?,

    ApplyStates: {string}?,

    SpecialEffects: {string}?,

    Message: string,

    MessageColor: Color3,
}
]]
