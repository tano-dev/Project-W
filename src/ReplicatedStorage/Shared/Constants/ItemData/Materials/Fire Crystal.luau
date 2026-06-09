-- File: Shared/Constants/ItemData/Materials/BlazingFireCrystal.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
	Name = "Tinh Thể Lửa Rực Cháy",
	Description = "Bộc phát sức mạnh của rồng lửa. Có thể yểm sát thương Lửa vào vũ khí, nhưng nếu thất bại có thể làm hỏng trạng thái của vũ khí.",
	Rarity = "Epic",

	ItemType = "Material",
	MaxStack = 99,

	BuyPrice = 10000,
	SellPrice = 2500,
	BindType = "Tradeable",
	IsImportant = true,
	ConsumeOnUse = true,

	-- ⚙️ THUẬT TOÁN GACHA NÂNG CẤP
	UpgradeLogic = {
		AcceptTypes = {"Weapon"}, -- Chỉ cho phép đập vào Vũ khí
		UpgradeCountCost = 1,     -- Tốn 1 slot nâng cấp của vũ khí

		BaseSuccessRate = 0.6,    -- Mặc định 60% thành công

		Conditions = {
			-- Vũ khí càng "Tinh khiết" thì tỉ lệ thành công càng cao (Cộng tối đa 20%)
			{ StatName = "Purity", RatePerPoint = 0.05, MaxCap = 0.2 },
		},

		-- 🎯 KẾT QUẢ NẾU ĐẬP THÀNH CÔNG (Roll bằng Weight)
		SuccessPool = {
			-- Kịch bản 1: Cực xịn (Weight 10)
			{
				Weight = 10,
				StatPools = {
					{ StatName = "MagicDamage", Min = 20, Max = 50, Weight = 100 },
					{ StatName = "Damage", Min = 5, Max = 15, Weight = 50 }
				},
				Message = "Tuyệt vời! Vũ khí của bạn đang rực cháy một cách điên cuồng!",
				MessageColor = Color3.fromRGB(255, 100, 0),
			},
			-- Kịch bản 2: Tầm trung (Weight 90)
			{
				Weight = 90,
				StatPools = {
					{ StatName = "MagicDamage", Min = 5, Max = 15, Weight = 100 },
				},
				Message = "Vũ khí đã được hấp thụ tinh hoa của lửa.",
				MessageColor = Color3.fromRGB(255, 150, 50),
			}
		},

		-- 🎯 KẾT QUẢ NẾU ĐẬP XỊT (Roll bằng Weight)
		FailPool = {
			-- Xịt bình thường (Weight 80)
			{
				Weight = 80,
				Message = "Nâng cấp thất bại, tinh thể đã vỡ vụn.",
				MessageColor = Color3.fromRGB(150, 150, 150),
			},
			-- Xịt thảm họa (Weight 20) -> Phạt tăng độ tha hóa của vũ khí
			{
				Weight = 20,
				SpecialEffects = {"IncreaseCorruption"}, 
				Message = "Thảm họa! Năng lượng lửa mất kiểm soát và làm vấy bẩn vũ khí của bạn!",
				MessageColor = Color3.fromRGB(255, 0, 0),
			}
		}
	}
}

return Item