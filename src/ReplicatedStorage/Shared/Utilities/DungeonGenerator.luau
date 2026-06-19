-- File: Server/Services/DungeonGenerator.luau
local DungeonGenerator = {}

-- ==========================================
-- CẤU HÌNH HẦM NGỤC (Dungeon Config)
-- ==========================================
local CONFIG = {
	MaxDepth = 15, -- Tổng số tầng trước khi gặp Boss
	MinNodesPerDepth = 2, -- Số đường đi tối thiểu mỗi tầng
	MaxNodesPerDepth = 4, -- Số đường đi tối đa mỗi tầng

	-- Tỉ lệ xuất hiện các loại phòng (Trọng số - Weight)
	RoomWeights = {
		Combat = 45, -- Quái thường (45%)
		Event = 22, -- Sự kiện ẩn (22%)
		Elite = 16, -- Quái tinh anh (16%)
		Shop = 5, -- Cửa hàng (5%)
		Campfire = 12, -- Lửa trại hồi máu (12%)
	},
}

-- ==========================================
-- HÀM HỖ TRỢ: CHỌN PHÒNG THEO TRỌNG SỐ (WEIGHTED RANDOM)
-- ==========================================
local function PickRoomType(rng: Random, depth: number)
	-- Luật ép buộc (Forced Rules)
	if depth == 1 then
		return "Combat"
	end
	if depth == 8 or depth == 9 then
		return "Treasure"
	end -- Tầng kho báu giữa game
	if depth == CONFIG.MaxDepth then
		return "Boss"
	end

	-- Lọc bỏ Elite ở 3 tầng đầu tiên
	local availableWeights = {}
	local totalWeight = 0

	for roomType, weight in pairs(CONFIG.RoomWeights) do
		if roomType == "Elite" and depth <= 3 then
			continue -- Skip Elite
		end
		if roomType == "Campfire" and depth == 1 then
			continue -- Không cho nghỉ ngơi ở tầng 1
		end

		table.insert(availableWeights, { Type = roomType, Weight = weight })
		totalWeight += weight
	end

	local roll = rng:NextNumber(0, totalWeight)
	local currentWeight = 0

	for _, data in ipairs(availableWeights) do
		currentWeight += data.Weight
		if roll <= currentWeight then
			return data.Type
		end
	end

	return "Combat" -- Fallback an toàn
end

-- ==========================================
-- API CHÍNH: TẠO BẢN ĐỒ BẰNG SEED (DETERMINISTIC GENERATION)
-- ==========================================
function DungeonGenerator:GenerateMap(dungeonId: string, seed: number)
	-- Sử dụng Random.new(seed) để đảm bảo thuật toán sinh ngẫu nhiên giả (PRNG) luôn trả về chuỗi kết quả cố định
	local rng = Random.new(seed)

	local map = {
		Seed = seed,
		DungeonId = dungeonId,
		Nodes = {}, -- Lưu thông tin từng điểm: { ["1_1"] = { Type = "Combat", Depth = 1 }, ... }
		Paths = {}, -- Lưu đường đi: { ["1_1"] = {"2_1", "2_2"} } (Từ Node 1_1 có thể đi lên 2_1 và 2_2)
	}

	local nodesByDepth = {}

	-- BƯỚC 1: TẠO LƯỚI ĐIỂM (GRID GENERATION)
	for depth = 1, CONFIG.MaxDepth do
		nodesByDepth[depth] = {}

		local numNodes = rng:NextInteger(CONFIG.MinNodesPerDepth, CONFIG.MaxNodesPerDepth)
		if depth == CONFIG.MaxDepth then
			numNodes = 1
		end -- Tầng Boss chỉ có 1 phòng

		for i = 1, numNodes do
			local nodeId = tostring(depth) .. "_" .. tostring(i)
			table.insert(nodesByDepth[depth], nodeId)

			map.Nodes[nodeId] = {
				Id = nodeId,
				Depth = depth,
				Type = PickRoomType(rng, depth),
			}
		end
	end

	-- BƯỚC 2: THUẬT TOÁN KẾT NỐI ĐỒ THỊ (PATH ROUTING)
	for depth = 1, CONFIG.MaxDepth - 1 do
		local currentLayer = nodesByDepth[depth]
		local nextLayer = nodesByDepth[depth + 1]

		-- Đảm bảo mỗi Node ở tầng hiện tại đều nối ít nhất 1 Node ở tầng tiếp theo
		for i, currentNode in ipairs(currentLayer) do
			map.Paths[currentNode] = {}

			-- Tính toán mốc kết nối để đường đi không bị chéo vắt chéo nhau quá lộn xộn
			local targetIndex =
				math.clamp(math.floor((i / #currentLayer) * #nextLayer) + rng:NextInteger(0, 1), 1, #nextLayer)

			local targetNode = nextLayer[targetIndex]
			table.insert(map.Paths[currentNode], targetNode)

			-- Tỉ lệ 30% chẻ nhánh thêm 1 đường nữa
			if rng:NextNumber() < 0.3 and targetIndex < #nextLayer then
				table.insert(map.Paths[currentNode], nextLayer[targetIndex + 1])
			end
		end

		-- Đảm bảo mỗi Node ở tầng tiếp theo đều có ÍT NHẤT 1 Node ở tầng trước nối tới (Tránh phòng bị mồ côi)
		for j, nextNode in ipairs(nextLayer) do
			local hasParent = false
			for _, currentNode in ipairs(currentLayer) do
				if table.find(map.Paths[currentNode], nextNode) then
					hasParent = true
					break
				end
			end

			if not hasParent then
				-- Nối ép một Node bất kỳ ở tầng dưới vào Node mồ côi này
				local randomParent = currentLayer[rng:NextInteger(1, #currentLayer)]
				table.insert(map.Paths[randomParent], nextNode)
			end
		end
	end

	return map
end

-- ==========================================
-- API 2: KIỂM TRA TÍNH HỢP LỆ CỦA NƯỚC ĐI (VALIDATE MOVE)
-- ==========================================
function DungeonGenerator:IsValidMove(mapData: table, currentNodeId: string, targetNodeId: string)
	local allowedPaths = mapData.Paths[currentNodeId]
	if not allowedPaths then
		return false
	end

	return table.find(allowedPaths, targetNodeId) ~= nil
end

return DungeonGenerator
