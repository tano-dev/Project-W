-- File: Server/Systems/FarmingSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local InventorySystem = require(game.ServerScriptService.Server.Systems.Inventory)
local PlayerStatSystem = require(game.ServerScriptService.Server.Systems.PlayerStats)
local PlantDatabase = require(game.ReplicatedStorage.Shared.Constants.PlantData)
local Players = game:GetService("Players")

local FarmingSystem = {}

-- ==========================================
-- HÀM HỖ TRỢ: QUÉT TÌM CÂY TRONG Ô ĐẤT
-- ==========================================
local function FindPlantInSlot(profile: table, slotId: string)
	if profile.Data.Farming.Crops[slotId] then
		return "Crops", profile.Data.Farming.Crops[slotId]
	elseif profile.Data.Farming.Trees[slotId] then
		return "Trees", profile.Data.Farming.Trees[slotId]
	end
	return nil, nil
end

-- ==========================================
-- HÀM HỖ TRỢ: TÍNH TOÁN TRẠNG THÁI CÂY TRỒNG
-- ==========================================
function FarmingSystem:CalculatePlantState(plantData: table)
	local plantDef = PlantDatabase.GetAll()[plantData.Id]
	if not plantDef then
		return false, 0, 0
	end

	local currentTime = os.time()
	local isRegrowing = (plantData.LastHarvestTime > 0)
	local timePassed = 0
	local requiredTime = 0

	if isRegrowing and plantDef.HarvestBehavior and plantDef.HarvestBehavior.RepeatInterval then
		timePassed = currentTime - plantData.LastHarvestTime
		requiredTime = plantDef.HarvestBehavior.RepeatInterval
	else
		timePassed = currentTime - plantData.PlantedTime
		requiredTime = plantDef.GrowthTime
	end

	if timePassed >= requiredTime then
		return true, plantDef.Stages, 0
	else
		local progress = timePassed / requiredTime
		local currentStage = math.floor(progress * plantDef.Stages)
		local timeLeft = requiredTime - timePassed

		currentStage = math.clamp(currentStage, 0, plantDef.Stages - 1)
		return false, currentStage, timeLeft
	end
end

