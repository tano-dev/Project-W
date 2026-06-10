-- File: Shared/Components/StackableTemplateTypes.luau

-- Lấy Type từ các file khác vào (Importing)
local ItemTemplate = require(game.ReplicatedStorage.Shared.Components.ItemTemplate)
local UpgradeTemplate = require(game.ReplicatedStorage.Shared.Components.UpgradeTemplate) 
local GemstoneTemplate = require(game.ReplicatedStorage.Shared.Components.GemstoneTemplate) 
local EnchantTemplate = require(game.ReplicatedStorage.Shared.Components.EnchantTemplate) -- [MỚI] Gọi file Enchant vào đây!

-- 1. Khuôn mẫu cho Hiệu ứng tiêu hao (Bình máu, Buff)
export type ConsumableEffect = {
    Action: "Heal" | "RestoreMana" | "BuffStat" | "Cleanse",
    TargetStat: string?, 
    Amount: number,
    Duration: number?,
}

-- 2. Khuôn mẫu Chính cho Vật phẩm
export type StackableTemplate = {
    -- [THÔNG TIN CƠ BẢN]
    Description: string,
    Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic",

    ItemType: "Consumable" | "Material",
    MaxStack: number,              -- Giới hạn số lượng trong 1 ô túi (Thường là 99 hoặc 999).

    -- [KINH TẾ & GIAO DỊCH]
    BuyPrice: number?,             -- Giá mua từ NPC (nil = không bán).
    SellPrice: number,             -- Giá bán ve chai cho NPC.
    BindType: "Tradeable" | "BindOnPickup" | "BindOnEquip", 
                                   -- Khóa giao dịch: Giao dịch tự do | Rớt vào túi là khóa | Mặc vào mới khóa.
    IsImportant: boolean,          -- Vật phẩm nhiệm vụ/Cốt truyện (Không thể vứt, cảnh báo khi rã/bán).
    
    -- [HÀNH VI SỬ DỤNG]
    ConsumeOnUse: boolean,         -- Bấm sử dụng xong có bị trừ đi 1 cái không? (Thuốc = true, Sách vĩnh viễn = false).

    -- [PHÂN RÃ]
    DismantleExp: number?,         -- Điểm kinh nghiệm nghề Crafting nhận được khi rã vật phẩm này.
    DismantleDrops: {ItemTemplate.DismantleDropItem}?, -- Danh sách đồ rớt ra khi bấm phân rã.

    -- ==========================================
    -- BỐN NHÁNH TÍNH NĂNG CHÍNH (Một món đồ có thể sở hữu 1 hoặc nhiều nhánh)
    -- ==========================================
    
    -- Nhánh 1: Dành cho Consumable (Vật phẩm tiêu hao / Thuốc lắc / Cuộn giấy buff)
    Effects: {ConsumableEffect}?,

    -- Nhánh 2: Dành cho Material cường hóa (Đá đập đồ / Sách bảo hiểm)
    -- Cung cấp tỷ lệ thành công, các dòng chỉ số cộng thêm (StatRolls), và hiệu ứng rủi ro (FailPool).
    UpgradeLogic: UpgradeTemplate.UpgradeLogic?,
    
    -- Nhánh 3: Dành cho Gemstone (Ngọc khảm / Rune đính kèm)
    -- Mang các dòng chỉ số tĩnh (Passive Stats) scale theo Rarity hoặc Level của trang bị.
    GemLogic: GemstoneTemplate.GemstoneLogic?,
    
    -- Nhánh 4: Dành cho Enchant Rune (Đá ném bùa chú Gacha - Chuẩn The Pit)
    -- Quy định Hệ của viên đá (Attribute: Dark, Light, Chaos...) và số lần đổ xí ngầu (Tokens).
    RuneLogic: EnchantTemplate.RuneLogic?,
}

return {}