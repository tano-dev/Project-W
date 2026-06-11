# 📁 PROJECT W - COMPLETE PROJECT STRUCTURE

**Version:** 0.2 (Updated with Roguelike/Dungeon System)  
**Last Updated:** 2026-06-11

---

## 🎮 PROJECT TREE (DETAILED)

```
Project W/
├── src/
│   ├── ReplicatedStorage/
│   │   ├── Shared/
│   │   │   ├── Components/                    # [Matter ECS] Entity Components
│   │   │   │   ├── StatsComponent.luau       # Health, Mana, Stats
│   │   │   │   ├── ItemComponent.luau        # Item data, Rarity
│   │   │   │   ├── RoomComponent.luau        # [Mới] Room ID, Biome Type, Connected Doors
│   │   │   │   ├── DoorComponent.luau        # [Mới] Door state (Open/Locked), Target Room
│   │   │   │   ├── ChestComponent.luau       # [Mới] Chest loot, Opened state
│   │   │   │   ├── RoguelikeBuffComponent.luau # [Mới] Buff ID, Duration, Stacks
│   │   │   │   └── StatusEffectComponent.luau  # [Mới] Poison, Burn, Stun duration
│   │   │   │
│   │   │   ├── Constants/                    # [CODE DATA] All game definitions
│   │   │   │   ├── GameConfig.luau           # Global settings (MaxRooms, DifficultyScaling)
│   │   │   │   ├── ItemData/
│   │   │   │   │   ├── init.luau
│   │   │   │   │   ├── Items/
│   │   │   │   │   │   └── [Item definitions]
│   │   │   │   │   ├── Materials/
│   │   │   │   │   └── Consumables/
│   │   │   │   │
│   │   │   │   ├── MobData/                  # [Mới] Quái vật definitions
│   │   │   │   │   ├── init.luau
│   │   │   │   │   ├── Goblins.luau          # Health, AttackSpeed, LootTable [Normal mobs]
│   │   │   │   │   ├── Bandits.luau
│   │   │   │   │   ├── Elementals.luau
│   │   │   │   │   └── Bosses.luau           # Boss stats, Phases, Special abilities
│   │   │   │   │
│   │   │   │   ├── DungeonData/              # [Mới] Hầm ngục definitions
│   │   │   │   │   ├── init.luau
│   │   │   │   │   ├── Biomes.luau           # Khu vực (Forest, Volcanic, Undead)
│   │   │   │   │   ├── Rooms.luau            # Room templates (Combat, Shop, Treasure)
│   │   │   │   │   └── DungeonConfig.luau    # Depth, RoomCount, BossSpawnRate
│   │   │   │   │
│   │   │   │   ├── LootTables/               # [Mới] Hệ thống gacha/rớt đồ
│   │   │   │   │   ├── init.luau
│   │   │   │   │   ├── Drops.luau            # Weighted loot from mobs/chests
│   │   │   │   │   └── RoguelikeBuffs.luau   # Danh sách boon & curse
│   │   │   │   │
│   │   │   │   └── StatusEffects/            # [Mới] Trạng thái hiệu ứng
│   │   │   │       ├── init.luau
│   │   │   │       ├── Burn.luau
│   │   │   │       ├── Poison.luau
│   │   │   │       ├── Stun.luau
│   │   │   │       └── Bleed.luau
│   │   │   │
│   │   │   └── Utilities/                    # [LIBRARIES] Thư viện hỗ trợ
│   │   │       ├── Sift.luau                 # [Sift] Table utilities (filter, shuffle)
│   │   │       ├── Promise.luau              # [Roblox-Lua-Promise] Async/await
│   │   │       ├── Llama.luau                # [Llama] Functional programming
│   │   │       ├── Random.luau               # [Custom] Seeded RNG for dungeon sync
│   │   │       ├── LevelingCalculator.luau   # Exp → Level conversion
│   │   │       ├── Maid.luau                 # Instance cleanup
│   │   │       ├── Signal.luau               # Event system
│   │   │       └── PartCache.luau            # Object pooling
│   │   │
│   │   ├── Assets/                           # [3D MODELS & MEDIA]
│   │   │   ├── Models/
│   │   │   │   ├── Characters/
│   │   │   │   │   ├── Player.rbxm
│   │   │   │   │   ├── Goblin.rbxm
│   │   │   │   │   └── Boss.rbxm
│   │   │   │   │
│   │   │   │   └── DungeonRooms/             # [Mới] Mảnh phòng 3D
│   │   │   │       ├── CombatRoom_01.rbxm
│   │   │   │       ├── ShopRoom_01.rbxm
│   │   │   │       ├── TreasureRoom_01.rbxm
│   │   │   │       └── BossRoom_01.rbxm
│   │   │   │
│   │   │   ├── VFX/
│   │   │   │   ├── SpellEffects/
│   │   │   │   ├── StatusEffects/             # [Mới] Animation độc, cháy
│   │   │   │   └── Particles/
│   │   │   │
│   │   │   └── Sounds/
│   │   │       ├── Music/
│   │   │       ├── SFX/
│   │   │       └── Ambience/
│   │   │
│   │   ├── Network/                          # [BLINK FRAMEWORK] Network RPCs
│   │   │   ├── init.luau
│   │   │   ├── ClientNetwork.luau
│   │   │   └── ServerNetwork.luau
│   │   │       ├── GenerateRoom()            # [Mới] Generate + spawn room
│   │   │       ├── SelectRoguelikeBuff()     # [Mới] Player chọn 1 trong 3 boon
│   │   │       ├── EnterRoom()               # Player di chuyển vào phòng
│   │   │       ├── AttackEnemy()             # Combat action
│   │   │       └── ...
│   │   │
│   │   └── UI/                               # [REFLEX + FUSION/REACT] User Interface
│   │       ├── Components/
│   │       │   ├── HealthBar.luau
│   │       │   ├── InventoryGrid.luau
│   │       │   ├── BuffIcon.luau             # [Mới] Hiển thị boon icon
│   │       │   ├── StatusEffectIcon.luau     # [Mới] Hiển thị độc, cháy
│   │       │   └── ...
│   │       │
│   │       ├── Layouts/
│   │       │   ├── HUD.luau                  # Main gameplay UI
│   │       │   ├── Minimap.luau              # [Mới] Bản đồ phòng (Fog of war)
│   │       │   ├── BoonSelect.luau           # [Mới] Chọn 1 trong 3 buff
│   │       │   ├── CombatUI.luau             # Turn order, actions
│   │       │   └── ShopUI.luau
│   │       │
│   │       ├── Themes/
│   │       │   ├── Colors.luau
│   │       │   └── Fonts.luau
│   │       │
│   │       └── State/                        # Reflex state management
│   │           ├── DungeonSlice.luau         # [Mới] Current room, visited rooms
│   │           ├── PlayerSlice.luau          # Health, buffs
│   │           └── UISlice.luau
│   │
│   ├── ServerScriptService/
│   │   └── Server/
│   │       ├── ServerMain.server.luau        # Auto-load systems, initialize
│   │       │
│   │       ├── Systems/                      # [MATTER ECS] Game Logic
│   │       │   ├── init.luau
│   │       │   ├── TurnQueueSystem.luau      # Quản lý lượt chơi
│   │       │   ├── CombatSystem.luau         # Tính toán damage, hit chance
│   │       │   ├── StatusSystem.luau         # [Mới] Áp dụng damage từ Poison/Burn
│   │       │   ├── RoomSpawnSystem.luau      # [Mới] Spawn mob/chest khi player vào
│   │       │   ├── MovementSystem.luau       # Xử lý di chuyển giữa rooms
│   │       │   ├── InventorySystem.luau      # [Existing] Quản lý túi đồ
│   │       │   ├── CraftingSystem.luau       # [Existing]
│   │       │   └── ...
│   │       │
│   │       ├── Services/                     # [CORE LOGIC] Dịch vụ lõi
│   │       │   ├── DungeonGenerator.luau     # [Mới] THUẬT TOÁN SINH HẦM NGỤC
│   │       │   │   ├── Procedural generation algorithm
│   │       │   │   ├── Weighted room selection
│   │       │   │   └── Boss room placement
│   │       │   │
│   │       │   ├── InstanceManager.luau      # [Mới] Tách player vào Instance riêng
│   │       │   │   ├── CreatePlayerInstance()
│   │       │   │   ├── CleanupInstance()
│   │       │   │   └── SyncInstanceState()
│   │       │   │
│   │       │   ├── DataManager.luau          # [ProfileStore] Lưu trữ dữ liệu
│   │       │   │   ├── SaveRoguelikeProgress
│   │       │   │   ├── LoadDungeonState
│   │       │   │   └── ...
│   │       │   │
│   │       │   ├── LootManager.luau          # [Mới] Quản lý rớt đồ
│   │       │   │   ├── RollLoot()
│   │       │   │   ├── CreateChestContents()
│   │       │   │   └── ...
│   │       │   │
│   │       │   └── DifficultyScaler.luau     # [Mới] Tăng độ khó theo depth
│   │       │       ├── CalculateMobStats()
│   │       │       ├── ScaleLootQuality()
│   │       │       └── ...
│   │       │
│   │       ├── NetworkHandlers/              # Network RPC handlers
│   │       │   ├── GenerateRoomHandler.luau
│   │       │   ├── SelectBuffHandler.luau
│   │       │   └── ...
│   │       │
│   │       └── Utilities/                    # Helper functions
│   │           ├── MobSpawner.luau
│   │           ├── ChestSpawner.luau
│   │           └── ...
│   │
│   └── StarterPlayer/
│       └── StarterPlayerScripts/
│           └── Client/
│               ├── ClientMain.client.luau    # Entry point
│               │
│               ├── Systems/                  # [MATTER ECS] Client-side logic
│               │   ├── init.luau
│               │   ├── DungeonVisualSystem.luau # [Mới] Đọc room spawn lệnh, ghép mảnh phòng
│               │   ├── MinimapSystem.luau    # [Mới] Mở Fog of war, hiển thị map
│               │   ├── VFXSystem.luau        # Hiệu ứng đặc biệt
│               │   ├── QTESystem.luau        # Quick Time Events
│               │   ├── AnimationSystem.luau
│               │   └── InputSystem.luau      # Xử lý input người dùng
│               │
│               ├── Controllers/              # Điều khiển hành vi
│               │   ├── CameraController.luau
│               │   ├── CharacterController.luau
│               │   └── UIController.luau
│               │
│               ├── Managers/                 # [Mới] Quản lý state client-side
│               │   ├── DungeonManager.luau   # Cache room data locally
│               │   └── BuffManager.luau      # Track active buffs UI
│               │
│               └── UIMount/                  # Root component for Reflex UI
│                   └── init.luau
│
└── Documentation/
    ├── README.md                             # Main overview
    ├── INDEX.md                              # Navigation
    ├── QUICK_START.md                        # Quick guide
    ├── DOCUMENTATION.md                      # Full architecture
    ├── API_REFERENCE.md                      # API docs
    ├── ROADMAP.md                            # Development plan
    ├── PROJECT_STRUCTURE.md                  # This file! Detailed structure
    └── CODEBASE_CONTEXT.md                   # [Mới] Context for AI (copy to Claude)
```

