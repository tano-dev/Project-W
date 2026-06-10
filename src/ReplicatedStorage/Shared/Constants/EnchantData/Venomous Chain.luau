-- File: Shared/Constants/EnchantData/Phantom Strike.luau
local EnchantTemplate = require(game.ReplicatedStorage.Shared.Components.EnchantTemplate)

local Enchant: EnchantTemplate.EnchantTemplate = {
	Description = "Tiêu diệt một kẻ địch đang bị Trúng Độc sẽ kích nổ xác chết, văng độc và gây sát thương lan sang toàn bộ quái vật khác.",
	Rarity = "Epic",
	MaxLevel = 3,
	AcceptTypes = { "Weapon" },
	Attribute = "Dark",
	BaseWeight = 15,
	Conditions = { Enchanting = 0 },
	Effects = {
		OnKill = {
			-- Action 1: Gây sát thương lan
			{
				Target = "Enemy", -- Quái bị giết
				Conditions = {
					{ Type = "TargetHasStatus", Value = "Poison" },
				},
				Action = {
					Type = "AoECleave",
					DamageType = "Magic",
					BaseValue = 30,
					ScaleValue = 20, -- Lv1: Nổ 50 sát thương lan
				},
			},
			-- Action 2: Lây lan trạng thái Độc sang quái khác (Gắn Status)
			{
				Target = "Enemy",
				Conditions = {
					{ Type = "TargetHasStatus", Value = "Poison" },
				},
				Action = {
					Type = "ApplyStatus",
					StatusName = "Poison",
					BaseValue = 1, -- Truyền 1 stack độc
					ScaleValue = 1, -- Tăng số stack độc lây lan theo cấp độ Enchant
				},
			},
		},
	},
}

return Enchant
