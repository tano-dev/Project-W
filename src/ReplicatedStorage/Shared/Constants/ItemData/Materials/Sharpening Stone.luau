-- File: Shared/Constants/ItemData/Materials/Stone.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
	Description = "A sharp stone used for sharpening weapons.",
	Rarity = "Uncommon",
	
	ItemType = "Gemstone",
	MaxStack = 9999, -- Xếp chồng thoải mái

	BuyPrice = 50,
	SellPrice = 15,
	BindType = "Tradeable",
	IsImportant = false,
	ConsumeOnUse = false, -- Bấm dùng không có tác dụng


	-- TÍNH NĂNG KHẢM NGỌC
    GemLogic = {
        AcceptTypes = {"Weapon"},
        Modifiers = {
            -- Dòng 1: Tăng sát thương (Scale theo Level vũ khí, buff thêm nếu vũ khí xịn)
            {
                StatName = "Damage",
                BaseValue = 1,
			},
        },
        IsFragile = false, -- Tháo ra không bị mất
    }
}

return Item