-- File: Shared/Constants/ItemData/Items/...


local Template = require(game.ReplicatedStorage.Shared.Components.ItemTemplate)

-- 2. Gán Type cho biến Item
local Item: Template.ItemTemplate = {
	Description = "A basic iron sword.",
	Rarity = "Common",

	ItemType = "Weapon",
	EquipmentSlot = "MainHand",
	Type = "Sword",

	Requirements = {
		Level = 1,
	},

	BaseStats = {
		Damage = 7,
		AttackSpeed = 1.2,
		TurnSpeedWeight = 5,
	},

	MaxUpgrades = 5,
	MaxEnchants = 2,
	MaxGems = 1,

	BuyPrice = 250,
	SellPrice = 100,
	BindType = "Tradeable",
	IsImportant = false,

	DismantleExp = 10,
	DismantleDrops = {
		{ Id = "IronChunk", Min = 1, Max = 3, Chance = 0.8 },
		{ Id = "BrokenHilt", Min = 1, Max = 1, Chance = 1.0 }
	}
}

return Item