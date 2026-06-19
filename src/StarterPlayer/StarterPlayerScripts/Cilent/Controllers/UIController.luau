-- File: StarterPlayerScripts/Client/Controllers/UIController.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Fusion = require(ReplicatedStorage.Shared.Utilities.Fusion)

local scope = Fusion.scoped(Fusion)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local UIController = {
	ActiveScreen = scope:Value("None"),
	FadeOpacity = scope:Value(0),

	-- Danh sách tất cả các màn hình có thể bật/tắt (Đã thêm Info vào đây)
	ExclusiveScreens = {
		"Classes",
		"Combat",
		"Crafting",
		"Inventory",
		"MainGui",
		"Professions",
		"Shop",
		"Upgrade",
		"InventoryInfo",
	},

	-- [CẢI TIẾN MỚI]: BẢNG MÀN HÌNH LIÊN KẾT (LINKED SCREENS)
	-- Khi màn hình chính (Key) được bật, các màn hình phụ (Value) cũng sẽ tự động bật theo
	LinkedScreens = {
		["Inventory"] = { "InventoryInfo" }, -- Bật Inventory -> Bật kèm Info
		["Upgrade"] = { "Inventory" }, -- Bật Upgrade -> Bật kèm Inventory
		["Crafting"] = { "Inventory" }, -- Bật Crafting -> Bật kèm Inventory
	},

	-- Các màn hình luôn luôn bật trên màn hình HUD
	AlwaysOnScreens = {
		"MainButtons",
		"MainButtons_UI",
	},
}

function UIController:Start()
	-- 1. HYDRATE CÁC MÀN HÌNH ĐỘC QUYỀN VÀ LIÊN KẾT
	for _, screenName in ipairs(self.ExclusiveScreens) do
		local screenGui = PlayerGui:WaitForChild(screenName)

		scope:Hydrate(screenGui)({
			Enabled = scope:Computed(function(use)
				local currentScreen = use(self.ActiveScreen)

				-- Trường hợp 1: Nó chính là màn hình đang được chọn
				if currentScreen == screenName then
					return true
				end

				-- Trường hợp 2: Nó nằm trong danh sách "Màn hình phụ đi kèm" của màn hình đang chọn
				local linkedList = self.LinkedScreens[currentScreen]
				if linkedList and table.find(linkedList, screenName) then
					return true
				end

				return false
			end),
		})
	end

	-- 2. ĐẢM BẢO CÁC MÀN HÌNH HUD LUÔN BẬT
	for _, screenName in ipairs(self.AlwaysOnScreens) do
		local screenGui = PlayerGui:WaitForChild(screenName)
		screenGui.Enabled = true
	end

	-- 3. [CẢI TIẾN MỚI]: HYDRATE SHADER EFFECT TỰ ĐỘNG
	local shaderEffectGui = PlayerGui:WaitForChild("ShaderEffect")
	scope:Hydrate(shaderEffectGui)({
		-- Shader sẽ tự động BẬT khi đang ở trong Menu (ActiveScreen khác "None")
		-- Và tự động TẮT khi người chơi trở về sảnh HUD (ActiveScreen là "None")
		Enabled = scope:Computed(function(use)
			return use(self.ActiveScreen) ~= "None"
		end),
	})

	-- 4. HYDRATE MÀN HÌNH CHUYỂN CẢNH (Transition)
	local transitionGui = PlayerGui:WaitForChild("Transition")
	transitionGui.Enabled = true

	local fadeBackground = transitionGui:WaitForChild("Background")
	scope:Hydrate(fadeBackground)({
		BackgroundTransparency = scope:Spring(
			scope:Computed(function(use)
				return 1 - use(self.FadeOpacity)
			end),
			30,
			1
		),
	})
end

function UIController:ShowScreen(screenName: string)
	self.ActiveScreen:set(screenName)
end

function UIController:HideAll()
	self.ActiveScreen:set("None")
end

function UIController:PlayFadeTransition(midPointCallback: () -> ())
	self.FadeOpacity:set(1)
	task.wait(0.4)

	if midPointCallback then
		midPointCallback()
	end

	task.wait(0.1)
	self.FadeOpacity:set(0)
end

return UIController
