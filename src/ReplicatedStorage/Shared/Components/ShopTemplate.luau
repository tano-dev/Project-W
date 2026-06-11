-- File: Shared/Types/ShopTemplate.luau

-- Cấu trúc của 1 mặt hàng bán trong Shop
export type ShopItem = {
    Id: string,                  -- ID của vật phẩm (Tham chiếu đến ItemDatabase)
    Price: number,               -- Giá bán (Tính bằng đơn vị tiền tệ của Shop)
    
    GlobalStock: number?,        -- (Chỉ dùng cho Shop Limited) Tổng số lượng hàng có trên TOÀN SERVER
    MaxPerPurchase: number?,     -- (Chỉ dùng cho Shop Limited) Giới hạn mua mỗi lần bấm
    EndTime: number?,            -- (Tùy chọn) Thời điểm ngưng bán mặt hàng này (Tính bằng os.time())
    
    -- [SỨC MẠNH TÙY CHỈNH]
    -- Bạn có thể ghi đè bất kỳ chỉ số nào của trang bị ngay khi mua từ Shop
    NBT: {[string]: any}?,       -- Custom data (VD: PlantId cho hạt giống)
    Enchants: {                  -- Khảm sẵn bùa chú cho vũ khí bán trong Shop
        {Id: string, Level: number}
    }?,
    UpgradeCount: number?,       -- Bán đồ đã cường hóa sẵn (VD: Kiếm sắt +5)
    CustomName: string?,         -- Đổi tên vật phẩm (VD: "Thanh Gươm Của Nhà Vua")
    Aura: number?,               -- Ánh hào quang
}

-- Cấu trúc của 1 Thương nhân
export type ShopTemplate = {
    Name: string,                -- Tên thương nhân hiển thị trên UI
    Currency: string,            -- Loại tiền tệ dùng để giao dịch (VD: "Coin", "Gem")
    IsGlobalLimited: boolean,    -- Bật/tắt tính năng đồng bộ kho hàng liên server
    Items: {ShopItem},           -- Danh sách các mặt hàng bày bán
}

return {}