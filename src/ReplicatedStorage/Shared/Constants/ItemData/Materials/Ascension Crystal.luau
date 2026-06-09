-- File: Shared/Constants/ItemData/Materials/AscensionCore.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
    Description = "Thăng cấp phẩm chất (Rarity) của món đồ lên một bậc. Yêu cầu vũ khí phải có độ tinh khiết cao.",
    Rarity = "Mythic",
    ItemType = "Material",
    MaxStack = 5,
    
    UpgradeLogic = {
        AcceptTypes = {"Weapon"},
        UpgradeCountCost = 0,
        BaseSuccessRate = 0.05, -- Chỉ 5% thành công cơ bản

        Conditions = {
            -- Bắt buộc phải có Purity cao để ép. Ví dụ Purity 10 = +50% tỉ lệ
            { Type = "Purity", RatePerPoint = 0.05, MaxCap = 0.8 },
            -- Corruption càng cao càng dễ xịt
            { Type = "Corruption", RatePerPoint = -0.1, MaxCap = -0.5 }
        },

        SuccessPool = {
            {
                Weight = 100,
                SpecialEffects = {"UpRarity"}, -- Tự động tăng NBT.Rarity
                StatPools = {
                    -- Thưởng thêm dòng sát thương ngẫu nhiên khủng
                    { StatName = "Damage", Min = 50, Max = 100, Weight = 100 }
                },
                Message = "MÓN ĐỒ CỦA BẠN ĐÃ ĐỘT PHÁ CẢNH GIỚI CAO HƠN!",
                MessageColor = Color3.fromRGB(255, 0, 255),
            }
        },

        FailPool = {
            {
                Weight = 50,
                Message = "Đột phá thất bại. Lõi năng lượng đã cạn kiệt.",
                MessageColor = Color3.fromRGB(150, 150, 150),
            },
            {
                Weight = 50,
                SpecialEffects = {"ResetPurity"}, -- Phạt nặng: Mất trắng điểm tinh khiết
                Message = "Đột phá thất bại! Lực lượng dội ngược làm mất toàn bộ độ Tinh Khiết của vũ khí!",
                MessageColor = Color3.fromRGB(255, 0, 0),
            }
        }
    }
}

return Item