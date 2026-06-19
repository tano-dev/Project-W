-- File: Server/Constants/ProfileTemplate.luau

local PROFILE_TEMPLATE = {
	-- 1. TỔNG QUAN VĨNH VIỄN (Core Stats)
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
		Shard = 0, -- Tiền tệ cao cấp hoặc tài nguyên nâng cấp vĩnh viễn
	},

	-- 3. CHỈ SỐ CHIẾN ĐẤU CỦA CHÍNH NGƯỜI CHƠI (Player Attributes)
	Attributes = {
		UnspentPoints = 0,
		Strength = 0,
		Intelligence = 0,
		Dexterity = 0,
		Vitality = 0,
		Looting = 0,
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
	},

	-- 5. HỆ PHÁI CỦA NGƯỜI CHƠI (Player Classes)
	Classes = {
		SelectedClass = "Adventurer",
		Levels = {
			Adventurer = 0,
			Warrior = 0,
			Hunter = 0,
			Mage = 0,
		},
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

	-- 7. KHO ĐỒ TỔNG (Vĩnh viễn)
	Inventories = {
		Items = {}, -- Lưu Vũ khí, Giáp, Phụ kiện bằng UUID
		Consumables = {}, -- Lưu Bình máu, thuốc lắc bằng ID gộp
		Materials = {}, -- Lưu Quặng, gỗ, nguyên liệu chế tạo
	},

	-- =========================================================================
	-- [MỚI] 10. HỆ THỐNG ĐỒNG HÀNH & ĐỘI HÌNH CHƠI SOLO (Companions & Party System)
	-- Giúp cấu hình chỉ số, cấp độ và trang bị riêng cho các NPC khi chơi một mình
	-- =========================================================================
	Companions = {
		-- Ví dụ cấu trúc dữ liệu của 1 NPC Đồng Hành được mở khóa:
		["NPC_1"] = {
			Unlocked = true, -- Cờ kiểm tra xem đã mở khóa NPC này chưa
			Class = nil, -- Lưu lớp nhân vật của NPC này (VD: "Warrior") để áp dụng hệ thống kỹ năng phù hợp
			Exp = 0,
			Equipped = { Weapon = nil, Offhand = nil, Helmet = nil, Chestplate = nil, Boots = nil },
			Attributes = { -- Chỉ số chiến đấu riêng của NPC Đồng Hành này (tỉ lệ tăng trưởng có thể khác với người chơi chính)
				UnspentPoints = 0,
				Strength = 0,
				Intelligence = 0,
				Dexterity = 0,
				Vitality = 0,
				Looting = 0,
			},

			Skills = {}, -- Bộ kỹ năng chủ động được chọn
		},
		["NPC_2"] = {
			Unlocked = false, -- Cờ kiểm tra xem đã mở khóa NPC này chưa
			Class = nil, -- Lưu lớp nhân vật của NPC này (VD: "Mage") để áp dụng hệ thống kỹ năng phù hợp
			Exp = 0,
			Equipped = { Weapon = nil, Offhand = nil, Helmet = nil, Chestplate = nil, Boots = nil },
			Attributes = { -- Chỉ số chiến đấu riêng của NPC Đồng Hành này (tỉ lệ tăng trưởng có thể khác với người chơi chính)
				UnspentPoints = 0,
				Strength = 0,
				Intelligence = 0,
				Dexterity = 0,
				Vitality = 0,
				Looting = 0,
			},

			Skills = {}, -- Bộ kỹ năng chủ động được chọn
		},
		["NPC_3"] = {
			Unlocked = false, -- Cờ kiểm tra xem đã mở khóa NPC này chưa
			Class = nil, -- Lưu lớp nhân vật của NPC này (VD: "Hunter") để áp dụng hệ thống kỹ năng phù hợp
			Exp = 0,
			Equipped = { Weapon = nil, Offhand = nil, Helmet = nil, Chestplate = nil, Boots = nil },
			Attributes = { -- Chỉ số chiến đấu riêng của NPC Đồng Hành này (tỉ lệ tăng trưởng có thể khác với người chơi chính)
				UnspentPoints = 0,
				Strength = 0,
				Intelligence = 0,
				Dexterity = 0,
				Vitality = 0,
				Looting = 0,
			},

			Skills = {}, -- Bộ kỹ năng chủ động được chọn
		},
	},

	-- Thiết lập đội hình xuất phát vĩnh viễn của bạn (Tối đa 4 slot)
	-- Slot 1 luôn là chính bạn ("Player"). Slot 2,3,4 có thể điền ID của NPC Companion.
	-- Khi đi với bạn bè (Multiplayer), Slot 2,3,4 sẽ bị ghi đè bởi dữ liệu của người chơi khác.
	SavedPartyLayout = {
		Slot1 = "Player", -- Luôn luôn là chủ phòng
		Slot2 = nil, -- Tên ID của NPC Companion 1 (Hoặc nil nếu trống)
		Slot3 = nil, -- NPC Companion 2
		Slot4 = nil, -- NPC Companion 3
	},
	-- 8. TRANG BỊ MẶC ĐỊNH KHI Ở LÀNG (Thế giới ngoài hầm ngục) và áp dụng cho bản thân người chơi trong hầm ngục (Không áp dụng cho Companion)
	Equipped = {
		Weapon = nil,
		Offhand = nil,
		Helmet = nil,
		Armor = nil,
		Boots = nil,
	},
	Tool = {
		Pickaxe = nil,
		Axe = nil,
		FishingRod = nil,
	},
	-- =========================================================================
	-- [MỚI] 11. HỆ THỐNG LOADOUT TRƯỚC KHI VÀO HẦM NGỤC (Expedition Pre-Loadout)
	-- Giống Expedition 33, chuẩn bị hành trang giới hạn trước khi bấm "Vào hầm ngục"
	-- =========================================================================
	DungeonLoadout = {
		-- Lưu danh sách UUID các món Consumables mang theo (Giới hạn X ô, ví dụ tối đa 5 ô)
		-- Việc giới hạn X ô này sẽ được check bằng logic code ở Server hệ thống Inventory/Dungeon
		ConsumableSlots = {
			[1] = nil,
			[2] = nil,
			[3] = nil,
			[4] = nil,
			[5] = nil,
		},
		-- Kỹ năng chủ động mang theo vào hầm ngục của riêng Người chơi (Chọn X trong tổng số kỹ năng học được)
		SelectedSkills = { "PerfectParry", "Slash", "CounterAttack" },
	},

	-- =========================================================================
	-- [MỚI] 12. TIẾN TRÌNH HẦM NGỤC HIỆN TẠI (Active Roguelike Run State)
	-- Lưu trạng thái thời gian thực của màn chơi (Giống Slay the Spire 2)
	-- Nếu người chơi thoát trận, crash, hoặc tắt game, họ sẽ không bị mất tiến trình hầm ngục.
	-- =========================================================================
	ActiveRun = {
		InRun = false, -- Cờ kiểm tra xem có đang trong Dungeon không
		DungeonId = "", -- ID của hầm ngục (VD: "Volcanic_Castle")
		Seed = 0, -- Seed RNG để đồng bộ bản đồ, quái vật giữa các người chơi
		CurrentDepth = 1, -- Tầng hiện tại (Floor / Depth)
		CurrentNodeId = "1_1", -- Vị trí ô hiện tại trên cây bản đồ (Node)
		VisitedNodes = {}, -- Nhật ký các Node đã đi qua để vẽ Minimap (Fog of War)

		-- [BỔ SUNG MỚI] BẢN SAO CHÉP ĐỘI HÌNH TRONG TRẬN NÀY (Snapshot)
		-- Hệ thống sẽ Copy từ SavedPartyLayout (nếu đi Solo)
		-- HOẶC điền UserId của bạn bè vào đây (nếu đi Co-op) ngay khoảnh khắc bấm "Start Run"
		ActiveParty = {
			Slot1 = { Type = "Player", Id = "12345678" }, -- UserId của bạn
			Slot2 = { Type = "NPC", Id = "Gustave" }, -- ID của NPC
			Slot3 = { Type = "Player", Id = "87654321" }, -- UserId của bạn bè
			Slot4 = { Type = "Empty", Id = nil },
		},

		RunCurrencies = {
			Gold = 0, -- Tiền xu chỉ dùng trong hầm ngục (Ra ngoài sẽ reset về 0)
			Souls = 0,
		},

		-- Trạng thái sinh tồn thời gian thực của toàn bộ thành viên trong chuyến đi (Tối đa 4 thực thể)
		-- Cần lưu lại vì máu/mana sẽ không tự hồi sau mỗi phòng (Chuẩn Slay the Spire)
		PartyStates = {
			--[[
				["Slot1"] = {
                -- 1. TRẠNG THÁI SINH TỒN (Vitals)
                IsDead = false,
                CurrentHp = 100,
                MaxHp = 100,        -- Lấy từ Attributes + Trang bị trước khi vào Run
                CurrentMana = 50,   -- (Hoặc AP - Action Points)
                MaxMana = 50,
                
                -- 2. CHỈ SỐ CƠ ĐỘNG TRẬN ĐÁNH (Combat Mechanics)
                Shield = 0,         -- Giáp ảo (Block giống Slay the Spire, chặn sát thương). Thường reset về 0 mỗi hiệp, nhưng lưu ở đây nếu có Relic giữ giáp.
                Stagger = 0,        -- Thanh Choáng/Bể thế (Posture - Expedition 33 style). Đầy thanh này sẽ bị choáng hoặc nhận sát thương chí mạng.
                MaxStagger = 100,

                -- 3. HIỆU ỨNG BẤT LỢI (Debuffs / Status Effects)
                -- Dictionary giúp ECS tra cứu siêu nhanh. Lưu số hiệp (Duration) và Độ mạnh (Value).
                StatusEffects = {
                    -- Tí dụ: Bị trúng độc gây 5 HP mỗi hiệp, kéo dài 2 hiệp nữa
                    -- ["Poison"] = { Duration = 2, Value = 5 }, 
                    -- ["Stun"] = { Duration = 1, Value = 0 },
                },

                -- 4. HIỆU ỨNG CÓ LỢI TẠM THỜI (Combat Buffs)
                -- Khác với DraftedBuffs (tồn tại cả Run), Buff này chỉ tồn tại vài lượt trong combat.
                TemporaryBuffs = {
                    -- Ví dụ: Bơm thuốc tăng 20% sát thương trong 3 hiệp
                    -- ["AttackUp"] = { Duration = 3, Value = 0.2 }, 
                },

                -- 5. LƯU TRỮ HỒI CHIÊU (Skill Cooldowns)
                -- Cực kỳ quan trọng: Mang Cooldown từ phòng chiến đấu này sang phòng chiến đấu khác!
                Cooldowns = {
                    -- Ví dụ: Đánh xong phòng 1, chiêu cuối vẫn còn 2 lượt CD. Sang phòng 2 phải đợi 2 lượt mới được xài.
                    -- ["UltimateSlash"] = 2, 
                    -- ["PerfectParry"] = 0, 
                }
            },
            
            -- Slot2, Slot3, Slot4 sẽ có cấu trúc y hệt (Chép từ Template của Companions hoặc đồng đội)
            ["Slot2"] = nil,
            ["Slot3"] = nil,
            ["Slot4"] = nil,
			
			]]--,
		},

		-- Các Chúc phúc / Nguyền rủa (Boon / Curse / Relic) nhặt được TRONG RIÊNG RUN NÀY
		DraftedBuffs = {
			-- { Id = "Fire_Boon_01", Stacks = 1 },
			-- { Id = "Stunt_Double", Stacks = 2 }
		},
		-- [BỔ SUNG QUAN TRỌNG CHO VIỆC RECONNECT]
		ReservedServerCode = "", -- Mã server riêng mà họ đang chơi
		IsMultiplayer = false, -- Xác định xem đây là phòng Solo hay Co-op
		-- [MỚI] Mã định danh ĐỘC NHẤT của chuyến đi này trên toàn Server
		RunInstanceId = "", -- Ví dụ: "Run_Volcanic_88A7B2"
	},

	-- 13. HỆ THỐNG MỞ RỘNG KHÁC (Misc)
	Bank = {},
	Land = {},
	Quests = { Active = {}, Completed = {} },
	Farming = { Crops = {}, Trees = {} },
	ShopHistory = {},
}

return PROFILE_TEMPLATE
