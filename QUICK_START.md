# 🚀 PROJECT W - QUICK START GUIDE

**For:** New developers, architects, content creators  
**Read Time:** 5-10 minutes  
**Last Updated:** 2026-06-11

---

## 📌 TL;DR - PROJECT W là gì?

**Project W** là một game **Farming + Crafting + RPG** được xây dựng trên **Roblox Luau**. Toàn bộ hệ thống backend đã hoàn thành, hiện cần phát triển giao diện người dùng (UI).

### Kiến Trúc:
- **Server**: 9 systems độc lập (Inventory, Crafting, Enchanting, Farming, Shop, v.v.)
- **Data**: Replica (real-time sync) + ProfileStore (persistence)
- **Client**: Chưa có (cần phát triển Phase 2)

### Trạng Thái:
- ✅ Phase 1 (Backend): 85% complete
- ❌ Phase 2 (UI): Not started
- 🔄 Phase 3-4: Planned

---

## 🎯 QUICK FACTS

| Khía Cạnh | Chi Tiết |
|-----------|---------|
| **Ngôn Ngữ** | Luau (Roblox) |
| **Kiến Trúc** | Server-Client (Replica-based) |
| **Hệ Thống Chính** | 9 (Inventory, Crafting, Enchanting, Farming, Shop, Dismantling, Stats, Upgrade, Gemstone) |
| **Dữ Liệu** | ProfileStore + Replica |
| **Item Loại** | 3 (Unique Items, Stackables - Materials/Consumables) |
| **Tiền Tệ** | 1 (Coin - có thể expand) |
| **Professions** | 9 (Crafting, Enchanting, Farming, Combat, Fishing, v.v.) |
| **Cây Trồng** | 2+ loại (Wheat, Apple Tree) |
| **Cửa Hàng** | 3+ loại (Villager, Dark Merchant, Scam Villager) |
| **Bùa (Enchants)** | 6+ loại (Sharpness, Life Steal, Fire Burst, v.v.) |

---

## 🏃 GÓP PHẦN NHANH NHẤT

### 1️⃣ Muốn thêm Vật Phẩm mới?
**Thời gian: 5 phút**

```lua
-- 1. Tạo file: src/ReplicatedStorage/Shared/Constants/ItemData/Items/My Item.luau
return {
  Id = "My Item",
  Name = "My Item",
  Rarity = "Rare",
  ItemType = "Weapon",
  Type = "Sword",
  BuyPrice = 500,
  SellPrice = 250,
  MaxEnchants = 5
}

-- 2. Thêm vào init.luau
require(script:WaitForChild("My Item"))

-- 3. Test
/giveitem "My Item"
```

---

### 2️⃣ Muốn thêm Công Thức Chế Tạo?
**Thời gian: 3 phút**

```lua
-- Mở: src/ReplicatedStorage/Shared/Constants/CraftingRecipes.luau
["My Recipe"] = {
  Inputs = {
    { Id = "Wood", BaseAmount = 5 },
    { Id = "Iron", BaseAmount = 3 }
  },
  Outputs = {
    { Id = "My Item", Amount = 1 }
  },
  Requirements = {
    Professions = { Crafting = 10 }
  },
  ExpGains = { Crafting = 100 }
}

-- Test
/addprofexp Crafting 500
/givestackable Wood 10
/givestackable Iron 10
/craft "My Recipe"
```

---

### 3️⃣ Muốn thêm Bùa (Enchant) mới?
**Thời gian: 5 phút**

```lua
-- 1. Tạo file: src/ReplicatedStorage/Shared/Constants/EnchantData/My Enchant.luau
return {
  Id = "My Enchant",
  Name = "My Enchant",
  Rarity = "Rare",
  BaseWeight = 50,
  Conditions = { Enchanting = 20 },
  AcceptTypes = { "Sword", "Weapon" },
  MaxLevel = 5
}

-- 2. Thêm vào init.luau
require(script:WaitForChild("My Enchant"))

-- 3. Test
/giveitem "Iron Sword"
/givestackable "Uncommon Rune" 10
/enchant 1 1
```

---

### 4️⃣ Muốn thêm Cây Trồng mới?
**Thời gian: 5 phút**

```lua
-- 1. Tạo file: src/ReplicatedStorage/Shared/Constants/PlantData/My Plant.luau
return {
  Id = "My Plant",
  Name = "My Plant",
  Type = "Crops",
  GrowthTime = 300,
  Stages = 4,
  FarmingExp = 50,
  HarvestYield = {
    { Id = "My Item", Min = 3, Max = 5, Chance = 1.0 }
  }
}

-- 2. Thêm vào init.luau
require(script:WaitForChild("My Plant"))

-- 3. Test
/giveseed "My Plant" 5
/plant 1 slot1
-- Chờ 5 phút
/harvest slot1
```

---

## 🔧 DEBUGGING COMMANDS

