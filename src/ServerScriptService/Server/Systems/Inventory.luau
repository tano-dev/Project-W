-- File: Server/Systems/Inventory.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local ItemFactory = require(game.ReplicatedStorage.Shared.Components.ItemData)
local StackableFactory = require(game.ReplicatedStorage.Shared.Components.StackableData)
local HttpService = game:GetService("HttpService")
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local Players = game:GetService("Players")

local InventorySystem = {}

-- ==========================================
-- CẤU HÌNH HỆ THỐNG TRANG BỊ
-- ==========================================

-- Chỉ những Class này mới được phép trang bị vào Slot Offhand
local ALLOWED_OFFHAND_CLASSES = {
	["Assassin"] = true,
	["Tanker"] = true,
	["Paladin"] = true,
	["Mage"] = true,
}

-- Ánh xạ từ "EquipmentSlot" trong ItemTemplate sang key thực tế trong ProfileTemplate.Equipped
local SLOT_MAP = {
	["MainHand"] = "Weapon",
	["OffHand"] = "Offhand",
	["Helmet"] = "Helmet",
	["Chest"] = "Armor",
	["Legs"] = "Boots",
	["Accessory"] = "Accessory",
}

-- ==========================================
-- HÀM HỖ TRỢ
-- ==========================================

local function CompareNBT(nbt1, nbt2)
	if not nbt1 and not nbt2 then
		return true
	end
	if not nbt1 or not nbt2 then
		return false
	end
	return HttpService:JSONEncode(nbt1) == HttpService:JSONEncode(nbt2)
end

-- Trích xuất thông tin người mặc (Player hoặc NPC)
local function GetEntityInfo(profile: table, entityId: string)
	if entityId == "Player" then
		return {
			Class = profile.Data.Classes.SelectedClass,
			Level = profile.Data.Core.Level,
			EquippedDict = profile.Data.Equipped,
			UpdatePath = { "Equipped" },
		}
	else
		local companion = profile.Data.Companions[entityId]
		if not companion then
			return nil
		end
		if not companion.Unlocked then
			return nil
		end

		return {
			Class = companion.Class,
			Level = 1, -- (Có thể map với Level của NPC sau này)
			EquippedDict = companion.Equipped,
			UpdatePath = { "Companions", entityId, "Equipped" },
		}
	end
end

-- ==========================================
-- 1. API: TÌM KIẾM ĐỊNH VỊ VẬT PHẨM (TRUNG TÂM)
-- ==========================================
function InventorySystem:GetItemDataByUUID(player: Player, uuid: string)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return nil
	end

	local result = {
		ItemData = nil,
		Index = nil,
		IsEquipped = false,
		EntityId = nil,
		EquipSlot = nil,
	}

	-- 1. Tìm trong túi
	for i, item in ipairs(profile.Data.Inventories.Items) do
		if item.UUID == uuid then
			result.ItemData = item
			result.Index = i
			break
		end
	end

	if not result.Index then
		return nil
	end

	-- 2. Quét mảng Equipped của Player (Đã sửa lỗi vòng lặp)
	for slotName, equippedUUID in pairs(profile.Data.Equipped) do
		if equippedUUID == uuid then
			result.IsEquipped = true
			result.EntityId = "Player"
			result.EquipSlot = slotName
			return result
		end
	end

	-- 3. Quét mảng Equipped của NPC Companions
	for compId, compData in pairs(profile.Data.Companions) do
		for slotName, equippedUUID in pairs(compData.Equipped) do
			if equippedUUID == uuid then
				result.IsEquipped = true
				result.EntityId = compId
				result.EquipSlot = slotName
				return result
			end
		end
	end

	return result
end

-- ==========================================
-- 2. API: TRANG BỊ & GỠ TRANG BỊ
-- ==========================================

