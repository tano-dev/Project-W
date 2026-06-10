-- File: Shared/Constants/CraftingRecipes.luau
local CraftingRecipes = {
    -- BẠN KHÔNG CẦN GÕ RecipeId BÊN TRONG NỮA
    ["Recipe_IronSword"] = {
        Category = "Weapon",
        Inputs = {
            { Id = "Wood", BaseAmount = 5 },
            { Id = "Iron", BaseAmount = 3 },
        },
        Outputs = {
            { Id = "Iron Sword", Amount = 1 },
        },
        ExpGains = { Crafting = 10 }
    },
    
    ["Recipe_SteelIngot"] = {
        Category = "Material",
        Requirements = {
            Professions = { Crafting = 0 },
        },
        Inputs = {
            { Id = "Iron", BaseAmount = 5 },
            { Id = "Coal", BaseAmount = 2 },
        },
        Outputs = {
            { Id = "Steel Ingot", Amount = 1 },
        },
        ExpGains = { Crafting = 20 }
    },

    ["Recipe_SteelSword"] = {
        Category = "Weapon",
        Requirements = {
            Professions = { Crafting = 5 },
        },
        Inputs = {
            { Id = "Steel Ingot", BaseAmount = 3 },
            { Id = "Wood", BaseAmount = 10 },
        },
        MainIngredient = "Iron Sword", 
        Outputs = {
            { Id = "Steel Sword", Amount = 1 },
        },
        ExpGains = { Crafting = 25 }
    },
}

-- ==========================================
-- [THỦ THUẬT AUTO-MAPPING]
-- Tự động lấy cái Tên Key nhét vào làm biến RecipeId
-- ==========================================
for key, recipeData in pairs(CraftingRecipes) do
    recipeData.RecipeId = key
end

return CraftingRecipes