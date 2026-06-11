-- File: Shared/Components/PlantTemplate.luau

-- ==========================================
-- ĐỊNH NGHĨA KIỂU DỮ LIỆU
-- ==========================================
export type HarvestYield = {
    Id: string,
    Min: number,
    Max: number,
    Chance: number? -- Nếu nil, mặc định là 1.0 (100%)
}

export type HarvestBehavior = {
    HarvestTimes: number?,   -- Số lần thu hoạch tối đa (nil = vô hạn)
    RepeatInterval: number?  -- Thời gian chờ để thu hoạch lại (tính bằng giây)
}

export type PlantTemplate = {
    Name: string,
    Description: string,
    Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary",
    Type: "Crops" | "Trees",
    
    GrowthTime: number,      -- Thời gian phát triển lần đầu (Giây)
    Stages: number,          -- Số giai đoạn hình ảnh (VD: 4 giai đoạn: Hạt -> Mầm -> Cây -> Quả)
    
    HarvestBehavior: HarvestBehavior?,
    HarvestYield: {HarvestYield},
    
    FarmingExp: number,
    IconID: string,
}

-- Cấu trúc lưu trong Profile của người chơi
export type PlantData = {
    Id: string,
    PlantedTime: number,     -- Lưu bằng os.time()
    LastHarvestTime: number, -- Lưu bằng os.time(), bằng 0 nếu chưa thu hoạch lần nào
    HarvestedTimes: number,  -- Số lần đã hái
}

return {}