function InventorySystem:EquipItem(player: Player, uuid: string, targetEntityId: string)
	targetEntityId = targetEntityId or "Player"
	local profile = DataManager:GetProfile(player)
	if not profile then
		return { Success = false, Message = "Lỗi tải dữ liệu!" }
	end

	local itemInfo = self:GetItemDataByUUID(player, uuid)
	if not itemInfo then
		return { Success = false, Message = "Không tìm thấy vật phẩm trong túi đồ!" }
	end
	if itemInfo.IsEquipped then
		return {
			Success = false,
			Message = string.format("Vật phẩm đang được mặc bởi %s!", itemInfo.EntityId),
		}
	end

	local itemDef = ItemDatabase.Registry[itemInfo.ItemData.Id]
	if not itemDef then
		return { Success = false, Message = "Lỗi dữ liệu vật phẩm gốc!" }
	end

	-- Lấy EquipSlot thực tế từ SLOT_MAP
	local equipSlot = SLOT_MAP[itemDef.EquipmentSlot]
	if not equipSlot then
		return { Success = false, Message = "Vật phẩm này không có vị trí mặc hợp lệ!" }
	end

	local entityInfo = GetEntityInfo(profile, targetEntityId)
	if not entityInfo then
		return { Success = false, Message = "Không tìm thấy thông tin nhân vật/NPC này!" }
	end

	-- BỘ LỌC 1: KIỂM TRA LEVEL & CLASS
	local reqs = itemDef.Requirements
	if reqs then
		if reqs.Level and entityInfo.Level < reqs.Level then
			return { Success = false, Message = string.format("Cần đạt Cấp %d để trang bị!", reqs.Level) }
		end
		if reqs.Classes and #reqs.Classes > 0 then
			if not table.find(reqs.Classes, entityInfo.Class) then
				return {
					Success = false,
					Message = "Hệ phái của bạn không thể sử dụng vật phẩm này!",
				}
			end
		end
	end

	-- BỘ LỌC 2: KIỂM TRA LUẬT VŨ KHÍ PHỤ (OFFHAND)
	if equipSlot == "Offhand" and not ALLOWED_OFFHAND_CLASSES[entityInfo.Class] then
		return {
			Success = false,
			Message = string.format("Hệ phái [%s] không thể mang vũ khí phụ!", entityInfo.Class),
		}
	end

	-- BỘ LỌC 3: BIND-ON-EQUIP
	if itemDef.BindType == "BindOnEquip" and itemInfo.ItemData.BindState == "Unlocked" then
		profile.Replica:Set({ "Inventories", "Items", itemInfo.Index, "BindState" }, "Bound")
	end

	-- Thực thi: Ghi UUID vào Slot tương ứng
	local finalPath = { unpack(entityInfo.UpdatePath) }
	table.insert(finalPath, equipSlot)
	profile.Replica:Set(finalPath, uuid)

	return {
		Success = true,
		Message = string.format("Đã trang bị [%s] cho %s", itemDef.Name or itemInfo.ItemData.Id, targetEntityId),
	}
end

function InventorySystem:UnequipItem(player: Player, equipSlot: string, targetEntityId: string)
	targetEntityId = targetEntityId or "Player"
	local profile = DataManager:GetProfile(player)
	if not profile then
		return { Success = false, Message = "Lỗi tải dữ liệu!" }
	end

	local entityInfo = GetEntityInfo(profile, targetEntityId)
	if not entityInfo then
		return { Success = false, Message = "Không tìm thấy thông tin nhân vật/NPC này!" }
	end

	if not entityInfo.EquippedDict[equipSlot] then
		return { Success = false, Message = "Slot này hiện không có trang bị nào!" }
	end

	local finalPath = { unpack(entityInfo.UpdatePath) }
	table.insert(finalPath, equipSlot)
	profile.Replica:Set(finalPath, nil)

	return {
		Success = true,
		Message = string.format("Đã gỡ trang bị ở Slot %s của %s", equipSlot, targetEntityId),
	}
end

-- ==========================================
-- 3. API: THÊM & XÓA VẬT PHẨM (ĐỘC NHẤT)
-- ==========================================

