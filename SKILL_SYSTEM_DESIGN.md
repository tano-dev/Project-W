# ⚡ SKILL SYSTEM - COMPLETE DESIGN

**Game Style**: Slay The Spire 2 (Roguelike Skill Selection) + Clair Obscur (Real-time Combat)  
**Status**: Design Phase - Ready to Implement  
**Last Updated**: 2026-06-11

---

## 🎮 OVERVIEW

**Project W** is now a **Roguelike Dungeon Crawler with Skill-Based Combat**:
- 🎭 **3 Classes** (Hunter, Warrior, Mage) với khác nhau skill pool
- ⚡ **6-Slot Skill System** (Bắt đầu với 2 skills, learn up to 6)
- 🔥 **Real-time Combat** (Action-based, không turn-based)
- 🗺️ **Procedural Dungeons** (Slay The Spire style)
- 🎁 **Campfire Mechanic** (Rest area để học skill mới)
- 🎲 **Random Skill Offering** (3 skills ngẫu nhiên sau mỗi phòng)

---

## 📊 CLASS SYSTEM

### **Hunter**
**Playstyle**: Agile, Ranged, High Mobility

**Starter Skills** (Pick 2):
- `Quick Shot` - Fast attack, 8% crit chance
- `Evade` - Dodge next attack (1 turn cooldown)
- `Multi-Shot` - Attack all enemies (12s cooldown)

**Unique Pool** (Legendary/Rare):
- `Headshot` - Instant kill weak enemies
- `Camouflage` - Become invisible (5 turns)
- `Barrage` - Rapid fire succession
- `Hunter's Mark` - Weakness on target
- `Piercing Arrow` - Ignore armor

**Stats**:
- Base Health: 80
- Base Damage: 8
- Base Speed: 14
- Base Defense: 3

---

### **Warrior**
**Playstyle**: Tanky, Heavy Damage, Defense-Based

**Starter Skills** (Pick 2):
- `Slash` - Heavy melee attack, 12 damage
- `Shield Bash` - Block attack + stun
- `Whirlwind` - AOE damage around self (18s cooldown)

**Unique Pool** (Legendary/Rare):
- `Rage` - Boost damage 2x for 3 turns
- `Last Stand` - Tank massive damage, recover 50% after turn
- `Cleave` - AOE melee attack
- `Iron Skin` - +80% defense (4 turns)
- `Earthquake` - Stun all enemies

**Stats**:
- Base Health: 120
- Base Damage: 12
- Base Speed: 6
- Base Defense: 8

---

### **Mage**
**Playstyle**: High Damage, AOE, Resource Management (Mana)

**Starter Skills** (Pick 2):
- `Fireball` - AOE damage (costs 30 Mana)
- `Mana Shield` - Absorb damage with Mana
- `Teleport` - Dodge + reposition (60 Mana)

**Unique Pool** (Legendary/Rare):
- `Meteor Storm` - Rain massive damage AOE
- `Frost Nova` - Freeze all enemies
- `Chain Lightning` - Jump between enemies
- `Time Warp` - Skip enemy turn
- `Inferno` - Burn all enemies continuously

**Stats**:
- Base Health: 70
- Base Damage: 10
- Base Speed: 10
- Base Defense: 2
- Base Mana: 150

---

## ⚡ SKILL SYSTEM MECHANICS

### **Skill Slots**
- **Start**: 2 skill slots filled (player choice)
- **Max**: 6 skill slots total
- **Unlock**: Each campfire/rest area → learn 1 new skill

### **Skill Offering System**
```
After defeating a room:
1. Generate random 3 skills
2. Filter out duplicates (can't have 2 Fireballs)
3. Show UI: "Pick 1 skill"
4. Player selects → Add to inventory

Example:
┌─────────────────────────────┐
│  Choose New Skill           │
├─────────────────────────────┤
│ [Fireball]  [Frost Nova]   │
│                             │
│ [Chain Lightning]           │
│                             │
│ [Skip] (Can skip once/run)  │
└─────────────────────────────┘
```

### **Skill Structure**
```lua
Skill = {
  Id = "Fireball",
  Name = "Fireball",
  Class = "Mage",                    -- Only for Mage?
  Description = "Deal 35 damage AOE",
  Icon = "rbxassetid://xxx",
  
  CombatStats = {
    Damage = 35,
    Area = "AOE",                   -- AOE, Melee, Single
    ManaCost = 30,
    Cooldown = 12,
    HitChance = 1.0
  },
  
  Effects = {
    { Type = "Burn", Duration = 3, DamagePerTurn = 5 }
  },
  
  Requirements = {
    ClassOnly = "Mage",             -- nil = all classes
    MinDungeonDepth = 0,
    MinProficiency = 0
  },
  
  Rarity = "Common",
  Weight = 100                       -- Để weighted random
}
```

