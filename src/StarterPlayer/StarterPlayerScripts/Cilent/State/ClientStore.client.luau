-- File: StarterPlayerScripts/Client/State/ClientDataStore.luau
local Replica = require(game.ReplicatedStorage.Shared.Utilities.ReplicaCilent)

local ClientDataStore = {
    Data = nil,
    Replica = nil,
    IsReady = false
}

Replica.OnNew("PlayerData", function(replica)
    if replica.Tags.UserId == game.Players.LocalPlayer.UserId then
        ClientDataStore.Replica = replica
        ClientDataStore.Data = replica.Data
        ClientDataStore.IsReady = true
        
        print("🎯 [Replica] Hệ thống UI đã đồng bộ thành công cấu trúc dữ liệu tổng!")

        -- 1. Hàm OnSet vẫn tồn tại và dùng bình thường cho các giá trị đơn lẻ
        replica:OnSet({"Currencies", "Coin"}, function(new_value, old_value)
            print("💰 Tiền nhảy số từ " .. tostring(old_value) .. " -> " .. tostring(new_value))
        end)

        -- 2. [ĐÃ SỬA] Sử dụng OnChange để bắt sự kiện thêm/xóa trong Mảng (Array)
        replica:OnChange(function(action, path, param1, param2)
            -- param1 là value (Dữ liệu đồ), param2 là index (Vị trí)
            
            if action == "TableInsert" then
                -- Kiểm tra xem sự thay đổi này có nằm đúng trong {"Inventories", "Items"} không
                -- Lưu ý: Không thể dùng path == {"Inventories", "Items"} vì đây là 2 table khác nhau trong Lua
                if path[1] == "Inventories" and path[2] == "Items" then
                    local inserted_item = param1
                    local inserted_index = param2
                    print("⚔️ Nhặt được đồ mới tại ô slot [" .. inserted_index .. "]: " .. inserted_item.ID)
                    
                    -- [GẮN CODE UI Ở ĐÂY]
                end
                
            elseif action == "TableRemove" then
                -- Nếu bạn muốn xử lý lúc vứt đồ hoặc bán đồ đi
                if path[1] == "Inventories" and path[2] == "Items" then
                    local removed_item = param1
                    local removed_index = param2
                    print("🗑️ Đã xóa đồ tại ô [" .. removed_index .. "]: " .. removed_item.ID)
                end
            end
            
        end)
    end
end)

Replica.RequestData()

return ClientDataStore