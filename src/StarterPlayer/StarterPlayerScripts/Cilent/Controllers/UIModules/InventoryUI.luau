-- File: StarterPlayerScripts/Client/Controllers/UIModules/InventoryUI.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ClientDataStore = require(script.Parent.Parent.Parent.State.ClientDataStore)
local ItemDatabase = require(ReplicatedStorage.Shared.Constants.ItemData)
local Fusion = require(ReplicatedStorage.Shared.Utilities.Fusion)

local scope = Fusion.scoped(Fusion)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local InventoryScreen = PlayerGui:WaitForChild("Inventory")

-- Đường dẫn tới các Assets UI
local UIAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Inventory")
local HolderTemplate = UIAssets.Components.Holder
local ItemTemplate = UIAssets.Components.Item
local StackableTemplate = UIAssets.Components.Stackable
local MainEffects = UIAssets.Gradient.MainEffect
local SecondEffects = UIAssets.Gradient.SecondEffect

local InventoryUI = {}

-- Cấu trúc danh mục túi đồ
local Categories = {
	Items = {
		Container = nil,
		Holders = {},
		Capacity = 0,
		Template = ItemTemplate,
		IsStackable = false,
	},
	Consumables = {
		Container = nil,
		Holders = {},
		Capacity = 0,
		Template = StackableTemplate,
		IsStackable = true,
	},
	Materials = {
		Container = nil,
		Holders = {},
		Capacity = 0,
		Template = StackableTemplate,
		IsStackable = true,
	},
}

local syncDebounce = {}

-- ==========================================
-- 1. HÀM BẢO ĐẢM SỐ LƯỢNG Ô & GÁN LAYOUT ORDER
-- ==========================================
local function EnsureHolders(categoryName: string, targetCapacity: number)
	local cat = Categories[categoryName]
	if not cat or not cat.Container then
		return
	end

	local capacityNeeded = math.max(40, targetCapacity)

	while cat.Capacity < capacityNeeded do
		cat.Capacity += 1
		local newHolder = HolderTemplate:Clone()

		newHolder.Name = tostring(cat.Capacity)
		newHolder.LayoutOrder = cat.Capacity
		newHolder.Parent = cat.Container

		table.insert(cat.Holders, newHolder)
	end
end

-- ==========================================
-- 2. HÀM VẼ 1 MÓN ĐỒ
-- ==========================================
local function RenderItemUI(itemData, holderFrame, template, isStackable)
	local existingItem = holderFrame:FindFirstChild("ItemNode")

	if not itemData then
		if existingItem then
			existingItem:Destroy()
		end
		return
	end

	local itemDef = ItemDatabase.Registry[itemData.Id]
	if not itemDef then
		return
	end

	local itemBtn = existingItem
	if not itemBtn then
		itemBtn = template:Clone()
		itemBtn.Name = "ItemNode"
		itemBtn.Parent = holderFrame
	end

	local rarity = (itemData.NBT and itemData.NBT.Rarity) or itemDef.Rarity or "Common"

	local oldMain = itemBtn:FindFirstChildWhichIsA("UIGradient")
	if not oldMain or oldMain.Name ~= rarity then
		if oldMain then
			oldMain:Destroy()
		end
		local mainGrad = MainEffects:FindFirstChild(rarity) or MainEffects:FindFirstChild("Common")
		if mainGrad then
			local clone = mainGrad:Clone()
			clone.Name = rarity
			clone.Parent = itemBtn
		end
	end

	local effectFrame = itemBtn:FindFirstChild("EffectFrame")
	if effectFrame then
		local oldSec = effectFrame:FindFirstChildWhichIsA("UIGradient")
		if not oldSec or oldSec.Name ~= rarity then
			if oldSec then
				oldSec:Destroy()
			end
			local secGrad = SecondEffects:FindFirstChild(rarity) or SecondEffects:FindFirstChild("Common")
			if secGrad then
				local clone = secGrad:Clone()
				clone.Name = rarity
				clone.Parent = effectFrame
			end
		end
	end

	local itemIcon = itemBtn:FindFirstChild("ItemIcon")
	if itemIcon and itemDef.Image then
		itemIcon.Image = itemDef.Image
	end

	local amountContainer = itemBtn:FindFirstChild("Amount")

	if amountContainer then
		local amountTextLabel = amountContainer:IsA("TextLabel") and amountContainer
			or amountContainer:FindFirstChild("Amount")

		if isStackable and itemData.Amount and itemData.Amount > 0 then
			amountContainer.Visible = true
			if amountTextLabel then
				amountTextLabel.Text = tostring(itemData.Amount)
				amountTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		elseif not isStackable and itemData.UpgradeCount and itemData.UpgradeCount > 0 then
			amountContainer.Visible = true
			if amountTextLabel then
				amountTextLabel.Text = "+" .. itemData.UpgradeCount
				amountTextLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
			end
		else
			amountContainer.Visible = false
		end
	end
end

