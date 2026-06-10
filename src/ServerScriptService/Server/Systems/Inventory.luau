-- File: Server/Systems/Inventory.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local ItemFactory = require(game.ReplicatedStorage.Shared.Components.ItemData)
local StackableFactory = require(game.ReplicatedStorage.Shared.Components.StackableData)

-- [BỔ SUNG] Cần require Database để check giới hạn MaxStack của vật phẩm
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local Players = game:GetService("Players")

local InventorySystem = {}

-- ==========================================
-- 1. API: THÊM VẬT PHẨM (GIVE)
-- ==========================================

function InventorySystem:GiveItem(player: Player, Id: string)
    local profile = DataManager:GetProfile(player)
    if not profile then return nil end

    local newItem = ItemFactory.createNewItem(Id)
    if newItem then
        profile.Replica:TableInsert({"Inventories", "Items"}, newItem)
        return newItem.UUID
    end
    return nil
end

-- TỐI ƯU HÓA: Chia stack tự động nếu vượt quá MaxStack
function InventorySystem:GiveStackable(player: Player, category: string, Id: string, amount: number)
    local profile = DataManager:GetProfile(player)
    if not profile then return end

    if category ~= "Consumables" and category ~= "Materials" then
        warn("⚠️ Sai loại túi đồ Stackable!")
        return
    end

    local inventory = profile.Data.Inventories[category]
    local amountLeft = amount
    
    -- Lấy MaxStack từ Database, nếu không có thì mặc định là 99
    local itemDef = ItemDatabase.Registry[Id]
    local maxStack = (itemDef and itemDef.MaxStack) or 99 

    -- BƯỚC 1: Lấp đầy các Stack còn thiếu chỗ
    for index, itemData in ipairs(inventory) do
        if itemData.Id == Id and itemData.Amount < maxStack then
            local spaceLeft = maxStack - itemData.Amount
            local amountToAdd = math.min(amountLeft, spaceLeft)

            profile.Replica:Set({"Inventories", category, index, "Amount"}, itemData.Amount + amountToAdd)
            amountLeft -= amountToAdd

            if amountLeft <= 0 then break end
        end
    end

    -- BƯỚC 2: Nếu lấp đầy rồi mà vẫn dư đồ, tạo các Stack mới
    while amountLeft > 0 do
        local amountForNewStack = math.min(amountLeft, maxStack)
        local newStack = StackableFactory.create(Id, amountForNewStack)
        
        profile.Replica:TableInsert({"Inventories", category}, newStack)
        amountLeft -= amountForNewStack
    end
end

-- ==========================================
-- 2. API: ĐỊNH VỊ VÀ XÓA VẬT PHẨM
-- ==========================================

-- Lấy UUID từ trang bị đang mặc (VD: Lấy vũ khí đang cầm)
function InventorySystem:GetEquippedUUID(player: Player, equipCategory: string, slotName: string)
    local profile = DataManager:GetProfile(player)
    if not profile then return nil end
    
    local categoryData = profile.Data.Equipped[equipCategory]
    if categoryData then
        return categoryData[slotName] -- Trả về UUID hoặc nil
    end
    return nil
end

-- CẢI TIẾN: Tìm vị trí của vật phẩm (Trong túi hoặc đang mặc trên người)
function InventorySystem:FindItemLocationByUUID(player: Player, uuid: string)
    local profile = DataManager:GetProfile(player)
    if not profile then return nil end

    -- 1. Quét trong túi đồ Items
    for index, itemData in ipairs(profile.Data.Inventories.Items) do
        if itemData.UUID == uuid then
            return { Location = "Inventory", Index = index }
        end
    end

    -- 2. Quét trong Trang Bị (Equipped)
    for equipCategory, slots in pairs(profile.Data.Equipped) do
        for slotName, equippedUUID in pairs(slots) do
            if equippedUUID == uuid then
                return { Location = "Equipped", Category = equipCategory, Slot = slotName }
            end
        end
    end

    return nil -- Không tìm thấy
end

-- Xóa đồ độc nhất (Hỗ trợ xóa cả khi đang mặc trên người)
function InventorySystem:RemoveItemByUUID(player: Player, uuid: string)
    local profile = DataManager:GetProfile(player)
    if not profile then return false end

    local locationData = self:FindItemLocationByUUID(player, uuid)
    
    if locationData then
        if locationData.Location == "Inventory" then
            -- Nếu nằm trong túi, dùng TableRemove
            profile.Replica:TableRemove({"Inventories", "Items"}, locationData.Index)
        elseif locationData.Location == "Equipped" then
            -- Nếu đang mặc, ép vị trí đó về nil
            profile.Replica:Set({"Equipped", locationData.Category, locationData.Slot}, nil)
        end
        return true
    end
    return false
end

