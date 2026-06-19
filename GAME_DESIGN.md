# 🎮 GAME DESIGN DOCUMENT - PROJECT W

**Official Title**: Project W: Roguelike Dungeon Crawler  
**Inspiration**: Slay The Spire 2 + Clair Obscur: Expedition 33  
**Version**: 2.0 (Updated with Skill System)  
**Status**: Phase 2 Development  
**Last Updated**: 2026-06-11

---

## 🎯 EXECUTIVE SUMMARY

Project W is a **Roguelike Dungeon Crawler with Skill-Based Real-Time Combat**. Players choose a class, learn skills through exploration, and progress through procedurally-generated dungeons with tactical decision-making at every step.

### Core Loop
```
1. Choose Class (Hunter/Warrior/Mage)
2. Select 2 starter skills
3. Enter Dungeon
4. Combat: Real-time action fights
5. After Room Clear: Pick 1 skill from 3 random options
6. Reach Campfire: Rest & Learn another skill
7. Scale Difficulty & Reach Boss
8. Victory: Save run, unlock permanent benefits
```

---

## 🎭 GAME VISION

### **What Makes It Unique?**

**Hybrid of Two Great Games:**
- 🎲 **Slay The Spire 2 Mechanics**: Roguelike progression, random reward selection, strategic choices
- ⚔️ **Clair Obscur Combat**: Real-time action, positioning matters, dodge/block timing

**Result**: Roguelike progression meets fast-paced real-time combat (not turn-based)

### **Target Audience**
- Roguelike enthusiasts (Hades, Slay The Spire players)
- Action RPG fans (ARPG mechanics + strategy)
- Skill-based competitive players (dodge, timing matter)
- Ages: 16+

---

## 🎮 CORE GAMEPLAY SYSTEMS

### **1. CLASS SYSTEM**

#### **Hunter** 🏹
**Playstyle**: Agile ranged DPS, high mobility
- **Stats**: 80 HP, 8 DMG, 14 SPD, 3 DEF
- **Starter Skills** (pick 2 from 3):
  - `Quick Shot` - Fast attack, 8% crit
  - `Evade` - Dodge next attack
  - `Multi-Shot` - AOE all enemies
- **Unique Mechanics**: Positioning-based damage (closer = more damage)

#### **Warrior** 🗡️
**Playstyle**: Tank, heavy melee, defense-focused
- **Stats**: 120 HP, 12 DMG, 6 SPD, 8 DEF
- **Starter Skills** (pick 2 from 3):
  - `Slash` - Heavy melee (12 dmg)
  - `Shield Bash` - Block + stun
  - `Whirlwind` - AOE melee around self
- **Unique Mechanics**: Damage reduction stacks, last-stand abilities

#### **Mage** 🔥
**Playstyle**: High AOE damage, resource management (Mana)
- **Stats**: 70 HP, 10 DMG, 10 SPD, 2 DEF, 150 Mana
- **Starter Skills** (pick 2 from 3):
  - `Fireball` - AOE (30 mana)
  - `Mana Shield` - Absorb damage with mana
  - `Teleport` - Dodge + reposition (60 mana)
- **Unique Mechanics**: Mana management, AOE damage priority

---

### **2. SKILL SYSTEM**

#### **Skill Slots & Learning**
```
Dungeon Progression:

[Start] → Pick 2 skills (Slots 1-2)
   ↓
[Room 1 Clear] → Skill offer (pick 1, Slot 3)
   ↓
[Room 3 Clear] → Skill offer (pick 1, Slot 4)
   ↓
[Campfire] → Rest + Skill offer (pick 1, Slot 5)
   ↓
[Campfire] → Rest + Skill offer (pick 1, Slot 6 - MAX)
   ↓
[Boss Room] → Fight with full kit
   ↓
[Victory] → Save run, skills available next run
```

#### **Skill Offering Algorithm**
After each room/campfire:
- Generate 3 random skills
- Filter: Not already owned, level requirement met
- Weighted by rarity (Common 50%, Uncommon 30%, Rare 15%, Epic 4%, Legendary 1%)
- Player picks 1

**Example Offer**:
```
Pick 1 Skill:
□ Fireball (Common) - 35 AOE dmg
□ Chain Lightning (Rare) - Jump between enemies
□ Meteor Storm (Epic) - Massive AOE (locked - depth 8+)
```

#### **50+ Skills Total**
- **Hunter**: 15 unique skills (Ranged, mobility, utility)
- **Warrior**: 15 unique skills (Melee, defense, crowd control)
- **Mage**: 15 unique skills (Magic, AOE, mana management)
- **Shared**: 5 universal skills (potions, escape, etc.)

---

### **3. REAL-TIME COMBAT SYSTEM**

#### **Combat Flow**

