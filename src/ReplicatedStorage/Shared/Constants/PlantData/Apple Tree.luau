-- File: Shared/Constants/PlantData/Apple Tree.luau
local PlantTemplate = require(game.ReplicatedStorage.Shared.Components.PlantTemplate)
local Plant : PlantTemplate.PlantTemplate = {
    Description = "Mất thời gian dài để lớn, nhưng cho quả liên tục.",
    Rarity = "Uncommon",
    
    Type = "Trees", -- [QUAN TRỌNG]: Quyết định khu vực trồng
    
    GrowthTime = 300, 
    Stages = 5,
    HarvestBehavior = {
        HarvestTimes = nil,         
        RepeatInterval = 120, 
    },
    HarvestYield = {
        { Id = "Apple", Min = 3, Max = 6, Chance = 1.0 },
        { Id = "Golden Apple", Min = 1, Max = 1, Chance = 0.05 } 
    },
    FarmingExp = 50,
    IconID = "rbxassetid://00000000"
}
return Plant