---

## 📊 SYSTEM BREAKDOWN

### **Shared Components** (Matter ECS)
| Component | Purpose | New? |
|-----------|---------|------|
| StatsComponent | Health, Mana, Attributes | ❌ |
| ItemComponent | Item properties, Rarity | ❌ |
| **RoomComponent** | Room ID, Biome, Doors | ✅ |
| **DoorComponent** | Door state, connections | ✅ |
| **ChestComponent** | Loot, opened state | ✅ |
| **RoguelikeBuffComponent** | Buff ID, duration | ✅ |
| **StatusEffectComponent** | Poison/Burn/Stun time | ✅ |

### **Server Systems** (Game Logic)
| System | Purpose | New? |
|--------|---------|------|
| TurnQueueSystem | Manage turn order | ❌ |
| CombatSystem | Calculate damage | ❌ |
| **StatusSystem** | Apply status damage | ✅ |
| **RoomSpawnSystem** | Spawn mobs/chests | ✅ |
| MovementSystem | Room transitions | ⚙️ |
| InventorySystem | Manage items | ❌ |

### **Server Services** (Core Logic)
| Service | Purpose | New? |
|---------|---------|------|
| **DungeonGenerator** | Generate dungeon layout | ✅ |
| **InstanceManager** | Separate player instances | ✅ |
| DataManager | Save/load player data | ✅ |
| **LootManager** | Roll loot from drops | ✅ |
| **DifficultyScaler** | Scale by depth/difficulty | ✅ |

