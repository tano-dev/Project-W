# 🗺️ PROJECT W - DEVELOPMENT ROADMAP

**Status:** In Active Development  
**Last Updated:** 2026-06-11  
**Version:** 1.0

---

## 📊 ROADMAP OVERVIEW

```
Phase 1: Core Systems (✅ 70% Complete)
    ├─ Inventory System ✅
    ├─ Crafting System ✅
    ├─ Enchanting System ✅
    ├─ Farming System ✅
    ├─ Shop System ✅
    ├─ Dismantling System ✅
    ├─ PlayerStats System ✅
    ├─ Upgrade System 🔄 (70%)
    └─ Gemstone System 🔄 (20%)

Phase 2: Client UI (❌ Not Started - Priority 🔴 HIGH)
    ├─ Inventory UI (3-4 days)
    ├─ Crafting Panel (2-3 days)
    ├─ Enchanting Panel (2-3 days)
    ├─ Farming Dashboard (2-3 days)
    └─ Shop Browser (2-3 days)
    └─ Total: ~12-16 days

Phase 3: Advanced Features (❌ Not Started - Priority 🟠 MEDIUM)
    ├─ Upgrade System Completion (3-4 days)
    ├─ Gemstone System Completion (3-4 days)
    ├─ Trading System (5-7 days)
    ├─ Guild System (5-7 days)
    └─ PvP Arena (7-10 days) - Optional

Phase 4: Polish & Optimization (❌ Not Started - Priority 🟡 LOW)
    ├─ Performance Optimization (2-3 days)
    ├─ Analytics & Logging (2-3 days)
    ├─ Content Expansion (3-5 days)
    └─ Bug Fixes & QoL (2-3 days)
```

---

## 🎯 PHASE 1: CORE SYSTEMS (Current Phase)

### ✅ Completed

#### 1. Inventory System
- **Status**: ✅ Complete & Tested
- **Features**:
  - 3-tier inventory (Items, Materials, Consumables)
  - UUID-based unique item tracking
  - NBT system for extended data
  - Smart stackable management
  - Equipped gear tracking

#### 2. Crafting System
- **Status**: ✅ Complete & Tested
- **Features**:
  - Recipe-based crafting
  - Level requirements
  - Multi-batch crafting
  - Equipment upgrade via MainIngredient
  - Profession Exp integration

#### 3. Enchanting System
- **Status**: ✅ Complete & Tested
- **Features**:
  - Token-based enchanting
  - Rarity system (Common→Mythic)
  - Modifiers & Luck system
  - Weighted pool rolling
  - Disenchant with Exp reward

#### 4. Farming System
- **Status**: ✅ Complete & Tested
- **Features**:
  - Time-based plant growth
  - Multi-harvest crops
  - Seed NBT tracking
  - Farming Exp rewards
  - Plant destruction

#### 5. Shop System
- **Status**: ✅ Complete & Tested
- **Features**:
  - Buy/Sell mechanics
  - Global limited stock (MemoryStore)
  - Per-player purchase limits
  - Time-based shop opening
  - Price multipliers

#### 6. Dismantling System
- **Status**: ✅ Complete & Tested
- **Features**:
  - Chance-based drops
  - Stat inheritance (KeepStats)
  - Crafting Exp rewards
  - Both stackable & unique drops

#### 7. PlayerStats System
- **Status**: ✅ Complete & Tested
- **Features**:
  - Currency management
  - Core leveling
  - Profession leveling
  - Attribute system
  - Auto level-up logic

---

### 🔄 In Progress

#### 8. Upgrade System (70% Complete)

**Current Status:**
- Backend logic: ✅ 80%
- UI/Frontend: ❌ 0%

**To-Do:**
- [x] Core upgrade mechanics
- [x] Stat scaling calculation
- [x] Success/failure rates
- [ ] Reroll system (blueprint drafted)
- [ ] Blessing/Cursing (needs design)
- [ ] UI implementation (pending Phase 2)

