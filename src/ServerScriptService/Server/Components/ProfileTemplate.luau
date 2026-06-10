-- File: Server/Constants/ProfileTemplate.luau

local PROFILE_TEMPLATE = {
	-- 1. TỔNG QUAN (Core Stats)
	Core = {
		Level = 0,
		Exp = 0,
		Playtime = 0,
		Zone = 0,
		Place = 0,
		Awakened = 0,
	},

	-- 2. TIỀN TỆ (Currencies)
	Currencies = {
		Coin = 0,
		-- Nhóm vào đây giúp dễ viết hàm dùng chung: AddCurrency(player, "Coin", 100)
	},

	-- 3. CHỈ SỐ CHIẾN ĐẤU (Attributes)
	Attributes = {
		UnspentPoints = 0,     -- Thay cho CombatStatPoints và CombatAssignedStatPoints
		Strength = 0,
		Intelligence = 0,
		Dexterity = 0,
		Vitality = 0,
		Looting = 0,
		Proficiency = 0,
	},

	-- 4. KỸ NĂNG NGHỀ (Professions)
	Professions = {
		Combat = 0,
		Farming = 0,
		Foraging = 0,
		Fishing = 0,
		Mining = 0,
		Gemcrafting = 0,
		Crafting = 0,
		Alchemy = 0,
		Enchanting = 0,
		--

	},

	-- 5. HỆ PHÁI (Classes)
	Classes = {
		SelectedClass = "Adventurer", -- Dùng chữ dễ quản lý hơn số 0
		Levels = {
			Adventurer = 0,
			Warrior = 0,
			Hunter = 0,
			Mage = 0,
		}
	},

	-- 6. NGOẠI HÌNH (Appearance)
	Appearance = {
		Hair = 0,
		HairColor = 0,
		Face = 0,
		TorsoSkin = 0,
		ArmSkin = 0,
		LegSkin = 0,
	},

	-- ==========================================
	-- 7. KHO ĐỒ (INVENTORIES) - THAY ĐỔI QUAN TRỌNG NHẤT
	-- Tuyệt đối KHÔNG gán [1] = {}, [2] = {}. Cứ để mảng rỗng. 
	-- Khi nhặt đồ thì dùng table.insert() đẩy dữ liệu ItemData vào.
	-- ==========================================
	Inventories = {
		Items = {},  -- Lưu các cấu trúc ItemData (Vũ khí, Giáp, Phụ kiện)
		Consumables = {}, -- Lưu các cấu trúc StackableData (Bình máu, Thức ăn)
		Materials = {},   -- Lưu các cấu trúc StackableData (Quặng, Gỗ)
	},

	-- ==========================================
	-- 8. TRANG BỊ TRÊN NGƯỜI (EQUIPPED)
	-- Sử dụng tên (Dictionary) thay vì số (Array) để không bao giờ bị lỗi "Gaps"
	-- Lưu UUID của món đồ, thay vì lưu toàn bộ dữ liệu món đồ vào đây.
	-- ==========================================
	Equipped = {
		-- Trạng bị chính
		MainGear = {
			Weapon = nil, Offhand = nil, Tool = nil,
			Helmet = nil, Chestplate = nil, Boots = nil,
			Pet = nil, Aura = nil,
		},
		-- Phụ kiện
		Accessories = {
			Slot1 = nil, Slot2 = nil, Slot3 = nil,
			Slot4 = nil, Slot5 = nil, Slot6 = nil,
			Slot7 = nil, Slot8 = nil, Slot9 = nil,
		},
		-- Dụng cụ nghề nghiệp
		Fishing = { Reel = nil, Float = nil, Bait = nil },
		Ranged = { Arrow = nil, BowString = nil },
		Special = { A = nil, B = nil, C = nil },
	},

	-- 9. HỆ THỐNG MỞ RỘNG (Misc)
	Bank = {},
	Land = {},
	Quests = {
		Active = {},    -- Nhiệm vụ đang làm
		Completed = {}  -- Nhiệm vụ đã xong (Lưu Id để không nhận lại)
	},
}

return PROFILE_TEMPLATE