-- File: Shared/Constants/ItemData/Materials/Iron.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
    Description = "A seed pack containing various types of seeds. Perfect for starting your farming journey!",
    Rarity = "Common",
    ItemType = "Material",
    MaxStack = 99,
    SellPrice = 5,
    IsImportant = false,
    ConsumeOnUse = false,

    -- [HỆ THỐNG TRỒNG TRỌT] 
    -- Dùng Custom NBT mặc định (Giả định InventorySystem của bạn cấp phát Stackable có NBT)
    NBT = {
        -- PlantId = "Wheat" -- Lưu loại cây trồng (ví dụ: "Wheat")
    }
}

return Item