-- ==========================================
-- 3. LUỒNG ĐỒNG BỘ UI TỔNG THỂ
-- ==========================================
local function SyncCategoryUI(categoryName: string)
	local dataArray = ClientDataStore:Get({ "Inventories", categoryName }) or {}
	local itemCount = #dataArray

	-- [CẢI TIẾN LƯỚI 5 Ô]: Tính toán sao cho luôn đầy hàng hiện tại và dư 1 hàng hoàn chỉnh (5 ô)
	local fullRowsNeeded = math.ceil(itemCount / 5)
	local requiredCapacity = math.max(40, (fullRowsNeeded * 5) + 5)

	EnsureHolders(categoryName, requiredCapacity)

	local cat = Categories[categoryName]
	for i = 1, cat.Capacity do
		RenderItemUI(dataArray[i], cat.Holders[i], cat.Template, cat.IsStackable)
	end
end

local function TriggerSync(categoryName: string)
	if syncDebounce[categoryName] then
		return
	end
	syncDebounce[categoryName] = true

	task.defer(function()
		syncDebounce[categoryName] = false
		SyncCategoryUI(categoryName)
	end)
end

local function SyncAllEquipped()
	local equippedContainer = InventoryScreen:WaitForChild("Equipped"):WaitForChild("Holder")
	local equippedData = ClientDataStore:Get({ "Equipped" }) or {}
	local itemsArray = ClientDataStore:Get({ "Inventories", "Items" }) or {}

	for _, slotHolder in ipairs(equippedContainer:GetChildren()) do
		if slotHolder:IsA("Frame") then
			local targetUUID = equippedData[slotHolder.Name]
			local targetItemData = nil

			if targetUUID then
				for _, item in ipairs(itemsArray) do
					if item.UUID == targetUUID then
						targetItemData = item
						break
					end
				end
			end
			RenderItemUI(targetItemData, slotHolder, ItemTemplate, false)
		end
	end
end

-- ==========================================
-- 4. HỆ THỐNG TAB BẰNG FUSION & ROBLOX EVENT
-- ==========================================
local function SetupTabs(invFrame)
	local buttonBarFrame = invFrame:WaitForChild("ButtonBar"):WaitForChild("Frame")
	local currentTab = scope:Value("Items")

	local tabMappings = {
		Items = "Items",
		Consumables = "Consumables",
		Materials = "Materials",
	}

	for tabUIName, categoryKey in pairs(tabMappings) do
		local container = Categories[categoryKey].Container
		if container then
			scope:Hydrate(container)({
				Visible = scope:Computed(function(use)
					return use(currentTab) == categoryKey
				end),
			})
		end

		local tabFrame = buttonBarFrame:WaitForChild(tabUIName)
		local btn = tabFrame:FindFirstChild("Button") or tabFrame:FindFirstChildWhichIsA("TextButton")

		if btn then
			btn.MouseButton1Click:Connect(function()
				currentTab:set(categoryKey)
			end)

			scope:Hydrate(btn)({
				AutoButtonColor = false,
				Interactable = scope:Computed(function(use)
					return use(currentTab) ~= categoryKey
				end),
				BackgroundColor3 = scope:Spring(
					scope:Computed(function(use)
						if use(currentTab) == categoryKey then
							return Color3.fromRGB(150, 150, 150)
						else
							return Color3.fromRGB(200, 200, 200)
						end
					end),
					25,
					1
				),
			})
		else
			warn("🚨 LỖI: Không tìm thấy TextButton tên 'Button' bên trong: " .. tabUIName)
		end
	end
end

-- ==========================================
-- KHỞI CHẠY (START)
-- ==========================================
function InventoryUI:Start()
	print("🎒 Khởi tạo logic màn hình Túi Đồ...")

	local invFrame = InventoryScreen:WaitForChild("Inventory")
	Categories.Items.Container = invFrame:WaitForChild("Items")
	Categories.Consumables.Container = invFrame:WaitForChild("Consumables")
	Categories.Materials.Container = invFrame:WaitForChild("Materials")

	SetupTabs(invFrame)

	for categoryName, _ in pairs(Categories) do
		SyncCategoryUI(categoryName)
	end

	for categoryName, _ in pairs(Categories) do
		ClientDataStore:ListenToCollection({ "Inventories", categoryName }, {
			OnAdded = function()
				TriggerSync(categoryName)
			end,
			OnUpdated = function()
				TriggerSync(categoryName)
			end,
			OnRemoved = function()
				TriggerSync(categoryName)
			end,
		})

		ClientDataStore:ListenToValue({ "Inventories", categoryName }, function()
			TriggerSync(categoryName)
		end)
	end

	ClientDataStore:ListenToCollection({ "Equipped" }, {
		OnAdded = function()
			SyncAllEquipped()
		end,
		OnUpdated = function()
			SyncAllEquipped()
		end,
		OnRemoved = function()
			SyncAllEquipped()
		end,
	})

	ClientDataStore:ListenToValue({ "Equipped" }, function()
		SyncAllEquipped()
	end)

	ClientDataStore:ListenToCollection({ "Inventories", "Items" }, {
		OnUpdated = function()
			SyncAllEquipped()
		end,
	})
end

return InventoryUI
