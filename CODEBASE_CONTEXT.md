# 🤖 CODEBASE CONTEXT FOR AI

**Purpose**: Copy this entire file and paste into Claude for complete project context  
**Updated**: 2026-06-11  
**Status**: Ready to use

---

## 📋 INSTRUCTIONS FOR USING THIS FILE

### **Step 1: Copy everything below**
Select all text from "PROJECT OVERVIEW" to "END OF CONTEXT"

### **Step 2: Paste into Claude**
Open https://claude.ai/chat and paste

### **Step 3: Add your prompt**
After pasting, ask Claude anything like:
- "Add a new Roguelike buff called 'Double Damage'"
- "Create the DungeonGenerator system"
- "How should I implement the MinimapSystem?"
- "Fix this bug in the CombatSystem"

### **Step 4: Claude has full context**
Claude will understand:
- Your entire project structure
- All existing systems & APIs
- Coding patterns & conventions
- What's already implemented vs TODO
- Where to put new code

---

# PROJECT OVERVIEW

**Project Name**: Project W  
**Type**: Roblox Roguelike Dungeon Crawler  
**Status**: Phase 1 (85% complete) → Phase 2 (UI/Roguelike)  
**Language**: Luau (Roblox)  
**Framework**: Matter ECS, Replica, Reflex UI

---

## WHAT'S ALREADY IMPLEMENTED

### Core Systems (Complete ✅)
- **Inventory System**: 3 bags (Items, Materials, Consumables), UUID-based tracking, NBT support
- **Crafting System**: Recipe-based, Profession requirements, Batch crafting
- **Enchanting System**: Token-based, Weighted pools, Rarity scaling
- **Farming System**: Time-based growth, Multi-harvest crops, Seed tracking
- **Shop System**: Buy/sell, Global limits, Time-based restocks
- **Dismantling System**: Stat inheritance, Gacha drops
- **PlayerStats System**: Leveling, Professions, Currency management
- **Combat System**: Turn-based, Damage calculation
- **Inventory System**: Full item management

### Data & Architecture (Complete ✅)
- ProfileStore-based player data persistence
- Replica for real-time data sync
- ItemDatabase with 50+ items
- CraftingRecipes with 20+ recipes
- EnchantData with 6+ enchantments
- PlantData with 2+ crops
- ShopData with 3+ merchants

### Client Infrastructure
- Matter ECS for entity management
- Reflex for UI state management
- Basic input handling

---

## WHAT'S BEING ADDED (Phase 2)

### New Roguelike Systems (TODO 🔄)

**DungeonGenerator Service**
- Procedural generation algorithm
- Weighted room selection (Combat 50%, Treasure 20%, Shop 15%, Boss 5%)
- Difficulty scaling by depth
- Boss placement logic
- Connection generation (doors between rooms)
- Seeded RNG for multiplayer sync

**InstanceManager Service**
- Creates separate Roblox Instance for each player's dungeon
- Manages instance cleanup on dungeon exit
- Prevents player-to-player interference
- Syncs state updates

**RoomSpawnSystem**
- Spawns enemies based on room type
- Creates treasure chests with loot
- Scales mob stats by dungeon depth
- Initializes room state

**StatusSystem**
- Applies damage from Poison/Burn/Stun each turn
- Manages effect duration
- Removes expired effects
- Handles immunity

**LootManager Service**
- Rolls loot based on weighted LootTables
- Supports multiple drops per creature
- Scales rarity by difficulty
- Handles rarity randomization

**DifficultyScaler Service**
- Calculates mob stat multipliers by depth
- Scales loot drop quality
- Adjusts drop rates
- Boss scaling by phase

### New Client Systems (TODO 🔄)

**DungeonVisualSystem**
- Loads room models from Assets/Models/DungeonRooms/
- Assembles rooms in player instance
- Handles room transitions
- Manages door positioning

**MinimapSystem**
- Displays room layout as grid
- Fog of war (unknown rooms hidden)
- Shows current room highlight
- Updates as player explores

**BoonSelect UI**
- Shows 3 random roguelike buffs
- Player selects 1
- Applies buff to character
- Generates next room

### New Components & Data

**Components**
- RoomComponent: Room ID, Biome, Doors
- DoorComponent: Door state, connections
- ChestComponent: Loot, opened state
- RoguelikeBuffComponent: Buff ID, duration, stacks
- StatusEffectComponent: Effect type, duration, stacks

