local PlantTree = {}
-- 
-- Plant types and their properties
PlantTree.PlantTypes = {
	Wheat = {
		id = "wheat",
		name = "Wheat",
		growthTime = 300, -- seconds
		harvestYield = 3,
		waterNeeded = 5,
		icon = "rbxassetid://0",
	},
	Corn = {
		id = "corn",
		name = "Corn",
		growthTime = 450,
		harvestYield = 2,
		waterNeeded = 7,
		icon = "rbxassetid://0",
	},
	Tomato = {
		id = "tomato",
		name = "Tomato",
		growthTime = 600,
		harvestYield = 4,
		waterNeeded = 8,
		icon = "rbxassetid://0",
	},
	Carrot = {
		id = "carrot",
		name = "Carrot",
		growthTime = 350,
		harvestYield = 2,
		waterNeeded = 4,
		icon = "rbxassetid://0",
	},
}
--[[
1 File là PlantDatabase chứ các loại cây trồng
 PlantTemplates: Rarity,Types = {Crops , Trees phân ra để trồng khu vực riêng}, GrowthTime, Stages, HarvestBehavior = {HarvestTimes - số lần được thu hoạch (nếu nil/0 thì vĩnh viễn và lặp lại theo thời gian thu hoạch được theo RepeatInterval, RepeatInterval}, HarvestYield = {gồm các {Id, Min, Max, Chance? nếu ko thì mặc định 100%}, FarmingExp, IconID (Placeholder for now)
Và PlantData sẽ lưu vào Profile của người chơi mỗi khi trồng cây, gồm: Id (tham chiếu đến PlantDatabase), PlantedTime - lấy thời gian trồng, Slot (vị trí trồng), harvestedTimes (số lần đã thu hoạch), lastHarvestTime (lần cuối thu hoạch để tính thời gian thu hoạch tiếp theo nếu có) (Nếu có RepeatInterval, HarvestTimes = nil hay > 1 thì cứ đến thời gian thu hoạch tiếp theo là có thể thu hoạch lại được mà không cần trồng lại)

Khi trồng thì sẽ lưu vào Profile trong mục Farming = {Crops = {}, Trees = {}, ...}
Cơ chế trồng trọt sẽ dựa trên thời gian thực tế (tick()) để tính toán sự phát triển của cây, khi thu hoạch sẽ dựa vào thời gian thu hoạch tiếp theo để biết có thể thu hoạch lại được không hay phải trồng lại từ đầu.

Để trồng thì sẽ cần 1 vật phẩm material tên là Seed Pack có NBT  = {PlantId = "wheat") để biết trồng cây gì, khi thu hoạch sẽ trả về vật phẩm tương ứng với loại cây đó (Wheat, Corn, Tomato, Carrot) với số lượng ngẫu nhiên trong khoảng Min-Max của HarvestYield.
 ]]
-- Plant growth stages
PlantTree.GrowthStages = {
	Seed = 1,
	Sprout = 2,
	Growing = 3,
	Mature = 4,
	ReadyToHarvest = 5,
	Harvested = 6,
}

-- Plant instance structure
function PlantTree.new(plantType, positionX, positionY)
	local plant = {
		id = math.random(100000, 999999),
		type = plantType,
		stage = PlantTree.GrowthStages.Seed,
		position = { x = positionX, y = positionY },
		waterLevel = 0,
		health = 100,
		growthProgress = 0, -- 0-100%
		plantedTime = tick(),
		lastWateredTime = tick(),
		isAlive = true,
	}
	return plant
end

-- Update plant growth
function PlantTree.updateGrowth(plant, deltaTime)
	if not plant.isAlive then return end
	
	local plantType = PlantTree.PlantTypes[plant.type]
	if not plantType then return end
	
	-- Deduct health if not watered
	if tick() - plant.lastWateredTime > 120 then
		plant.health = plant.health - 0.5
	end
	
	if plant.health <= 0 then
		plant.isAlive = false
		plant.stage = PlantTree.GrowthStages.Harvested
		return
	end
	
	-- Update growth progress
	if plant.waterLevel > 0 then
		plant.growthProgress = plant.growthProgress + (deltaTime / plantType.growthTime) * 100
		plant.waterLevel = math.max(0, plant.waterLevel - 0.1 * deltaTime)
	end
	
	-- Update growth stage
	if plant.growthProgress >= 100 and plant.stage < PlantTree.GrowthStages.ReadyToHarvest then
		plant.stage = plant.stage + 1
		plant.growthProgress = 0
	end
end

-- Water the plant
function PlantTree.water(plant, amount)
	if plant.isAlive then
		plant.waterLevel = math.min(plant.waterLevel + amount, 10)
		plant.lastWateredTime = tick()
		plant.health = math.min(plant.health + 5, 100)
	end
end

-- Harvest the plant
function PlantTree.harvest(plant)
	if plant.stage == PlantTree.GrowthStages.ReadyToHarvest then
		local yield = PlantTree.PlantTypes[plant.type].harvestYield
		plant.stage = PlantTree.GrowthStages.Harvested
		plant.isAlive = false
		return yield
	end
	return 0
end

return PlantTree
