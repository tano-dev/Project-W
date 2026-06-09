-- File: Server/Services/DataManager.luau
local ProfileStore = require(game.ServerScriptService.Server.Libraries.ProfileStore)

-- [REPLICA] Khởi tạo Token định danh cho gói dữ liệu (Đặt cố định ở ngoài)
local Replica = require(game.ServerScriptService.Server.Libraries.ReplicaServer)
local PlayerToken = Replica.Token("PlayerData")

-- 1. Khuôn mẫu dữ liệu gốc
local PlayerDataTemplate = require(game.ServerScriptService.Server.Components.ProfileTemplate)

-- 2. Khởi tạo kho lưu trữ
local PlayerStore = ProfileStore.New("PlayerData_v1", PlayerDataTemplate)

-- 3. Biến lưu trữ Profile của những người chơi đang online
local Profiles = {}

local DataManager = {}
function DataManager:LoadProfile(player)
    local profile = PlayerStore:StartSessionAsync(tostring(player.UserId), {
        Cancel = function()
            return player.Parent ~= game.Players
        end,
    })

    if profile ~= nil then
        profile:AddUserId(player.UserId) 
        profile:Reconcile()

        -- [REPLICA] Khởi tạo thực thể Replica mới trỏ thẳng vào profile.Data
        local replica = Replica.New({
            Token = PlayerToken,
            Tags = { UserId = player.UserId }, -- Gắn nhãn UserId để Client dễ nhận biết bảo mật
            Data = profile.Data
        })
        
        -- [REPLICA] Chỉ định duy nhất player này được quyền nhận dữ liệu của chính họ
        replica:Subscribe(player)
        profile.Replica = replica

        profile.OnSessionEnd:Connect(function()
            Profiles[player] = nil
            
            -- [REPLICA] Giải phóng bộ nhớ mạng khi Profile bị đóng đóng
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
        -- [REPLICA] Phải hủy Replica trước khi nhả session của ProfileStore
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
-- HÀM HỖ TRỢ: FORMAT TABLE THÀNH CHUỖI ĐẸP
-- ==========================================
local function FormatTableToString(t, indent)
	indent = indent or ""
	local result = ""

	for k, v in pairs(t) do
		-- Định dạng Key (Khóa)
		local keyStr = type(k) == "number" and "[" .. k .. "]" or tostring(k)

		if type(v) == "table" then
			-- Nếu mảng rỗng thì in {} luôn trên 1 dòng cho gọn
			if next(v) == nil then
				result = result .. indent .. keyStr .. " = {}, \n"
			else
				-- Nếu mảng có đồ, xuống dòng và thụt lề thêm
				result = result .. indent .. keyStr .. " = {\n"
				result = result .. FormatTableToString(v, indent .. "    ")
				result = result .. indent .. "},\n"
			end
		elseif type(v) == "string" then
			-- Bọc chuỗi trong dấu ngoặc kép
			result = result .. indent .. keyStr .. ' = "' .. v .. '", \n'
		else
			-- Các kiểu số, boolean...
			result = result .. indent .. keyStr .. " = " .. tostring(v) .. ", \n"
		end
	end

	return result
end

-- ==========================================
-- HÀM IN DỮ LIỆU ĐỂ DEBUG
-- ==========================================
function DataManager:DebugProfile(player)
	local profile = self:GetProfile(player)

	if not profile then
		warn("❌ Không tìm thấy dữ liệu của người chơi: " .. player.Name)
		return
	end

	print("\n=== 📊 DỮ LIỆU CỦA NGƯỜI CHƠI: " .. player.Name .. " ===")

	-- Nối chuỗi để in ra toàn bộ cấu trúc
	local prettyData = "{\n" .. FormatTableToString(profile.Data, "    ") .. "}"

	print(prettyData)
	print("==================================================\n")
end
-- Hàm này sẽ được Bootstrapper tự động gọi!
function DataManager:Start()
    local Players = game:GetService("Players")

    -- Tự động load khi người chơi vào
    Players.PlayerAdded:Connect(function(player)
        self:LoadProfile(player)
    end)

    -- Tự động lưu khi người chơi thoát
    Players.PlayerRemoving:Connect(function(player)
        self:UnloadProfile(player)
    end)

    -- Catch Studio Edge Case (Cho những người load nhanh hơn cả server)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            self:LoadProfile(player)
        end)
    end
end

return DataManager