function InventorySystem:GiveItem(player: Player, Id: string)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return nil
	end
	local newItem = ItemFactory.createNewItem(Id)
	if newItem then
		profile.Replica:TableInsert({ "Inventories", "Items" }, newItem)
		return newItem.UUID
	end
	return nil
end

function InventorySystem:GiveCustomItem(player: Player, customItemData: table)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end
	profile.Replica:TableInsert({ "Inventories", "Items" }, customItemData)
	return true
end

function InventorySystem:RemoveItemByUUID(player: Player, uuid: string)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	local itemInfo = self:GetItemDataByUUID(player, uuid)
	if not itemInfo then
		return false
	end

	-- Nếu đang mặc, lột ra trước
	if itemInfo.IsEquipped then
		local updatePath = itemInfo.EntityId == "Player" and { "Equipped", itemInfo.EquipSlot }
			or { "Companions", itemInfo.EntityId, "Equipped", itemInfo.EquipSlot }
		profile.Replica:Set(updatePath, nil)
	end

	profile.Replica:TableRemove({ "Inventories", "Items" }, itemInfo.Index)
	return true
end

-- ==========================================
-- 4. API: CẬP NHẬT CHỈ SỐ VẬT PHẨM
-- ==========================================
function InventorySystem:UpdateItemData(player: Player, uuid: string, newItemData: table)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	local itemInfo = self:GetItemDataByUUID(player, uuid)
	-- Dù đang mặc hay cất trong túi, dữ liệu gốc luôn nằm ở Inventories.Items
	if itemInfo and itemInfo.Index then
		profile.Replica:Set({ "Inventories", "Items", itemInfo.Index }, newItemData)
		return true
	end

	warn("⚠️ Không thể cập nhật chỉ số! (Vật phẩm không tồn tại)")
	return false
end

-- ==========================================
-- 5. API: THÊM & XÓA STACKABLE (GỘP CHUNG NBT)
-- ==========================================
function InventorySystem:GiveStackable(player: Player, category: string, Id: string, amount: number, customNBT: table?)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return
	end
	if category ~= "Consumables" and category ~= "Materials" then
		return
	end

	local inventory = profile.Data.Inventories[category]
	local amountLeft = amount
	local itemDef = ItemDatabase.Registry[Id]
	local maxStack = (itemDef and itemDef.MaxStack) or 99

	for index, itemData in ipairs(inventory) do
		if itemData.Id == Id and itemData.Amount < maxStack and CompareNBT(itemData.NBT, customNBT) then
			local spaceLeft = maxStack - itemData.Amount
			local amountToAdd = math.min(amountLeft, spaceLeft)
			profile.Replica:Set({ "Inventories", category, index, "Amount" }, itemData.Amount + amountToAdd)
			amountLeft -= amountToAdd
			if amountLeft <= 0 then
				break
			end
		end
	end

	while amountLeft > 0 do
		local amountForNewStack = math.min(amountLeft, maxStack)
		local newStack = StackableFactory.create(Id, amountForNewStack)
		if customNBT then
			newStack.NBT = HttpService:JSONDecode(HttpService:JSONEncode(customNBT))
		end
		profile.Replica:TableInsert({ "Inventories", category }, newStack)
		amountLeft -= amountForNewStack
	end
end

function InventorySystem:RemoveStackable(
	player: Player,
	category: string,
	Id: string,
	amountToRemove: number,
	targetNBT: table?
)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end
	local inventory = profile.Data.Inventories[category]

	local totalHas = 0
	for _, item in ipairs(inventory) do
		if item.Id == Id and CompareNBT(item.NBT, targetNBT) then
			totalHas += item.Amount
		end
	end
	if totalHas < amountToRemove then
		return false
	end

	local amountLeftToRemove = amountToRemove
	for i = #inventory, 1, -1 do
		local itemData = inventory[i]
		if itemData.Id == Id and CompareNBT(itemData.NBT, targetNBT) then
			if itemData.Amount > amountLeftToRemove then
				profile.Replica:Set({ "Inventories", category, i, "Amount" }, itemData.Amount - amountLeftToRemove)
				amountLeftToRemove = 0
				break
			else
				amountLeftToRemove -= itemData.Amount
				profile.Replica:TableRemove({ "Inventories", category }, i)
				if amountLeftToRemove <= 0 then
					break
				end
			end
		end
	end
	return true
