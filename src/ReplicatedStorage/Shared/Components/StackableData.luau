-- File: Shared/Components/StackableData.luau

-- [MỚI] Require Database vật phẩm để tra cứu
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)

export type StackableData = {
    Id: string,     -- Id gốc (VD: "HealthPotion", "IronOre")
    Amount: number,         -- Số lượng
    NBT: {[string]: any}?   -- Dành cho trường hợp đặc biệt (ví dụ: bình máu có hạn sử dụng)
}

local StackableFactory = {}

-- [MỚI] Thêm dấu "?" vào `StackableData?` vì hàm này có thể trả về nil nếu Id sai
function StackableFactory.create(Id: string, amount: number): StackableData?
    
    -- 1. KIỂM TRA TÍNH HỢP LỆ CỦA Id TỪ DATABASE
    if not ItemDatabase.Registry[Id] then
        warn("🚨 [StackableFactory] Từ chối tạo đồ! Id không tồn tại trong GlobalRegistry: " .. tostring(Id))
        return nil
    end

    -- (Tùy chọn) Nếu Database của bạn có lưu Category, bạn có thể kiểm tra thêm:
    -- if ItemDatabase.Registry[Id].Category == "Weapon" then
    --     warn("🚨 Sai loại! Vũ khí không được dùng StackableFactory.")
    --     return nil
    -- end

    -- 2. NẾU HỢP LỆ, TIẾN HÀNH TẠO DATA
    return {
        Id = Id,
        Amount = amount or 1,
    }
end

return StackableFactory