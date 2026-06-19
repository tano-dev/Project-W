-- File: Server/Services/DataStore.luau
local DataStoreService = game:GetService("DataStoreService") -- [MỚI] Dùng để quản lý Sổ cái toàn cục
local ProfileStore = require(game.ServerScriptService.Server.Libraries.ProfileStore)

-- [REPLICA] Khởi tạo Token định danh cho gói dữ liệu (Đặt cố định ở ngoài)
local Replica = require(game.ServerScriptService.Server.Libraries.ReplicaServer)
local PlayerToken = Replica.Token("PlayerData")

-- 1. Khuôn mẫu dữ liệu gốc
local PlayerDataTemplate = require(game.ServerScriptService.Server.Components.ProfileTemplate)

-- 2. Khởi tạo kho lưu trữ cá nhân (Vòng đời theo người chơi online/offline)
local PlayerStore = ProfileStore.New("PlayerData_v1", PlayerDataTemplate)

-- [MỚI] 2b. Khởi tạo kho lưu trữ Sổ Cái Hầm Ngục toàn cục (Lưu theo ID trận đấu, không theo người chơi)
local DungeonLedgerStore = DataStoreService:GetDataStore("DungeonLedger_v1")

-- 3. Biến lưu trữ Profile của những người chơi đang online
local Profiles = {}

local DataManager = {}

-- ==========================================
-- [MỚI] API HỆ THỐNG SỔ CÁI HẦM NGỤC (DUNGEON LEDGER)
-- ==========================================

-- Hàm 1: Tạo một bản ghi sổ cái mới khi tổ đội bắt đầu vào hầm ngục
function DataManager:CreateDungeonLedgerAsync(runInstanceId: string, participantUserIds: table)
    local initialLedger = {
        Status = "Active", -- Trạng thái mặc định: Đang diễn ra
        FloorReached = 1,
        SharedRewards = {
            Gold = 0,
            Items = {} -- Mảng chứa ID vật phẩm rớt chung
        },
        ParticipantIds = participantUserIds, -- Danh sách UserId của các thành viên trong đội
        Timestamp = os.time()
    }
    
    local success, err = pcall(function()
        DungeonLedgerStore:SetAsync(runInstanceId, initialLedger)
    end)
    
    if not success then
        warn("🚨 [DataManager] Không thể tạo Sổ cái Hầm ngục cho " .. runInstanceId .. ": " .. tostring(err))
    end
    return success
end

-- Hàm 2: Đọc dữ liệu sổ cái (Dùng khi người chơi bị văng game và muốn Reconnect kiểm tra xem team thắng hay thua)
function DataManager:GetDungeonLedgerAsync(runInstanceId: string)
    local success, ledgerData = pcall(function()
        return DungeonLedgerStore:GetAsync(runInstanceId)
    end)
    
    if success then
        return ledgerData -- Trả về bảng dữ liệu hoặc nil nếu không tìm thấy
    else
        warn("🚨 [DataManager] Lỗi khi đọc Sổ cái Hầm ngục " .. runInstanceId .. ": " .. tostring(ledgerData))
        return nil
    end
end

-- Hàm 3: Cập nhật kết quả hầm ngục (Được gọi từ DungeonManager/LootManager khi kết thúc hoặc cập nhật phần thưởng)
function DataManager:UpdateDungeonLedgerAsync(runInstanceId: string, status: string, sharedRewards: table?, floorReached: number?)
    local success, err = pcall(function()
        DungeonLedgerStore:UpdateAsync(runInstanceId, function(currentLedger)
            if not currentLedger then return nil end -- Phòng hờ trường hợp không tìm thấy bản ghi cũ
            
            currentLedger.Status = status or currentLedger.Status
            if sharedRewards then
                currentLedger.SharedRewards = sharedRewards
            end
            if floorReached then
                currentLedger.FloorReached = floorReached
            end
            
            return currentLedger
        end)
    end)
    
    if not success then
        warn("🚨 [DataManager] Không thể cập nhật Sổ cái Hầm ngục " .. runInstanceId .. ": " .. tostring(err))
    end
    return success
end


-- ==========================================
-- API QUẢN LÝ PROFILE NGƯỜI CHƠI (GIỮ NGUYÊN)
-- ==========================================
function DataManager:LoadProfile(player)
    local profile = PlayerStore:StartSessionAsync(tostring(player.UserId), {
        Cancel = function()
            return player.Parent ~= game.Players
        end,
    })

    if profile ~= nil then
        profile:AddUserId(player.UserId) 
        profile:Reconcile()

        local replica = Replica.New({
            Token = PlayerToken,
            Tags = { UserId = player.UserId }, 
            Data = profile.Data
        })
        
        replica:Subscribe(player)
        profile.Replica = replica

        profile.OnSessionEnd:Connect(function()
            Profiles[player] = nil
            if profile.Replica then
                profile.Replica:Destroy()
            end
            player:Kick("Dữ liệu của bạn đã được tải ở một server khác. Vui lòng vào lại!")
        end)

        if player.Parent == game.Players then
            Profiles[player] = profile
            print("✅ Đã tải dữ liệu & Replica thành công cho:", player.Name)
        else
            profile:EndSession()
        end
    else
        player:Kick("Không thể tải dữ liệu. Vui lòng thử lại!")
    end
end

function DataManager:UnloadProfile(player)
    local profile = Profiles[player]
    if profile ~= nil then
        if profile.Replica then
            profile.Replica:Destroy()
        end
        profile:EndSession()
        Profiles[player] = nil
        print("💾 Đã lưu và đóng dữ liệu của:", player.Name)
    end
end

function DataManager:GetProfile(player)
    return Profiles[player]
end

-- ==========================================
-- HÀM HỖ TRỢ: FORMAT TABLE THÀNH CHUỖI ĐẸP (GIỮ NGUYÊN)
-- ==========================================
local function FormatTableToString(t, indent)
    indent = indent or ""
    local result = ""
    for k, v in pairs(t) do
        local keyStr = type(k) == "number" and "[" .. k .. "]" or tostring(k)
        if type(v) == "table" then
            if next(v) == nil then
                result = result .. indent .. keyStr .. " = {}, \n"
            else
                result = result .. indent .. keyStr .. " = {\n"
                result = result .. FormatTableToString(v, indent .. "    ")
                result = result .. indent .. "},\n"
            end
        elseif type(v) == "string" then
            result = result .. indent .. keyStr .. ' = "' .. v .. '", \n'
        else
            result = result .. indent .. keyStr .. " = " .. tostring(v) .. ", \n"
        end
    end
    return result
end

function DataManager:DebugProfile(player)
    local profile = self:GetProfile(player)
    if not profile then
        warn("❌ Không tìm thấy dữ liệu của người chơi: " .. player.Name)
        return
    end
    print("\n=== 📊 DỮ LIỆU CỦA NGƯỜI CHƠI: " .. player.Name .. " ===")
    local prettyData = "{\n" .. FormatTableToString(profile.Data, "    ") .. "}"
    print(prettyData)
    print("==================================================\n")
end

function DataManager:Start()
    local Players = game:GetService("Players")
    Players.PlayerAdded:Connect(function(player)
        self:LoadProfile(player)
    end)
    Players.PlayerRemoving:Connect(function(player)
        self:UnloadProfile(player)
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            self:LoadProfile(player)
        end)
    end
end

return DataManager