-- File: Shared/Types/EnchantTemplateTypes.luau

-- ==========================================
-- 1. ĐIỀU KIỆN MỞ KHÓA BÙA CHÚ
-- ==========================================
export type EnchantCondition = {
    Enchanting: number?,           -- [CẬP NHẬT] Yêu cầu cấp độ nghề Enchanting tối thiểu để có thể roll ra dòng này.
    -- PlayerLevel: number?,       -- (Tùy chọn) Có thể mở rộng thêm yêu cầu cấp độ người chơi.
    -- QuestCompleted: string?,    -- (Tùy chọn) Yêu cầu hoàn thành nhiệm vụ để mở khóa bùa.
}

-- ==========================================
-- 2. KHUÔN MẪU GỐC CỦA BÙA CHÚ (ENCHANT TEMPLATE)
-- Đại diện cho dữ liệu trả về từ các file nằm trong EnchantDatabase
-- ==========================================
export type EnchantTemplate = {
    Description: string,
    Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic", -- Đã thêm Mythic
    
    MaxLevel: number,              -- Cấp độ tối đa của dòng bùa (VD: 3). Nếu đã Max, hệ thống sẽ chặn nâng cấp.
    AcceptTypes: {string},         -- Loại trang bị cho phép khảm. Hỗ trợ hệ thống Category (VD: "Weapon", "Armor", "Sword").
    
    Attribute: string?,            -- Thuộc tính (Màu/Hệ). VD: "Dark", "Light", "Chaos". 
                                   -- [QUAN TRỌNG]: Nếu = nil (Trung tính), mọi loại Rune đều có thể bốc trúng nó.
    
    BaseWeight: number,            -- Điểm trọng số cơ sở. Càng cao càng dễ trúng. Khuyên dùng: Common (100) -> Mythic (2).
    Conditions: EnchantCondition?, -- Các điều kiện bắt buộc để bùa này xuất hiện trong bể Roll.

    -- [HỆ THỐNG DATA-DRIVEN LÕI]
    Effects: {[string]: any}?,     -- Chứa cấu trúc Interpreter (OnHit, OnTurnStart, OnKill...) quy định chức năng của bùa.
                                   -- Định dạng dictionary để hệ thống Combat tự động đọc và kích hoạt.
}

-- ==========================================
-- 3. BỘ LỌC ĐIỀU KIỆN NÂNG CAO CHO RUNE (MODIFIERS)
-- Tạo ra các viên Rune "Định hướng" (Targeted Gacha)
-- ==========================================
export type RuneModifiers = {
    OnlyRarity: string?,           -- Bắt buộc chỉ roll ra/nâng cấp bùa có đúng Rarity này (VD: "Epic").
    MinRarity: string?,            -- Bùa roll ra phải có Rarity TỪ ngưỡng này trở lên (VD: "Rare" -> Bốc Rare, Epic...).
    MaxRarity: string?,            -- Bùa roll ra có Rarity TỐI ĐA là ngưỡng này (Chặn bốc đồ quá xịn).
    ExcludeEnchants: {string}?,    -- Danh sách ID (Tên File) các bùa chú bị cấm vĩnh viễn không được phép roll trúng.
}

-- ==========================================
-- 4. KHUÔN MẪU THỰC THI CỦA VIÊN ĐÁ KHẢM (RUNE LOGIC)
-- Nằm trong nhánh thứ 4 của StackableTemplate
-- ==========================================
export type RuneLogic = {
    Attribute: string?,            -- Viên Rune mang hệ gì? (VD: "Dark" bốc Dark+Trung tính; "Chaos" bốc tất cả mọi hệ). Nếu rỗng (nil) sẽ chỉ bốc Trung Tính.
    Tokens: number,                -- Số vòng lặp (Số lần tung đồng xu Gacha). Mỗi Token trúng sẽ tương đương Mở khóa 1 dòng Mới hoặc +1 Level dòng Cũ.
    EnchantingExp: number?,        -- Lượng Exp nghề Enchanting thưởng thêm ngay khi người chơi bấm nút đập viên Rune này.
    
    -- [CƠ CHẾ MAY MẮN & ĐỊNH HƯỚNG MỚI]
    Luck: number?,                 -- Điểm may mắn cộng thẳng vào BaseWeight của MỌI Enchant trong bể (Giúp đồ hiếm dễ ra hơn rất nhiều).
    Modifiers: RuneModifiers?,     -- Các thẻ điều kiện lọc bể Gacha. Cực kỳ hữu dụng để thiết kế Rune Sự kiện hoặc Rune Cao cấp.
}

-- ==========================================
-- 5. LƯU TRỮ TRÊN TRANG BỊ (NẰM TRONG ITEM DATA)
-- Mảng các bùa chú đang tồn tại trên món đồ thực tế của người chơi.
-- ==========================================
export type Enchant = {
    Id: string,                    -- Lưu Tên File của Enchant (VD: "Life Steal", "Sharpness"). Không lưu toàn bộ Data.
    Level: number                  -- Cấp độ hiện tại của bùa chú trên món đồ đó.
}

return {}

--[[
RuneLogic = {
    Attribute = "Chaos", 
    Tokens = 5,
    Modifiers = {
        OnlyRarity = "Rare", -- Chắc chắn 5 lần đập đều rơi vào nâng cấp/ra mới bùa Rare
        ExcludeEnchants = {"Life Steal", "Sharpness"} -- Không bao giờ roll ra 2 dòng này
    }
}

RuneLogic = {
    Attribute = "Dark", 
    Tokens = 2,
    Luck = 150, -- Trọng số của đồ Mythic sẽ từ 1 nhảy vọt lên 151, dễ ra y như đồ Common!
    EnchantingExp = 500
}
]]--