```
Arena Setup:
  Left:  Player character
  Right: 2-3 enemies
  
Real-time Gameplay:
  - Move: WASD (strafe/position)
  - Look: Mouse (aim/target)
  - Skills: Number keys 1-6
  
Skill Casting:
  1. Hold key to aim (see preview)
  2. Release to cast
  3. Animation plays
  4. Damage applied
  5. Cooldown starts
  
Enemy AI:
  - Approach player
  - Cast own abilities
  - React to player position
  
Victory:
  - All enemies HP = 0
  - Loot dropped
  - Skill offer shows
```

#### **Combat Mechanics**

| Mechanic | Details |
|----------|---------|
| **Health** | 0 HP = death/respawn at campfire |
| **Positioning** | Close range deals more damage |
| **Cooldowns** | Skills have per-skill cooldowns (8-40s) |
| **Mana** (Mage) | Mages manage mana pool, regenerate slowly |
| **Status Effects** | Poison (DoT), Burn (DoT), Stun (disable), Bleed (DoT) |
| **Dodge** | Some skills have dodge/invulnerability frames |
| **Interrupt** | Can interrupt enemy skills with stunning abilities |

---

### **4. DUNGEON SYSTEM**

#### **Dungeon Generation**
- **Size**: 10-15 rooms per run
- **Boss Room**: Always at depth 10
- **Room Types** (weighted):
  - Combat: 50% (fight enemies)
  - Treasure: 20% (loot items)
  - Shop: 15% (buy/sell items)
  - Campfire/Rest: 10% (heal + learn skill)
  - Boss: 5% (final fight)

#### **Difficulty Scaling**
```
Depth 1: 1.0x difficulty
Depth 3: 1.2x difficulty (enemies +20% HP & DMG)
Depth 5: 1.5x difficulty
Depth 10: 2.0x (Boss) difficulty
```

#### **Room Mechanics**

**Combat Room**:
- 2-3 mobs spawn
- Loot on defeat
- Skill offer after

**Treasure Room**:
- 1-3 chests
- Multiple rare items
- No combat

**Shop**:
- Buy/sell items
- Heal for gold
- Sell excess loot

**Campfire** (Rest Area):
- Restore 50% health
- Learn new skill
- Meditate (optional stat boost)
- Safe zone

**Boss Room**:
- 1 elite boss enemy
- High HP, special abilities
- Epic loot on defeat

---

### **5. ROGUELIKE PROGRESSION**

#### **Permanent Benefits (After Runs)**
- Unlock new skills (for future runs)
- Improve equipment
- Increase proficiency levels (unlock harder content)
- Unlock new classes/skills

#### **Current Run**
- Temporary buffs (only this run)
- Learned skills (only this run)
- Inventory (reset on exit)

#### **Profile Progression**
- Lifetime stats (total damage, runs completed)
- Unlocked content (classes, skills, items)
- Best run records (damage dealt, rooms cleared)

---

## 🎨 UI/UX FLOW

### **Main Menu**
```
┌─────────────────────────┐
│   Project W             │
├─────────────────────────┤
│                         │
│  [Enter Dungeon]        │
│  [Stats]                │
│  [Settings]             │
│  [Exit]                 │
│                         │
└─────────────────────────┘
```

### **Class Selection**
```
┌──────────────────────────────────┐
│ Choose Your Class               │
├──────────────────────────────────┤
│                                  │
│ [Hunter]  [Warrior]  [Mage]     │
│  Ranged    Tank       Magic      │
│  80 HP    120 HP      70 HP      │
│                                  │
└──────────────────────────────────┘
```

### **Skill Selection (Start)**
```
┌──────────────────────────────────┐
│ Choose 2 Starter Skills         │
├──────────────────────────────────┤
│                                  │
│ [Quick Shot]  [Evade]  [Multi]  │
│   (8 dmg)      (dodge)  (AOE)   │
│                                  │
│ [Confirm]                        │
└──────────────────────────────────┘
```

### **Combat UI**
```
Top Left:
┌────────────────────────┐
│ [████░] 80/120 HP      │
│ [██████] 100/150 Mana  │
│ Room: 3/10 | Depth: 1 │
└────────────────────────┘

Bottom (Skills):
┌─────────────────────────────────────┐
│ [1]       [2]       [3]  [4] [5][6] │
│ Fire      Tele      MS   [x] [x][x] │
│ 0s/12s   0s/30s     12s   -   -  -  │
└─────────────────────────────────────┘

Right (Combat Log):
Enemy 1: Slash (12 dmg)
You: Fireball (35 dmg to all)
Enemy 2: Healed (5 hp)
```

