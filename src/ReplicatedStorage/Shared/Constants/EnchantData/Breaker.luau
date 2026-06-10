-- File: Shared/Constants/EnchantData/Phantom Strike.luau
local EnchantTemplate = require(game.ReplicatedStorage.Shared.Components.EnchantTemplate)

local Enchant: EnchantTemplate.EnchantTemplate = {
	Description = "Trong hiệp đầu tiên của trận đấu, đòn đánh trúng đích gây thêm sát thương và đánh lùi lượt của mục tiêu.",
	Rarity = "Common",
	MaxLevel = 5,
	AcceptTypes = { "Weapon" },
	Attribute = nil,
	BaseWeight = 150,
	Conditions = { Enchanting = 0 },
	Effects = {
		OnHit = {
			-- Action 1: Gây thêm sát thương
			{
				Target = "Enemy",
				Conditions = {
					{ Type = "IsFirstTurn" }, -- Chỉ kích hoạt ở hiệp 1
				},
				Action = {
					Type = "DealDamage",
					DamageType = "Physical",
					BaseValue = 0,
					ScaleValue = 0.30, -- +30% sát thương đòn đánh mỗi cấp (Lv3 = +90%)
					ScaleWith = "DamageDealt",
				},
			},
			-- Action 2: Đẩy lùi Timeline của quái
			{
				Target = "Enemy",
				Conditions = {
					{ Type = "IsFirstTurn" },
				},
				Action = {
					Type = "DelayTargetTurn",
					BaseValue = 10,
					ScaleValue = 5, -- Lùi 15 đơn vị tốc độ ở Lv1
				},
			},
		},
	},
}

return Enchant