### **Skill Learning Progression**

| Event | Action |
|-------|--------|
| **Start Dungeon** | Pick 2 skills → Fill slots 1-2 |
| **Room 1 Clear** | Get 3-skill offer → Pick 1 (Slot 3) |
| **Room 3 Clear** | Get 3-skill offer → Pick 1 (Slot 4) |
| **Campfire/Rest** | Get 3-skill offer → Pick 1 (Slot 5) |
| **Campfire/Rest** | Get 3-skill offer → Pick 1 (Slot 6) |
| **Dungeon Exit** | Skills saved to profile (optional) |

---

## 🏕️ CAMPFIRE MECHANIC

### **What is Campfire?**
Safe room where player can:
1. Rest & heal
2. Learn new skill
3. Manage inventory
4. Save progress

### **Campfire Offering**

```lua
Campfire = {
  RoomType = "Rest",
  HealAmount = 50,                   -- Restore 50% health
  SkillOffer = 3,                    -- Show 3 random skills
  
  Actions = {
    "Rest & Heal",
    "Learn Skill",
    "Meditate (boost stats)"
  }
}
```

### **UI Flow**

```
Room Clear (Combat Room)
    ↓
[Show: Continue / Campfire]
    ↓
If Campfire:
  ├─ Restore 50% Health
  ├─ Show: "Learn New Skill"
  │   ├─ [Skill 1] [Skill 2] [Skill 3]
  │   └─ [Skip] (can skip once per dungeon)
  └─ Back to Dungeon Map
```

---

## 🎲 SKILL POOL GENERATION

### **Algorithm**

```lua
function GenerateSkillOffer(playerClass, currentSkills, dungeonDepth)
  local availableSkills = {}
  
  -- 1. Get all skills (filter by class)
  for skillId, skillDef in pairs(SkillDatabase) do
    if not skillDef.ClassOnly or skillDef.ClassOnly == playerClass then
      -- 2. Filter: Not already owned
      if not currentSkills[skillId] then
        -- 3. Filter: Depth requirement
        if skillDef.Requirements.MinDungeonDepth <= dungeonDepth then
          table.insert(availableSkills, skillId)
        end
      end
    end
  end
  
  -- 4. Pick 3 random, weighted by rarity
  local chosen = {}
  for i = 1, 3 do
    local picked = WeightedRandom(availableSkills)
    table.insert(chosen, picked)
    table.remove(availableSkills, picked)  -- No duplicates
  end
  
  return chosen
end
```

### **Rarity Weighting**

| Rarity | Weight | Drop Chance |
|--------|--------|------------|
| Common | 100 | 50% |
| Uncommon | 70 | 30% |
| Rare | 35 | 15% |
| Epic | 10 | 4% |
| Legendary | 2 | 1% |

---

## ⚔️ REAL-TIME COMBAT SYSTEM

### **Combat Flow**

```
1. Player enters Combat Room
   ├─ Scene: 3D arena
   ├─ Player on left
   └─ Enemies on right (2-3)
   
2. Real-time action starts
   ├─ Player can move (WASD)
   ├─ Look around (Mouse)
   └─ Cast skills (Number keys: 1-6 for skill slots)
   
3. Skill Cast
   ├─ Hold key for aim preview
   ├─ Release to cast
   ├─ Animation plays
   ├─ Damage applied
   └─ Cooldown starts
   
4. Enemy Actions
   ├─ Each enemy: AI decides action
   ├─ Move toward player
   ├─ Cast own ability
   ├─ Deal damage → Player health -= dmg
   
5. Victory Condition
   ├─ All enemies health = 0
   ├─ Loot dropped
   ├─ Return to map
   └─ Skill offer (pick 1 new)
   
6. Defeat Condition
   ├─ Player health = 0
   ├─ Respawn at last campfire
   ├─ Or exit dungeon (lose run)
```

### **UI in Combat**

```
┌─ Top Left: Player Health ─────────────────────────┐
│ [████████░] 80/120 HP                             │
│                                                   │
│ Skills: [1] [2] [3] [4] [5] [6]                   │
│         Cooldown indicators below each             │
│                                                   │
├─ Enemy Health Bars ────────────────────────────────┤
│ Enemy 1 [██░] 45/50                               │
│ Enemy 2 [████] 80/80                              │
│ Enemy 3 [░░░░░] 0/60 [DEAD]                       │
│                                                   │
└─ Combat Log (Right) ───────────────────────────────┘
  You cast: Fireball (35 dmg)
  Enemy 1: Slash (12 dmg)
```

