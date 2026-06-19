-- File: Server/Systems/RoomSpawnSystem.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MobData = require(ReplicatedStorage.Shared.Constants.MobData)
local Components = require(ReplicatedStorage.Shared.Components) -- Giả định nơi chứa các Component của Matter

local RoomSpawnSystem = {}
local ecsWorld = nil

-- Thư mục chứa các Instance hầm ngục đang chạy (để tránh rác Workspace)
local DungeonFolder = Workspace:FindFirstChild("ActiveDungeons") or Instance.new("Folder")
DungeonFolder.Name = "ActiveDungeons"
DungeonFolder.Parent = Workspace

-- Lưu trữ tham chiếu phòng hiện tại của từng chuyến đi (Key: RunInstanceId hoặc UserId)
local ActiveRoomInstances = {}

-- Khởi tạo hệ thống và nhận ecsWorld từ ServerMain
function RoomSpawnSystem:Start(world)
	ecsWorld = world
end

-- ==========================================
-- HÀM HỖ TRỢ: DỌN DẸP PHÒNG CŨ
-- ==========================================
local function CleanupPreviousRoom(runId: string)
	if ActiveRoomInstances[runId] then
		local oldRoom = ActiveRoomInstances[runId].Model
		if oldRoom then
			oldRoom:Destroy()
		end

		-- Dọn dẹp các Entity quái vật của phòng cũ khỏi Matter ECS
		for _, entityId in ipairs(ActiveRoomInstances[runId].Entities) do
			if ecsWorld:contains(entityId) then
				ecsWorld:despawn(entityId)
			end
		end

		ActiveRoomInstances[runId] = nil
	end
end

-- ==========================================
-- HÀM HỖ TRỢ: SINH QUÁI VẬT (MATTER ECS)
-- ==========================================
local function SpawnEnemies(roomModel: Model, depth: number, rng: Random)
	local spawnedEntities = {}
	local spawnPoints = roomModel:FindFirstChild("EnemySpawns")

	if not spawnPoints then
		return spawnedEntities
	end

	-- Lựa chọn nhóm quái vật dựa trên Tầng (Depth)
	local availableMobs = { "Mob_1", "Mob_2" }
	if depth > 5 then
		table.insert(availableMobs, "Mob_3")
	end

	for _, spawnPoint in ipairs(spawnPoints:GetChildren()) do
		-- 1. Chọn quái ngẫu nhiên bằng Seed (Đảm bảo mỗi lần spawn cùng một loại quái nếu cùng Seed và Depth)
		local mobId = availableMobs[rng:NextInteger(1, #availableMobs)]
		local mobDef = MobData[mobId]

		-- 2. Clone Model 3D của quái vật
		local mobModel = ReplicatedStorage.Assets.Models.Characters[mobDef.ModelName]:Clone()
		mobModel:PivotTo(spawnPoint.CFrame)
		mobModel.Parent = roomModel

		-- 3. ĐĂNG KÝ VÀO MATTER ECS
		local entityId = ecsWorld:spawn(
			Components.Model({ Instance = mobModel }),
			Components.Enemy({ Id = mobId, Type = mobDef.Type }),

			-- Tích hợp Stats (Có scale theo Depth)
			Components.Stats({
				CurrentHp = mobDef.BaseHp + (depth * 5),
				MaxHp = mobDef.BaseHp + (depth * 5),
				Shield = 0,
				Stagger = 0,
				MaxStagger = mobDef.BaseStagger,
			}),

			-- Slay The Spire Mechanic: Gán Intent ban đầu
			Components.Intent({ Action = "Idle", Target = nil, BaseDamage = 0 }),

			-- Dùng để theo dõi lượt (Expedition 33 Style)
			Components.Speed({ Value = mobDef.BaseSpeed })
		)

		table.insert(spawnedEntities, entityId)
	end

	return spawnedEntities
end

-- ==========================================
-- API CHÍNH: XÂY PHÒNG & DỊCH CHUYỂN
-- ==========================================
-- (runId có thể là DungeonId + Seed hoặc UserId của Host)
function RoomSpawnSystem:BuildAndTeleport(player: Player, nodeInfo: table, runId: string, seed: number)
	-- Sử dụng Seed để đảm bảo phòng sinh ra y hệt nếu người chơi bị crash và reconnect
	local rng = Random.new(seed + nodeInfo.Depth)

	-- 1. Dọn dẹp tàn dư phòng cũ
	CleanupPreviousRoom(runId)

	-- 2. Xây dựng phòng 3D mới
	-- Random hóa biến thể phòng (Ví dụ: CombatRoom_01, CombatRoom_02)
	local variation = rng:NextInteger(1, 3)
	local roomTemplateName = string.format("%sRoom_0%d", nodeInfo.Type, variation)

	local roomTemplate = ReplicatedStorage.Assets.Models.DungeonRooms:FindFirstChild(roomTemplateName)
	if not roomTemplate then
		-- Fallback nếu không có biến thể
		roomTemplate = ReplicatedStorage.Assets.Models.DungeonRooms:FindFirstChild(nodeInfo.Type .. "Room_01")
	end

	local newRoom = roomTemplate:Clone()

	-- Đặt phòng ở một vị trí rất xa để cách ly (Có thể dùng công thức tính toán tọa độ lưới)
	local offsetOffset = Vector3.new(0, 10000, rng:NextInteger(-50000, 50000))
	newRoom:PivotTo(CFrame.new(offsetOffset))
	newRoom.Parent = DungeonFolder

	-- 3. Tạo Entity dựa trên loại phòng (Bơm sự sống)
	local currentEntities = {}

	if nodeInfo.Type == "Combat" or nodeInfo.Type == "Elite" or nodeInfo.Type == "Boss" then
		currentEntities = SpawnEnemies(newRoom, nodeInfo.Depth, rng)
	elseif nodeInfo.Type == "Shop" then
		-- Sinh ra Entity Cửa hàng (NPC)
		-- ecsWorld:spawn( Components.Shopkeeper(...) )
	elseif nodeInfo.Type == "Treasure" then
		-- Sinh ra Entity Rương kho báu
		-- ecsWorld:spawn( Components.Chest(...) )
	end

	-- 4. Lưu vết để dọn dẹp sau này
	ActiveRoomInstances[runId] = {
		Model = newRoom,
		Entities = currentEntities,
	}

	-- 5. Dịch chuyển Người chơi (Player) và Đồng đội (Companions)
	local playerSpawn = newRoom:FindFirstChild("PlayerSpawn")
	if playerSpawn then
		-- Teleport nhân vật chính
		local char = player.Character
		if char and char:GetPivot() then
			char:PivotTo(playerSpawn.CFrame + Vector3.new(0, 3, 0))
		end

		-- [Tương lai]: Viết vòng lặp để spawn/teleport luôn các Model của 3 NPC Đồng hành đứng xung quanh Player
	else
		warn("🚨 Phòng " .. roomTemplateName .. " bị thiếu part 'PlayerSpawn'!")
	end
end

return RoomSpawnSystem