**Data Structure (Draft):**
```lua
Upgrade = {
  MaxUpgradeLevel = 20,
  UpgradeExp = 100,        -- Exp per upgrade attempt
  BaseSuccessRate = 0.8,   -- 80% success at +0
  SuccessRateDecay = 0.05, -- -5% per level (+10 is 30% success)
  EnhancementMultiplier = {
    [0] = 1.0,
    [5] = 1.5,
    [10] = 2.0,
    [15] = 3.0,
    [20] = 5.0
  }
}
```

**Implementation Plan:**
1. Create `Upgrade.luau` with:
   - `ProcessUpgrade(player, itemIndex, materialId, amount)` 
   - `CalculateStats(baseItem, upgradeLevel)`
   - `GetUpgradeChance(currentLevel)`

2. Integrate with Inventory:
   - Store `UpgradeCount` on item
   - Update on upgrade success

3. Integrate with Stats:
   - Emit `OnEquipmentUpgraded` event
   - Recalculate character stats

---

#### 9. Gemstone System (20% Complete)

**Current Status:**
- Data models: ✅ 30%
- Backend logic: ❌ 20%
- Socket mechanics: ❌ 0%
- Fusion system: ❌ 0%

**To-Do:**
- [ ] Gem data definitions (Attribute type, Rarity, Stats)
- [ ] Socket count logic per item
- [ ] Socket insertion mechanics
- [ ] Gem removal mechanics
- [ ] Gem fusion/upgrade
- [ ] Gem combining (e.g., 3x Common → 1x Uncommon)
- [ ] UI for gem socket management

**Gem Rarities (Proposed):**
- Common (1-2 stats)
- Uncommon (2-3 stats, +10% higher multiplier)
- Rare (3-4 stats)
- Epic (4-5 stats)
- Legendary (5+ stats, special effects)

**Planned APIs:**
```lua
GemstoneSystem:InsertGem(player, itemUUID, socketSlot, gemUUID)
GemstoneSystem:RemoveGem(player, itemUUID, socketSlot)
GemstoneSystem:CombineGems(player, gem1, gem2, gem3) -- 3x -> higher rarity
GemstoneSystem:CalculateGemStats(gem, level) -- Calculate stat boost
```

---

## 🎨 PHASE 2: CLIENT UI (Not Started)

### Priority: 🔴 HIGH | Estimated: 12-16 days

> **Blocker**: No UI framework selected yet. Suggest using **Fusion** (Roblox UI library) for maintainability.

---

### 2.1 Inventory UI (Priority: 🔴 CRITICAL)

**Estimated**: 3-4 days

**Features**:
- [ ] Three-tab interface (Items | Materials | Consumables)
- [ ] Item grid display (8x10 recommended)
- [ ] Item cards with:
  - Thumbnail image
  - Name & rarity color
  - Stack count (for stackables)
  - Hover tooltip with full stats
- [ ] Drag & drop support
- [ ] Quick actions:
  - Right-click → Sell / Dismantle / Equip
  - Ctrl+Click → Move to other tab (if applicable)
- [ ] Search & filter
- [ ] Sorting options (rarity, name, date acquired)

**UI Layout:**
```
┌─────────────────────────────────┐
│ Inventory | Materials | Items   │
├─────────────────────────────────┤
│ [Search...] [Filter ▼] [Sort ▼] │
├─────────────────────────────────┤
│ [Item] [Item] [Item] [Item] ... │
│ [Item] [Item] [Item] [Item] ... │
│ ...                              │
├─────────────────────────────────┤
│ [Details Panel]                 │
│ Name: Iron Sword                │
│ Rarity: Uncommon                │
│ Enchants: Sharpness Lv2         │
│ [Sell] [Dismantle]              │
└─────────────────────────────────┘
```

---

### 2.2 Crafting Panel (Priority: 🔴 HIGH)

**Estimated**: 2-3 days

**Features**:
- [ ] Recipe list (searchable)
- [ ] Filter by:
  - Profession type
  - Item rarity
  - Materials owned (show missing in red)
- [ ] Recipe details:
  - Input materials with check (✓ have / ✗ need)
  - Output items
  - Profession requirement (show current level vs needed)
  - Exp reward
  - Craft time estimate
