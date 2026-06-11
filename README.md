# 🎮 PROJECT W - Game Documentation

> **A complete game project with backend systems fully implemented. Ready for UI development.**

---

## 📌 PROJECT STATUS

| Component | Status | Completion |
|-----------|--------|-----------|
| **Backend Systems** | ✅ Complete | 85% |
| **Data Architecture** | ✅ Complete | 100% |
| **APIs** | ✅ Complete | 100% |
| **Frontend UI** | ❌ Not Started | 0% |
| **Documentation** | ✅ Complete | 100% |

---

## 🎯 WHAT IS PROJECT W?

Project W is a **Roblox Roguelike Dungeon Crawler** with a sophisticated backend system. The core economy systems (inventory, crafting, enchanting, farming, shop) are complete. Phase 2 adds procedural dungeon generation, instance-based gameplay, and roguelike progression.

### Core Features (Phase 1 ✅):
- 🎒 **Advanced Inventory System** (3 bag types, NBT support, UUID tracking)
- 🔨 **Crafting System** (recipes, professions, batch crafting, stat inheritance)
- ✨ **Enchanting System** (weighted pools, modifiers, rune logic)
- 🌾 **Farming System** (time-based plants, multi-harvest crops, seed NBT)
- 🏪 **Shop System** (buy/sell, global limits, seasonal items)
- ⚒️ **Dismantling System** (stat inheritance, gacha drops)
- 👤 **Player Stats System** (leveling, professions, currencies)
- 📈 **Upgrade System** (equipment leveling, in-progress)
- 💎 **Gemstone System** (socket gems, in-progress)

### Roguelike Features (Phase 2 🔄):
- 🗺️ **Procedural Dungeon Generation** (weighted rooms, difficulty scaling)
- 🎮 **Instance Management** (isolated player dungeons, no interference)
- 👹 **Enemy System** (mob types, scaling, loot drops)
- 🎁 **Roguelike Buffs** (3-choice selection after rooms, permanent for run)
- 🗝️ **Room Types** (Combat, Treasure, Shop, Rest, Boss)
- 📊 **Minimap** (fog of war, room exploration tracking)
- ⚡ **Status Effects** (Poison, Burn, Stun, Bleed - turn-based damage)
- 🎲 **Weighted Loot Tables** (gacha-style drops with rarity)

---

## 📚 DOCUMENTATION STRUCTURE

### **[📖 INDEX.md](INDEX.md)** - START HERE
Navigation hub for all documentation. Choose your role and find what you need.

### **[🚀 QUICK_START.md](QUICK_START.md)**
5-10 minute quick start for new contributors. Perfect for:
- Adding items, recipes, enchants (3-5 min each)
- Debugging commands
- FAQ

### **[📖 DOCUMENTATION.md](DOCUMENTATION.md)**
Comprehensive system architecture (30-40 min read). For architects & tech leads:
- System overview & design decisions
- All 9+ systems explained
- Data flow diagrams
- API relationships

### **[📖 API_REFERENCE.md](API_REFERENCE.md)**
Complete API documentation (20-30 min read). For developers:
- Detailed method signatures
- Parameters & return values
- Code examples
- Error handling
- Common patterns

### **[📁 PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - DETAILED STRUCTURE
Complete project tree with all files, systems, and components (20-30 min read):
- Full folder structure (src/, ReplicatedStorage/, Server/, Client/)
- 9+ systems breakdown
- New Roguelike systems (DungeonGenerator, InstanceManager, etc.)
- Data structure examples
- Dependencies and flows
- Files to create (with priority)

### **[🤖 CODEBASE_CONTEXT.md](CODEBASE_CONTEXT.md)** - **FOR AI ASSISTANTS**
**COPY THIS FILE TO YOUR AI CHAT FOR FULL PROJECT CONTEXT!**
- Complete project overview
- All existing APIs & patterns
- Data structures
- Coding conventions
- Files to create with examples
- Implementation notes
- ~5000 words of pure context

### **[🗺️ ROADMAP.md](ROADMAP.md)**
Development roadmap & timeline (15-20 min read). For planning:
- 4-phase development plan
- Phase 2 Roguelike specifications
- Task breakdown
- Resource estimates

