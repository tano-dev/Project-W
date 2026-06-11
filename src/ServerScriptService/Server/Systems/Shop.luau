-- File: Server/Systems/ShopSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local InventorySystem = require(game.ServerScriptService.Server.Systems.Inventory)
local PlayerStatSystem = require(game.ServerScriptService.Server.Systems.PlayerStats)
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local ShopDatabase = require(game.ReplicatedStorage.Shared.Constants.ShopData)
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")

local ShopSystem = {}
local GlobalShopStockMap = MemoryStoreService:GetSortedMap("GlobalShopStockMap_v2")

-- ==========================================
-- HÀM HỖ TRỢ
-- ==========================================
local function DeepCopyData(data)
	if type(data) ~= "table" then
		return data
	end
	return HttpService:JSONDecode(HttpService:JSONEncode(data))
end

local function ParseMessage(message: string)
	local args = {}
	local currentArg = ""
	local inQuotes = false

	for i = 1, #message do
		local char = string.sub(message, i, i)
		if char == '"' then
			inQuotes = not inQuotes
		elseif char == " " and not inQuotes then
			if currentArg ~= "" then
				table.insert(args, currentArg)
				currentArg = ""
			end
		else
			currentArg = currentArg .. char
		end
	end
	if currentArg ~= "" then
		table.insert(args, currentArg)
	end
	return args
end

-- ==========================================
-- TÍNH TOÁN KHÓA PHIÊN (SESSION ID) ĐỂ TỰ ĐỘNG RESTOCK
-- ==========================================
local function GetItemSessionInfo(shopId: string, itemId: string, itemDef: table)
	local currentTime = os.time()

	if not itemDef.RestockInterval or itemDef.RestockInterval <= 0 then
		return shopId .. "_" .. itemId .. "_Eternal", -1
	end

	local originTime = itemDef.StartTime or 0
	if currentTime < originTime then
		return nil, -1
	end

	local timePassed = currentTime - originTime
	local currentSession = math.floor(timePassed / itemDef.RestockInterval)
	local timeRemaining = itemDef.RestockInterval - (timePassed % itemDef.RestockInterval)

	local sessionKey = string.format("%s_%s_Session_%d", shopId, itemId, currentSession)
	return sessionKey, timeRemaining
end

local function CleanupShopHistory(profile)
	if not profile.Data.ShopHistory then
		return
	end
	local currentTime = os.time()
	for key, data in pairs(profile.Data.ShopHistory) do
		if data.Expiry ~= -1 and currentTime > data.Expiry then
			profile.Data.ShopHistory[key] = nil
		end
	end
end

