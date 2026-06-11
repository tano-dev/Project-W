-- File: Shared/Constants/ShopDatabase/Dark Merchant.luau
return {
    Name = "Dark Merchant",
    Currency = "Coin",
    IsGlobalLimited = true, -- Bật tính năng MemoryStore (Đồng bộ kho hàng toàn Server)
    Items = {
        { 
            Id = "Steel Sword", 
            PriceMultiplier = 2, 
            GlobalStock = 5, -- Tổng kho toàn thế giới chỉ có 5 cây
            MaxPerPurchase = 17, -- [MỚI] Giới hạn mua mỗi lần bấm (Ngăn 1 đại gia ôm hết)
            RestockInterval = 86400
        },
        { 
            Id = "Epic Rune", 
            PriceMultiplier = 2, 
            GlobalStock = 100,
            RestockInterval = 86400
        }
    }
}