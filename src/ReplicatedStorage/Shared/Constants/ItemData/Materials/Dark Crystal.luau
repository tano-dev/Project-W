-- File: Shared/Constants/ItemData/Materials/Shadow Shard.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
    Description = "Mảnh vỡ từ chiều không gian tối. Sức mạnh của nó cực kỳ bất ổn — thành công mang lại sức mạnh vượt trội, thất bại có thể hủy hoại vũ khí.",
    Rarity = "Epic",
    ItemType = "Material",
    MaxStack = 30,

    BuyPrice = 5000,
    SellPrice = 1200,
    BindType = "Tradeable",
    IsImportant = true,
    ConsumeOnUse = true,

    UpgradeLogic = {
        AcceptTypes = {"Weapon"},
        UpgradeCountCost = 1,
        BaseSuccessRate = 0.45, -- 45% cơ bản, khá thấp

        Conditions = {
            -- Corruption càng cao càng dễ thành công (Thuận chiều bóng tối)
            { Type = "Corruption", RatePerPoint = 0.04, MaxCap = 0.25 },
            -- Purity cao lại giảm tỉ lệ (Xung đột năng lượng)
            { Type = "Purity", RatePerPoint = -0.03, MaxCap = -0.15 },
        },

        SuccessPool = {
            -- Kịch bản S: Cộng sát thương + LifeSteal (Hiếm, weight thấp)
            {
                Weight = 15,
                Rolls = 2,
                StatPools = {
                    { StatName = "Damage",    Min = 25, Max = 50, Weight = 0 }, -- Weight 0 = CHẮC CHẮN có
                    { StatName = "LifeSteal", Min = 3,  Max = 8,  Weight = 60 },
                    { StatName = "CritChance",Min = 2,  Max = 5,  Weight = 40 },
                },
                Message = "Bóng tối thức tỉnh! Vũ khí hút lấy sinh khí từ kẻ thù!",
                MessageColor = Color3.fromRGB(80, 0, 200),
            },
            -- Kịch bản A: Chỉ cộng Damage thuần
            {
                Weight = 85,
                Rolls = 1,
                StatPools = {
                    { StatName = "Damage",     Min = 10, Max = 30, Weight = 70 },
                    { StatName = "TrueDamage", Min = 5,  Max = 15, Weight = 30 },
                },
                Message = "Bóng tối thẩm thấu vào lưỡi kiếm.",
                MessageColor = Color3.fromRGB(120, 0, 255),
            },

            -- Kịch bản ALL: tất cả các chỉ số 
                        {
                Weight = 85,
                Rolls = 0, -- Nhận tất cả các chỉ số trong pool
                StatPools = {
                    { StatName = "Damage",     Min = 10, Max = 30, Weight = 70 },
                    { StatName = "Strength", Min = 1,  Max = 3, Weight = 30 },
                    { StatName = "Intelligence", Min = 1,  Max = 3, Weight = 30 },
                    { StatName = "Vitality", Min = 1,  Max = 3, Weight = 30 },
                    { StatName = "Dexterity", Min = 1,  Max = 3, Weight = 30 },
                },
                Message = "Bóng tối thẩm thấu vào lưỡi kiếm.",
                MessageColor = Color3.fromRGB(120, 0, 255),
            },
        },

        FailPool = {
            -- Xịt thường: Mất Purity
            {
                Weight = 60,
                StatPools = {
                    { StatName = "Purity", Min = -4, Max = -1, Weight = 100 },
                },
                Message = "Năng lượng bóng tối phản lại, làm vẩn đục vũ khí.",
                MessageColor = Color3.fromRGB(80, 80, 80),
            },
            -- Xịt thảm: Tăng Corruption + mất Purity
            {
                Weight = 30,
                StatPools = {
                    { StatName = "Corruption", Min = 2, Max = 5, Weight = 100 },
                    { StatName = "Purity",     Min = -3, Max = -1, Weight = 100 },
                },
                Message = "Hỗn loạn! Vũ khí bị tha hóa bởi bóng tối!",
                MessageColor = Color3.fromRGB(150, 0, 0),
            },
            -- Xịt hủy diệt: Phá đồ (chỉ 10%)
            {
                Weight = 10,
                SpecialEffects = {"DestroyItem"},
                Message = "Bóng tối nuốt chửng vũ khí của bạn... Nó biến mất trong màn đêm vĩnh cửu.",
                MessageColor = Color3.fromRGB(0, 0, 0),
            },
        },
    },
}

return Item