---

## 🚀 GET STARTED IN 3 STEPS

### 1. **Understand the System** (10 minutes)
```bash
1. Read: QUICK_START.md (TL;DR section)
2. Read: INDEX.md (choose your path)
3. Pick a doc based on your role
```

### 2. **Explore the Code** (20 minutes)
```
Project Structure:
├── src/
│   ├── ServerScriptService/Server/
│   │   ├── ServerMain.server.luau (entry point)
│   │   ├── Systems/ (9 systems)
│   │   └── Network/
│   └── ReplicatedStorage/
│       ├── Constants/ (items, recipes, enchants, plants, shops)
│       ├── Components/ (templates & factories)
│       └── Utilities/
└── Documentation/
    ├── INDEX.md
    ├── QUICK_START.md
    ├── DOCUMENTATION.md
    ├── API_REFERENCE.md
    └── ROADMAP.md
```

### 3. **Contribute** (5-30 minutes depending on task)
```lua
-- Add new item (5 min)
/giveitem "My Item"

-- Add new recipe (5 min)
/craft "My Recipe"

-- Add new enchant (5 min)
/enchant 1 1

-- Add new plant (5 min)
/harvest slot1

-- Add new shop (5 min)
/buy "My Shop" 1 1
```

---

## 📊 SYSTEM OVERVIEW

### The 9 Systems

| System | Status | Lines | APIs | Purpose |
|--------|--------|-------|------|---------|
| **Inventory** | ✅ Complete | ~335 | 7 | Manage items, stacks, equipment |
| **Crafting** | ✅ Complete | ~210 | 1 | Create items from recipes |
| **Enchanting** | ✅ Complete | ~410 | 2 | Add/upgrade enchants on equipment |
| **Farming** | ✅ Complete | ~335 | 5 | Plant, grow, harvest crops |
| **Shop** | ✅ Complete | ~490 | 3 | Buy/sell with global limits |
| **Dismantling** | ✅ Complete | ~175 | 1 | Dismantle items → materials |
| **PlayerStats** | ✅ Complete | ~172 | 5 | Manage coins, exp, attributes |
| **Upgrade** | 🔄 In Progress | ~100 | - | Level up equipment stats |
| **Gemstone** | 🔄 In Progress | ~50 | - | Socket gems into equipment |

**Total Code**: ~2,000 lines (backend only)

---

## 🔄 HOW SYSTEMS INTERACT

```
┌─────────────────────────────────────────┐
│     INVENTORY SYSTEM (Core)             │
│  (Items, Materials, Consumables)        │
└────────────┬────────────────────────────┘
             │
    ┌────────┼────────┬──────────┬─────────┐
    │        │        │          │         │
    ▼        ▼        ▼          ▼         ▼
┌────────┐ ┌───────┐ ┌────────┐ ┌─────┐ ┌──────┐
│Crafting│ │Enchant│ │Farming │ │Shop │ │Dismantle
│System  │ │System │ │System  │ │System│ │System
└────┬───┘ └───┬───┘ └───┬────┘ └──┬──┘ └──┬───┘
     │         │         │        │      │
     └─────────┼─────────┼────────┼──────┘
               │         │        │
           ┌───▼─────────▼────────▼───┐
           │  PLAYERSTATS SYSTEM      │
           │ (Coins, Exp, Attributes) │
           └──────────────────────────┘
```

---

## 🛠️ TECH STACK

- **Language**: Luau (Roblox)
- **Platform**: Roblox
- **Data Sync**: Replica (real-time player-server sync)
- **Data Persistence**: ProfileStore
- **Storage**: MemoryStore (for global shop limits)
- **Architecture**: Server-Client (Server authority)

---

## 📈 ROADMAP AT A GLANCE

