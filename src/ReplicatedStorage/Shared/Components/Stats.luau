-- File: Shared/Constants/StatDefinitions.luau

-- 1. Định nghĩa các thông số theo từng NHÓM (Dùng Mảng / Array)
-- Thứ tự bạn viết ở đây chính là thứ tự hiển thị trên UI.
local StatCategories = {
	Combat = {
		"Health",
		"HealthRegenRate",
		"Mana",
		"ManaRegenRate",
		"HealingAmplification",
		"LifeSteal",            -- [MỚI] Hút máu
		-- Sát thương
		"Damage",
		"RangedDamage",
		"MagicDamage",
		"TrueDamage",
		"ArmorPenetration",     -- [MỚI] Xuyên giáp vật lý
		"MagicPenetration",     -- [MỚI] Xuyên kháng phép
		"CritChance",
		"CritDamage",
		"AttackSpeed",
		"Ferocity",
		-- Phòng thủ
		"Defense",
		"RangedDefense",
		"MagicDefense",
		"TrueDefense",
		"CritResistance",       -- [SỬA] Kháng sát thương bạo kích
		"DamageReduction",
	},
	TurnBased = {
		"ActionTurn",
		"ActionBonusRate",
		"Speed",
		"Jump",
		"DodgeChance",
		"MissChance",
		"Aggro",                -- [MỚI] Độ thù hận (Dụ quái đánh mình)
		"Tenacity",             -- [MỚI] Kháng choáng/đóng băng
	},
	ReflexAndQTE = {            -- [NHÓM MỚI] Dành riêng cho cơ chế Clair Obscur
		"ParryWindow",          -- Tăng thời gian (mili-giây) hiển thị nút đỡ đòn
		"ParryDamage",          -- Sát thương gây ra khi Perfect Parry
		"DodgeWindow",
		"CounterChance",        -- Tỉ lệ tự động phản công sau khi né/đỡ
	},
	Attributes = {
		"Strength",
		"Dexterity",
		"Intelligence",
		"Vitality",
		"Proficiency",
		"Looting"
	},
	Experience = {
		"ClassExp",
		"ProfessionExp",
		"SpellExp",
	},
	Utility = {
		"Luck",
		"BonusCoins",
		"MovementSpeed",        -- [MỚI] Tốc độ chạy trên bản đồ (rất cần cho Roguelike)
	},
	-- Các nhóm Nghề nghiệp
	Mining = {
		"MiningSpeed",
		"MiningPower",
		"MiningFortune",
		"MiningPristine",
	},
	Farming = {
		"HarvestSpeed",
		"FarmingFortune",
		"FarmingPristine",
	},
	Foraging = {
		"CuttingSpeed",
		"CuttingPower",
		"ForagingFortune",
		"ForagingPristine",
	},
	Fishing = {
		"ReelingSpeed",
		"ReelingPower",
		"Lure",
		"RareFishChance",
		"TreasureChance"
	},
	Alchemy = {
		"CookingSpeed",
		"Duration",
		"Effectiveness",
	},
	Gemcrafting = {
		"Refinery",
		"GemPower",
		"GemChance",
	},
	Enchanting = {
		"RareEnchantChance",
		"EnchantCost"
	},
	Crafting = {
		"CraftingCost",
		"DismantlingCost",
		"UpgradeCost"
	}
}


-- 2. Tự động chuyển đổi thành Dictionary cho hệ thống đọc O(1)
local StatsPriority = {}
local currentGlobalPriority = 1

for categoryName, statsList in StatCategories do
	for index, statName in ipairs(statsList) do
		StatsPriority[statName] = {
			GlobalPriority = currentGlobalPriority, -- Thứ tự tổng thể từ 1 -> 59
			LocalPriority = index,                  -- Thứ tự trong nhóm
			Category = categoryName                 -- Nhóm chứa nó (Combat, Mining, Utility...)
		}
		currentGlobalPriority += 1
	end
end

-- 3. Trả về module với các hàm tiện ích
local StatService = {}

-- Trả về toàn bộ từ điển nếu cần tra cứu trực tiếp
StatService.AllStats = StatsPriority

-- Lấy mức độ ưu tiên để UI sắp xếp (VD: table.sort)
function StatService.GetPriority(statName: string): number
	local statData = StatsPriority[statName]
	return statData and statData.GlobalPriority or 999 
end

-- Lấy nhóm của stat để phân Tab trên UI
function StatService.GetCategory(statName: string): string
	local statData = StatsPriority[statName]
	return statData and statData.Category or "Unknown"
end

-- (Tính năng bổ sung) Lấy toàn bộ Stat của một nhóm cụ thể
function StatService.GetStatsInCategory(categoryName: string): {string}
	return StatCategories[categoryName] or {}
end

return StatService