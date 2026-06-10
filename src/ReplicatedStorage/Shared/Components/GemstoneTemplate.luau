-- File: Shared/Components/GemstoneTemplate.luau
-- ==========================================
-- ĐỊNH NGHĨA CHỈ SỐ CỦA NGỌC (GEM MODIFIER)
-- Hỗ trợ Scale theo Level và Rarity của trang bị
-- ==========================================
export type GemStatModifier = {
    StatName: string,       -- VD: "Damage", "CritRate", "MaxHealth"
    BaseValue: number,      -- Chỉ số gốc. VD: 10
    
    -- [TÍNH NĂNG SCALE ĐỘNG]
    ScalePerItemLevel: number?, -- Cộng thêm bao nhiêu điểm trên mỗi cấp độ của vũ khí. 
                                -- VD: 2.0 (Vũ khí cấp 10 -> Nhận thêm 20 điểm).
                                
    RarityMultipliers: {[string]: number}?, 
                                -- Hệ số nhân theo phẩm chất của trang bị gắn vào.
                                -- VD: { Epic = 1.2, Legendary = 1.5 } -> Vũ khí cam được buff mạnh hơn 50%.
                                
    MaxCap: number?,            -- Ngưỡng tối đa để tránh việc vũ khí cấp quá cao làm chỉ số bị lạm phát.
                                -- VD: 50 (Dù tính toán ra 100 thì vẫn chỉ lấy 50).
}

-- ==========================================
-- CẤU TRÚC LÕI CỦA GEMSTONE
-- ==========================================
export type GemstoneLogic = {
    AcceptTypes: {string},         -- Loại đồ cho phép khảm. VD: {"Weapon", "Sword"}, hoặc {"Armor"}
    Modifiers: {GemStatModifier},  -- Danh sách các chỉ số mà viên ngọc này mang lại
    
    -- [CÁC TÍNH NĂNG MỞ RỘNG SAU NÀY]
    SetBonusId: string?,           -- Khảm 3 viên ngọc cùng Set sẽ kích hoạt hiệu ứng ẩn (như Diablo).
    RemovalCost: number?,          -- Phí tháo ngọc (Tiền Vàng), tạo Gold Sink cho game.
    IsFragile: boolean?,           -- Bị vỡ (biến mất) nếu tháo ra thay vì trả lại vào túi?
}

return {}