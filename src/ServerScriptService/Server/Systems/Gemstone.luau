-- File: Server/Systems/GemstoneSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local InventorySystem = require(game.ServerScriptService.Server.Systems.Inventory)
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local Players = game:GetService("Players")

local GemstoneSystem = {}

-- ==========================================
-- TỪ ĐIỂN PHÂN LOẠI VẬT PHẨM (ĐỂ CHECK ACCEPT TYPES)
-- ==========================================
local ITEM_CATEGORIES = {
	Weapon = { "Sword", "Rapier", "Katana", "Dagger", "Staff", "Axe", "Hoe", "Fishing Rod", "Pickaxe" },
	Armor = { "Headgear", "Chestplate", "Boots" },
	Tool = { "Axe", "Hoe", "Fishing Rod", "Pickaxe" },
}

-- Hàm hỗ trợ: Kiểm tra loại đồ hợp lệ (Đã bổ sung vòng quét Category chuẩn xác)
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

-- ==========================================
-- API 1: KHẢM NGỌC (INSERT GEM)
-- Đã tối ưu: Mặc định tự động tìm ngọc trong túi "Materials"
-- ==========================================
function GemstoneSystem:InsertGem(player: Player, targetItemIndex: number, gemIndex: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	-- 1. Trích xuất dữ liệu
	local targetItem = profile.Data.Inventories.Items[targetItemIndex]
	-- Mặc định lấy từ Materials
	local gemStack = profile.Data.Inventories.Materials and profile.Data.Inventories.Materials[gemIndex]

	if not targetItem then
		return { Success = false, Message = "Không tìm thấy trang bị ở ô này!" }
	end
	if not gemStack or gemStack.Amount < 1 then
		return { Success = false, Message = "Không tìm thấy ngọc ở vị trí này!" }
	end

	local baseItemDef = ItemDatabase.Registry[targetItem.Id]
	local gemDef = ItemDatabase.Registry[gemStack.Id]

	if not baseItemDef or not gemDef or not gemDef.GemLogic then
		return { Success = false, Message = "Dữ liệu vật phẩm hoặc ngọc không hợp lệ!" }
	end

	-- 2. Kiểm tra điều kiện khảm
	local maxGems = baseItemDef.MaxGems or 0
	local currentGems = targetItem.Gems or {}

	if maxGems <= 0 then
		return { Success = false, Message = "Trang bị này không có lỗ khảm ngọc!" }
	end

	if #currentGems >= maxGems then
		return { Success = false, Message = "Trang bị đã kín lỗ khảm!" }
	end

	local itemType = baseItemDef.Type or "Unknown"
	if not IsItemTypeAccepted(itemType, gemDef.GemLogic.AcceptTypes) then
		return { Success = false, Message = "Viên ngọc này không thể khảm lên loại trang bị này!" }
	end

	-- 3. Thực thi Tiêu hao & Cập nhật
	-- Gọi InventorySystem để xóa ngọc từ Materials
	local successRemove = InventorySystem:RemoveStackable(player, "Materials", gemStack.Id, 1)
	if not successRemove then
		return { Success = false, Message = "Lỗi khi trừ ngọc!" }
	end

	local newItemData = table.clone(targetItem)
	if not newItemData.Gems then
		newItemData.Gems = {}
	end

	-- Lưu Id của ngọc vào mảng
	table.insert(newItemData.Gems, gemStack.Id)

	InventorySystem:UpdateItemData(player, targetItem.UUID, newItemData)

	return { Success = true, Message = "Khảm ngọc thành công!" }
end

-- ==========================================
-- API 2: GỠ NGỌC (REMOVE GEM)
-- ==========================================
function GemstoneSystem:RemoveGem(player: Player, targetItemIndex: number, gemSlotIndex: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	-- 1. Trích xuất dữ liệu
	local targetItem = profile.Data.Inventories.Items[targetItemIndex]
	if not targetItem then
		return { Success = false, Message = "Không tìm thấy trang bị!" }
	end

	if not targetItem.Gems or not targetItem.Gems[gemSlotIndex] then
		return { Success = false, Message = "Không có ngọc ở vị trí lỗ khảm này!" }
	end

	local gemId = targetItem.Gems[gemSlotIndex]
	local gemDef = ItemDatabase.Registry[gemId]

	-- [MỞ RỘNG TƯƠNG LAI]: Kiểm tra phí tháo ngọc (Tiền vàng) ở đây

	-- 2. Thực thi Tháo & Cập nhật
	local newItemData = table.clone(targetItem)
	table.remove(newItemData.Gems, gemSlotIndex)

	-- Dọn rác RAM nếu mảng ngọc rỗng
	if #newItemData.Gems == 0 then
		newItemData.Gems = nil
	end

	-- Cấp lại ngọc vào túi Materials (nếu ngọc không bị thiết lập là IsFragile)
	if not (gemDef.GemLogic and gemDef.GemLogic.IsFragile) then
		InventorySystem:GiveStackable(player, "Materials", gemId, 1)
	end

	InventorySystem:UpdateItemData(player, targetItem.UUID, newItemData)

	return { Success = true, Message = "Tháo ngọc thành công!" }
end

-- ==========================================
-- LẮNG NGHE LỆNH CHAT ĐỂ TEST
-- ==========================================
GemstoneSystem.Start = function()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			-- Bắt cờ auto-debug ở cuối
			local autoDebug = false
			if #args > 0 and string.lower(args[#args]) == "true" then
				autoDebug = true
				table.remove(args, #args)
			end

			-- Lệnh: /insertgem [Vị trí Trang bị] [Vị trí Ngọc]
			-- VD: /insertgem 1 2
			if command == "/insertgem" then
				local targetItemIndex = tonumber(args[1])
				local gemIndex = tonumber(args[2])

				if not targetItemIndex or not gemIndex then
					return
				end
				print(
					string.format(
						"🖥️ Lệnh: Khảm ngọc (ô %d) vào trang bị (ô %d)",
						gemIndex,
						targetItemIndex
					)
				)

				local result = GemstoneSystem:InsertGem(player, targetItemIndex, gemIndex)
				if result then
					print("👉 Kết quả: " .. result.Message)
				end

				if autoDebug then
					DataManager:DebugProfile(player)
				end

			-- Lệnh: /removegem [Vị trí Trang bị] [Số thứ tự lỗ khảm]
			-- VD: /removegem 1 1 (Tháo viên ngọc ở lỗ số 1 của vũ khí ô số 1)
			elseif command == "/removegem" then
				local targetItemIndex = tonumber(args[1])
				local gemSlotIndex = tonumber(args[2])

				if not targetItemIndex or not gemSlotIndex then
					return
				end
				print(
					string.format(
						"🖥️ Lệnh: Tháo ngọc ở lỗ số %d của trang bị (ô %d)",
						gemSlotIndex,
						targetItemIndex
					)
				)

				local result = GemstoneSystem:RemoveGem(player, targetItemIndex, gemSlotIndex)
				if result then
					print("👉 Kết quả: " .. result.Message)
				end

				if autoDebug then
					DataManager:DebugProfile(player)
				end
			end
		end)
	end)
end

return GemstoneSystem