```
PHASE 1: Core Systems ✅ (Complete)
├─ Inventory, Crafting, Enchanting
├─ Farming, Shop, Dismantling
├─ PlayerStats
└─ Upgrade (70%), Gemstone (20%)

PHASE 2: Client UI 🔴 HIGH PRIORITY (2-3 weeks)
├─ Inventory UI
├─ Crafting Panel
├─ Enchanting Panel
├─ Farming Dashboard
└─ Shop Browser

PHASE 3: Advanced Features 🟠 MEDIUM (3-4 weeks)
├─ Complete Upgrade & Gemstone
├─ Trading System
├─ Guild System
└─ PvP Arena (optional)

PHASE 4: Polish & Optimization 🟡 LOW (2-3 weeks)
├─ Performance Tuning
├─ Analytics
├─ Content Expansion
└─ QoL Improvements

Total Timeline: ~10-13 weeks
```

---

## 🎯 IMMEDIATE PRIORITIES

### Next 2 Weeks:
1. ✅ **Documentation Complete** (you're reading it!)
2. 🔄 **Complete Phase 1** (Upgrade & Gemstone systems)
3. 📋 **Plan Phase 2** (UI framework selection)

### Next 4 Weeks:
1. 🎨 **Start Phase 2** (UI development)
2. 🧪 **QA Testing** (all systems)
3. 📝 **Balance Tuning** (economy)

---

## 📊 QUICK FACTS

| Khía Cạnh | Chi Tiết |
|-----------|---------|
| **Loại Game** | Roblox Roguelike Dungeon Crawler |
| **Ngôn Ngữ** | Luau (Roblox) |
| **Kiến Trúc** | Server-Client (Replica-based, Matter ECS) |
| **Hệ Thống Chính** | 16+ (9 Core + 7 Roguelike) |
| **Dữ Liệu** | ProfileStore + Replica + MemoryStore |
| **Item Loại** | 3 (Unique Items, Materials, Consumables) |
| **Professions** | 9+ (Crafting, Enchanting, Farming, Combat, etc.) |
| **Cây Trồng** | 2+ loại (Wheat, Apple Tree) |
| **Cửa Hàng** | 3+ loại (Villager, Dark Merchant, Scam Villager) |
| **Bùa** | 6+ loại (Sharpness, Life Steal, Fire Burst, etc.) |
| **Quái Vật** | 4+ loại (Goblin, Bandit, Elemental, Boss) |
| **Kiểu Phòng** | 5+ (Combat, Treasure, Shop, Rest, Boss) |
| **Buff Roguelike** | 20+ (tùy chỉnh) |
| **Code Lines** | ~2000 (Phase 1) + ~2500 (Phase 2) |

### NBT System
Named Binary Tag - extensible data on items. Used for:
- Plant identification (PlantId on Seed Pack)
- Custom attributes
- Special effects

### Profession Leveling
Each profession has:
- Experience (Exp)
- Level (calculated from Exp)
- Requirements for recipes/enchants
- Profession-specific tasks (Farming, Enchanting, etc.)

### Global Shop Limits
Using MemoryStore for:
- Global item stock tracking
- Per-session item limits (restock every N hours)
- Per-player purchase limits
- Anti-duplication measures

---

## ⚡ QUICK REFERENCE

### Most Common Operations

```lua
-- Add item to player
InventorySystem:GiveItem(player, "Iron Sword")

-- Add stackable (e.g., materials)
InventorySystem:GiveStackable(player, "Materials", "Iron", 50)

-- Remove stackable
InventorySystem:RemoveStackable(player, "Materials", "Iron", 5)

-- Craft item
CraftingSystem:ProcessCraft(player, "Steel Ingot", nil, 10)

-- Enchant item
EnchantSystem:ProcessEnchant(player, 1, 1)

-- Plant seed
FarmingSystem:PlantSeed(player, 1, "slot1")

-- Harvest
FarmingSystem:HarvestPlant(player, "slot1")

-- Buy from shop
ShopSystem:BuyItem(player, "Villager", 1, 5)

-- Sell item
ShopSystem:SellItem(player, "uuid-xxx", 1)

-- Add currency
PlayerStatSystem:AddCurrency(player, "Coin", 1000)

-- Add experience
PlayerStatSystem:AddProfessionExp(player, "Crafting", 500)
```

---

## 🐛 DEBUGGING

### Available Commands
```
/debug                              Show full player profile
/addcoin [amount]                  Add coins
/addexp [amount]                   Add core exp
/addprofexp [prof] [amount]        Add profession exp
/giveitem [id]                     Give equipment
/givestackable [id] [amount]       Give stackable
/craft [recipe] [main?] [amt?]     Craft item
/enchant [itemIdx] [runeIdx]       Enchant item
/harvest [slot]                    Harvest plant
/buy [shop] [idx] [amt]            Buy from shop
/sell [id/uuid] [amt]              Sell item
```

---

## 💼 FOR DIFFERENT ROLES

### Content Creator
- 📚 Read: [QUICK_START.md](QUICK_START.md)
- ⏱️ Time: 5-10 minutes
- 🎯 Goal: Add items, recipes, enchants

### Backend Developer
- 📚 Read: [API_REFERENCE.md](API_REFERENCE.md)
- ⏱️ Time: 20-30 minutes
- 🎯 Goal: Implement new features

### UI/Frontend Developer
- 📚 Read: [ROADMAP.md](ROADMAP.md) (Phase 2 section)
- ⏱️ Time: 30-40 minutes
- 🎯 Goal: Plan UI architecture

### Architect/Tech Lead
- 📚 Read: [DOCUMENTATION.md](DOCUMENTATION.md)
- ⏱️ Time: 40-50 minutes
- 🎯 Goal: Understand system design

### Project Manager
- 📚 Read: [ROADMAP.md](ROADMAP.md)
- ⏱️ Time: 15-20 minutes
- 🎯 Goal: Plan timeline & resources

---

## ❓ FAQ

**Q: Can I run the game right now?**  
A: Yes! Download Roblox, open the project, and run. Use chat commands to test.

**Q: Can I add new items without coding?**  
A: Almost! Create a new .luau file in ItemData folder, fill in data, add to init.luau.

**Q: When will UI be ready?**  
A: Phase 2 starts in ~1 week, estimated 2-3 weeks to complete basic UI.

**Q: Can players cheat?**  
A: Extremely hard. All logic is server-side. Client just receives data.

**Q: Is the code production-ready?**  
A: Mostly yes! Needs UI layer and some optimization, but backend is solid.

**Q: Where do I file a bug?**  
A: Check [API_REFERENCE.md → Error Handling](API_REFERENCE.md#error-handling) section.

---

## 🚀 GETTING STARTED NOW

### Step 1: Read Documentation
```
Quick (5 min):    QUICK_START.md
Medium (30 min):  DOCUMENTATION.md  
Complete (90 min): All 4 docs
```

### Step 2: Explore Code
```
cd d:\Project W
code .
```

### Step 3: Test the Game
```
1. Open Roblox Studio
2. Load project
3. Run game
4. Type: /debug
5. Try: /giveitem "Iron Sword"
```

### Step 4: Contribute
```
1. Add new item/recipe/enchant
2. Test with chat command
3. Commit & push
4. Done!
```

---

## 📞 SUPPORT

### Need Help?
1. Check [INDEX.md](INDEX.md) for topic lookup
2. Search in relevant documentation
3. Review [API_REFERENCE.md → Error Handling](API_REFERENCE.md#error-handling)
4. Ask team lead or check code comments

### Found a Bug?
1. Document the issue
2. Add debug output
3. Check with `/debug` command
4. File issue with reproduction steps

---

## 📄 LICENSE & CREDITS

**Project**: Project W  
**Status**: In Active Development  
**Version**: 0.1  
**Team**: _[Add team info]_

---

## 🎉 READY?

👉 **Start with [INDEX.md](INDEX.md)** - Choose your role and dive in!

---

## 📚 DOCUMENTATION FILES

| File | Purpose | Read Time |
|------|---------|-----------|
| **README.md** | This file! Overview | 5 min |
| **INDEX.md** | Navigation hub | 5 min |
| **QUICK_START.md** | New contributor guide | 5-10 min |
| **DOCUMENTATION.md** | Complete architecture | 30-40 min |
| **API_REFERENCE.md** | API documentation | 20-30 min |
| **ROADMAP.md** | Development plan | 15-20 min |

---

**Last Updated:** 2026-06-11  
**Status:** ✅ Complete & Current  
**Next Review:** 2026-06-25

🎮 **Happy Game Development!** 🎮