-- ==========================================
-- API 1: MUA VẬT PHẨM
-- ==========================================
function ShopSystem:BuyItem(player: Player, shopId: string, itemIndex: number, amount: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	amount = math.floor(amount or 1)
	if amount <= 0 then
		return { Success = false, Message = "Số lượng không hợp lệ!" }
	end

	local shopDef = ShopDatabase.GetAll()[shopId]
	if not shopDef then
		return { Success = false, Message = string.format("Cửa hàng '%s' không tồn tại!", shopId) }
	end

	local itemToBuy = shopDef.Items[itemIndex]
	if not itemToBuy then
		return { Success = false, Message = "Vật phẩm không tồn tại trong cửa hàng này!" }
	end

	local baseItemDef = ItemDatabase.Registry[itemToBuy.Id]
	if not baseItemDef then
		return { Success = false, Message = "Lỗi dữ liệu vật phẩm gốc!" }
	end

	if not baseItemDef.BuyPrice or baseItemDef.BuyPrice <= 0 then
		return {
			Success = false,
			Message = "Vật phẩm này không được định giá bán trên thị trường!",
		}
	end

	local currentTime = os.time()

	if itemToBuy.StartTime and currentTime < itemToBuy.StartTime then
		return { Success = false, Message = "Vật phẩm này chưa tới giờ mở bán!" }
	end
	if itemToBuy.EndTime and currentTime > itemToBuy.EndTime then
		return { Success = false, Message = "Vật phẩm này đã ngừng bán!" }
	end

	local multiplier = itemToBuy.PriceMultiplier or 1.0
	local unitPrice = math.floor(baseItemDef.BuyPrice * multiplier)
	local totalCost = unitPrice * amount
	local currency = shopDef.Currency or "Coin"

	if not profile.Data.ShopHistory then
		profile.Data.ShopHistory = {}
	end
	CleanupShopHistory(profile)

	local sessionKey, sessionTimeRemaining = GetItemSessionInfo(shopId, itemToBuy.Id, itemToBuy)
	if not sessionKey then
		return { Success = false, Message = "Vật phẩm chưa sẵn sàng!" }
	end

	-- 1. KIỂM TRA ĐỒ LIMITED (CÁ NHÂN)
	if shopDef.IsGlobalLimited and itemToBuy.MaxPerPurchase then
		local historyData = profile.Data.ShopHistory[sessionKey]
		local boughtSoFar = historyData and historyData.Bought or 0

		if boughtSoFar + amount > itemToBuy.MaxPerPurchase then
			return {
				Success = false,
				Message = string.format(
					"Giới hạn mua: Bạn chỉ có thể mua thêm %d cái trong phiên này!",
					math.max(0, itemToBuy.MaxPerPurchase - boughtSoFar)
				),
			}
		end
	end

	-- 2. TRỪ TIỀN (KHÓA TÀI SẢN)
	local isPaid = PlayerStatSystem:RemoveCurrency(player, currency, totalCost)
	if not isPaid then
		return {
			Success = false,
			Message = string.format("Bạn không đủ %d %s để mua món này!", totalCost, currency),
		}
	end

	-- 3. XỬ LÝ MEMORY STORE (KHO HÀNG TOÀN CẦU THEO PHIÊN)
	if shopDef.IsGlobalLimited and itemToBuy.GlobalStock then
		local successBuy = false
		local stockLeft = 0
		local cacheTime = (sessionTimeRemaining > 0) and (sessionTimeRemaining + 3600) or 86400

		local success, _ = pcall(function()
			GlobalShopStockMap:UpdateAsync(sessionKey, function(currentStock)
				if currentStock == nil then
					currentStock = itemToBuy.GlobalStock
				end
				if currentStock >= amount then
					successBuy = true
					stockLeft = currentStock - amount
					return stockLeft
				else
					successBuy = false
					stockLeft = currentStock
					return nil
				end
			end, cacheTime)
		end)

		if not success or not successBuy then
			PlayerStatSystem:AddCurrency(player, currency, totalCost) -- HOÀN TIỀN
			return {
				Success = false,
				Message = string.format(
					"Rất tiếc! Món đồ này chỉ còn lại %d cái trên toàn thế giới.",
					stockLeft
				),
			}
		end
	end

	-- CẬP NHẬT LỊCH SỬ MUA HÀNG CÁ NHÂN VÀO DATASTORE
	if shopDef.IsGlobalLimited and itemToBuy.MaxPerPurchase then
		local historyData = profile.Data.ShopHistory[sessionKey] or { Bought = 0, Expiry = -1 }
		historyData.Bought += amount
		historyData.Expiry = (sessionTimeRemaining > 0) and (currentTime + sessionTimeRemaining) or -1
		profile.Data.ShopHistory[sessionKey] = historyData
	end

	-- 4. NHẬN DIỆN TÚI ĐỒ (DỰA TRÊN KIẾN TRÚC ITEM DATABASE MỚI)
	local bagCategory = "Items" -- Mặc định là đồ độc nhất
	if ItemDatabase.Materials[itemToBuy.Id] then
		bagCategory = "Materials"
	elseif ItemDatabase.Consumables[itemToBuy.Id] then
		bagCategory = "Consumables"
	end

	-- 5. PHÂN PHỐI ĐỒ VÀO TÚI
	if bagCategory ~= "Items" then
		InventorySystem:GiveStackable(player, bagCategory, itemToBuy.Id, amount, itemToBuy.NBT)
	else
		for _ = 1, amount do
			local newEquipment = {
				UUID = HttpService:GenerateGUID(false),
				Id = itemToBuy.Id,
				BindState = "Unlocked",
				UpgradeCount = itemToBuy.UpgradeCount,
				CustomName = itemToBuy.CustomName,
				Aura = itemToBuy.Aura,
				Enchants = itemToBuy.Enchants and DeepCopyData(itemToBuy.Enchants),
				NBT = itemToBuy.NBT and DeepCopyData(itemToBuy.NBT),
			}
			InventorySystem:GiveCustomItem(player, newEquipment)
		end
	end

	local finalName = itemToBuy.CustomName or baseItemDef.Name or itemToBuy.Id
	return {
		Success = true,
		Message = string.format(
			"Mua thành công %dx %s với tổng giá %d %s!",
			amount,
			finalName,
			totalCost,
			currency
		),
	}
end

-- ==========================================
-- API 2: BÁN VẬT PHẨM (NHẬN DIỆN THÔNG MINH BẰNG UUID HOẶC TÊN)
-- ==========================================
function ShopSystem:SellItem(player: Player, identifier: string, amount: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	amount = math.floor(amount or 1)
	if amount <= 0 then
		return { Success = false, Message = "Số lượng bán không hợp lệ!" }
	end

	-- BƯỚC 1: KIỂM TRA IDENTIFIER CÓ PHẢI LÀ UUID TRANG BỊ
	local locData = InventorySystem:FindItemLocationByUUID(player, identifier)
	if locData then
		if locData.Location ~= "Inventory" then
			return { Success = false, Message = "Trang bị đang được mặc, không thể bán!" }
		end

		local itemData = profile.Data.Inventories.Items[locData.Index]
		local itemDef = ItemDatabase.Registry[itemData.Id]

		if not itemDef or not itemDef.SellPrice or itemDef.SellPrice <= 0 then
			return { Success = false, Message = "Trang bị này không thể bán lấy tiền!" }
		end
		if itemDef.IsImportant then
			return { Success = false, Message = "Không thể bán vật phẩm cốt truyện!" }
		end
		if itemData.BindState == "Locked" then
			return { Success = false, Message = "Vật phẩm đang bị khóa bảo vệ!" }
		end

		local totalGold = itemDef.SellPrice
		if itemData.Enchants then
			for _, enc in ipairs(itemData.Enchants) do
				totalGold += (enc.Level * 50)
			end
		end
		if itemData.UpgradeCount and itemData.UpgradeCount > 0 then
			totalGold += (itemData.UpgradeCount * 100)
		end

		local successRemove = InventorySystem:RemoveItemByUUID(player, identifier)
		if successRemove then
			PlayerStatSystem:AddCurrency(player, "Coin", totalGold)
			return {
				Success = true,
				Message = string.format(
					"Đã bán %s thu về %d Coin.",
					itemData.CustomName or itemDef.Name or itemData.Id,
					totalGold
				),
			}
		end
		return { Success = false, Message = "Không thể xóa trang bị!" }
	end

	-- BƯỚC 2: NẾU LÀ ITEM ID -> KIỂM TRA XEM NÓ THUỘC TÚI NÀO TỪ ITEM DATABASE
	local itemDef = ItemDatabase.Registry[identifier]
	if not itemDef then
		return { Success = false, Message = "Không tìm thấy vật phẩm hoặc ID/UUID không hợp lệ!" }
	end

	if not itemDef.SellPrice or itemDef.SellPrice <= 0 then
		return { Success = false, Message = "Vật phẩm này không thể bán lấy tiền!" }
	end
	if itemDef.IsImportant then
		return { Success = false, Message = "Không thể bán vật phẩm cốt truyện!" }
	end

	local bagCategory = "Items"
	if ItemDatabase.Materials[identifier] then
		bagCategory = "Materials"
	elseif ItemDatabase.Consumables[identifier] then
		bagCategory = "Consumables"
	end

	-- Xử lý bán đồ gộp
	if bagCategory ~= "Items" then
		local totalGold = itemDef.SellPrice * amount
		local successRemove = InventorySystem:RemoveStackable(player, bagCategory, identifier, amount)
		if successRemove then
			PlayerStatSystem:AddCurrency(player, "Coin", totalGold)
			return {
				Success = true,
				Message = string.format(
					"Đã bán %dx %s thu về %d Coin.",
					amount,
					itemDef.Name or identifier,
					totalGold
				),
			}
		else
			return { Success = false, Message = "Số lượng vật phẩm trong túi không đủ để bán!" }
		end
	else
		-- Xử lý bán tự động trang bị độc nhất (Tìm vũ khí chưa khóa đầu tiên)
		local foundUUID = nil
		for _, item in ipairs(profile.Data.Inventories.Items) do
			if item.Id == identifier and item.BindState ~= "Locked" then
				foundUUID = item.UUID
				break
			end
		end

		if foundUUID then
			return ShopSystem:SellItem(player, foundUUID, 1)
		else
			return {
				Success = false,
				Message = string.format(
					"Không tìm thấy '%s' nào trong túi đồ (hoặc tất cả đang bị khóa/mặc)!",
					itemDef.Name or identifier
				),
			}
		end
	end
end

-- ==========================================
-- API 3: XEM THÔNG TIN CỬA HÀNG
-- ==========================================
function ShopSystem:ViewShop(shopId: string)
	local shopDef = ShopDatabase.GetAll()[shopId]
	if not shopDef then
		return { Success = false, Message = string.format("Cửa hàng '%s' không tồn tại!", shopId) }
	end

	local shopTypeStr = shopDef.IsGlobalLimited and "🔴 [LIMITED SHOP]" or "🟢 [SHOP THƯỜNG]"
	local infoLines = {
		string.format("🏪 %s: %s (Tiền tệ: %s)", shopTypeStr, shopDef.Name, shopDef.Currency),
		"----------------------------------------",
	}

	local currentTime = os.time()

	for index, item in ipairs(shopDef.Items) do
		local baseItemDef = ItemDatabase.Registry[item.Id]
		if not baseItemDef then
			continue
		end

		local multiplier = item.PriceMultiplier or 1.0
		local unitPrice = math.floor((baseItemDef.BuyPrice or 0) * multiplier)
		local itemName = item.CustomName or baseItemDef.Name or item.Id
		local stockInfo = ""

		if item.StartTime and currentTime < item.StartTime then
			stockInfo = " | 🔒 Chưa mở bán"
		elseif item.EndTime and currentTime > item.EndTime then
			stockInfo = " | ❌ Ngừng kinh doanh"
		else
			if shopDef.IsGlobalLimited then
				local sessionKey, timeRemaining = GetItemSessionInfo(shopId, item.Id, item)

				if item.MaxPerPurchase then
					stockInfo = string.format(" | Limit: %d/User", item.MaxPerPurchase)
				end

				if item.GlobalStock and sessionKey then
					local success, currentStock = pcall(function()
						return GlobalShopStockMap:GetAsync(sessionKey)
					end)
					local actualStock = (success and currentStock) or item.GlobalStock

					if actualStock <= 0 then
						stockInfo = stockInfo .. " | ❌ HẾT HÀNG GLOBAL"
					else
						stockInfo = stockInfo .. string.format(" | 📦 Global: %d/%d", actualStock, item.GlobalStock)
					end
				end

				if timeRemaining > 0 then
					local hrs = math.floor(timeRemaining / 3600)
					local mins = math.floor((timeRemaining % 3600) / 60)
					stockInfo = stockInfo .. string.format(" (Làm mới sau: %dh %dm)", hrs, mins)
				end
			end
		end

		table.insert(infoLines, string.format("[%d] %s - Giá: %d%s", index, itemName, unitPrice, stockInfo))
	end

	return { Success = true, Message = table.concat(infoLines, "\n") }
end

-- ==========================================
-- LẮNG NGHE LỆNH CHAT ĐỂ TEST
-- ==========================================
ShopSystem.Start = function()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = ParseMessage(message)
			if #args == 0 then
				return
			end

			local command = string.lower(args[1])
			table.remove(args, 1)

			if command == "/buy" then
				local shopId = args[1]
				local itemIndex = tonumber(args[2])
				local amount = tonumber(args[3]) or 1
				if not shopId or not itemIndex then
					return
				end
				local result = ShopSystem:BuyItem(player, shopId, itemIndex, amount)
				if result then
					print("🛒 " .. result.Message)
				end
			elseif command == "/sell" then
				local identifier = args[1]
				local amount = tonumber(args[2]) or 1
				if not identifier then
					return
				end
				local result = ShopSystem:SellItem(player, identifier, amount)
				if result then
					print("💰 " .. result.Message)
				end
			elseif command == "/viewshop" then
				local shopId = args[1]
				if not shopId then
					return
				end
				local result = ShopSystem:ViewShop(shopId)
				if result then
					print(result.Message)
				end
			end
		end)
	end)
end

return ShopSystem
