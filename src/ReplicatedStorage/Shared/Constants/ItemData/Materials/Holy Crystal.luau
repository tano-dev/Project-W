-- File: Shared/Constants/ItemData/Materials/ScrollOfCleansing.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
    Description = "Xóa bỏ mọi chỉ số đã được nâng cấp trước đây, khôi phục lại trạng thái nguyên bản của vũ khí. Không phục hồi số lần ép (UpgradeCount).",
    Rarity = "Rare",
    ItemType = "Material",
    MaxStack = 99,
    
    UpgradeLogic = {
        AcceptTypes = {"All"}, -- Ép được cho mọi loại đồ
        UpgradeCountCost = 0,  -- Tuyệt vời: Dùng bùa này không bị tốn lượt ép
        BaseSuccessRate = 0.8, -- 80% thành công

        Conditions = {
            -- Đồ càng xịn (Rarity cao) thì tẩy càng khó, giảm 5% tỉ lệ cho mỗi cấp Rarity
            { Type = "Rarity", RatePerPoint = -0.05, MaxCap = -0.3 },
        },

        SuccessPool = {
            {
                Weight = 100,
                SpecialEffects = {"ClearOneFailedUpgrade"}, -- Gọi luồng Rollback trong UpgradeSystem
                Message = "Tẩy tủy thành công! Vũ khí của bạn đã trở về trạng thái nguyên bản.",
                MessageColor = Color3.fromRGB(0, 255, 255),
            }
        },

        FailPool = {
            {
                Weight = 100,
                StatPools = {
                    -- Phạt: Giảm độ tinh khiết từ -1 đến -3 điểm
                    { StatName = "Purity", Min = -3, Max = -1, Weight = 100 },
                },
                Message = "Tẩy tủy thất bại! Sức mạnh hỗn loạn làm vũ khí của bạn trở nên đục ngầu.",
                MessageColor = Color3.fromRGB(100, 100, 100),
            }
        }
    }
}

return Item