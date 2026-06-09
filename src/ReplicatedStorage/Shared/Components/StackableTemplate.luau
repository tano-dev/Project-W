-- File: Shared/Components/StackableTemplateTypes.luau

-- Lấy Type từ các file khác vào (Importing)
local ItemTemplate = require(game.ReplicatedStorage.Shared.Components.ItemTemplate)
local UpgradeTemplate = require(game.ReplicatedStorage.Shared.Components.UpgradeTemplate) -- [MỚI] Gọi file Upgrade xịn vào đây!

-- 1. Khuôn mẫu cho Hiệu ứng tiêu hao (Bình máu, Buff)
export type ConsumableEffect = {
	Action: "Heal" | "RestoreMana" | "BuffStat" | "Cleanse",
	TargetStat: string?, 
	Amount: number,
	Duration: number?,
}

-- CHÚ Ý: Đã xóa toàn bộ UpgradeCondition, StatRoll, UpgradeLogic cũ ở đây để tránh trùng lặp!

-- 2. Khuôn mẫu Chính cho Vật phẩm
export type StackableTemplate = {
	Name: string,
	Description: string,
	Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic",

	ItemType: "Consumable" | "Material",
	MaxStack: number,

	BuyPrice: number?,
	SellPrice: number,
	BindType: "Tradeable" | "BindOnPickup" | "BindOnEquip",
	IsImportant: boolean,
	ConsumeOnUse: boolean,

	DismantleExp: number?,
	DismantleDrops: {ItemTemplate.DismantleDropItem}?,

	-- Nhánh 1: Dành cho Consumable
	Effects: {ConsumableEffect}?,

	-- Nhánh 2: Dành cho Material nâng cấp
	-- Sử dụng Type UpgradeLogic từ file UpgradeTypes.luau
	UpgradeLogic: UpgradeTemplate.UpgradeLogic?, 
}

return {}