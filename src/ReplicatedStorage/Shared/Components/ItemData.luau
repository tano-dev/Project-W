-- File: Shared/Components/ItemData.luau
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local HttpService = game:GetService("HttpService")
-- Định nghĩa kiểu dữ liệu 
export type Enchant = {
	Id: string,
	Level: number
}

-- Mẫu dữ liệu cho 1 lần nâng cấp
export type UpgradeEntry = {
	Material: string,            -- Loại tinh thể/vật liệu dùng
	StatChanges: {[string]: number}, -- Các chỉ số được cộng (VD: {Damage = 2, Crit = 5})
	Time: number            -- Lưu thời điểm để sau này làm log
}

export type ItemData = {
	UUID: string,             -- Id độc nhất của cục đồ này (VD: "item_982hjsdf-2342")
	Id: string,       -- Tên của đồ gốc (VD: "IronSword" -> để tra trong Constants/Weapons)

	-- Các chỉ số bị biến đổi (Chỉ tồn tại khi có sự thay đổi)
	CustomName: string?,      -- Dấu "?" nghĩa là có thể bị nil (không lưu vào DataStore nếu trống)
	CustomLore: string?,

	UpgradeCount: number?,    -- Thay cho UpgradeAttemptsUsed, nếu = 0 thì gán bằng nil luôn
	Purity: number?,
	Corruption: number?,

	OwnerId: number?,         -- UserId của chủ sở hữu (nếu là đồ bị khóa)
	BindState: "Unlocked" | "BoundToCharacter" | "BoundToAccount", -- Dễ đọc, dễ hiểu

	-- Dùng Array để lưu, không giới hạn số slot cứng.
	-- Server sẽ check `#Enchants < MaxEnchantSlots` lấy từ Template gốc.
	EnchantCount: number?,     -- Số lượng Enchant đã dùng (Dùng để check khi roll, tránh trường hợp Enchant bị xóa nhưng Count vẫn còn)
	Enchants: {Enchant}?,
	Gems: {string}?,          -- Chỉ cần lưu mảng Id của các viên ngọc (VD: {"Ruby", "Sapphire"})
	UpgradeHistory: {UpgradeEntry}?,
	
	State: {string}?,
	NBT: {[string]: any}?,     -- Lưu data tùy ý (Custom Data) cho các event đặc biệt
	Aura: number?
}

-- Trả về 1 hàm Factory để tạo vật phẩm mới cực kỳ sạch sẽ
local ItemFactory = {}

-- [MỚI] Thêm dấu "?" vào `ItemData?` vì hàm này có thể trả về nil nếu Id nhập vào bị sai
function ItemFactory.createNewItem(Id: string): ItemData?
    
    -- 1. KIỂM TRA TÍNH HỢP LỆ CỦA Id TỪ DATABASE
    if not ItemDatabase.Registry[Id] then
        warn("🚨 [ItemFactory] Từ chối tạo đồ! Id vật phẩm không tồn tại trong GlobalRegistry: " .. tostring(Id))
        return nil
    end

    -- 2. NẾU HỢP LỆ, TIẾN HÀNH TẠO NHỮNG DATA BẮT BUỘC
    local newItem: ItemData = {
        UUID = HttpService:GenerateGUID(false),
        Id = Id,
        BindState = "Unlocked",
    }

    return newItem
end

return ItemFactory