---

## 💾 DATA STRUCTURES

### **SkillDatabase Structure**

```lua
SkillDatabase = {
  ["Fireball"] = {
    Id = "Fireball",
    Name = "Fireball",
    Class = "Mage",
    Rarity = "Common",
    CombatStats = {...},
    Effects = {...}
  },
  ["Slash"] = {...},
  ["Evade"] = {...},
  -- ... 50+ skills total
}
```

### **Player Profile - Skills**

```lua
Profile.Data.Combat = {
  SelectedClass = "Mage",
  
  Skills = {
    [1] = "Fireball",           -- Current run skills
    [2] = "Teleport",
    [3] = "Mana Shield",
    [4] = nil,                  -- Empty slot
    [5] = nil,
    [6] = nil
  },
  
  SkillsMastered = {            -- Permanent profile progress
    ["Fireball"] = { Level = 2, Exp = 150 },
    ["Teleport"] = { Level = 1, Exp = 50 }
  },
  
  CurrentRun = {
    Depth = 5,
    SkillsLearned = ["Fireball", "Teleport", "Mana Shield"],
    RoomsCleaned = 5,
    BossDefeated = false
  }
}
```

---

## 🎯 NEW SYSTEMS TO BUILD

### **1. ClassSystem**
```lua
ClassSystem:SelectClass(player, className) -> bool
  -- Save class choice
  -- Validate (Hunter/Warrior/Mage)
  -- Generate starter skills
```

### **2. SkillSystem**
```lua
SkillSystem:GetClassSkills(className) -> table
  -- Return all skills for class
  
SkillSystem:GenerateSkillOffer(player, count) -> table
  -- Return N random skills (weighted, no duplicates)
  
SkillSystem:LearnSkill(player, skillId) -> bool
  -- Add to skill slots
  -- Check max 6 slots
  
SkillSystem:CastSkill(player, skillId, targetPos) -> {Damage, Effects}
  -- Execute skill
  -- Apply cooldown
  -- Trigger effects
```

### **3. CombatSystem (Real-time)**
```lua
CombatSystem:StartCombat(player, enemyIds) -> bool
  -- Load enemies
  -- Initialize combat state
  -- Start real-time loop
  
CombatSystem:ProcessPlayerAction(player, skillId, targetPos) -> results
  -- Cast skill
  -- Calculate damage
  -- Update health
  
CombatSystem:ProcessEnemyAI(enemy) -> action
  -- Decide enemy action
  -- Skill or move
  
CombatSystem:CheckVictory(combatState) -> bool
  -- All enemies dead?
```

### **4. CampfireSystem**
```lua
CampfireSystem:EnterCampfire(player) -> bool
  -- Show UI
  -- Heal player
  
CampfireSystem:OfferSkillReward(player) -> table
  -- Generate 3 skills
  -- Wait for player choice
  
CampfireSystem:LearnSkillFromCampfire(player, skillId) -> bool
  -- Add to inventory
  -- Update UI
```

---

## 📁 FILE STRUCTURE (New/Modified)

```
src/ReplicatedStorage/Shared/Constants/

├── ClassData/                   [NEW]
│   ├── init.luau
│   ├── Hunter.luau
│   ├── Warrior.luau
│   └── Mage.luau
│
├── SkillData/                   [NEW]
│   ├── init.luau
│   ├── HunterSkills.luau        # Quick Shot, Evade, Multi-Shot, etc.
│   ├── WarriorSkills.luau       # Slash, Shield Bash, Whirlwind, etc.
│   ├── MageSkills.luau          # Fireball, Teleport, Mana Shield, etc.
│   └── CommonSkills.luau        # Shared skills (if any)
│
└── [Update] MobData/
    └── (Mobs have skills too?)

src/ServerScriptService/Server/Systems/

├── ClassSystem.luau             [NEW]
├── SkillSystem.luau             [NEW]
├── CombatSystem.luau            [MODIFIED - Real-time]
├── CampfireSystem.luau          [NEW]
└── [Update] RoomSpawnSystem.luau (Add campfire room type)

src/StarterPlayer/Client/Systems/

├── CombatVisualSystem.luau      [NEW] Real-time graphics
├── SkillCastSystem.luau         [NEW] Input handling (1-6 keys)
├── CombatUISystem.luau          [NEW] Health bars, skill icons, log
└── [Update] MinimapSystem.luau  (Add campfire icon)
```

---

## 🔄 PROGRESSION FLOW

### **Game Flow**

