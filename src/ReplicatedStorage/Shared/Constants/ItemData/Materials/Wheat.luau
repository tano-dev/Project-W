-- File: Shared/Constants/ItemData/Materials/Wheat.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
	Description = "Can be used for Alchemy and crafting. Commonly grown.",
	Rarity = "Common",

	ItemType = "Material",
	MaxStack = 9999, -- Xếp chồng thoải mái

	BuyPrice = 50,
	SellPrice = 15,
	BindType = "Tradeable",
	IsImportant = false,
	ConsumeOnUse = false, -- Bấm dùng không có tác dụng
}

return Item