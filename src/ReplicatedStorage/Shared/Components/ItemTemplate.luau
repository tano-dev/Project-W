-- File: Shared/Types/ItemTemplateTypes.luau

export type DismantleDropItem = {
	Id: string,
	Min: number, -- Nếu Items thì skip
	Max: number, -- Nếu Items thì skip
	Chance: number,
	KeepStats: string?, -- "All" | "None" | "EnchantsOnly"
}

export type ItemTemplate = {
	Description: string,
	Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic",

	ItemType: "Equipment",
	EquipmentSlot: "MainHand" | "OffHand" | "Helmet" | "Chest" | "Legs" | "Accessory",
	WeaponType: string?,

	Requirements: {
		Level: number,
		Classes: {string}?,
		Stats: {[string]: number}?,
	},

	BaseStats: {[string]: number}, -- Đã rút gọn để linh hoạt với file StatDefinitions

	MaxUpgrades: number?,
	MaxEnchants: number?,
	MaxGems: number?,

	BuyPrice: number?,
	SellPrice: number,
	BindType: "Tradeable" | "BindOnPickup" | "BindOnEquip",
	IsImportant: boolean,

	DismantleExp: number?,
	DismantleDrops: {DismantleDropItem}?,
}

return {} -- Trả về bảng rỗng vì file này chỉ dùng để export Type