**Constants** (Data files to create)
- MobData/: Goblin, Bandit, Elemental, Boss definitions
- DungeonData/: Biome definitions, Room templates
- LootTables/: Drop rates, RoguelikeBuff definitions
- StatusEffects/: Burn, Poison, Stun, Bleed definitions

---

## PROJECT STRUCTURE

```
src/
├── ReplicatedStorage/Shared/
│   ├── Components/          [Matter] 7 components
│   ├── Constants/           [Data] ItemData, MobData, DungeonData, LootTables, StatusEffects
│   ├── Utilities/           [Libs] Sift, Promise, Llama, Random
│   ├── Assets/              [3D] Models, VFX, Sounds
│   ├── Network/             [Blink] RPC definitions
│   └── UI/                  [Reflex+Fusion] Components, Layouts, State
│
├── ServerScriptService/Server/
│   ├── Systems/             [Matter] 7 systems (Inventory, Combat, Crafting, etc.)
│   ├── Services/            [Core] DungeonGenerator, InstanceManager, DataManager, etc.
│   └── NetworkHandlers/     RPC handlers
│
└── StarterPlayer/Client/
    ├── Systems/             [Matter] DungeonVisualSystem, MinimapSystem, VFXSystem
    ├── Managers/            DungeonManager, BuffManager
    └── UIMount/             Root UI component
```

---

## EXISTING APIs & PATTERNS

### Inventory System
```lua
InventorySystem:GiveItem(player, "Iron Sword") -> UUID
InventorySystem:GiveStackable(player, "Materials", "Iron", 50, customNBT?)
InventorySystem:RemoveStackable(player, "Materials", "Iron", 5, targetNBT?)
InventorySystem:UpdateItemData(player, uuid, newItemData)
InventorySystem:FindItemLocationByUUID(player, uuid) -> location
```

### Crafting System
```lua
CraftingSystem:ProcessCraft(player, recipeId, mainItemIndex?, craftAmount?)
-> { Success: bool, Message: string }
```

### Enchanting System
```lua
EnchantSystem:ProcessEnchant(player, targetItemIndex, runeIndex)
-> { Success: bool, Message: string }

EnchantSystem:DisenchantItem(player, targetItemIndex)
```

### Farming System
```lua
FarmingSystem:PlantSeed(player, seedInvIndex, slotId)
FarmingSystem:HarvestPlant(player, slotId)
FarmingSystem:CalculatePlantState(plantData)
-> (isReady: bool, stage: number, timeLeft: number)
```

### Shop System
```lua
ShopSystem:BuyItem(player, shopId, itemIndex, amount)
ShopSystem:SellItem(player, identifier, amount)
```

### PlayerStats System
```lua
PlayerStatSystem:AddCurrency(player, currencyType, amount)
PlayerStatSystem:RemoveCurrency(player, currencyType, amount)
PlayerStatSystem:AddExp(player, amount)
PlayerStatSystem:AddProfessionExp(player, profName, amount)
```

---

## EXISTING DATA STRUCTURES

### Item Data
```lua
{
  Id = "Iron Sword",
  Name = "Iron Sword",
  Rarity = "Uncommon",
  ItemType = "Weapon",
  Type = "Sword",
  BuyPrice = 100,
  SellPrice = 50,
  MaxEnchants = 5,
  DismantleDrops = { ... }
}
```

### Recipe Data
```lua
["Steel Ingot"] = {
  Inputs = { { Id = "Iron", BaseAmount = 5 } },
  Outputs = { { Id = "Steel Ingot", Amount = 2 } },
  Requirements = { Professions = { Crafting = 10 } },
  ExpGains = { Crafting = 100 }
}
```

### Profile Structure (PlayerData)
```lua
{
  Core = { Level, Exp, Playtime, Zone },
  Currencies = { Coin },
  Attributes = { UnspentPoints, Strength, Intelligence, ... },
  Professions = { Combat, Farming, Crafting, Enchanting, ... },
  Inventories = { Items = {}, Consumables = {}, Materials = {} },
  Equipped = { MainGear = {...}, Accessories = {...} },
  Farming = { Crops = {}, Trees = {} },
  Quests = { Active = {}, Completed = {} }
}
```

---

## CODING CONVENTIONS