### **Client Systems** (Rendering & Input)
| System | Purpose | New? |
|--------|---------|------|
| **DungeonVisualSystem** | Assemble room models | ✅ |
| **MinimapSystem** | Fog of war UI | ✅ |
| VFXSystem | Effects | ❌ |
| QTESystem | Quick time events | ❌ |
| InputSystem | Player input | ❌ |

### **UI Layouts**
| Layout | Purpose | New? |
|--------|---------|------|
| HUD | Main gameplay UI | ❌ |
| **Minimap** | Room map with fog | ✅ |
| **BoonSelect** | Pick 1 of 3 buffs | ✅ |
| CombatUI | Turn/actions | ❌ |
| ShopUI | Merchant | ❌ |

---

## 🆕 KEY NEW SYSTEMS (Roguelike)

### 1. **DungeonGenerator Service**
- Procedurally generates dungeon layout
- Weighted room selection (Combat 50%, Treasure 20%, Shop 20%, Boss 10%)
- Difficulty scaling by depth
- Boss room placement logic
- Connection generation (doors between rooms)

**Files**: `DungeonGenerator.luau`

### 2. **InstanceManager Service**
- Creates separate Roblox Instance for each player's dungeon
- Prevents players from seeing each other's dungeons
- Manages cleanup on exit
- Syncs state between server & player instance

