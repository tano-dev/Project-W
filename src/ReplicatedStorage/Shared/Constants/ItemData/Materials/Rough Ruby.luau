-- File: Shared/Constants/ItemData/Materials/Rough Ruby.luau
local Stackable = require(game.ReplicatedStorage.Shared.Components.StackableTemplate)


local Item: Stackable.StackableTemplate = {
    Description = "Viên hồng ngọc hoàn mỹ. Gắn vào Vũ khí tăng Sát Thương, gắn vào Giáp tăng Máu.",
    Rarity = "Epic",
    ItemType = "Material",
    MaxStack = 99,

    -- TÍNH NĂNG KHẢM NGỌC
    GemLogic = {
        AcceptTypes = {"Weapon", "Armor"},
        Modifiers = {
            -- Dòng 1: Tăng sát thương (Scale theo Level vũ khí, buff thêm nếu vũ khí xịn)
            {
                StatName = "Damage",
                BaseValue = 5,
                RarityMultipliers = {
                    Epic = 1.2,       -- Vũ khí tím: Ngọc mạnh lên 20%
                    Legendary = 1.5,  -- Vũ khí cam: Ngọc mạnh lên 50%
                },
                MaxCap = 100, -- Dù vũ khí cấp 999 thì viên ngọc này cũng chỉ cho tối đa 100 Sát thương
            },
            -- Dòng 2: Tăng xíu Máu (Cứng, không scale)
            {
                StatName = "MaxHealth",
                BaseValue = 50,
            }
        },
        IsFragile = false, -- Tháo ra không bị mất
    }
}

return Item