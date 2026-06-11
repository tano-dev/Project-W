# 📚 PROJECT W - API REFERENCE GUIDE

**Version:** 1.0 | **Updated:** 2026-06-11

---

## 🗂️ QUICK NAVIGATION

- [Inventory API](#inventory-api)
- [Crafting API](#crafting-api)
- [Enchanting API](#enchanting-api)
- [Farming API](#farming-api)
- [Shop API](#shop-api)
- [Dismantling API](#dismantling-api)
- [PlayerStats API](#playerstats-api)
- [Common Patterns](#common-patterns)
- [Error Handling](#error-handling)

---

## 💾 INVENTORY API

### GiveItem()
Cấp phát một vật phẩm độc nhất (trang bị).

```lua
local uuid = InventorySystem:GiveItem(player, "Iron Sword")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật nhận vật phẩm |
| `Id` | string | ID vật phẩm từ ItemDatabase |

| Returns | Type | Description |
|---------|------|-------------|
| UUID | string | ID duy nhất vật phẩm, hoặc nil nếu fail |

**Example:**
```lua
local uuid = InventorySystem:GiveItem(player, "Iron Sword")
if uuid then
  print("Cấp phát thành công! UUID:", uuid)
else
  print("Vật phẩm không tồn tại")
end
```

---

### GiveStackable()
Cấp phát vật phẩm có thể xếp chồng (nguyên liệu, thực phẩm).

```lua
InventorySystem:GiveStackable(player, "Materials", "Iron", 64, customNBT)
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player` | Player | ✅ | Nhân vật nhận |
| `category` | string | ✅ | "Materials" hoặc "Consumables" |
| `Id` | string | ✅ | ID vật phẩm |
| `amount` | number | ✅ | Số lượng cấp phát |
| `customNBT` | table | ❌ | Dữ liệu mở rộng (e.g., {PlantId = "Wheat"}) |

**Example - Cấp hạt giống:**
```lua
local customNBT = { PlantId = "Wheat" }
InventorySystem:GiveStackable(player, "Materials", "Seed Pack", 5, customNBT)
```

**Example - Cấp nguyên liệu thường:**
```lua
InventorySystem:GiveStackable(player, "Materials", "Wood", 100)
```

**Behavior:**
- Tự động gộp vào stack hiện có nếu đủ chỗ
- Tạo stack mới nếu toàn bộ stacks hiện có đều đầy
- Kế thừa MaxStack từ ItemDatabase
- Chỉ gộp nếu NBT giống y hệt nhau

---

### FindItemLocationByUUID()
Tìm vị trí vật phẩm bằng UUID (trong túi hay đang mặc).

```lua
local location = InventorySystem:FindItemLocationByUUID(player, uuid)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `uuid` | string | UUID vật phẩm |

| Returns | Type | Description |
|---------|------|-------------|
| location | table or nil | {Location: "Inventory/Equipped", Index/Slot: ...} |

**Example:**
```lua
local loc = InventorySystem:FindItemLocationByUUID(player, uuid)
if loc then
  if loc.Location == "Inventory" then
    print("Vật phẩm ở túi, vị trí:", loc.Index)
  elseif loc.Location == "Equipped" then
    print("Vật phẩm đang mặc:", loc.Category, loc.Slot)
  end
else
  print("Không tìm thấy")
end
```

---

### RemoveItemByUUID()
Xóa vật phẩm độc nhất bằng UUID (hỗ trợ xóa cả khi đang mặc).

```lua
local success = InventorySystem:RemoveItemByUUID(player, uuid)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `uuid` | string | UUID vật phẩm |

| Returns | Type | Description |
|---------|------|-------------|
| success | bool | true nếu xóa thành công |

---

### RemoveStackable()
Trừ vật phẩm stackable (hỗ trợ NBT filtering).

```lua
local success = InventorySystem:RemoveStackable(player, "Materials", "Wheat", 10, {PlantId = "Wheat"})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player` | Player | ✅ | Nhân vật |
| `category` | string | ✅ | "Materials" hoặc "Consumables" |
| `Id` | string | ✅ | ID vật phẩm |
| `amountToRemove` | number | ✅ | Số lượng trừ |
| `targetNBT` | table | ❌ | Chỉ trừ stack có NBT này |

| Returns | Type | Description |
|---------|------|-------------|
| success | bool | true nếu đủ để trừ |

**Example - Trừ vật phẩm thường:**
```lua
if InventorySystem:RemoveStackable(player, "Materials", "Iron", 5) then
  print("Trừ thành công")
else
  print("Không đủ sắt")
end
```

**Example - Trừ chỉ Wheat từ Wheat Plant (có NBT):**
```lua
local targetNBT = { PlantId = "Wheat" }
if InventorySystem:RemoveStackable(player, "Materials", "Seed Pack", 1, targetNBT) then
  print("Trừ hạt Wheat thành công")
else
  print("Không có hạt Wheat")
end
```

**Behavior:**
- Trừ từ stack **cuối cùng** lên (reverse order)
- Chỉ trừ từ stack có NBT giống `targetNBT`
- Return false nếu tổng số không đủ

---

### UpdateItemData()
Cập nhật toàn bộ dữ liệu vật phẩm (dùng cho Enchant, Upgrade, v.v.).

```lua
local newItemData = table.clone(oldItemData)
newItemData.Enchants = {{Id = "Sharpness", Level = 1}}
local success = InventorySystem:UpdateItemData(player, uuid, newItemData)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `uuid` | string | UUID vật phẩm |
| `newItemData` | table | Dữ liệu vật phẩm mới |

| Returns | Type | Description |
|---------|------|-------------|
| success | bool | true nếu update thành công |

⚠️ **Lưu ý**: Chỉ hoạt động nếu vật phẩm ở trong túi (Inventory), không hoạt động khi vật phẩm đang mặc trên người!

---

### GiveCustomItem()
Cấp phát vật phẩm với dữ liệu tùy chỉnh (dùng cho Crafting, Shop inheritance).

```lua
local craftedItem = {
  UUID = HttpService:GenerateGUID(false),
  Id = "Steel Sword",
  BindState = "Unlocked",
  UpgradeCount = 1,
  Enchants = {{Id = "Sharpness", Level = 1}}
}
InventorySystem:GiveCustomItem(player, craftedItem)
```

---

## 🔨 CRAFTING API

### ProcessCraft()
Thực hiện chế tạo vật phẩm.

```lua
local result = CraftingSystem:ProcessCraft(player, "Steel Ingot", nil, 5)
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player` | Player | ✅ | Nhân vật chế tạo |
| `recipeId` | string | ✅ | ID công thức từ CraftingRecipes |
| `mainItemIndex` | number | ❌ | Chỉ số vật phẩm gốc (nếu upgrade) |
| `craftAmount` | number | ❌ | Số lô chế tạo (mặc định 1) |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Example - Chế tạo thường:**
```lua
local result = CraftingSystem:ProcessCraft(player, "Steel Ingot", nil, 10)
if result.Success then
  print(result.Message)  -- "Chế tạo thành công 10 lô vật phẩm!"
else
  print("Lỗi:", result.Message)  -- "Không đủ nguyên liệu: Iron (Cần: 50, Có: 30)"
end
```

**Example - Nâng cấp trang bị:**
```lua
-- Chỉ có thể nâng cấp 1 cái một lần
local result = CraftingSystem:ProcessCraft(player, "Upgrade Sword", 1, 1)
if result.Success then
  print("Trang bị được nâng cấp!")
end
```

**Behavior:**
- Kiểm tra Requirements (Profession level)
- Tính toán nguyên liệu cần thiết từ `BaseAmount * craftAmount`
- Trừ nguyên liệu từ cả Materials và Consumables
- Nếu có MainIngredient, xóa vật phẩm gốc và kế thừa chỉ số
- Cộng Exp từ `recipe.ExpGains`

---

## ✨ ENCHANTING API

### ProcessEnchant()
Thực hiện phát động bộ vật phẩm bằng rune.

```lua
local result = EnchantSystem:ProcessEnchant(player, 1, 2)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật phát động |
| `targetItemIndex` | number | Chỉ số vật phẩm trong túi |
| `runeIndex` | number | Chỉ số rune trong Materials |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Example:**
```lua
local result = EnchantSystem:ProcessEnchant(player, 1, 2)
if result.Success then
  print(result.Message)  -- Enchant thành công! (Số lần: 1/5)\n✨ Mới: Sharpness\n⬆️ Cấp 2: Life Steal
else
  print("Lỗi:", result.Message)  -- "Trang bị không có độ bền để Enchant!"
end
```

**Behavior:**
- Kiểm tra MaxEnchants & EnchantCounts
- Kiểm tra Enchanting level >= Rune requirements
- Loop qua Tokens, mỗi token có cơ hội:
  - Thêm enchant mới (decreasing chance by level)
  - Nâng cấp enchant hiện có (with level catchup)
- Áp dụng Luck + Modifiers từ Rune để filter pool
- Trừ rune & cộng Enchanting Exp

---

### DisenchantItem()
Tẩy bùa khỏi vật phẩm (nhận Exp).

```lua
local result = EnchantSystem:DisenchantItem(player, 1)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `targetItemIndex` | number | Chỉ số vật phẩm |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Behavior:**
- Tính Exp reward từ rarity & level của từng enchant
- Xóa toàn bộ Enchants & EnchantCounts
- Cộng Exp Enchanting

---

## 🌾 FARMING API

### GiveSeedPack()
Cấp phát hạt giống động với NBT.

```lua
local result = FarmingSystem:GiveSeedPack(player, "Wheat", 5)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `plantId` | string | ID cây từ PlantDatabase |
| `amount` | number | Số túi hạt |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Behavior:**
- Kiểm tra plant có tồn tại trong PlantDatabase
- Cấp Seed Pack với NBT {PlantId = plantId}
- NBT cho phép biết được loại hạt nào khi gieo

---

### PlantSeed()
Gieo hạt vào ô đất.

```lua
local result = FarmingSystem:PlantSeed(player, 1, "slot1")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `seedInvIndex` | number | Chỉ số hạt trong Materials |
| `slotId` | string | ID ô đất (e.g., "slot1", "A1") |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Behavior:**
- Kiểm tra ô đất trống
- Lấy PlantId từ NBT của Seed Pack
- Trừ 1 Seed Pack
- Tạo plant data với PlantedTime = os.time()

---

### HarvestPlant()
Thu hoạch cây trồng.

```lua
local result = FarmingSystem:HarvestPlant(player, "slot1")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `slotId` | string | ID ô đất |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Behavior:**
- Kiểm tra cây chín (CalculatePlantState)
- Loop qua HarvestYield, roll Chance từng loại
- Cộng Farming Exp
- Nếu có RepeatInterval, update LastHarvestTime
- Nếu đạt HarvestTimes max, xóa cây

---

### CalculatePlantState()
Tính trạng thái tăng trưởng của cây.

```lua
local isReady, stage, timeLeft = FarmingSystem:CalculatePlantState(plantData)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `plantData` | table | Dữ liệu cây từ profile.Data.Farming |

| Returns | Type | Description |
|---------|------|-------------|
| isReady | bool | Cây đã chín chưa |
| stage | number | Stage hiện tại (0-N) |
| timeLeft | number | Thời gian còn lại (giây) |

**Behavior:**
- Nếu lần đầu lần tiên (LastHarvestTime = 0), dùng PlantedTime
- Nếu tái sinh (LastHarvestTime > 0), dùng LastHarvestTime
- Tính progress = timePassed / requiredTime
- currentStage = floor(progress * Stages)

---

### DestroyPlant()
Nhổ bỏ cây.

```lua
local result = FarmingSystem:DestroyPlant(player, "slot1")
```

---

## 🏪 SHOP API

### BuyItem()
Mua hàng từ cửa hàng.

```lua
local result = ShopSystem:BuyItem(player, "Villager", 1, 5)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật mua |
| `shopId` | string | ID cửa hàng |
| `itemIndex` | number | Chỉ số vật phẩm trong shop (1-based) |
| `amount` | number | Số lượng mua |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Example:**
```lua
local result = ShopSystem:BuyItem(player, "Villager", 2, 3)
if result.Success then
  print(result.Message)  -- "Mua thành công 3x Iron Sword với tổng giá 150 Coin!"
else
  print("Lỗi:", result.Message)  -- "Bạn không đủ 150 Coin để mua món này!"
end
```

**Behavior:**
- Kiểm tra StartTime/EndTime
- Kiểm tra MaxPerPurchase (cá nhân)
- Trừ tiền bằng PlayerStats
- Cập nhật GlobalShopStockMap (nếu IsGlobalLimited)
- Lấy item vào kho (auto-detect tên túi)

---

### SellItem()
Bán vật phẩm hoặc chỉ vật phẩm từ UUID/ID.

```lua
local result = ShopSystem:SellItem(player, "xxx-xxx-xxx-uuid", 1)
-- hoặc
local result = ShopSystem:SellItem(player, "Iron Sword", 1)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật bán |
| `identifier` | string | UUID hoặc ItemId |
| `amount` | number | Số lượng (với stackable) |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Behavior:**
- Nếu identifier là UUID, tìm vật phẩm đó
- Nếu là ItemId, tự động tìm vật phẩm đầu tiên
- Tính giá = SellPrice + (EnchantLevel * 50) + (UpgradeCount * 100)
- Kiểm tra BindState (không thể bán Locked)
- Kiểm tra IsImportant (không thể bán)

---

### ViewShop()
Xem thông tin cửa hàng.

```lua
local result = ShopSystem:ViewShop("Villager")
```

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string (multiline shop info)} |

---

## ⚒️ DISMANTLING API

### ProcessDismantle()
Phân rã vật phẩm thành nguyên liệu.

```lua
local result = DismantleSystem:ProcessDismantle(player, 1)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `itemIndex` | number | Chỉ số vật phẩm trong Items |

| Returns | Type | Description |
|---------|------|-------------|
| result | table | {Success: bool, Message: string} |

**Behavior:**
- Kiểm tra BindState (không thể rã Locked)
- Loop qua DismantleDrops, roll Chance
- Stackable → GiveStackable, roll Min-Max
- Unique → GiveCustomItem, áp dụng KeepStats
- Xóa vật phẩm gốc bằng UUID
- Cộng Crafting Exp

**KeepStats Options:**
| Value | Behavior |
|-------|----------|
| nil | Không kế thừa gì |
| "EnchantsOnly" | Kế thừa chỉ Enchants & Gems |
| "All" | Kế thừa tất cả: Upgrade, Purity, Enchants, v.v. |

---

## 👤 PLAYERSTATS API

### AddCurrency()
Cộng tiền.

```lua
PlayerStatSystem:AddCurrency(player, "Coin", 1000)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `currencyType` | string | Loại tiền (e.g., "Coin") |
| `amount` | number | Số tiền cộng |

---

### RemoveCurrency()
Trừ tiền.

```lua
local success = PlayerStatSystem:RemoveCurrency(player, "Coin", 500)
```

| Returns | Type | Description |
|---------|------|-------------|
| success | bool | true nếu đủ tiền |

---

### AddExp()
Cộng kinh nghiệm chính (Core Level).

```lua
PlayerStatSystem:AddExp(player, 250)
```

**Behavior:**
- Cộng Exp
- Tự động level up nếu đạt threshold
- Cộng UnspentPoints (3 điểm per level)

---

### AddAttribute()
Cộng chỉ số chiến đấu.

```lua
PlayerStatSystem:AddAttribute(player, "Strength", 10)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `attributeName` | string | Strength, Intelligence, Dexterity, v.v. |
| `amount` | number | Số điểm cộng |

---

### AddProfessionExp()
Cộng kinh nghiệm nghề.

```lua
PlayerStatSystem:AddProfessionExp(player, "Crafting", 500)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | Player | Nhân vật |
| `profName` | string | Tên nghề: Crafting, Enchanting, Farming, v.v. |
| `amount` | number | Exp cộng |

**Behavior:**
- Tự động level up nếu đạt threshold
- Print log khi level up

---

## 🔄 COMMON PATTERNS

### Pattern 1: Sử Dụng Deep Copy
```lua
local function DeepCopyData(data)
  if type(data) ~= "table" then
    return data
  end
  return HttpService:JSONDecode(HttpService:JSONEncode(data))
end

-- Dùng khi copy Enchants, Gems, v.v.
local newItem = {
  ...
  Enchants = deepCopyData(oldItem.Enchants)
}
```

### Pattern 2: Giao Dịch an Toàn
Luôn trừ trước, rồi add sau (không bao giờ add rồi trừ):
```lua
-- ✅ ĐÚNG
if InventorySystem:RemoveStackable(player, "Materials", "Iron", 5) then
  InventorySystem:GiveStackable(player, "Materials", "Steel Ingot", 1)
else
  print("Không đủ sắt")
end

-- ❌ SAI (nếu add rồi trừ fail, người chơi mất item)
InventorySystem:GiveStackable(player, "Materials", "Steel Ingot", 1)
if not InventorySystem:RemoveStackable(player, "Materials", "Iron", 5) then
  print("Không đủ sắt - nhưng đã thêm ingot rồi!")
end
```

### Pattern 3: NBT Matching
```lua
-- Chỉ lấy Wheat từ Wheat plant
local targetNBT = { PlantId = "Wheat" }
local success = InventorySystem:RemoveStackable(player, "Materials", "Seed Pack", 1, targetNBT)
```

### Pattern 4: Xử Lý Lỗi
```lua
local result = CraftingSystem:ProcessCraft(player, recipeId)
if result.Success then
  -- Thành công
  print(result.Message)
else
  -- Thất bại, hiển thị lý do
  print("❌ " .. result.Message)
end
```

### Pattern 5: Finding & Updating
```lua
-- Tìm vị trí
local location = InventorySystem:FindItemLocationByUUID(player, uuid)
if location and location.Location == "Inventory" then
  -- Cập nhật
  local newData = table.clone(profile.Data.Inventories.Items[location.Index])
  newData.CustomName = "Sword of Power"
  InventorySystem:UpdateItemData(player, uuid, newData)
end
```

---

## ⚠️ ERROR HANDLING

### Thường Gặp & Cách Fix

| Lỗi | Nguyên Nhân | Cách Fix |
|-----|-----------|----------|
| "Không tìm thấy vật phẩm" | Item không tồn tại trong túi | Kiểm tra index/UUID có hợp lệ |
| "Vật phẩm đang bị khóa" | Item BindState = "Locked" | Cần unlock trước khi bán/rã |
| "Không đủ nguyên liệu" | Thiếu vật phẩm để chế tạo | Kiểm tra Materials/Consumables |
| "Vật phẩm này không thể bán" | IsImportant = true hoặc SellPrice = 0 | Không thể bán vật phẩm cốt truyện |
| "Trang bị đang được mặc" | Cố gắng bán vật phẩm đang mặc | Cần bỏ trang bị trước |
| "Giới hạn mua" | Vượt MaxPerPurchase | Chờ phiên mới (reset shop stock) |

### Debugging Tips
```lua
-- Print profile debug
local profile = DataManager:GetProfile(player)
print(HttpService:JSONEncode(profile.Data))

-- Check inventory
print("Items:", #profile.Data.Inventories.Items)
print("Materials:", #profile.Data.Inventories.Materials)

-- Check professions
print("Crafting Exp:", profile.Data.Professions.Crafting)
local level = LevelingCalculator.CalculateLevel(profile.Data.Professions.Crafting)
print("Crafting Level:", level)
```

---

**Last Updated:** 2026-06-11  
**Version:** 1.0