**Files**: `InstanceManager.luau`

### 3. **RoomSpawnSystem**
- Spawns mobs based on room type
- Spawns chests with loot
- Scales difficulty by dungeon depth
- Uses LootManager for drop rolls

**Files**: `RoomSpawnSystem.luau`

### 4. **StatusSystem**
- Applies damage from status effects each turn
- Manages Poison/Burn/Stun/Bleed duration
- Handles immunity logic
- Removes effects when expired

**Files**: `StatusSystem.luau`

### 5. **LootManager Service**
- Rolls loot based on LootTables
- Supports weighted drops
- Can roll multiple items from one creature
- Handles rarity scaling

**Files**: `LootManager.luau`

### 6. **DifficultyScaler Service**
- Scales mob stats (health, damage) by dungeon depth
- Increases loot quality by depth
- Adjusts drop rates
- Scales boss stats by phase

**Files**: `DifficultyScaler.luau`

### 7. **DungeonVisualSystem (Client)**
- Receives room spawn command from server
- Loads room model from Assets/Models/DungeonRooms/
- Assembles room in player instance
- Positions doors to next rooms
- Handles room transitions

**Files**: `DungeonVisualSystem.luau`

### 8. **MinimapSystem (Client)**
- Displays discovered rooms on minimap
- Fog of war (unknown rooms greyed out)
- Shows current room highlight
- Shows item/enemy count per room
- Updates as player explores

**Files**: `MinimapSystem.luau`

### 9. **BoonSelect UI**
- Shows 3 random roguelike buffs
- Player selects 1
- Sends selection to server
- Applies buff to player
- Generates next room after selection

**Files**: `BoonSelect.luau`

---

## 📋 DATA STRUCTURE EXAMPLE

### **MobData (Quái vật)**
```lua
{
  Id = "Goblin",
  Name = "Goblin",
  Health = 30,
  AttackPower = 5,
  DefensePower = 1,
  Speed = 4,
  
  LootTable = {
    { Id = "Wood", Min = 1, Max = 3, Chance = 0.8 },
    { Id = "Gold Coin", Min = 10, Max = 25, Chance = 1.0 }
  },
  
  DifficultyScaling = {
    HealthPerDepth = 2,      -- +2 health per dungeon level
    DamagePerDepth = 0.5
  }
}
```

### **Room Data**
```lua
{
  Id = "CombatRoom_01",
  Type = "Combat",
  EnemySpawns = {
    { Biome = "Forest", Enemies = {"Goblin", "Goblin"} },
    { Biome = "Volcanic", Enemies = {"FireElemental"} }
  },
  LootSpawn = {
    { Rarity = "Common", Chance = 0.5 },
    { Rarity = "Rare", Chance = 0.1 }
  },
  Connections = {
    North = nil,
    South = "auto",
    East = "auto",
    West = nil
  }
}
```

### **RoguelikeBuff (Boon)**
```lua
{
  Id = "ExtraHealth",
  Name = "+50 Max Health",
  Rarity = "Common",
  Icon = "rbxassetid://xxx",
  
  Effects = {
    { Stat = "MaxHealth", Modifier = 50 }
  },
  
  Duration = math.huge,  -- Permanent until run ends
  Stackable = true,
  MaxStacks = 3
}
```

---

## 🔄 DATA FLOW EXAMPLE: Player Enters Dungeon

