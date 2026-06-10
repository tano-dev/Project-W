-- File: Shared/Constants/ItemData/Items/...


local Template = require(game.ReplicatedStorage.Shared.Components.ItemTemplate)

-- 2. Gán Type cho biến Item
local Item: Template.ItemTemplate = {
	Description = "A basic steel sword.",
	Rarity = "Common",

	ItemType = "Weapon",
	EquipmentSlot = "MainHand",
	Type = "Sword",

	Requirements = {
		Level = 1,
	},

	BaseStats = {
		Damage = 7,
	},

	MaxUpgrades = 5,
	MaxEnchants = 2,
	MaxGems = 2,

	BuyPrice = 250,
	SellPrice = 100,
	BindType = "Tradeable",
	IsImportant = false,

	DismantleExp = 10,
	DismantleDrops = {
        -- Luôn rớt 1 đến 2 miếng thép (100% ra)
        { Id = "Steel Ingot", Min = 1, Max = 2, Chance = 1.0 }, 
        
        -- Rớt lại cán gỗ (50% ra)
        { Id = "Wood", Min = 1, Max = 3, Chance = 0.5 },
        
        -- Lối chơi thú vị: Rã kiếm tỉ lệ 10% ra được ĐÁ MÀI (Vật phẩm hiếm)
        { Id = "Sharpening Stone", Min = 1, Max = 1, Chance = 0.1 },
    }
}

return Item