```
1. Main Menu
   └─ [Enter Dungeon]
   
2. Class Selection UI
   ├─ Hunter
   ├─ Warrior
   └─ Mage
   
3. Starter Skill Selection
   ├─ Pick 2 from class pool (Hunter: 3 options, etc.)
   └─ [Confirm]
   
4. Dungeon Starts
   ├─ Enter at Room 1
   ├─ Combat
   └─ Victory → Skill Offer (3 choices, pick 1)
   
5. Next Room
   ├─ Map shows next room type icon
   ├─ If Campfire: Heal + Skill Offer
   ├─ If Combat: Fight enemies → Skill Offer
   ├─ If Treasure: Loot items
   └─ If Boss: Final fight
   
6. Boss Room (Room 10+)
   ├─ Harder enemies (scaled stats)
   ├─ Victory → Legendary skill offer (1/5 pick)
   └─ Defeat → Respawn at Campfire or exit
   
7. Dungeon Complete
   ├─ Stats screen (damage dealt, rooms cleared)
   ├─ Save run data
   └─ Back to menu
```

---

## 🎮 EXAMPLE: HUNTER CLASS SKILL TREE

### **Common Skills** (Start with 1-2)
| Skill | Damage | Cooldown | Effect |
|-------|--------|----------|--------|
| Quick Shot | 8 | 2s | 8% crit |
| Evade | 0 | 12s | Dodge next (1 turn) |
| Multi-Shot | 6x2 | 12s | Hit all enemies |

### **Uncommon Skills** (Room 3+)
| Skill | Damage | Cooldown | Effect |
|-------|--------|----------|--------|
| Headshot | 40 | 20s | Instakill weak |
| Piercing Arrow | 25 | 8s | Ignore armor |
| Poison Arrow | 10 | 10s | Poison 3 turns |

### **Rare Skills** (Room 6+)
| Skill | Damage | Cooldown | Effect |
|-------|--------|----------|--------|
| Camouflage | 0 | 30s | Invisible 5 turns |
| Barrage | 5x5 | 25s | Rapid fire |
| Hunter's Mark | 0 | 15s | Weakness |

### **Epic Skills** (Room 10+)
| Skill | Damage | Cooldown | Effect |
|-------|--------|----------|--------|
| Deadeye | 80 | 40s | Guaranteed kill |
| Multibarrage | 8x8 | 45s | AOE rapid |

---

## ⚙️ BALANCE PARAMETERS

### **Combat Balance**

```lua
GameConfig = {
  Combat = {
    PlayerHealthBase = 100,
    EnemyHealthScaling = 1.1,           -- +10% per depth
    DamageScaling = 1.05,               -- +5% per depth
    CooldownScaling = 0.95,             -- Skills scale faster
    
    SkillRewardFrequency = 3,           -- Every 3 rooms
    CampfireFrequency = 5,              -- Every 5 rooms
    SkillOfferCount = 3,                -- Pick 1 from 3
    SkipChance = 1,                     -- Can skip once per run
  }
}
```

### **Class Balance**

| Class | HP | DMG | DEF | SPD | Role |
|-------|----|----|-----|-----|------|
| Hunter | 80 | 8 | 3 | 14 | Ranged DPS |
| Warrior | 120 | 12 | 8 | 6 | Tank |
| Mage | 70 | 10 | 2 | 10 | Magical AOE |

---

## 🚀 IMPLEMENTATION PRIORITY

### **Week 1: Foundations**
- [ ] ClassSystem.luau (select class, starter skills)
- [ ] SkillData/ definitions (50+ skills)
- [ ] SkillSystem.luau (learn, manage skills)

### **Week 2: Combat**
- [ ] Real-time CombatSystem (replace turn-based)
- [ ] SkillCastSystem.luau (input 1-6 keys)
- [ ] CombatVisualSystem.luau (animations, VFX)

### **Week 3: UI & Progression**
- [ ] CampfireSystem.luau (rest & learn)
- [ ] CombatUISystem.luau (health bars, skill icons)
- [ ] Skill offer UI (3 choices)

### **Week 4: Polish**
- [ ] Balance tuning
- [ ] Animation polish
- [ ] Sound design

---

## 🎬 VISUAL REFERENCE

**Combat Scene**:
```
        [Enemy 1]  [Enemy 2]  [Enemy 3]
           HP         HP         HP
           
           
           
                    [3D Arena]
           
                    
           
        [PLAYER]
           
      [Skill 1] [Skill 2] [Skill 3]
      [Skill 4] [Skill 5] [Skill 6]
      
      Cooldown timers below each
```

---

**Version**: 1.0  
**Status**: Design Complete - Ready to Code  
**Estimated Implementation**: 4 weeks (Phase 2.1-2.4)

