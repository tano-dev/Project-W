-- File: Shared/Constants/ItemData/Consumables/ElixirOfLife.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
	Description = "Bình thuốc phát sáng rực rỡ. Hồi phục một lượng lớn Máu và cường hóa Tốc độ đánh trong thời gian ngắn.",
	Rarity = "Rare",

	ItemType = "Consumable",
	MaxStack = 99,

	BuyPrice = 1500,
	SellPrice = 300,
	BindType = "Tradeable",
	IsImportant = false,
	ConsumeOnUse = true, -- Bấm dùng xong sẽ mất 1 bình

	-- LOGIC CHO BÌNH THUỐC
	Effects = {
		{
			Action = "Heal",
			TargetStat = "Health",
			Amount = 500 -- Hồi 500 Máu
		},
		{
			Action = "BuffStat",
			TargetStat = "AttackSpeed",
			Amount = 0.5, -- Cộng 50% Tốc đánh
			Duration = 30 -- Kéo dài 30 giây (hoặc 30 Turn)
		}
	}
}

return Item