end

function InventorySystem:ClearInventory(player: Player)
	local profile = DataManager:GetProfile(player)
	if profile then
		profile.Replica:Set({ "Inventories", "Items" }, {})
		profile.Replica:Set({ "Inventories", "Consumables" }, {})
		profile.Replica:Set({ "Inventories", "Materials" }, {})
	end
end

-- ==========================================
-- LẮNG NGHE LỆNH CHAT ĐỂ TEST
-- ==========================================
function InventorySystem:Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			-- CÚ PHÁP MỚI: /equip [Vị trí Index] [TargetEntity]
			-- VD: /equip 1 Player (Mặc đồ ở ô số 1 cho Player)
			-- VD: /equip 2 Gustave (Mặc đồ ở ô số 2 cho Gustave)
			if command == "/equip" then
				local itemIndex = tonumber(args[1])
				local targetEntity = args[2] or "Player"

				if itemIndex then
					local profile = DataManager:GetProfile(player)
					if profile then
						local itemData = profile.Data.Inventories.Items[itemIndex]
						if itemData then
							-- Lấy UUID từ vị trí Index và gọi hàm
							local result = self:EquipItem(player, itemData.UUID, targetEntity)
							print(result.Success and "✅" or "❌", result.Message)
						else
							print("❌ Không tìm thấy vật phẩm ở ô số " .. itemIndex .. "!")
						end
					end
				else
					print("❌ Cú pháp sai! Vui lòng nhập số Index. VD: /equip 1")
				end

			-- /unequip [SlotName] [TargetEntity]
			-- VD: /unequip Weapon Player
			elseif command == "/unequip" then
				local slotName = args[1]
				local targetEntity = args[2] or "Player"
				if slotName then
					local result = self:UnequipItem(player, slotName, targetEntity)
					print(result.Success and "✅" or "❌", result.Message)
				end

			-- /giveitem [Id Vật phẩm]
			elseif command == "/giveitem" then
				local itemId = table.concat(args, " ")
				if itemId ~= "" then
					local uuid = self:GiveItem(player, itemId)
					print("✅ Đã nhận vật phẩm mới. UUID:", uuid)
				end

			-- /givestackable [Số lượng] [Id Vật phẩm]
			elseif command == "/givestackable" then
				local amount = tonumber(args[#args]) or 1
				if type(tonumber(args[#args])) == "number" then
					table.remove(args, #args)
				end
				local itemId = table.concat(args, " ")
				if itemId ~= "" then
					self:GiveStackable(player, "Materials", itemId, amount)
					print("✅ Lệnh: Nhận", amount, itemId)
				end

			-- /testlocation
			elseif command == "/testlocation" then
				local profile = DataManager:GetProfile(player)
				if profile and #profile.Data.Inventories.Items > 0 then
					local targetUUID = profile.Data.Inventories.Items[1].UUID
					local loc = self:GetItemDataByUUID(player, targetUUID)
					if loc then
						print("🔍 UUID:", targetUUID)
						print(
							"📍 Đang mặc:",
							loc.IsEquipped and ("Có (Bởi: " .. loc.EntityId .. " - Slot: " .. loc.EquipSlot .. ")")
								or "Không"
						)
					end
				end

			-- /clearinventory
			elseif command == "/clearinventory" then
				self:ClearInventory(player)
				print("🗑️ Đã dọn sạch túi đồ!")
			end
		end)
	end)
end

return InventorySystem