```
1. Player clicks "Enter Dungeon"
   ↓
2. Server: DungeonGenerator generates layout
   ├─ Creates 15 rooms (procedurally)
   ├─ Assigns enemies to each
   ├─ Places boss room at depth 10
   └─ Saves layout to DataManager
   ↓
3. Server: InstanceManager creates Player Instance
   ├─ Clones dungeon folder
   ├─ Teleports player to Start Room
   └─ Initializes room state
   ↓
4. Server: RoomSpawnSystem spawns mobs/chests
   ├─ Reads room template
   ├─ Scales mob stats by depth (DifficultyScaler)
   ├─ Spawns 2-3 mobs
   └─ Creates treasure chest
   ↓
5. Client: DungeonVisualSystem receives spawn event
   ├─ Loads room model from Assets
   ├─ Positions mobs
   ├─ Shows chest
   └─ Renders on screen
   ↓
6. Client: MinimapSystem shows current room
   ├─ Highlights current room
   ├─ Shows connected doors
   └─ Fog of war on unexplored
   ↓
7. Player: Defeats all enemies
   ↓
8. Server: Spawns BoonSelect prompt
   ├─ Randomly selects 3 buffs
   ├─ Sends to client
   └─ Waits for player selection
   ↓
9. Client: BoonSelect UI shows 3 choices
   ↓
10. Player: Clicks 1 buff
    ↓
11. Server: Applies buff to player
    ├─ Updates RoguelikeBuffComponent
    ├─ Generates next room
    └─ Calls step 4 again
```

---

## 🎯 NEW CONFIGURATION FILES

### **GameConfig.luau** (Global Settings)
```lua
return {
  Roguelike = {
    MaxRoomsPerDungeon = 15,
    BossRoomAtDepth = 10,
    ItemsPerBuffSelect = 3,
    DifficultyPerDepth = 1.1  -- 1.1x harder per level
  },
  
  RoomRates = {
    Combat = 0.50,
    Treasure = 0.20,
    Shop = 0.15,
    Rest = 0.10,
    Boss = 0.05
  }
}
```

### **DungeonConfig.luau** (Dungeon Settings)
```lua
return {
  Biomes = {"Forest", "Volcanic", "Undead", "Frost"},
  
  Depths = {
    Early = { Rooms = 1-5, Difficulty = 1.0 },
    Mid = { Rooms = 6-10, Difficulty = 1.5 },
    Late = { Rooms = 11-14, Difficulty = 2.0 },
    Boss = { Rooms = 15, Difficulty = 3.0 }
  }
}
```

---

## 📦 DEPENDENCY MAP

```
DungeonGenerator
    ├─→ MobData
    ├─→ DungeonData (Rooms, Biomes)
    ├─→ GameConfig
    └─→ Random.luau (seeded)

InstanceManager
    ├─→ DungeonGenerator (output)
    └─→ DataManager

RoomSpawnSystem
    ├─→ DungeonData
    ├─→ MobData
    ├─→ LootManager
    ├─→ DifficultyScaler
    └─→ InstanceManager

LootManager
    ├─→ LootTables (Drops, Buffs)
    └─→ DifficultyScaler

DifficultyScaler
    └─→ GameConfig

(Client)
DungeonVisualSystem
    ├─→ Assets/Models/DungeonRooms/
    ├─→ InstanceManager (gets room data)
    └─→ Matter.World (entities)

MinimapSystem
    ├─→ DungeonData (room layout)
    ├─→ State (visited rooms)
    └─→ Reflex (UI state)

BoonSelect UI
    ├─→ LootTables (RoguelikeBuffs)
    └─→ Network (send selection)
```

---

## 🗂️ FILES TO CREATE (Priority)

| Priority | File | Lines | Purpose |
|----------|------|-------|---------|
| 🔴 HIGH | DungeonGenerator.luau | 300-400 | Core dungeon generation |
| 🔴 HIGH | InstanceManager.luau | 200-300 | Instance creation/cleanup |
| 🔴 HIGH | RoomSpawnSystem.luau | 150-200 | Spawn mobs/chests |
| 🟠 MEDIUM | StatusSystem.luau | 100-150 | Status effect damage |
| 🟠 MEDIUM | LootManager.luau | 150-200 | Loot rolling |
| 🟠 MEDIUM | DifficultyScaler.luau | 100-150 | Difficulty scaling |
| 🟠 MEDIUM | DungeonVisualSystem.luau | 200-300 | Client room assembly |
| 🟠 MEDIUM | MinimapSystem.luau | 150-200 | Minimap rendering |
| 🟡 LOW | BoonSelect.luau | 100-150 | Buff selection UI |
| 🟡 LOW | Various Data files | 50-100 each | MobData, RoomData, etc. |

**Total Estimated**: ~2000-2500 new lines of code for Phase 2

---

**Last Updated:** 2026-06-11  
**Version:** 1.0  
**Status:** Structure Complete