### File Organization
- Server Systems in `ServerScriptService/Server/Systems/`
- Server Services in `ServerScriptService/Server/Services/`
- Client Systems in `StarterPlayer/Client/Systems/`
- Constants data in `ReplicatedStorage/Shared/Constants/`
- Components in `ReplicatedStorage/Shared/Components/`

### Naming Conventions
- **Systems**: PascalCase + "System" (e.g., `CombatSystem`, `DungeonVisualSystem`)
- **Services**: PascalCase + "Manager/Service" (e.g., `DungeonGenerator`, `InstanceManager`)
- **Functions**: camelCase (e.g., `spawnEnemy`, `calculateStats`)
- **Constants**: UPPER_CASE (e.g., `MAX_ENCHANTS = 5`)

### Data File Pattern
Each data file returns a table with Id, Name, and properties:
```lua
-- File: MobData/Goblin.luau
return {
  Id = "Goblin",
  Name = "Goblin",
  Health = 30,
  AttackPower = 5,
  ...
}

-- File: init.luau (registers all)
local GoblinData = require(script.Goblin)
return {
  [GoblinData.Id] = GoblinData,
  ...
}
```

### Error Handling Pattern
Returns success tuple:
```lua
function System:DoAction(player, param)
  if not validation then
    return { Success = false, Message = "Error reason" }
  end
  return { Success = true, Message = "Success message" }
end
```

### Deep Copy Pattern
```lua
local function DeepCopyData(data)
  return HttpService:JSONDecode(HttpService:JSONEncode(data))
end
```

### Stacking System Pattern
When adding stackable items, always:
1. Try to fill existing stacks
2. Create new stacks for overflow
3. Check MaxStack from ItemDatabase
4. Match NBT when combining

---

## NEW SYSTEMS TO BUILD (With Examples)

### Example: MobData Definition
```lua
-- File: src/ReplicatedStorage/Shared/Constants/MobData/Goblin.luau
return {
  Id = "Goblin",
  Name = "Goblin",
  Health = 30,
  AttackPower = 5,
  DefensePower = 1,
  Speed = 4,
  
  LootTable = {
    { Id = "Wood", Min = 1, Max = 3, Chance = 0.8 },
    { Id = "Gold", Min = 10, Max = 25, Chance = 1.0 }
  },
  
  DifficultyScaling = {
    HealthPerDepth = 2,
    DamagePerDepth = 0.5
  }
}
```

### Example: RoomData Definition
```lua
-- File: src/ReplicatedStorage/Shared/Constants/DungeonData/Rooms.luau
["CombatRoom_01"] = {
  Id = "CombatRoom_01",
  Type = "Combat",
  Size = "Medium",
  EnemySpawns = {
    { Biome = "Forest", Enemies = {"Goblin", "Goblin"} }
  },
  Connections = { North = "auto", South = "auto" },
  Difficulty = 1.0
}
```

### Example: Roguelike Buff Definition
```lua
-- File: src/ReplicatedStorage/Shared/Constants/LootTables/Buffs.luau
["ExtraHealth"] = {
  Id = "ExtraHealth",
  Name = "+50 Max Health",
  Rarity = "Common",
  Effects = { { Stat = "MaxHealth", Modifier = 50 } },
  Duration = math.huge,
  Stackable = true
}
```

---

## NETWORKING PATTERN (Blink)

### Defining RPC
```lua
-- File: Network/module.luau
Network:DefineRPC("GenerateRoom", function(player, dungeonConfig)
  return ServerService.DungeonGenerator:GenerateRoom(dungeonConfig)
end)

Network:DefineRPC("SelectBuff", function(player, buffId)
  return ServerService.LootManager:ApplyBuff(player, buffId)
end)
```

### Calling RPC (Client)
```lua
Network:InvokeServer("GenerateRoom", { BiomeType = "Forest" }):then(function(result)
  if result.Success then
    print("Room generated:", result.RoomId)
  end
end)
```

---

## TESTING COMMANDS (Chat)

```
/debug                                 -- Show profile
/giveitem "Iron Sword"                -- Add item
/givestackable Wood 50                -- Add material
/craft "Steel Ingot" 1 5              -- Craft item
/enchant 1 1                          -- Enchant
/harvest slot1                        -- Harvest plant
/buy "Villager" 1 5                   -- Buy item
/sell "uuid" 1                        -- Sell item
/addcoin 1000                         -- Add currency
/addprofexp Crafting 500              -- Add profession exp
```

---

## KEY DECISION POINTS FOR NEW SYSTEMS

