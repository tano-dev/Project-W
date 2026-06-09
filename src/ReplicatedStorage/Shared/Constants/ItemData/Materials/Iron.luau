-- File: Shared/Constants/ItemData/Materials/PureIron.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
	Description = "Một khối sắt đã được rèn giũa cẩn thận, loại bỏ mọi tạp chất. Dùng để chế tạo hoặc nâng cấp vũ khí.",
	Rarity = "Uncommon",

	ItemType = "Material",
	MaxStack = 999, -- Xếp chồng thoải mái

	BuyPrice = 50,
	SellPrice = 15,
	BindType = "Tradeable",
	IsImportant = false,
	ConsumeOnUse = false, -- Bấm dùng không có tác dụng

	DismantleExp = 2,
	-- Rã cục sắt xịn này ra sẽ nhận lại 2-4 cục sắt vụn
	DismantleDrops = {
		{ Id = "IronChunk", Min = 2, Max = 4, Chance = 1.0 } 
	}
}

return Item