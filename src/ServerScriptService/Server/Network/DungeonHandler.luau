-- File: ServerScriptService/Server/Network/DungeonHandler.luau

local DataStoreSystem = require(game.ServerScriptService.Server.Systems.DataStore)
local DungeonGenerator = require(game.ReplicatedStorage.Shared.Utilities.DungeonGenerator)
local RoomSpawnSystem = require(game.ServerScriptService.Server.Systems.RoomSpawn)
local DungeonNetwork = require(game.ReplicatedStorage.Shared.Network.DungeonNetwork)

local DungeonHandler = {}

function DungeonHandler:Start()
	-- 1. NGƯỜI CHƠI YÊU CẦU BẮT ĐẦU CHUYẾN ĐI MỚI
	DungeonNetwork.RequestStartRun.listen(function(dungeonId, player)
		local profile = DataStoreSystem:GetProfile(player)
		if not profile or profile.Data.ActiveRun.InRun then
			return
		end

		-- Tạo Seed ngẫu nhiên
		local newSeed = os.time() + math.random(1, 100000)

		-- Server vẽ bản đồ ngầm (Dùng để xác thực)
		local mapData = DungeonGenerator:GenerateMap(dungeonId, newSeed)

		-- Lưu vào Profile (Dữ liệu vĩnh viễn đề phòng rớt mạng)
		profile.Replica:Set({ "ActiveRun", "InRun" }, true)
		profile.Replica:Set({ "ActiveRun", "DungeonId" }, dungeonId)
		profile.Replica:Set({ "ActiveRun", "Seed" }, newSeed)
		profile.Replica:Set({ "ActiveRun", "CurrentDepth" }, 1)
		profile.Replica:Set({ "ActiveRun", "CurrentNodeId" }, "1_1")
		profile.Replica:Set({ "ActiveRun", "VisitedNodes" }, { ["1_1"] = true })

		-- Spawn phòng 3D đầu tiên cho họ
		RoomSpawnSystem:BuildAndTeleport(player, mapData.Nodes["1_1"], tostring(player.UserId), newSeed)
        
		-- [BYTENET] Gửi gói tin siêu nhẹ xuống Client để Client TỰ VẼ LẠI MAP
		DungeonNetwork.RunStarted.sendTo({
			Seed = newSeed,
			DungeonId = dungeonId,
		}, player)
	end)

	-- 2. NGƯỜI CHƠI BẤM VÀO MINIMAP YÊU CẦU CHUYỂN PHÒNG
	DungeonNetwork.RequestEnterRoom.listen(function(targetNodeId, player)
		local profile = DataStoreSystem:GetProfile(player)
		if not profile then
			return
		end

		local activeRun = profile.Data.ActiveRun
		if not activeRun.InRun then
			return
		end

		-- Xác thực (Server tự vẽ lại map bằng Seed cũ trên RAM để đối chiếu)
		local mapData = DungeonGenerator:GenerateMap(activeRun.DungeonId, activeRun.Seed)
		local currentNodeId = activeRun.CurrentNodeId

		if not DungeonGenerator:IsValidMove(mapData, currentNodeId, targetNodeId) then
			warn("🚨 Gian lận thám hiểm: Người chơi " .. player.Name .. " cố nhảy cóc phòng!")
			return
		end

		local targetNodeInfo = mapData.Nodes[targetNodeId]

		-- Cập nhật Tiến trình hợp lệ
		profile.Replica:Set({ "ActiveRun", "CurrentNodeId" }, targetNodeId)
		profile.Replica:Set({ "ActiveRun", "CurrentDepth" }, targetNodeInfo.Depth)
		profile.Replica:Set({ "ActiveRun", "VisitedNodes", targetNodeId }, true)

		-- Sử dụng RunInstanceId (hoặc UserId nếu đi Solo) để làm Key quản lý Instance
		local runId = activeRun.RunInstanceId ~= "" and activeRun.RunInstanceId or tostring(player.UserId)

		-- GỌI HỆ THỐNG SPAWN PHÒNG
		RoomSpawnSystem:BuildAndTeleport(player, targetNodeInfo, runId, activeRun.Seed)

		-- [BYTENET] Gửi tín hiệu chuyển cảnh xuống Client
		DungeonNetwork.RoomTransition.sendTo(targetNodeInfo.Type, player)
	end)
end

return DungeonHandler
