-- File: Server/Systems/PlayerStatSystem.luau
local DataManager = require(game.ServerScriptService.Server.Systems.DataStore)
local LevelingCalculator = require(game.ReplicatedStorage.Shared.Utilities.LevelingCalculator)
local Players = game:GetService("Players")

local PlayerStatSystem = {}

-- ==========================================
-- CÁC HÀM XỬ LÝ LOGIC (API)
-- ==========================================

-- 1. Hàm cộng/trừ tiền tệ chung (Coin, Gem...)
function PlayerStatSystem:AddCurrency(player: Player, currencyType: string, amount: number)
    local profile = DataManager:GetProfile(player)
    if profile and profile.Data.Currencies[currencyType] ~= nil then
        local newValue = profile.Data.Currencies[currencyType] + amount
        profile.Replica:Set({"Currencies", currencyType}, newValue)
    end
end

-- 2. Hàm cộng kinh nghiệm (Core Stats)
function PlayerStatSystem:AddExp(player: Player, amount: number)
    local profile = DataManager:GetProfile(player)
    if not profile then return end

    local oldExp = profile.Data.Core.Exp
    local oldLevel = profile.Data.Core.Level
    
    -- 1. Cộng dồn vào Tổng EXP trọn đời
    local newExp = oldExp + amount
    profile.Replica:Set({"Core", "Exp"}, newExp)
    
    -- 2. Tính toán cấp độ mới dựa trên Tổng EXP
    local newLevel, currentProgress, expNext = LevelingCalculator.CalculateLevel(newExp)
    
    -- 3. Kiểm tra xem người chơi có lên cấp không
    if newLevel > oldLevel then
        -- Ép thông số Level mới lên mạng
        profile.Replica:Set({"Core", "Level"}, newLevel)
        
        -- Tính số cấp vừa nhảy (Trường hợp được buff 1 lúc 10.000 exp nhảy 5 cấp)
        local levelsGained = newLevel - oldLevel
        
        -- Thưởng 3 điểm cộng chỉ số chiến đấu cho mỗi cấp
        local pointsEarned = levelsGained * 3 
        self:AddAttribute(player, "UnspentPoints", pointsEarned)
        
        print("🎉 " .. player.Name .. " thăng cấp: Lv " .. oldLevel .. " -> Lv " .. newLevel)
        
        -- (Tùy chọn) Bắn một event xuống Client để hiện chữ "Level Up" hoặc tạo hạt (VFX)
    else
        -- Debug để theo dõi Exp nếu chưa lên cấp
        print("📊 " .. player.Name .. " nhận " .. amount .. " Exp. Tiến trình: " .. currentProgress .. "/" .. expNext)
    end
end
-- 3. Hàm cộng điểm chỉ số chiến đấu (Attributes)
function PlayerStatSystem:AddAttribute(player: Player, attributeName: string, amount: number)
    local profile = DataManager:GetProfile(player)
    if profile and profile.Data.Attributes[attributeName] ~= nil then
        local newValue = profile.Data.Attributes[attributeName] + amount
        profile.Replica:Set({"Attributes", attributeName}, newValue)
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
            table.remove(args, 1) -- Bỏ phần command đi để lấy tham số

            if command == "/addcoin" then
                -- Lấy số tiền người chơi gõ, nếu không gõ số thì mặc định là 100
                local amount = tonumber(args[1]) or 100
                print("🖥️ Thực thi lệnh: +" .. amount .. " Coin")
                self:AddCurrency(player, "Coin", amount)

            elseif command == "/addexp" then
                local amount = tonumber(args[1]) or 50
                print("🖥️ Thực thi lệnh: +" .. amount .. " Exp")
                self:AddExp(player, amount)

            elseif command == "/debug" then
                -- Chuyển lệnh debug về đây cho hợp lý
                DataManager:DebugProfile(player)
            end
        end)
    end)
end

return PlayerStatSystem