### **Skill Offer (Room Clear)**
```
┌──────────────────────────────────────┐
│ Room Cleared! Pick a Skill          │
├──────────────────────────────────────┤
│                                      │
│ [Fireball]     [Chain Lightning]    │
│ 35 AOE dmg     Jump enemies         │
│                                      │
│ [Meteor Storm] (Locked - depth 8+)  │
│                                      │
│ [Skip] (1 use left)                 │
└──────────────────────────────────────┘
```

---

## ⚙️ BALANCE PHILOSOPHY

### **Core Principles**
1. **Skill Variety**: 50+ skills ensures multiple viable strategies
2. **Class Balance**: Each class strong in different scenarios
3. **Difficulty Ramp**: Progressive challenge (1.1x per depth)
4. **Decision Points**: Strategic choices at skill selection, not overpowering
5. **Comeback Mechanics**: Good skill picks can overcome bad RNG

### **Balance Parameters**
```lua
-- Difficulty per depth
EnemyHealthMultiplier = 1.0 + (depth * 0.1)
EnemyDamageMultiplier = 1.0 + (depth * 0.05)

-- Skill offer frequency
SkillOfferAfterRooms = 1    -- After EVERY room
CampfireFrequency = 5        -- Every 5 rooms

-- Rarity drops
CommonChance = 50%
UncommonChance = 30%
RareChance = 15%
EpicChance = 4%
LegendaryChance = 1%
```

---

## 🗺️ DEVELOPMENT ROADMAP

### **Phase 1: Core Systems** ✅ 85%
- Inventory, Crafting, Enchanting
- Farming, Shop, Dismantling
- Player Stats

### **Phase 2: Roguelike Foundations** 🔄
**Week 1-2**: Class & Skill System
- Class definitions
- 50+ skill definitions
- Skill learning logic

**Week 2-3**: Real-Time Combat
- Replace turn-based with real-time
- Input handling (1-6 keys)
- Damage calculation

**Week 3-4**: Dungeon & Progression
- Procedural generation
- Campfire mechanics
- Instance management

### **Phase 3: Polish** ⏳
- Balance tuning
- Animation/VFX
- Sound design
- UI polish

---

## 📊 GAME STATS (Target)

| Stat | Value |
|------|-------|
| **Average Run Length** | 30-45 minutes |
| **Skill Pick Decisions** | 6-8 decisions per run |
| **Combat Encounters** | 6-8 per run |
| **Replayability** | 100+ unique runs (skill combinations) |
| **Skill Mastery Curve** | 5-10 runs to feel "skilled" |

---

## 🚀 SUCCESS METRICS

### **Gameplay**
- ✅ Players can complete a dungeon run
- ✅ 30+ min average session
- ✅ Want to retry with different strategies
- ✅ Feel progression (skills → power)

### **Content**
- ✅ 50+ skills (variety)
- ✅ 3 classes feel distinct
- ✅ 15+ room types
- ✅ 100+ equipment combinations

### **Technical**
- ✅ Real-time combat smooth (60 FPS)
- ✅ No lag in multiplayer instances
- ✅ Save/load working perfectly
- ✅ Procedural generation fast (<1s)

---

## 🎬 EXAMPLE GAMEPLAY SESSION

```
[Player Starts Game]

1. Menu → [Enter Dungeon]
2. Class Select → Pick Mage
3. Skill Select → Pick Fireball + Teleport
4. Dungeon Starts (Room 1)
5. Combat: 2 Goblins
   - Cast Fireball (35 AOE dmg)
   - Teleport away (dodge enemy attack)
   - Enemies defeated
6. Skill Offer → Pick Chain Lightning
7. Room 2: Treasure Room
   - Find Iron Ore + Potion
8. Room 3: Combat - Bandits
   - Use Chain Lightning on group
   - Victory
9. Skill Offer → Pick Meteor Storm
10. Room 4: Campfire
    - Heal 50 HP
    - Learn Frost Nova
11. Rooms 5-9: Combat progression
    - Getting harder (1.5x difficulty)
    - Learning new skills
12. Room 10: Boss Fight
    - Goblin King (300 HP, multiple abilities)
    - Intense battle using all 6 skills
    - VICTORY!
13. Results Screen
    - Damage dealt: 2400
    - Rooms cleared: 10/10
    - Skills learned: 8
    - [Save Run] [Main Menu]
```

---

## 🎯 FINAL VISION

**Project W** aims to be a **Roguelike for Skill Enthusiasts** - combining the strategic decision-making of Slay The Spire with the fast-paced action of real-time combat games.

Every run feels unique because:
- Different class choices
- Different skill combinations
- Different room ordering
- Different difficulty encounters

Players will chase the perfect run - finding the ultimate skill synergy and executing it flawlessly.

---

**Version**: 2.0  
**Status**: Design Locked - Ready to Implement  
**Approval**: ✅ Approved for Development

