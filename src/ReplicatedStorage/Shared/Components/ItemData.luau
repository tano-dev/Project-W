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
	UUID: string,             -- ID độc nhất của cục đồ này (VD: "item_982hjsdf-2342")
	ID: string,       -- Tên của đồ gốc (VD: "IronSword" -> để tra trong Constants/Weapons)

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
	Enchants: {Enchant}?,     
	Gems: {string}?,          -- Chỉ cần lưu mảng ID của các viên ngọc (VD: {"Ruby", "Sapphire"})
	UpgradeHistory: {UpgradeEntry}?,
	
	State: {string}?,
	NBT: {[string]: any}?,     -- Lưu data tùy ý (Custom Data) cho các event đặc biệt
	Aura: number?
}

-- Trả về 1 hàm Factory để tạo vật phẩm mới cực kỳ sạch sẽ
local ItemFactory = {}

-- [MỚI] Thêm dấu "?" vào `ItemData?` vì hàm này có thể trả về nil nếu ID nhập vào bị sai
function ItemFactory.createNewItem(Id: string): ItemData?
    
    -- 1. KIỂM TRA TÍNH HỢP LỆ CỦA ID TỪ DATABASE
    if not ItemDatabase.Registry[Id] then
        warn("🚨 [ItemFactory] Từ chối tạo đồ! ID vật phẩm không tồn tại trong GlobalRegistry: " .. tostring(Id))
        return nil
    end

    -- 2. NẾU HỢP LỆ, TIẾN HÀNH TẠO NHỮNG DATA BẮT BUỘC
    local newItem: ItemData = {
        UUID = HttpService:GenerateGUID(false),
        ID = Id,
        BindState = "Unlocked",
    }

    return newItem
end

return ItemFactory