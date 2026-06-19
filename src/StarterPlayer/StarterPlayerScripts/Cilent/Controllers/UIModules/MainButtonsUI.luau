-- File: StarterPlayerScripts/Client/Controllers/UIModules/MainButtonsUI.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Fusion = require(ReplicatedStorage.Shared.Utilities.Fusion)
local ColorTemplate = require(ReplicatedStorage.Shared.Components.ColorTemplate)
local UIController = require(script.Parent.Parent.UIController)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local MainButtonsUI = {}

local BUTTON_MAP = {
	["Inventory"] = { Screen = "Inventory", ColorKey = "Inventory" },
	["Stats"] = { Screen = "Professions", ColorKey = "Profession" },
	["Upgrade"] = { Screen = "Upgrade", ColorKey = "Upgrade" },
	["Crafting"] = { Screen = "Crafting", ColorKey = "Crafting" },
	["Classes"] = { Screen = "Classes", ColorKey = "Classes" },
	["Players"] = { Screen = "Party", ColorKey = "Party" },
	["Settings"] = { Screen = "Settings", ColorKey = "Settings" },
	["Exit"] = { Screen = "None", ColorKey = "Exit", IsCloseButton = true },
}

local function HydrateButtonGroup(container)
	if not container then
		return
	end

	for _, child in ipairs(container:GetChildren()) do
		local button = child:IsA("TextButton") and child or child:FindFirstChildWhichIsA("TextButton")

		if button then
			local buttonName = child.Name
			local mapData = BUTTON_MAP[buttonName]

			if mapData then
				local isHovered = scope:Value(false)

				-- [SỬA LỖI GHOST HOVER]: Bắt sự kiện chuyển màn hình
				-- Cứ mỗi lần màn hình thay đổi (Đóng hoặc Mở), lập tức reset trạng thái Hover về false.
				-- Điều này chống kẹt màu khi người chơi đóng UI bằng phím tắt hoặc khi UI bị ẩn đột ngột.
				scope:Observer(UIController.ActiveScreen):onChange(function()
					isHovered:set(false)
				end)

				-- Tính toán Màu sắc mục tiêu
				local targetColor = scope:Computed(function(use)
					local isScreenActive = use(UIController.ActiveScreen) == mapData.Screen
					local isMouseOver = use(isHovered)

					if isScreenActive or isMouseOver then
						return ColorTemplate.MainButtons[mapData.ColorKey] or ColorTemplate.MainButtons.Default
					else
						return ColorTemplate.MainButtons.Default
					end
				end)

				-- 1. HYDRATE NÚT BẤM CHÍNH
				scope:Hydrate(button)({
					AutoButtonColor = false,

					[Fusion.OnEvent("MouseEnter")] = function()
						isHovered:set(true)
					end,

					[Fusion.OnEvent("MouseLeave")] = function()
						isHovered:set(false)
					end,

					[Fusion.OnEvent("Activated")] = function()
						-- [SỬA LỖI GHOST HOVER]: Ép tắt Hover ngay khoảnh khắc bấm chuột
						isHovered:set(false)

						-- Chống spam click
						if peek(UIController.FadeOpacity) > 0 then
							return
						end

						local currentScreen = peek(UIController.ActiveScreen)

						if mapData.IsCloseButton then
							if currentScreen ~= "None" then
								UIController:PlayFadeTransition(function()
									UIController:HideAll()
								end)
							end
						else
							if currentScreen == mapData.Screen then
								UIController:PlayFadeTransition(function()
									UIController:HideAll()
								end)
							else
								UIController:PlayFadeTransition(function()
									UIController:ShowScreen(mapData.Screen)
								end)
							end
						end
					end,
				})

				-- 2. HYDRATE COLOR FRAME
				local colorFrame = button:FindFirstChild("ColorFrame")

				if colorFrame and colorFrame:IsA("GuiObject") then
					scope:Hydrate(colorFrame)({
						BackgroundColor3 = scope:Spring(targetColor, 15, 1),
					})
				else
					warn("⚠️ Không tìm thấy 'ColorFrame' bên trong nút: " .. buttonName)
					scope:Hydrate(button)({
						BackgroundColor3 = scope:Spring(targetColor, 15, 1),
					})
				end
			end
		end
	end
end

function MainButtonsUI:Start()
	print("🔘 Khởi tạo giao diện các Nút Điều Hướng...")

	local menuGui = PlayerGui:WaitForChild("MainButtons_UI", 3)
	local hudGui = PlayerGui:WaitForChild("MainButtons", 3)

	if menuGui then
		scope:Hydrate(menuGui)({
			Enabled = scope:Computed(function(use)
				return use(UIController.ActiveScreen) ~= "None"
			end),
		})
		local containerFrame = menuGui:FindFirstChildWhichIsA("Frame")
		HydrateButtonGroup(containerFrame)
	end

	if hudGui then
		scope:Hydrate(hudGui)({
			Enabled = scope:Computed(function(use)
				return use(UIController.ActiveScreen) == "None"
			end),
		})
		local containerFrameHUD = hudGui:FindFirstChildWhichIsA("Frame")
		HydrateButtonGroup(containerFrameHUD)
	end
end

return MainButtonsUI