-- ==========================================
-- API: CẤP PHÁT HẠT GIỐNG ĐỘNG
-- ==========================================
function FarmingSystem:GiveSeedPack(player: Player, plantId: string, amount: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	local allPlants = PlantDatabase.GetAll()
	local plantDef = allPlants[plantId]

	if not plantDef then
		return {
			Success = false,
			Message = string.format("Cây trồng '%s' không tồn tại trong PlantDatabase!", plantId),
		}
	end

	amount = amount or 1

	local customNBT = { PlantId = plantId }
	InventorySystem:GiveStackable(player, "Materials", "Seed Pack", amount, customNBT)

	local plantName = plantDef.Name or plantId
	return {
		Success = true,
		Message = string.format("Đã cấp %d túi hạt giống [%s] cho %s!", amount, plantName, player.Name),
	}
end

-- ==========================================
-- API: TRỒNG CÂY
-- ==========================================
function FarmingSystem:PlantSeed(player: Player, seedInvIndex: number, slotId: string)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	local _, existingPlant = FindPlantInSlot(profile, slotId)
	if existingPlant then
		return { Success = false, Message = "Ô đất này đã có cây trồng rồi!" }
	end

	local seedItem = profile.Data.Inventories.Materials[seedInvIndex]
	if not seedItem or seedItem.Id ~= "Seed Pack" then
		return { Success = false, Message = "Không tìm thấy vật phẩm Seed Pack tại ô này!" }
	end

	if not seedItem.NBT or not seedItem.NBT.PlantId then
		return { Success = false, Message = "Túi hạt giống này bị lỗi dữ liệu (Thiếu PlantId)!" }
	end

	local plantId = seedItem.NBT.PlantId
	local plantDef = PlantDatabase.GetAll()[plantId]

	if not plantDef then
		return { Success = false, Message = "Dữ liệu cây trồng của túi hạt này không tồn tại!" }
	end

	local plotType = plantDef.Type

	if plotType ~= "Crops" and plotType ~= "Trees" then
		return {
			Success = false,
			Message = string.format(
				"Hạt giống %s bị lỗi định dạng khu vực trồng!",
				plantDef.Name or plantId
			),
		}
	end

	local successRemove = InventorySystem:RemoveStackable(player, "Materials", "Seed Pack", 1, seedItem.NBT)
	if not successRemove then
		return { Success = false, Message = "Lỗi khi trừ số lượng hạt giống!" }
	end

	local newPlantData = {
		Id = plantId,
		PlantedTime = os.time(),
		LastHarvestTime = 0,
		HarvestedTimes = 0,
	}
	profile.Data.Farming[plotType][slotId] = newPlantData

	return { Success = true, Message = string.format("Đã gieo hạt %s thành công!", plantDef.Name or plantId) }
end

-- ==========================================
-- API: THU HOẠCH
-- ==========================================
function FarmingSystem:HarvestPlant(player: Player, slotId: string)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	local plotType, plantData = FindPlantInSlot(profile, slotId)
	if not plantData then
		return { Success = false, Message = "Ô đất này không có gì để thu hoạch!" }
	end

	local plantDef = PlantDatabase.GetAll()[plantData.Id]
	if not plantDef then
		return { Success = false, Message = "Dữ liệu cây trồng bị lỗi!" }
	end

	local isReady, _, timeLeft = self:CalculatePlantState(plantData)
	if not isReady then
		return { Success = false, Message = string.format("Cây chưa chín! Còn khoảng %d giây nữa.", timeLeft) }
	end

	local rewardsLog = {}
	for _, drop in ipairs(plantDef.HarvestYield) do
		local chance = drop.Chance or 1.0
		if math.random() <= chance then
			local amount = math.random(drop.Min, drop.Max)
			InventorySystem:GiveStackable(player, "Materials", drop.Id, amount)
			table.insert(rewardsLog, string.format("%dx %s", amount, drop.Id))
		end
	end

	if plantDef.FarmingExp and plantDef.FarmingExp > 0 then
		PlayerStatSystem:AddProfessionExp(player, "Farming", plantDef.FarmingExp)
	end

	local isDead = false

	if not plantDef.HarvestBehavior or not plantDef.HarvestBehavior.RepeatInterval then
		isDead = true
	else
		plantData.HarvestedTimes += 1
		local maxHarvests = plantDef.HarvestBehavior.HarvestTimes
		if maxHarvests and plantData.HarvestedTimes >= maxHarvests then
			isDead = true
		else
			plantData.LastHarvestTime = os.time()
		end
	end

	if isDead then
		profile.Data.Farming[plotType][slotId] = nil
		table.insert(rewardsLog, "(Cây đã tàn lụi)")
	end

	local plantName = plantDef.Name or plantData.Id
	local finalMsg = string.format("Thu hoạch thành công %s! Nhận: %s", plantName, table.concat(rewardsLog, ", "))
	return { Success = true, Message = finalMsg }
end

-- ==========================================
-- [MỚI] API: HỦY CÂY TRỒNG (DESTROY PLANT)
-- ==========================================
function FarmingSystem:DestroyPlant(player: Player, slotId: string)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	-- 1. Tìm cây tự động
	local plotType, plantData = FindPlantInSlot(profile, slotId)
	if not plantData then
		return {
			Success = false,
			Message = string.format("Ô đất [%s] hiện đang trống, không có cây để nhổ!", slotId),
		}
	end

	local plantDef = PlantDatabase.GetAll()[plantData.Id]
	local plantName = plantDef and plantDef.Name or plantData.Id

	-- 2. Xóa dữ liệu cây khỏi ô đất
	profile.Data.Farming[plotType][slotId] = nil

	return {
		Success = true,
		Message = string.format("Đã nhổ bỏ %s ở ô đất [%s] thành công!", plantName, slotId),
	}
end

-- ==========================================
-- LẮNG NGHE LỆNH CHAT ĐỂ TEST
-- ==========================================
FarmingSystem.Start = function()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			if command == "/giveseed" then
				local plantId = args[1]
				local amount = tonumber(args[2]) or 1

				if not plantId then
					return
				end
				if #args > 2 and not tonumber(args[2]) then
					plantId = args[1] .. " " .. args[2]
					amount = tonumber(args[3]) or 1
				end

				local result = FarmingSystem:GiveSeedPack(player, plantId, amount)
				if result then
					print("📦 " .. result.Message)
				end
			elseif command == "/plant" then
				local seedIndex = tonumber(args[1])
				local slotId = args[2] and tostring(args[2])

				if not seedIndex or not slotId then
					return
				end

				local result = FarmingSystem:PlantSeed(player, seedIndex, slotId)
				if result then
					print("🌾 " .. result.Message)
				end
			elseif command == "/harvest" then
				local slotId = args[1] and tostring(args[1])

				if not slotId then
					return
				end

				local result = FarmingSystem:HarvestPlant(player, slotId)
				if result then
					print("🧺 " .. result.Message)
				end

			-- [MỚI] CÚ PHÁP: /destroyplant [Tên ô đất]
			-- VD: /destroyplant 1
			elseif command == "/destroyplant" then
				local slotId = args[1] and tostring(args[1])

				if not slotId then
					return
				end

				local result = FarmingSystem:DestroyPlant(player, slotId)
				if result then
					print("⛏️ " .. result.Message)
				end
			elseif command == "/checkplant" then
				local slotId = args[1] and tostring(args[1])
				if not slotId then
					return
				end

				local profile = DataManager:GetProfile(player)
				if not profile then
					return
				end

				local _, plantData = FindPlantInSlot(profile, slotId)

				if plantData then
					local isReady, stage, timeLeft = FarmingSystem:CalculatePlantState(plantData)
					print(
						string.format(
							"🔍 Ô đất [%s] | Trạng thái: Stage %d | Sẵn sàng: %s | Cần chờ: %ds",
							slotId,
							stage,
							tostring(isReady),
							timeLeft
						)
					)
				else
					print(string.format("🔍 Ô đất [%s] đang trống.", slotId))
				end
			end
		end)
	end)
end

return FarmingSystem