1. **Dungeon Layout**
   - Use weighted random (50% Combat, 20% Treasure, 20% Shop, 5% Boss)
   - Boss room always at depth 10
   - 15 rooms per dungeon
   - Connected with doors

2. **Difficulty Scaling**
   - Health +10% per depth level
   - Damage +5% per depth level
   - Loot rarity +1 level per 3 depths

3. **Buff Selection**
   - Show 3 random buffs after each room
   - Only allow 1 pick
   - Buffs are permanent for run
   - Stacking allowed up to 3x

4. **Fog of War (Minimap)**
   - Unknown rooms = grey
   - Visited rooms = shown
   - Current room = highlighted
   - Show enemy count per room

5. **Instance Management**
   - One Instance per player per dungeon run
   - Cleanup on death or exit
   - No player-to-player interference

---

## CRITICAL IMPLEMENTATION NOTES

### RNG for Multiplayer
Must use **seeded RNG** (same seed = same dungeon for all players in same group):
```lua
local Random = require(script.Random)
local rng = Random.new(seed)
local randomValue = rng:NextNumber(min, max)
```

### Room Assembly
1. Load room model from Assets
2. Clone into player instance
3. Position mobs from spawn points
4. Setup doors to next rooms
5. Initialize chest with rolled loot

### Status Effects
Must track on Entity component:
- Duration (in turns, not seconds)
- Damage per turn
- Can be removed by certain items/buffs

### Buff System
- 3 random buffs offered after each room
- Player picks 1
- Applied to character permanently
- Can stack (same buff twice = 2x effect)

---

## FILES TO CREATE (In Order)

### Phase 2.1: Core Dungeon (Week 1)
1. [ ] MobData definitions (Goblin, Bandit, Elemental, Goblin King Boss)
2. [ ] DungeonData definitions (Rooms, Biomes, RoomConfig)
3. [ ] LootTables definitions (Drops, RoguelikeBuffs)
4. [ ] StatusEffects definitions (Burn, Poison, Stun, Bleed)
5. [ ] DungeonGenerator.luau service
6. [ ] InstanceManager.luau service
7. [ ] RoomSpawnSystem.luau system

### Phase 2.2: Game Logic (Week 2)
8. [ ] StatusSystem.luau system
9. [ ] LootManager.luau service
10. [ ] DifficultyScaler.luau service
11. [ ] Update CombatSystem for status effects

### Phase 2.3: Client Visuals (Week 3)
12. [ ] DungeonVisualSystem.luau client system
13. [ ] MinimapSystem.luau client system
14. [ ] BoonSelect.luau UI layout
15. [ ] Room model assembly logic

### Phase 2.4: Polish (Week 4)
16. [ ] Testing & bug fixes
17. [ ] Balance tuning
18. [ ] Performance optimization

---

## COMMON QUESTIONS ANSWERED

**Q: How do I add a new mob type?**
A: Create MobData/NewMob.luau with stats, add to init.luau, then reference in RoomData

**Q: How do I scale difficulty?**
A: Use DifficultyScaler:CalculateMobStats(baseMob, depth) before spawning

**Q: How do players see different layouts?**
A: Each gets their own Instance; use seeded RNG with same seed for group play

**Q: How do buffs persist?**
A: Store in RoguelikeBuffComponent on player entity; serialize with profile on exit

**Q: Where do I add new enchantments?**
A: Create file in EnchantData/ folder, follow existing pattern in EnchantTemplate

---

## DEBUGGING TIPS

1. **Check dungeon generation**: Print room list after DungeonGenerator runs
2. **Check mob spawning**: Print positions before creating entities
3. **Check buff application**: Print RoguelikeBuffComponent after selection
4. **Check map generation**: Use `/debug` to see profile state
5. **Use MinimapSystem**: Visual debugging of room connectivity

---

## LINKS TO MAIN DOCS

- **Full Architecture**: DOCUMENTATION.md
- **API Reference**: API_REFERENCE.md
- **Development Plan**: ROADMAP.md
- **Project Structure**: PROJECT_STRUCTURE.md
- **Quick Start**: QUICK_START.md

---

## END OF CONTEXT

**Total Length**: ~5000 words  
**Time to read**: 15-20 minutes  
**Suitable for**: Claude, ChatGPT, or any AI assistant

**To use**: Copy everything above and paste into your AI assistant along with your coding request.

---

*Created: 2026-06-11*  
*Status: Ready for Production Use*
