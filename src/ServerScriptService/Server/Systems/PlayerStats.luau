-- File: Server/Systems/PlayerStatSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local LevelingCalculator = require(game.ReplicatedStorage.Shared.Utilities.LevelingCalculator)
local Players = game:GetService("Players")

local PlayerStatSystem = {}

-- ==========================================
-- 1. XỬ LÝ TIỀN TỆ (Currencies)
-- ==========================================
function PlayerStatSystem:AddCurrency(player: Player, currencyType: string, amount: number)
	local profile = DataManager:GetProfile(player)
	if profile and profile.Data.Currencies[currencyType] ~= nil then
		local newValue = profile.Data.Currencies[currencyType] + amount
		profile.Replica:Set({ "Currencies", currencyType }, newValue)
	end
end

-- ==========================================
-- 2. XỬ LÝ KINH NGHIỆM CHÍNH (Core Level)
-- ==========================================
function PlayerStatSystem:AddExp(player: Player, amount: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return
	end

	local oldExp = profile.Data.Core.Exp
	local oldLevel = profile.Data.Core.Level

	local newExp = oldExp + amount
	profile.Replica:Set({ "Core", "Exp" }, newExp)

	local newLevel, currentProgress, expNext = LevelingCalculator.CalculateLevel(newExp)

	if newLevel > oldLevel then
		profile.Replica:Set({ "Core", "Level" }, newLevel)

		local levelsGained = newLevel - oldLevel
		local pointsEarned = levelsGained * 3
		self:AddAttribute(player, "UnspentPoints", pointsEarned)

		print(
			string.format(
				"🎉 %s thăng cấp nhân vật: Lv %d -> Lv %d (+%d Điểm tiềm năng)",
				player.Name,
				oldLevel,
				newLevel,
				pointsEarned
			)
		)
	else
		print(
			string.format("📊 %s nhận %d Exp. Tiến trình: %d/%d", player.Name, amount, currentProgress, expNext)
		)
	end
end

-- ==========================================
-- 3. XỬ LÝ CHỈ SỐ CHIẾN ĐẤU (Attributes)
-- ==========================================
function PlayerStatSystem:AddAttribute(player: Player, attributeName: string, amount: number)
	local profile = DataManager:GetProfile(player)
	if profile and profile.Data.Attributes[attributeName] ~= nil then
		local newValue = profile.Data.Attributes[attributeName] + amount
		profile.Replica:Set({ "Attributes", attributeName }, newValue)
	end
end

-- ==========================================
-- 4. [MỚI] XỬ LÝ KINH NGHIỆM NGHỀ NGHIỆP (Professions)
-- ==========================================
function PlayerStatSystem:AddProfessionExp(player: Player, profName: string, amount: number)
	local profile = DataManager:GetProfile(player)
	if not profile then
		return
	end

	-- Đảm bảo dữ liệu nghề tồn tại
	if profile.Data.Professions[profName] == nil then
		profile.Data.Professions[profName] = 0
	end

	local oldExp = profile.Data.Professions[profName]
	local oldLevel = LevelingCalculator.CalculateLevel(oldExp) -- Dùng hàm để moi Level cũ ra

	-- Cộng exp mới
	local newExp = oldExp + amount
	profile.Replica:Set({ "Professions", profName }, newExp)

	-- Tính Level mới
	local newLevel, currentProgress, expNext = LevelingCalculator.CalculateLevel(newExp)

	if newLevel > oldLevel then
		print(
			string.format(
				"🛠️🎉 %s thăng cấp nghề [%s]: Lv %d -> Lv %d",
				player.Name,
				profName,
				oldLevel,
				newLevel
			)
		)
		-- Có thể gửi Event xuống Client để bắn pháo hoa UI ở đây
	else
		print(
			string.format(
				"🛠️ %s nhận %d Exp nghề [%s]. Tiến trình: %d/%d",
				player.Name,
				amount,
				profName,
				currentProgress,
				expNext
			)
		)
	end
end

-- ==========================================
-- LẮNG NGHE LỆNH CHAT ĐỂ TEST
-- ==========================================
function PlayerStatSystem:Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")
			local command = string.lower(args[1])
			table.remove(args, 1)

			if command == "/addcoin" then
				local amount = tonumber(args[1]) or 100
				self:AddCurrency(player, "Coin", amount)
			elseif command == "/addexp" then
				local amount = tonumber(args[1]) or 50
				self:AddExp(player, amount)
			elseif command == "/addprofexp" then
				-- VD: /addprofexp Crafting 500
				local profName = args[1]
				local amount = tonumber(args[2]) or 50
				if profName then
					self:AddProfessionExp(player, profName, amount)
				end
			elseif command == "/debug" then
				DataManager:DebugProfile(player)
			end
		end)
	end)
end

return PlayerStatSystem