-- [BỔ SUNG MỚI] Trừ/Xóa Stackable (Dùng cho Crafting, Tiêu thụ)
function InventorySystem:RemoveStackable(player: Player, category: string, Id: string, amountToRemove: number)
    local profile = DataManager:GetProfile(player)
    if not profile then return false end

    local inventory = profile.Data.Inventories[category]
    
    -- Bước 1: Kiểm tra xem có đủ số lượng để trừ không
    local totalHas = 0
    for _, item in ipairs(inventory) do
        if item.Id == Id then
            totalHas += item.Amount
        end
    end
    
    if totalHas < amountToRemove then
        warn("⚠️ Không đủ " .. Id .. " để trừ!")
        return false 
    end

    -- Bước 2: Bắt đầu trừ từ Stack cuối cùng lên (Duyệt ngược mảng để TableRemove không bị lệch index)
    local amountLeftToRemove = amountToRemove
    for i = #inventory, 1, -1 do
        local itemData = inventory[i]
        
        if itemData.Id == Id then
            if itemData.Amount > amountLeftToRemove then
                -- Nếu Stack này to hơn số cần trừ -> Chỉ trừ số lượng
                profile.Replica:Set({"Inventories", category, i, "Amount"}, itemData.Amount - amountLeftToRemove)
                amountLeftToRemove = 0
                break
            else
                -- Nếu Stack này nhỏ hơn hoặc bằng số cần trừ -> Xóa nguyên Stack
                amountLeftToRemove -= itemData.Amount
                profile.Replica:TableRemove({"Inventories", category}, i)
                
                if amountLeftToRemove <= 0 then break end
            end
        end
    end
    
    return true
end

-- Dọn sạch toàn bộ túi (Dùng cho test)
function InventorySystem:ClearInventory(player: Player)
    local profile = DataManager:GetProfile(player)
    if profile then
        profile.Replica:Set({"Inventories", "Items"}, {})
        profile.Replica:Set({"Inventories", "Consumables"}, {})
        profile.Replica:Set({"Inventories", "Materials"}, {})
    end
end

-- ==========================================
-- 3. API: THAY ĐỔI CHỈ SỐ VẬT PHẨM
-- ==========================================

-- Dùng cho hệ thống Enchant, Reforge
function InventorySystem:UpdateItemData(player: Player, uuid: string, newItemData: table)
    local profile = DataManager:GetProfile(player)
    if not profile then return false end

    local locationData = self:FindItemLocationByUUID(player, uuid)
    if locationData and locationData.Location == "Inventory" then
        profile.Replica:Set({"Inventories", "Items", locationData.Index}, newItemData)
        return true
    end
    
    warn("⚠️ Không thể cập nhật chỉ số! (Vật phẩm đang được mặc hoặc không tồn tại)")
    return false
end
-- [BỔ SUNG MỚI]: Thêm vật phẩm đã có sẵn dữ liệu (Dành cho Kế thừa Crafting / Trading)
function InventorySystem:GiveCustomItem(player: Player, customItemData: table)
    local profile = DataManager:GetProfile(player)
    if not profile then return false end

    -- Tùy chọn: Bạn có thể thêm code kiểm tra Full túi đồ ở đây sau này
    
    profile.Replica:TableInsert({"Inventories", "Items"}, customItemData)
    return true
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

            -- [BƯỚC MỚI]: Bắt cờ auto-debug ở cuối câu
            -- local autoDebug = false
            if #args > 0 and string.lower(args[#args]) == "true" then
                -- autoDebug = true
                table.remove(args, #args) -- Cắt chữ "true" vứt đi để bảo vệ tên vật phẩm
            end

            if command == "/giveitem" then
                local itemId = table.concat(args, " ")
                if itemId ~= "" then 
                    self:GiveItem(player, itemId)
                end

            elseif command == "/givestackable" then
                local amount = tonumber(args[#args]) or 1 
                if type(tonumber(args[#args])) == "number" then 
                    table.remove(args, #args) 
                end
                local itemId = table.concat(args, " ")
                
                if itemId ~= "" then
                    print("🖥️ Lệnh: Nhận " .. amount .. " " .. itemId)
                    self:GiveStackable(player, "Materials", itemId, amount)
                end
                
            elseif command == "/removestackable" then
                local amount = tonumber(args[#args]) or 1 
                if type(tonumber(args[#args])) == "number" then 
                    table.remove(args, #args)
                end
                local itemId = table.concat(args, " ")
                
                if itemId ~= "" then
                    print("🖥️ Lệnh: Xóa " .. amount .. " " .. itemId)
                    local success = self:RemoveStackable(player, "Materials", itemId, amount)
                    if success then print("✅ Xóa thành công!")
                    else print("❌ Không đủ đồ để xóa!")
                    end
                end

            elseif command == "/testlocation" then
                local profile = DataManager:GetProfile(player)
                if profile and #profile.Data.Inventories.Items > 0 then
                    local targetUUID = profile.Data.Inventories.Items[1].UUID
                    local loc = self:FindItemLocationByUUID(player, targetUUID)
                    
                    if loc then
                        print("🔍 UUID:", targetUUID)
                        print("📍 Đang nằm ở:", loc.Location, "(Index/Slot:", loc.Index or loc.Slot, ")")
                    end
                end

            elseif command == "/clearinventory" then
                self:ClearInventory(player)
            
            -- elseif command == "/debug" then
            --     -- Lệnh gọi thủ công
            --     DataManager:DebugProfile(player)
            end

            -- [BƯỚC MỚI]: Chạy bảng Debug nếu cờ được bật (và bỏ qua nếu lệnh gốc vốn đã là /debug để tránh in 2 lần)
            -- if autoDebug and command ~= "/debug" then
            --     print("🖥️ [Auto-Debug] In dữ liệu sau khi thực thi lệnh...")
            --     DataManager:DebugProfile(player)
            -- end
        end)
    end)
end

return InventorySystem