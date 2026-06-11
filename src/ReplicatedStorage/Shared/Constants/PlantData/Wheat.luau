-- File: Shared/Constants/PlantDatabase/Wheat.luau
local PlantTemplate = require(game.ReplicatedStorage.Shared.Components.PlantTemplate)
local Plant : PlantTemplate.PlantTemplate = {
    Description = "Cây lương thực cơ bản, mọc rất nhanh.",
    Rarity = "Common",
    
    Type = "Crops", -- [QUAN TRỌNG]: Quyết định khu vực trồng
    
    GrowthTime = 60,
    Stages = 4,
    HarvestBehavior = nil,
    HarvestYield = {
        { Id = "Wheat", Min = 2, Max = 4, Chance = 1.0 },
        { Id = "Wheat Seed", Min = 1, Max = 2, Chance = 0.5 }
    },
    FarmingExp = 10,
    IconID = "rbxassetid://00000000"
}

return Plant