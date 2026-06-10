-- File: Shared/Constants/ItemData/Materials/Wood.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
	Description = "A small rune used for basic enchantments. It hums with a faint magical energy.",
	Rarity = "Common",

	ItemType = "Rune",
	MaxStack = 9999, -- Xếp chồng thoải mái

	BuyPrice = 50,
	SellPrice = 15,
	BindType = "Tradeable",
	IsImportant = false,
	ConsumeOnUse = false, -- Bấm dùng không có tác dụng

	-- [CẤU HÌNH ENCHANT RUNE]
    RuneLogic = {
        Tokens = 7,          -- Ném 2 lần xí ngầu (Tối đa nhận 1 dòng Lv2 hoặc 2 dòng Lv1)
		EnchantingExp = 10, -- [MỚI] Cấp 1 Rune này sẽ cho 10 Exp nghề Enchanting khi sử dụng. Cấp cao hơn có thể tăng exp này lên (Tùy chỉnh trong hệ thống Enchanting).
    }
}

return Item