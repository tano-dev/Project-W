-- File: Shared/Constants/ItemData/Materials/AngelsTear.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)

local Item: Stackable.StackableTemplate = {
    Description = "Ban phước cho vũ khí một lớp bảo hộ tuyệt đối, giúp nó không bị phá hủy trong 1 lần ép xịt tiếp theo. Nhưng nếu việc ban phước thất bại, vũ khí sẽ tan biến.",
    Rarity = "Legendary",
    ItemType = "Material",
    MaxStack = 10,
    
    UpgradeLogic = {
        AcceptTypes = {"Weapon", "Armor"},
        UpgradeCountCost = 0,
        BaseSuccessRate = 0.3, -- Chỉ 30% thành công

        Conditions = {
            -- Chỉ những vũ khí chưa từng ép (Reforge = 0) mới được buff tỉ lệ
            { Type = "NotUpgraded", BonusRate = 0.2 }, 
        },

        SuccessPool = {
            {
                Weight = 100,
                ApplyStates = {"AntiNuke"}, -- Thêm bùa chú vào ItemData.State
                Message = "Thánh thần đã mỉm cười! Vũ khí của bạn giờ đây đã được bảo hộ.",
                MessageColor = Color3.fromRGB(255, 255, 0),
            }
        },

        FailPool = {
            {
                Weight = 100,
                SpecialEffects = {"DestroyItem"}, -- Gọi lệnh Hủy Diệt
                Message = "Bạn đã chọc giận Thần Linh. Món đồ đã tan thành mây khói...",
                MessageColor = Color3.fromRGB(0, 0, 0),
            }
        }
    }
}

return Item