- [ ] Craft controls:
  - MainIngredient selector (for upgrades)
  - Batch slider (1-1000)
  - [Craft] button
- [ ] Crafting progress bar (if async)

**UI Layout:**
```
┌──────────────────────────────────────┐
│ [Search Recipes...]  [Filter ▼]     │
├──────────────────────────────────────┤
│ Recipes (showing 24/156)             │
│ ┌─ Steel Ingot (Crafting Lv 10)    │
│ │ Cost: 5x Iron, 2x Coal           │
│ │ Gives: 2x Steel Ingot (+100 Exp) │
│ │ Status: [✓ Ready] [x2] [Craft]   │
│ └─────────────────────────────────┘
│ ┌─ Upgrade Helmet (Crafting Lv 15) │
│ │ Main: [Select Item ▼]            │
│ │ Cost: 5x Steel Ingot             │
│ │ Status: [x Need Steel] [Craft]   │
│ └─────────────────────────────────┘
└──────────────────────────────────────┘
```

---

### 2.3 Enchanting Panel (Priority: 🔴 HIGH)

**Estimated**: 2-3 days

**Features**:
- [ ] Two-panel layout:
  - **Left**: Item selector (show only enchantable items)
  - **Right**: Rune selector + preview
- [ ] Item details:
  - Current enchants list with levels
  - Enchant count (3/5)
  - Disenchant button
- [ ] Rune details:
  - Enchanting Exp reward
  - Token count & pool preview
  - Modifiers breakdown (MinRarity, MaxRarity, Exclude)
  - Luck modifier visualization
- [ ] Preview panel:
  - "Possible outcomes" (show pool top 5 enchants)
  - Weight distribution chart
- [ ] [Enchant] button

**UI Layout:**
```
┌────────────────┬────────────────────┐
│   ITEM SELECT  │    RUNE SELECT     │
├────────────────┼────────────────────┤
│ [Sword1] [Axe] │ [Rune] [Rune]      │
│ [Staff] [Dagger]│ Common  Uncommon   │
│ ...            │ Rare    Epic       │
│                │                    │
│ Iron Sword     │ Common Rune        │
│ Enchants: 2/5  │ Tokens: 3          │
│ • Sharpness L1 │ Exp: +100          │
│ • Poison L2    │ Modifiers:         │
│ [Disenchant]   │ • Max: Rare        │
│                │ • Luck: +50        │
│                │ ┌─ New Pool ─┐    │
│                │ │ Poison 45% │    │
│                │ │ Fire 35%   │    │
│                │ │ Ice 20%    │    │
│                │ └────────────┘    │
│                │ [Enchant!]       │
└────────────────┴────────────────────┘
```

---

### 2.4 Farming Dashboard (Priority: 🟠 MEDIUM)

**Estimated**: 2-3 days

**Features**:
- [ ] Farm plot grid layout (8x6 or customizable)
- [ ] Plot visualization:
  - Empty plots (soil icon)
  - Growing plants (with stage indicator 1-5)
  - Harvestable plants (green highlight)
- [ ] Seed inventory panel (quick access)
- [ ] Quick actions per plot:
  - Hover → Plant / Harvest / Destroy
- [ ] Plant info modal:
  - Growth time remaining
  - Current stage
  - Harvest yields (with icons)
  - Can harvest button (if ready)
- [ ] Farming stats:
  - Total plots unlocked
  - Seeds owned
  - Proficiency level

**UI Layout:**
```
┌────────────────────────────────────┐
│ Farming Dashboard                  │
├────────────────────────────────────┤
│ Seeds: [Wheat x5] [Apple x3] ...   │
├────────────────────────────────────┤
│ ┌─────┬─────┬─────┬─────┐         │
│ │ 🌾  │ 🌾  │ 🌾  │ 🌾  │         │
│ │ S3  │ S2  │ 100%│ ___ │         │
│ ├─────┼─────┼─────┼─────┤         │
│ │ ___ │ S1  │ ___ │ ___ │         │
│ │     │ 50% │     │     │         │
│ ├─────┼─────┼─────┼─────┤         │
│ │ ___ │ ___ │ ___ │ ___ │         │
│ │     │     │     │     │         │
│ └─────┴─────┴─────┴─────┘         │
│ [Selected: Slot 4] [Plant ▼]      │
│ [Harvest] [Destroy]               │
└────────────────────────────────────┘
```

