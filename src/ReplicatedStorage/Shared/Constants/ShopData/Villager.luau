-- File: Shared/Constants/ShopDatabase/Villager.luau
return {
    Name = "Villager",
    Currency = "Coin",
    IsGlobalLimited = false,
    Items = {
        { Id = "Iron Sword", PriceMultiplier = 1 },
        { Id = "Iron Ingot", PriceMultiplier = 1 },
        { Id = "Seed Pack", PriceMultiplier = 1, NBT = { PlantId = "Wheat" } }
    }
}