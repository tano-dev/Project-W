-- File: Shared/Types/EnchantTemplateTypes.luau

export type EnchantCondition = {
    PlayerLevel: number?,
    -- Có thể thêm điều kiện khác như Quest, Profession...
}

export type EnchantTemplate = {
    Description: string,
    Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary",
    
    MaxLevel: number,              -- Cấp độ tối đa (VD: 3). Nếu roll trúng khi đã max thì sẽ roll lại dòng khác.
    AcceptTypes: {string},         -- Áp dụng cho "Weapon", "Armor", hoặc "All".
    
    Attribute: string?,            -- Thuộc tính (Màu). VD: "Dark", "Light", "Fire". 
                                   -- [QUAN TRỌNG]: Nếu = nil (Trung tính), mọi loại Rune đều có thể roll ra nó.
    
    BaseWeight: number,            -- Độ hiếm. Weight càng cao càng dễ ra. Weight thấp = siêu hiếm.
    Conditions: EnchantCondition?, -- Yêu cầu người chơi phải đạt level X mới roll ra được dòng này.
}

export type RuneLogic = {
    Attribute: string,             -- Viên Rune này mang hệ gì? (VD: "Dark" sẽ chỉ roll ra Enchant hệ Dark và Trung tính).
    Tokens: number,                -- Số lần hệ thống sẽ đổ xí ngầu. Mỗi 1 Token trúng sẽ tương đương +1 Level cho Enchant đó.
                                   -- VD: Tokens = 3. Có thể ra 3 dòng Level 1, hoặc 1 dòng Level 3, hoặc 1 dòng Lv2 + 1 dòng Lv1.
    EnchantingExp: number,          -- Kinh nghiệm nhận được khi sử dụng viên Rune này. Dùng để tăng cấp độ Enchanting của người chơi.
}

-- Mảng lưu trên ItemData của bạn
export type Enchant = {
    Id: string,
    Level: number
}

return {}