---

### 2.5 Shop Browser (Priority: 🟠 MEDIUM)

**Estimated**: 2-3 days

**Features**:
- [ ] Shop list with tabs (Villager | Dark Merchant | Scam Villager)
- [ ] Item grid (5x4 recommendation)
- [ ] Item cards:
  - Icon & name
  - Price + currency icon
  - Stock info (if limited)
  - Time remaining (if limited)
  - Personal limit (if limited)
- [ ] Quick buy:
  - Quantity slider (1-99)
  - [Buy] button
- [ ] Sell panel:
  - Quick sell button (estimate value)
  - Identifier input (UUID or ItemId)
- [ ] Notifications:
  - Purchase limit reached
  - Out of stock
  - Time until restock

**UI Layout:**
```
┌──────────────────────────────────┐
│ [Villager] [Dark Merchant] [Scam] │
├──────────────────────────────────┤
│ [Item] [Item] [Item] [Item] [Item]│
│ [Item] [Item] [Item] [Item] [Item]│
│ ...                               │
│                                  │
│ Iron Sword                        │
│ Price: 100 Coin 🪙               │
│ Stock: 15/100 (Global)           │
│ Personal: 3/5                    │
│                                  │
│ Quantity: [====O] 5              │
│ [Buy] [Sell Items ▼]             │
└──────────────────────────────────┘
```

---

## 🚀 PHASE 3: ADVANCED FEATURES

### Priority: 🟠 MEDIUM | Estimated: 20-28 days

---

### 3.1 Upgrade System Completion (3-4 days)

**Current State**: 70% backend done

**Remaining**:
- [ ] Reroll mechanics (randomize stats on weapon)
- [ ] Blessing/Cursing system (positive/negative modifiers)
- [ ] Reversal options (pay Coin to downgrade)
- [ ] UI implementation
- [ ] Integration with ItemStats display

**Proposed APIs**:
```lua
UpgradeSystem:ProcessUpgrade(player, itemUUID, materialId, amount)
  -> { Success: bool, NewStats: table, Message: string }

UpgradeSystem:RerollStats(player, itemUUID)
  -> { Success: bool, OldStats: table, NewStats: table }

UpgradeSystem:ApplyBlessing(player, itemUUID, blessingType)
  -> { Success: bool, ModifierApplied: table }
```

---

### 3.2 Gemstone System Completion (3-4 days)

**Current State**: 20% design done

**Remaining**:
- [ ] Complete gem data definitions
- [ ] Socket insertion logic
- [ ] Gem removal logic
- [ ] Fusion/combining system
- [ ] UI for socket management
- [ ] Integration with item stats

**Proposed APIs**:
```lua
GemstoneSystem:InsertGem(player, itemUUID, socketSlot, gemId, gemLevel)
GemstoneSystem:RemoveGem(player, itemUUID, socketSlot)
GemstoneSystem:CombineGems(player, gem1UUID, gem2UUID, gem3UUID)
  -> { Success: bool, ResultGem: table }
```

---

### 3.3 Trading System (5-7 days)

**Status**: ❌ Not started

**Features**:
- [ ] Trade request system
- [ ] Trade verification (both items exist)
- [ ] Trade confirmation window
- [ ] Trade history & logs
- [ ] Trade limits (anti-abuse)
- [ ] Blacklist system

**Key Design Decisions Needed**:
1. Should trades be fee-based? (% Coin tax)
2. Trading limits (per day / per week)?
3. Can you trade gear with active Enchants?
4. Rollback on trade failure?

---

### 3.4 Guild System (5-7 days)

**Status**: ❌ Not started

**Features**:
- [ ] Create/join guilds
- [ ] Guild leader & permissions
- [ ] Guild treasury
- [ ] Guild storage (shared inventory)
- [ ] Guild permissions (roles)
- [ ] Guild chat
- [ ] Guild quests/missions

