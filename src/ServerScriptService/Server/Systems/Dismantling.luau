-- File: Server/Systems/Dismantle.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local InventorySystem = require(game.ServerScriptService.Server.Systems.Inventory)
local ItemDatabase = require(game.ReplicatedStorage.Shared.Constants.ItemData)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DismantleSystem = {}

-- ==========================================
-- HÀM HỖ TRỢ: DEEP COPY
-- ==========================================
local function DeepCopyData(data)
	if type(data) ~= "table" then
		return data
	end
	return HttpService:JSONDecode(HttpService:JSONEncode(data))
end

-- ==========================================
-- LOGIC LÕI: THỰC THI PHÂN RÃ VẬT PHẨM
-- ==========================================
function DismantleSystem:ProcessDismantle(player: Player, itemIndex: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return false
	end

	-- 1. Lấy thông tin vật phẩm cần phân rã
	local itemData = profile.Data.Inventories.Items[itemIndex]
	if not itemData then
		return { Success = false, Message = "Không tìm thấy vật phẩm tại vị trí này!" }
	end

	-- Đảm bảo vật phẩm không bị khóa (Ví dụ: Đang khóa bảo vệ thì không cho rã)
	if itemData.BindState == "Locked" then
		return { Success = false, Message = "Vật phẩm đang bị khóa bảo vệ, không thể phân rã!" }
	end

	local baseDef = ItemDatabase.Registry[itemData.Id]
	if not baseDef then
		return { Success = false, Message = "Lỗi dữ liệu vật phẩm gốc!" }
	end

	-- 2. Kiểm tra xem đồ này có cho phép rã không
	if not baseDef.DismantleDrops or #baseDef.DismantleDrops == 0 then
		return { Success = false, Message = "Vật phẩm này không thể bị phân rã!" }
	end

	-- Cảnh báo nếu đồ IsImportant (Có thể tùy biến thêm UI confirm ở Client)
	if baseDef.IsImportant then
		print("⚠️ Chú ý: Đang phân rã một vật phẩm Quan Trọng (IsImportant = true)")
	end

	-- 3. CHUẨN BỊ LƯỚI RÓT PHẦN THƯỞNG (GACHA DROPS)
	local rewardsLog = {}

	for _, dropRule in ipairs(baseDef.DismantleDrops) do
		-- Đổ xí ngầu xem có rơi ra món này không (Chance từ 0.0 đến 1.0)
		if math.random() <= dropRule.Chance then
			local dropDef = ItemDatabase.Registry[dropRule.Id]

			if dropDef then
				-- Phân loại: Stackable (Nguyên liệu/Thuốc) hay Đồ Độc Nhất (Trang bị)
				if dropDef.ItemType == "Material" or dropDef.ItemType == "Consumable" then
					-- XỬ LÝ ĐỒ STACKABLE (Tính Min/Max, Bỏ qua KeepStats)
					local bagCategory = (dropDef.ItemType == "Material") and "Materials" or "Consumables"
					local amountToGive = math.random(dropRule.Min or 1, dropRule.Max or 1)

					InventorySystem:GiveStackable(player, bagCategory, dropRule.Id, amountToGive)
					table.insert(rewardsLog, string.format("%dx %s", amountToGive, dropRule.Id))
				else
					-- XỬ LÝ ĐỒ ĐỘC NHẤT (Luôn rớt 1 cái, Bỏ qua Min/Max, Kích hoạt KeepStats)
					local newDropItem = {
						UUID = HttpService:GenerateGUID(false),
						Id = dropRule.Id,
						BindState = "Unlocked",
					}

					-- Kế thừa chỉ số (KeepStats Logic)
					local keep = dropRule.KeepStats
					if keep == "All" then
						newDropItem.UpgradeCount = itemData.UpgradeCount
						newDropItem.Purity = itemData.Purity
						newDropItem.Corruption = itemData.Corruption
						newDropItem.Aura = itemData.Aura

						newDropItem.UpgradeHistory = itemData.UpgradeHistory and DeepCopyData(itemData.UpgradeHistory)
						newDropItem.State = itemData.State and DeepCopyData(itemData.State)
						newDropItem.NBT = itemData.NBT and DeepCopyData(itemData.NBT)
						newDropItem.Enchants = itemData.Enchants and DeepCopyData(itemData.Enchants)
						newDropItem.Gems = itemData.Gems and DeepCopyData(itemData.Gems)
					elseif keep == "EnchantsOnly" then
						-- Chỉ bóc tách phần Enchant và Gem (rất hữu dụng để làm công cụ "Gỡ ngọc")
						newDropItem.Enchants = itemData.Enchants and DeepCopyData(itemData.Enchants)
						newDropItem.Gems = itemData.Gems and DeepCopyData(itemData.Gems)
					end

					InventorySystem:GiveCustomItem(player, newDropItem)
					table.insert(rewardsLog, string.format("1x %s", dropRule.Id))
				end
			end
		end
	end

	-- 4. TIÊU HỦY VẬT PHẨM GỐC BẰNG INVENTORY SYSTEM
	InventorySystem:RemoveItemByUUID(player, itemData.UUID)

	-- 5. CỘNG KINH NGHIỆM NGHỀ (NẾU CÓ)
	local expGained = baseDef.DismantleExp or 0
	if expGained > 0 then
		if not profile.Data.Professions then
			profile.Data.Professions = {}
		end
		-- Mặc định phân rã sẽ cho Exp nghề Crafting
		profile.Data.Professions["Crafting"] = (profile.Data.Professions["Crafting"] or 0) + expGained
	end

	-- 6. TỔNG HỢP MESSAGE PHẢN HỒI
	local finalMessage = "Đã phân rã thành công!"
	if #rewardsLog > 0 then
		finalMessage = "Phân rã thành công! Nhận được: " .. table.concat(rewardsLog, ", ")
	else
		finalMessage = "Phân rã thành công, nhưng không thu lại được nguyên liệu nào..."
	end

	if expGained > 0 then
		finalMessage = finalMessage .. string.format(" (+%d Exp Crafting)", expGained)
	end

	return { Success = true, Message = finalMessage }
end

-- ==========================================
-- LẮNG NGHE LỆNH CHAT ĐỂ TEST
-- ==========================================
function DismantleSystem:Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			local autoDebug = false
			if #args > 0 and string.lower(args[#args]) == "true" then
				autoDebug = true
				table.remove(args, #args)
			end

			-- Cú pháp test: /dismantle [Vị trí ô đồ]
			-- VD: /dismantle 1
			if command == "/dismantle" then
				local targetIndex = tonumber(args[1])
				if not targetIndex then
					return
				end

				print(string.format("🖥️ Lệnh: Phân rã vật phẩm tại ô [%d]", targetIndex))

				local result = self:ProcessDismantle(player, targetIndex)
				if result then
					print("👉 Kết quả: " .. result.Message)
				end

				if autoDebug then
					DataManager:DebugProfile(player)
				end
			end
		end)
	end)
end

return DismantleSystem
