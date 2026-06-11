# 🎮 PROJECT W - GAME SYSTEMS DOCUMENTATION

**Version:** 0.1 | **Ngôn ngữ:** Luau (Roblox) | **Cập nhật:** 2026-06-11

---

## 📋 MỤC LỤC
1. [Tổng Quan Hệ Thống](#tổng-quan-hệ-thống)
2. [Kiến Trúc Cơ Bản](#kiến-trúc-cơ-bản)
3. [Các Systems Chính](#các-systems-chính)
4. [Data Flow & API Mapping](#data-flow--api-mapping)
5. [Hướng Dẫn Sử Dụng](#hướng-dẫn-sử-dụng)
6. [Kế Hoạch Tiếp Theo](#kế-hoạch-tiếp-theo)

---

## 🎯 TỔNG QUAN HỆ THỐNG

Project W là một **Game Farming/Crafting/Enchanting** được xây dựng trên nền tảng **Roblox** với kiến trúc **Server-Client** hiện đại. Hệ thống sử dụng **Replica** để đồng bộ dữ liệu real-time và **ProfileStore** để lưu trữ dữ liệu người chơi.

### Đặc Điểm Chính:
- ✅ Hệ thống kho đồ (Inventory) với 3 loại: Items, Consumables, Materials
- ✅ Chế tạo đồ (Crafting) với công thức linh hoạt
- ✅ Phát động bộ (Enchanting) với rune logic phức tạp
- ✅ Canh tác (Farming) với thời gian thực và thu hoạch lặp lại
- ✅ Cửa hàng (Shop) với hỗ trợ giới hạn toàn cầu
- ✅ Phân rã vật phẩm (Dismantling) với kế thừa chỉ số
- ✅ Hệ thống chỉ số (Stats) với Professions & Leveling
- ✅ Nâng cấp trang bị (Upgrade) - _Sắp triển khai_

---

## 🏗️ KIẾN TRÚC CƠ BẢN

### 1. Server Architecture

```
ServerScriptService/
├── ServerMain.server.luau          # Entry point - Auto-load tất cả Systems
├── Systems/
│   ├── DataStore.luau               # Quản lý dữ liệu & ProfileStore
│   ├── Inventory.luau               # Quản lý túi đồ
│   ├── Crafting.luau                # Chế tạo vật phẩm
│   ├── Enchanting.luau              # Phát động bộ với Rune
│   ├── Farming.luau                 # Canh tác & thu hoạch
│   ├── Shop.luau                    # Mua/bán hàng
│   ├── Dismantling.luau             # Phân rã vật phẩm
│   ├── PlayerStats.luau             # Quản lý tiền & kinh nghiệm
│   ├── Upgrade.luau                 # Nâng cấp trang bị (Dev)
│   └── Gemstone.luau                # Hệ thống ngọc (Dev)
└── Network/
    └── module.luau                  # Communication gateway

ReplicatedStorage/
├── Constants/
│   ├── ItemData/                    # Định nghĩa vật phẩm
│   │   ├── Items/
│   │   ├── Materials/
│   │   ├── Consumables/
│   │   └── init.luau
│   ├── CraftingRecipes.luau         # Công thức chế tạo
│   ├── EnchantData/                 # Định nghĩa bùa
│   ├── PlantData/                   # Định nghĩa cây trồng
│   └── ShopData/                    # Định nghĩa cửa hàng
├── Components/
│   ├── ItemData.luau                # Factory tạo Item
│   ├── StackableData.luau           # Factory tạo Stackable
│   ├── ItemTemplate.luau            # Template vật phẩm
│   ├── EnchantTemplate.luau         # Template bùa
│   ├── PlantTemplate.luau           # Template cây trồng
│   └── Stats.luau                   # Template chỉ số
└── Utilities/
    ├── LevelingCalculator.luau      # Tính Level từ Exp
    └── ReplicaClient.luau           # Client Replica handler
```

### 2. Data Structure - ProfileTemplate

```lua
PROFILE = {
  Core = {              -- Dữ liệu cơ bản nhân vật
    Level,              -- Cấp độ chính
    Exp,                -- Kinh nghiệm
    Playtime,           -- Thời gian chơi
    Zone,               -- Khu vực hiện tại
    Awakened            -- Đã tỉnh thức chưa
  },
  
  Currencies = {        -- Tiền tệ
    Coin                -- Đơn vị tiền chính
  },
  
  Attributes = {        -- Chỉ số chiến đấu
    UnspentPoints,      -- Điểm tiềm năng chưa dùng
    Strength,           -- Sức mạnh
    Intelligence,       -- Trí tuệ
    Dexterity,          -- Nhanh nhẹn
    Vitality,           -- Sức sống
    Looting,            -- Nhặt hái
    Proficiency         -- Thành thạo
  },
  
  Professions = {       -- Kỹ năng nghề
    Combat,             -- Chiến đấu
    Farming,            -- Canh tác
    Crafting,           -- Chế tạo
    Enchanting,         -- Phát động
    Gemcrafting,        -- Chế tác ngọc
    ...
  },
  
  Inventories = {       -- Kho đồ
    Items = {},         -- Trang bị độc nhất (UUID)
    Consumables = {},   -- Thực phẩm (Stackable)
    Materials = {}      -- Nguyên liệu (Stackable)
  },
  
  Equipped = {          -- Trang bị trên người
    MainGear = {        -- Trang bị chính
      Weapon,
      Offhand,
      Helmet, ...
    },
    Accessories = {},   -- Phụ kiện (9 slot)
    Fishing = {},       -- Công cụ câu cá
    Ranged = {},        -- Công cụ bắn
    Special = {}        -- Công cụ đặc biệt
  },
  
  Farming = {           -- Hệ thống canh tác
    Crops = {},         -- Cây trồng theo ô đất
    Trees = {}          -- Cây ăn quả theo ô đất
  },
  
  Bank = {},            -- Ngân hàng
  Land = {},            -- Đất đai
  Quests = {            -- Nhiệm vụ
    Active = {},
    Completed = {}
  },
  ShopHistory = {}      -- Lịch sử mua hàng (Limited Shop)
}
```

### 3. Item Data Structure

**Unique Item (vũ khí, giáp, phụ kiện):**
```lua
ItemData = {
  UUID = "xxx-xxx-xxx",           -- ID duy nhất
  Id = "Iron Sword",              -- ID vật phẩm
  BindState = "Unlocked",         -- Trạng thái khóa (Locked/Unlocked)
  UpgradeCount = 0,               -- Số lần nâng cấp
  Purity = 0,                     -- Độ tinh khiết
  Corruption = 0,                 -- Mức ô nhiễm
  Aura = nil,                     -- Hiệu ứng khí tượng
  CustomName = nil,               -- Tên tùy chỉnh
  UpgradeHistory = {},            -- Lịch sử nâng cấp
  State = {},                     -- Trạng thái tùy chỉnh
  NBT = {},                       -- Named Binary Tag (dữ liệu mở rộng)
  Enchants = [                    -- Danh sách bùa
    { Id = "Sharpness", Level = 1 },
    { Id = "Life Steal", Level = 2 }
  ],
  Gems = {}                       -- Danh sách ngọc lắp
}

StackableData = {                 -- Vật phẩm có thể xếp chồng
  Id = "Wood",                    -- ID vật phẩm
  Amount = 64,                    -- Số lượng
  NBT = {                         -- Dữ liệu mở rộng
    PlantId = "Wheat"             -- Ví dụ: Loại hạt giống
  }
}
```

---

## ⚙️ CÁC SYSTEMS CHÍNH

### 1. **Inventory System** (`Inventory.luau`)
Quản lý toàn bộ kho đồ của người chơi.

#### APIs Chính:
```lua
-- 1. Cấp phát vật phẩm độc nhất
InventorySystem:GiveItem(player: Player, Id: string) -> UUID

-- 2. Cấp phát vật phẩm stackable (với NBT)
InventorySystem:GiveStackable(
  player: Player, 
  category: string,         -- "Consumables" hoặc "Materials"
  Id: string, 
  amount: number, 
  customNBT: table?
)

-- 3. Tìm vị trí vật phẩm bằng UUID
InventorySystem:FindItemLocationByUUID(player: Player, uuid: string)
  -> { Location = "Inventory/Equipped", Index/Slot = ... }

-- 4. Xóa vật phẩm bằng UUID
InventorySystem:RemoveItemByUUID(player: Player, uuid: string) -> bool

-- 5. Trừ vật phẩm stackable (với NBT)
InventorySystem:RemoveStackable(
  player: Player,
  category: string,
  Id: string,
  amountToRemove: number,
  targetNBT: table?
) -> bool

-- 6. Cập nhật dữ liệu vật phẩm
InventorySystem:UpdateItemData(player: Player, uuid: string, newItemData: table) -> bool

-- 7. Cấp phát vật phẩm với dữ liệu tùy chỉnh
InventorySystem:GiveCustomItem(player: Player, customItemData: table) -> bool
```

**Lệnh Chat Test:**
```
/giveitem [ItemId]                  -- Nhận 1 vật phẩm
/givestackable [ItemId] [Amount]    -- Nhận N vật phẩm stackable
/removestackable [ItemId] [Amount]  -- Xóa N vật phẩm stackable
/testlocation                       -- Kiểm tra vị trí vật phẩm đầu tiên
/clearinventory                     -- Xóa sạch kho
```

---

### 2. **Crafting System** (`Crafting.luau`)
Chế tạo vật phẩm từ nguyên liệu và công thức.

#### APIs Chính:
```lua
-- Thực hiện chế tạo
CraftingSystem:ProcessCraft(
  player: Player,
  recipeId: string,
  mainItemIndex: number?,    -- Vật phẩm gốc (nếu là công thức nâng cấp)
  craftAmount: number?       -- Số lượng chế tạo
) -> { Success: bool, Message: string }
```

#### Dữ Liệu Công Thức:
```lua
Recipe = {
  MainIngredient = "Iron Sword",        -- Phôi nâng cấp (tùy chọn)
  Inputs = [
    { Id = "Iron", BaseAmount = 5 },
    { Id = "Coal", BaseAmount = 2 }
  ],
  Outputs = [
    { Id = "Steel Ingot", Amount = 2 }
  ],
  Requirements = {
    Professions = {
      Crafting = 15                     -- Yêu cầu nghề
    }
  },
  ExpGains = {
    Crafting = 100                      -- Exp được cộng
  }
}
```

**Lệnh Chat Test:**
```
/craft [RecipeId] [MainItemIndex?] [Amount?]
-- VD: /craft "Steel Ingot" 1 5       (chế tạo 5 lô)
-- VD: /craft "Upgrade Helmet" 1      (nâng cấp mũ ở vị trí 1)
```

---

### 3. **Enchanting System** (`Enchanting.luau`)
Phát động bộ vật phẩm bằng rune với xác suất và modifiers phức tạp.

#### APIs Chính:
```lua
-- Thực hiện phát động
EnchantSystem:ProcessEnchant(
  player: Player,
  targetItemIndex: number,
  runeIndex: number
) -> { Success: bool, Message: string }

-- Tẩy bùa (disenchant)
EnchantSystem:DisenchantItem(player: Player, targetItemIndex: number)
  -> { Success: bool, Message: string, ExpGained?: number }
```

#### Rune Logic (Dữ Liệu Rune):
```lua
RuneLogic = {
  Attribute = "Sharpness",            -- Thuộc tính chính
  Tokens = 5,                         -- Số token phát động
  Luck = 50,                          -- Tăng trọng số hiếm hơi
  EnchantingExp = 200,                -- Exp được cộng
  Modifiers = {
    MinRarity = "Uncommon",           -- Chỉ lấy bùa từ Uncommon+
    MaxRarity = "Epic",               -- Chỉ lấy bùa đến Epic
    OnlyRarity = nil,                 -- Chỉ lấy rarity cụ thể
    ExcludeEnchants = {"Fake"}        -- Bù từ nào bị loại bỏ
  }
}
```

#### Enchant Data:
```lua
Enchant = {
  Rarity = "Rare",                    -- Common/Uncommon/Rare/Epic/Legendary/Mythic
  BaseWeight = 50,                    -- Trọng số baseline
  Conditions = { Enchanting = 20 },   -- Yêu cầu cấp độ nghề
  AcceptTypes = {"Sword", "Weapon"}, -- Loại vũ khí chấp nhận
  MaxLevel = 5,                       -- Cấp độ tối đa
  MaxEnchants = 5                     -- Bùa tối đa trên vật phẩm
}
```

**Lệnh Chat Test:**
```
/enchant [TargetItemIndex] [RuneIndex] [true?]
/disenchant [TargetItemIndex] [true?]
```

---

### 4. **Farming System** (`Farming.luau`)
Canh tác cây trồng và cây ăn quả với thời gian thực.

#### APIs Chính:
```lua
-- Cấp phát hạt giống động
FarmingSystem:GiveSeedPack(player: Player, plantId: string, amount: number)

-- Gieo hạt
FarmingSystem:PlantSeed(
  player: Player,
  seedInvIndex: number,
  slotId: string
) -> { Success: bool, Message: string }

-- Thu hoạch
FarmingSystem:HarvestPlant(player: Player, slotId: string)
  -> { Success: bool, Message: string }

-- Nhổ bỏ cây
FarmingSystem:DestroyPlant(player: Player, slotId: string)

-- Tính trạng thái cây
FarmingSystem:CalculatePlantState(plantData: table)
  -> (isReady: bool, currentStage: number, timeLeft: number)
```

#### Plant Data:
```lua
Plant = {
  Id = "Wheat",
  Type = "Crops",                     -- Crops hoặc Trees
  GrowthTime = 300,                   -- Thời gian trưởng thành (giây)
  Stages = 5,                         -- Số stage tăng trưởng
  FarmingExp = 50,                    -- Exp nhận được
  HarvestYield = [
    { Id = "Wheat", Min = 3, Max = 5, Chance = 1.0 },
    { Id = "Seed Pack", Min = 1, Max = 2, Chance = 0.5 }
  ],
  HarvestBehavior = {
    RepeatInterval = 600,             -- Thời gian tái sinh
    HarvestTimes = 3                  -- Số lần thu hoạch tối đa
  }
}
```

**Lệnh Chat Test:**
```
/giveseed [PlantId] [Amount?]
/plant [SeedInvIndex] [SlotId]
/harvest [SlotId]
/destroyplant [SlotId]
/checkplant [SlotId]
```

---

### 5. **Shop System** (`Shop.luau`)
Mua/bán hàng hóa với hỗ trợ giới hạn toàn cầu.

#### APIs Chính:
```lua
-- Mua hàng
ShopSystem:BuyItem(
  player: Player,
  shopId: string,
  itemIndex: number,
  amount: number
) -> { Success: bool, Message: string }

-- Bán hàng
ShopSystem:SellItem(
  player: Player,
  identifier: string,     -- UUID hoặc ItemId
  amount: number
) -> { Success: bool, Message: string }

-- Xem cửa hàng
ShopSystem:ViewShop(shopId: string)
  -> { Success: bool, Message: string }
```

#### Shop Data:
```lua
Shop = {
  Name = "Villager",
  Currency = "Coin",                  -- Loại tiền
  IsGlobalLimited = false,            -- Là limited shop?
  Items = [
    {
      Id = "Iron Sword",
      PriceMultiplier = 1.2,          -- Nhân giá gốc
      UpgradeCount = 1,               -- Mặc định nâng cấp
      MaxPerPurchase = 5,             -- Giới hạn mua/phiên
      GlobalStock = 100,              -- Kho hàng toàn cầu
      StartTime = 1719576000,         -- Lúc bắt đầu bán
      EndTime = nil,                  -- Lúc kết thúc bán
      RestockInterval = 86400         -- Thời gian tái kho (giây)
    }
  ]
}
```

**Lệnh Chat Test:**
```
/buy [ShopId] [ItemIndex] [Amount?]
/sell [UUID or ItemId] [Amount?]
/viewshop [ShopId]
```

---

### 6. **Dismantling System** (`Dismantling.luau`)
Phân rã vật phẩm để nhận nguyên liệu lại.

#### APIs Chính:
```lua
-- Phân rã vật phẩm
DismantleSystem:ProcessDismantle(player: Player, itemIndex: number)
  -> { Success: bool, Message: string }
```

#### Dismantle Rules:
```lua
DismantleDrops = [
  {
    Id = "Wood",
    Chance = 0.8,                     -- Xác suất rơi
    Min = 5,
    Max = 10,
    KeepStats = nil                   -- Không kế thừa gì
  },
  {
    Id = "Iron Ingot",
    Chance = 0.5,
    Min = 2,
    Max = 4,
    KeepStats = nil
  },
  {
    Id = "Tool",
    Chance = 0.3,
    KeepStats = "EnchantsOnly"        -- Kế thừa chỉ bùa & ngọc
  }
]
```

**Lệnh Chat Test:**
```
/dismantle [ItemIndex] [true?]
```

---

### 7. **PlayerStats System** (`PlayerStats.luau`)
Quản lý tiền, kinh nghiệm và chỉ số nhân vật.

#### APIs Chính:
```lua
-- Tiền tệ
PlayerStatSystem:HasCurrency(player, type, amount) -> bool
PlayerStatSystem:AddCurrency(player, type, amount)
PlayerStatSystem:RemoveCurrency(player, type, amount) -> bool

-- Kinh nghiệm chính
PlayerStatSystem:AddExp(player, amount)

-- Chỉ số chiến đấu
PlayerStatSystem:AddAttribute(player, attributeName, amount)

-- Kinh nghiệm nghề
PlayerStatSystem:AddProfessionExp(player, profName, amount)
```

**Lệnh Chat Test:**
```
/addcoin [Amount?]
/addexp [Amount?]
/addprofexp [ProfName] [Amount?]
/debug
```

---

### 8. **Upgrade System** (_Trong phát triển_) (`Upgrade.luau`)
Nâng cấp trang bị để tăng chỉ số.

---

### 9. **Gemstone System** (_Trong phát triển_) (`Gemstone.luau`)
Lắp đặt ngọc vào vật phẩm để tăng hiệu năng.

---

## 📊 DATA FLOW & API MAPPING

### 1. Luồng Dữ Liệu Khi Chế Tạo

```
Player Chat: /craft "Steel Ingot" 1 5
    ↓
CraftingSystem:ProcessCraft()
    ├─ Kiểm tra Requirements (Crafting Level)
    ├─ Xác minh nguyên liệu (Wood x 5, Coal x 2)
    ├─ Gọi InventorySystem:RemoveStackable() × N
    ├─ Tạo Item mới bằng ItemFactory.createNewItem()
    ├─ Gọi InventorySystem:GiveCustomItem()
    ├─ Gọi PlayerStatSystem:AddProfessionExp()
    └─ Return { Success: true, Message: "..." }
    ↓
Client nhận Message → UI cập nhật
```

### 2. Luồng Dữ Liệu Khi Phát Động

```
Player Chat: /enchant 1 2
    ↓
EnchantSystem:ProcessEnchant()
    ├─ Lấy Item[1] & Rune[2]
    ├─ Kiểm tra MaxEnchants
    ├─ Loop Tokens từ Rune:
    │   ├─ GetNewEnchantPool() → Lọc bùa mới
    │   ├─ GetUpgradeEnchantPool() → Lọc bùa nâng cấp
    │   ├─ RollFromPool() → Chọn bùa đã lọc
    │   └─ Thêm/Nâng cấp vào Enchants[]
    ├─ Gọi InventorySystem:RemoveStackable() (Rune)
    ├─ Gọi InventorySystem:UpdateItemData() (Item mới)
    ├─ Gọi PlayerStatSystem:AddProfessionExp()
    └─ Return { Success: true, Message: "..." }
```

### 3. Luồng Khi Canh Tác & Thu Hoạch

```
Timeline Canh Tác:
─────────────────────────────────────────
t=0s: Plant gieo hạt
     PlantedTime = os.time()
     LastHarvestTime = 0
     
t=300s: Cây chín
     CalculatePlantState() return true
     
Player: /harvest slot1
     HarvestPlant()
     ├─ Kiểm tra isReady
     ├─ Loop HarvestYield[]
     │   └─ math.random() ≤ Chance?
     │       └─ GiveStackable() các loot
     ├─ AddProfessionExp(Farming)
     └─ Check RepeatInterval?
        ├─ Có: LastHarvestTime = os.time()
        └─ Không: Xóa plant khỏi slot
```

### 4. Luồng Mua Hàng Limited

```
Player: /buy "ShopId" 1 1
    ↓
ShopSystem:BuyItem()
    ├─ GetItemSessionInfo() → sessionKey = "ShopId_ItemId_Session_N"
    ├─ Kiểm tra StartTime/EndTime
    ├─ Kiểm tra MaxPerPurchase (cá nhân)
    │   └─ profile.Data.ShopHistory[sessionKey].Bought
    ├─ Trừ tiền: RemoveCurrency()
    ├─ Cập nhật GlobalShopStockMap (MemoryStore)
    │   └─ UpdateAsync() → Atomic decrement kho toàn cầu
    ├─ Cập nhật ShopHistory cá nhân
    └─ GiveItem/GiveStackable() → Thêm vào kho
```

---

## 🔗 API LIÊN KẾT & DEPENDENCIES

### Dependency Graph

```
ItemDatabase (Constants)
    ↓
    ├─→ InventorySystem
    │   ├─→ CraftingSystem
    │   ├─→ EnchantingSystem
    │   ├─→ FarmingSystem
    │   ├─→ ShopSystem
    │   └─→ DismantlingSystem
    │
    ├─→ EnchantData (Constants)
    │   └─→ EnchantingSystem
    │
    ├─→ CraftingRecipes (Constants)
    │   └─→ CraftingSystem
    │
    ├─→ PlantDatabase (Constants)
    │   └─→ FarmingSystem
    │
    └─→ ShopDatabase (Constants)
        └─→ ShopSystem

DataManager (DataStore)
    ↓
    └─→ TẤT CẢ Systems (Mọi System cần Profile)

PlayerStatSystem
    ↓
    ├─→ CraftingSystem
    ├─→ EnchantingSystem
    ├─→ FarmingSystem
    └─→ ShopSystem

LevelingCalculator
    ↓
    ├─→ CraftingSystem
    ├─→ EnchantingSystem
    └─→ PlayerStatSystem
```

### Cross-System Data Updates

| Sự Kiện | Trigger | Hệ Thống Chính | Hệ Thống Phụ | Dữ Liệu Thay Đổi |
|--------|---------|--------------|------------|-----------------|
| Chế tạo | /craft | Crafting | Inventory, PlayerStats | Items -/+ Materials +, Professions.Crafting +, Coin ± |
| Phát động | /enchant | Enchanting | Inventory, PlayerStats | Item.Enchants[], Professions.Enchanting +, Materials - |
| Nhặt hái | /harvest | Farming | Inventory, PlayerStats | Crops/Trees[], Materials +, Professions.Farming +, Playtime + |
| Mua hàng | /buy | Shop | Inventory, PlayerStats | Items/Materials +, Coin -, ShopHistory +/- |
| Bán hàng | /sell | Shop | Inventory, PlayerStats | Items/Materials -, Coin + |
| Phân rã | /dismantle | Dismantling | Inventory, PlayerStats | Items -, Materials +, Professions.Crafting + |

---

## 📖 HƯỚNG DẪN SỬ DỤNG

### Chế Tạo Vật Phẩm Mới

1. **Định nghĩa vật phẩm** trong `src/ReplicatedStorage/Shared/Constants/ItemData/Items/[Name].luau`:
```lua
return {
  Id = "Mystic Sword",
  Name = "Mystic Sword",
  Rarity = "Legendary",
  ItemType = "Weapon",
  Type = "Sword",
  BuyPrice = 500,
  SellPrice = 250,
  MaxEnchants = 5,
  DismantleDrops = {
    { Id = "Steel Ingot", Chance = 0.8, Min = 3, Max = 5 }
  }
}
```

2. **Thêm vào ItemDatabase** trong `init.luau`:
```lua
require(script:WaitForChild("Mystic Sword"))
```

3. **Tạo công thức trong CraftingRecipes**:
```lua
["Mystic Sword"] = {
  Inputs = {
    { Id = "Steel Ingot", BaseAmount = 10 },
    { Id = "Mana Crystal", BaseAmount = 5 }
  },
  Outputs = {
    { Id = "Mystic Sword", Amount = 1 }
  },
  Requirements = {
    Professions = { Crafting = 20 }
  },
  ExpGains = { Crafting = 500 }
}
```

### Thêm Bùa Mới

1. **Định nghĩa bùa** trong `src/ReplicatedStorage/Shared/Constants/EnchantData/[Name].luau`:
```lua
return {
  Id = "Fire Burst",
  Name = "Fire Burst",
  Rarity = "Epic",
  BaseWeight = 30,
  Conditions = { Enchanting = 25 },
  AcceptTypes = { "Sword", "Staff" },
  MaxLevel = 3,
  Effects = {
    { Stat = "Damage", Modifier = 1.5, PerLevel = 0.25 }
  }
}
```

2. **Thêm vào EnchantData** trong `init.luau`.

### Tạo Cây Trồng

1. **Định nghĩa cây** trong `src/ReplicatedStorage/Shared/Constants/PlantData/[Name].luau`:
```lua
return {
  Id = "Apple Tree",
  Name = "Apple Tree",
  Type = "Trees",
  GrowthTime = 600,
  Stages = 4,
  FarmingExp = 100,
  HarvestYield = {
    { Id = "Apple", Min = 3, Max = 5, Chance = 1.0 }
  },
  HarvestBehavior = {
    RepeatInterval = 300,
    HarvestTimes = 5
  }
}
```

2. **Thêm vào PlantDatabase** trong `init.luau`.

### Tạo Cửa Hàng

1. **Định nghĩa cửa hàng** trong `src/ReplicatedStorage/Shared/Constants/ShopData/[Name].luau`:
```lua
return {
  Id = "Weapon Merchant",
  Name = "Weapon Merchant",
  Currency = "Coin",
  IsGlobalLimited = false,
  Items = {
    {
      Id = "Iron Sword",
      PriceMultiplier = 1.0
    }
  }
}
```

---

## 🚀 KỀ HOẠCH TIẾP THEO

### Phase 1: Core Systems (Hiện Tại ✅)
- ✅ Inventory System
- ✅ Crafting System
- ✅ Enchanting System
- ✅ Farming System
- ✅ Shop System
- ✅ Dismantling System
- ✅ PlayerStats System
- 🔄 Upgrade System (70%)
- 🔄 Gemstone System (20%)

### Phase 2: Client UI (Priority: 🔴 HIGH)
**Mục tiêu:** Tạo giao diện người dùng cho tất cả systems

#### 2.1 Main Inventory UI
- [ ] Hiển thị 3 túi đồ: Items, Materials, Consumables
- [ ] Drag & drop items
- [ ] Xem chi tiết vật phẩm
- [ ] Quick sell/dismantle
- [ ] NBT editor (cho PlantId)

#### 2.2 Crafting Panel
- [ ] Danh sách công thức
- [ ] Filter by Profession/Category
- [ ] Craft amount selector
- [ ] Main ingredient selector
- [ ] Material checker (highlight missing)

#### 2.3 Enchanting Panel
- [ ] Item selector
- [ ] Rune selector
- [ ] Preview: Enchant pool + weights
- [ ] Enchant history log
- [ ] Disenchant button

#### 2.4 Farming Dashboard
- [ ] Farm plot grid (visual representation)
- [ ] Growth progress bar
- [ ] Seed inventory
- [ ] Quick plant/harvest
- [ ] Plant info tooltip

#### 2.5 Shop Browser
- [ ] Shop list & filter
- [ ] Item cards với stock info
- [ ] Buy quantity selector
- [ ] Global/Personal limit display
- [ ] Sell quick panel

### Phase 3: Advanced Features (Priority: 🟠 MEDIUM)

#### 3.1 Upgrade System (Completion)
- [ ] Equipment leveling mechanics
- [ ] Blessing/Cursing system
- [ ] Reroll stats
- [ ] Upgrade UI panel

#### 3.2 Gemstone System (Completion)
- [ ] Socket equipment
- [ ] Combine gems
- [ ] Gem fusion
- [ ] Gem UI

#### 3.3 Trading System
- [ ] Player-to-player trading
- [ ] Trade interface
- [ ] Trade history
- [ ] Escrow mechanism

#### 3.4 Guild System
- [ ] Create/join guild
- [ ] Guild storage
- [ ] Guild permissions
- [ ] Guild quests

#### 3.5 PvP Arena (Optional)
- [ ] 1v1 duels
- [ ] Tournament brackets
- [ ] Leaderboard
- [ ] Reward distribution

### Phase 4: Polish & Optimization (Priority: 🟡 LOW)

#### 4.1 Performance
- [ ] Reduce network updates
- [ ] Optimize Replica syncing
- [ ] Caching strategy
- [ ] Memory cleanup

#### 4.2 Analytics
- [ ] Player activity logging
- [ ] Economy monitoring
- [ ] Bug report system
- [ ] Telemetry dashboard

#### 4.3 Content Expansion
- [ ] New items/recipes
- [ ] New enchants/gems
- [ ] Seasonal events
- [ ] Daily challenges

#### 4.4 Bug Fixes & QoL
- [ ] Inventory UI improvements
- [ ] Error message localization
- [ ] Keybindings customization
- [ ] Settings menu

---

## 🔧 DEVELOPMENT TIPS

### Debugging
```lua
-- In game console:
/debug                  -- Dump toàn bộ profile
/giveitem [Id]         -- Cấp phát vật phẩm
/addcoin 1000          -- Cộng tiền
/addprofexp Crafting 500  -- Cộng exp nghề
```

### Testing Crafting
```lua
/addprofexp Crafting 1000    -- Đạt level cao
/givestackable Iron 50
/givestackable Coal 50
/craft "Steel Ingot" 1 10    -- Chế tạo
```

### Testing Enchanting
```lua
/giveitem "Iron Sword"
/givestackable "Common Rune" 5
/enchant 1 1
```

### Testing Farming
```lua
/giveseed Wheat 10
/plant 1 slot1              -- Gieo
-- Chờ 5 phút hoặc tăng GrowthTime = 1 trong PlantData
/harvest slot1
```

---

## 📝 NOTES & FUTURE CONSIDERATIONS

### Known Limitations
1. **NBT System**: Hiện chỉ support PlantId, cần mở rộng cho các use-case khác
2. **Global Shop Stock**: Dùng MemoryStore, sẽ reset khi server tắt (không persistent)
3. **Enchanting Pool**: Có thể lag nếu quá nhiều loại bùa (optimize needed)
4. **No Rollback**: Nếu player gặp lỗi mid-transaction, không có cách undo

### Architecture Decisions
- ✅ **Replica vs DataStore**: Replica cho real-time sync, DataStore cho persistence
- ✅ **UUID cho Items**: Ensures uniqueness, dễ track enhancement history
- ✅ **Stackable vs Unique**: Tách biệt rõ ràng, avoid edge cases
- ✅ **Constants Database**: Tập trung quản lý, dễ balance

### Performance Considerations
- Mỗi RemoveStackable() scan từ cuối lên (O(n))
- EnchantPool generation có thể được cache nếu item không đổi
- Global shop sync dùng MemoryStore (network optimized)

---

## 📧 CONTACT & SUPPORT

Dự án được quản lý tại: `d:\Project W`  
Git Branch: `main`  
Latest Commit: `v0.1 - Add crafting, dismantling, enchanting, and gemstone systems`

---

**Last Updated:** 2026-06-11  
**Documentation Version:** 1.0  
**Status:** ✅ In Active Development