**Key Decision**: Persistent storage location? (DataStore or separate backend)

---

### 3.5 PvP Arena (7-10 days) - Optional

**Status**: ❌ Not started

**Features**:
- [ ] 1v1 duel system
- [ ] Tournament brackets
- [ ] Leaderboard
- [ ] Ranking system
- [ ] Reward distribution
- [ ] Anti-cheat measures

**Blocker**: Need game design document for PvP balance first.

---

## 🔧 PHASE 4: POLISH & OPTIMIZATION

### Priority: 🟡 LOW | Estimated: 8-14 days

---

### 4.1 Performance (2-3 days)

- [ ] Profile network traffic (Replica updates)
- [ ] Implement debouncing for frequent updates
- [ ] Cache commonly-accessed data
- [ ] Memory leak audit
- [ ] Load test with 100+ concurrent players

**Targets**:
- <50ms avg update latency
- <5MB memory per player profile
- <500KB/min network per player

---

### 4.2 Analytics & Logging (2-3 days)

- [ ] Player activity logging (crafts, trades, deaths)
- [ ] Economy monitoring (Coin sink/source)
- [ ] Telemetry dashboard
- [ ] Bug report system (in-game)
- [ ] Error tracking (Sentry or custom)

---

### 4.3 Content Expansion (3-5 days)

- [ ] 50+ new items
- [ ] 20+ new recipes
- [ ] 15+ new enchants
- [ ] Seasonal events
- [ ] Daily challenges

---

### 4.4 QoL Improvements (2-3 days)

- [ ] Hotkeys/keybindings
- [ ] Settings panel
- [ ] Localization (Vietnamese → other languages)
- [ ] Accessibility options
- [ ] Mobile support (if applicable)

---

## 📅 TIMELINE ESTIMATE

| Phase | Duration | Start | End |
|-------|----------|-------|-----|
| **Phase 1** (Core) | 2 weeks | ✅ Done | ✅ Done |
| **Phase 2** (UI) | 2-3 weeks | _Soon_ | - |
| **Phase 3** (Advanced) | 3-4 weeks | After Phase 2 | - |
| **Phase 4** (Polish) | 2-3 weeks | In parallel with Phase 3 | - |
| **TOTAL** | **10-13 weeks** | 2026-06-11 | ~2026-09-01 |

---

## 🎯 IMMEDIATE NEXT STEPS (Next 1-2 Weeks)

### Priority 1: Finalize Phase 1
- [ ] Complete Upgrade System backend (remaining 30%)
- [ ] Complete Gemstone System design
- [ ] Code review of all Systems
- [ ] Bug testing & fixes

### Priority 2: Prepare Phase 2
- [ ] Choose UI framework (Fusion recommended)
- [ ] Create UI mockups/wireframes
- [ ] Set up UI project structure
- [ ] Create Inventory UI component

### Priority 3: Documentation
- [ ] ✅ DOCUMENTATION.md (System overview)
- [ ] ✅ API_REFERENCE.md (API docs)
- [ ] [ ] DEV_GUIDE.md (for new team members)
- [ ] [ ] TESTING_GUIDE.md (test procedures)

---

## 🤝 TEAM COLLABORATION NOTES

**Currently Working On**:
- [ ] Solo development or team?
- [ ] Code review process?
- [ ] Deployment strategy?
- [ ] Testing methodology?

**Suggested Structure** (if team grows):
- **Backend Lead**: System architecture, data models
- **UI Lead**: Client UI, UX/design
- **QA Lead**: Testing, bug reports
- **Content Lead**: Item design, balance tuning

---

## 📝 NOTES

- **Risk**: Phase 2 (UI) can be slow if not careful with performance
- **Opportunity**: Monetization system design for Phase 3+
- **Tech Debt**: Consider refactoring ItemDatabase structure when 200+ items
- **Community**: Plan for feedback system early

---

**Created:** 2026-06-11  
**Last Updated:** 2026-06-11  
**Next Review:** After Phase 1 completion