```lua
/debug                              -- Xem profile đầy đủ
/addcoin 1000                       -- Cộng tiền
/addexp 500                         -- Cộng Exp chính
/addprofexp [ProfName] [Amount]     -- Cộng Exp nghề
/giveitem [ItemId]                  -- Nhận vật phẩm
/givestackable [ItemId] [Amount]    -- Nhận stackable
/craft [RecipeId] [MainIdx?] [Amt?] -- Chế tạo
/enchant [ItemIdx] [RuneIdx]        -- Phát động
/harvest [SlotId]                   -- Thu hoạch
/buy [ShopId] [ItemIdx] [Amt]       -- Mua hàng
/sell [UUID or ItemId] [Amt]        -- Bán hàng
```

---

## 📚 DOCUMENTATION FILES

| File | Nội Dung | Cho Ai |
|------|----------|--------|
| **DOCUMENTATION.md** | Tổng quan kiến trúc, tất cả 9 systems, data flow | Architects, Backend devs |
| **API_REFERENCE.md** | Chi tiết API, parameters, examples, error handling | Backend devs, integrators |
| **ROADMAP.md** | Kế hoạch 4 phases, timeline, tasks | Project managers, tech leads |
| **QUICK_START.md** | This file! Bắt đầu nhanh nhất | New devs, content creators |

---

## 🎨 NEXT: Giai Đoạn Phát Triển UI (Phase 2)

### Ước tính: 2-3 tuần | Priority: 🔴 CRITICAL

**Cần phát triển:**
1. **Inventory UI** (3-4 days)
   - Hiển thị Items, Materials, Consumables
   - Drag & drop
   - Quick sell/dismantle

2. **Crafting Panel** (2-3 days)
   - Danh sách công thức
   - Material checker
   - Craft controls

3. **Enchanting Panel** (2-3 days)
   - Item + Rune selector
   - Preview pool
   - Disenchant button

4. **Farming Dashboard** (2-3 days)
   - Farm plot grid
   - Seed inventory
   - Growth tracker

5. **Shop Browser** (2-3 days)
   - Item grid
   - Buy/sell quick actions
   - Stock display

---

## 💡 TIPS FOR CONTRIBUTORS

### For Content Creators (Adding Items/Recipes):
1. Định nghĩa vật phẩm trong Constants
2. Thêm vào ItemDatabase init.luau
3. Test bằng chat commands
4. Không cần chạy cả game, chỉ cần test trên server

### For Backend Developers (Adding Systems):
1. Đặt file mới trong `Server/Systems/`
2. Implement `:Init()` & `:Start()` methods
3. ServerMain tự động load & gọi
4. Tích hợp với DataManager & InventorySystem

### For Frontend Developers (Building UI):
1. Chưa bắt đầu - chờ Phase 2
2. Suggest: Dùng **Fusion** library (Roblox)
3. Ưu tiên: Inventory UI trước (blocker cho toàn bộ UI)

---

## ❓ FAQ

**Q: Có test automation không?**  
A: Hiện chưa có. Dùng chat commands để test thủ công.

**Q: Có multiplayer support không?**  
A: Có! Mỗi player có riêng profile, Replica đồng bộ real-time.

**Q: Mỗi vật phẩm có thể có bao nhiêu Enchants?**  
A: Tối đa 5 (MaxEnchantLines). Có thể điều chỉnh trong CraftingRecipes.

**Q: Khi player logout, dữ liệu có được lưu không?**  
A: Có! ProfileStore lưu tự động khi player rời.

**Q: Có PvP không?**  
A: Chưa. Nằm trong Phase 3 (planned).

**Q: Có thể mod/cheat không?**  
A: Khó. Toàn bộ logic ở Server, Client chỉ nhận dữ liệu.

---

## 🚀 GETTING STARTED (3 BƯỚC)

### Step 1: Khám Phá Code
```bash
cd d:\Project W
code .
```

### Step 2: Hiểu Architecture
```
Đọc: DOCUMENTATION.md → Mục "KIẾN TRÚC CƠ BẢN"
```

### Step 3: Chạy Game & Test
```
1. Open Roblox Studio
2. Run game locally
3. Test bằng chat: /debug → xem profile
```

---

## 📧 NEXT STEPS

- [ ] **For New Developers**: Đọc DOCUMENTATION.md + chạy thử game
- [ ] **For Content Creators**: Thêm 5-10 vật phẩm mới test
- [ ] **For UI Developers**: Lên kế hoạch Phase 2 UI framework
- [ ] **For Project Manager**: Review ROADMAP.md, adjust timeline

---

## 🎉 SUMMARY

```
Project W = Roblox Game với 9 Backend Systems
Status = 85% Done (chỉ thiếu UI)
Next = Build Client UI (Inventory, Crafting, Enchanting, Farming, Shop)
Timeline = 2-3 weeks cho Phase 2
Contribution = Dễ! Thêm items/recipes/enchants chỉ cần 3-5 phút
```

---

**Happy Coding! 🚀**

Nếu có câu hỏi, refer lại:
- 📚 **DOCUMENTATION.md** (System overview)
- 📖 **API_REFERENCE.md** (API details)  
- 🗺️ **ROADMAP.md** (Development plan)

---

*Last Updated: 2026-06-11*  
*Questions? Check other docs or ask team lead!*
