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
		Attribute = nil, -- Lấy đồ trung tính
		Tokens = 1,
		Luck = 0,
		Modifiers = {
			MinRarity = "Epic", -- Nếu vũ khí đã max hết đồ Epic, Legendary, Mythic thì đập sẽ báo lỗi và không tốn Rune.
		},
	},
}

return Item
