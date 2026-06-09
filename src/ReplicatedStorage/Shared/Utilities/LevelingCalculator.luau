-- File: Shared/Utilities/LevelingCalculator.luau
local LevelingCalculator = {}

-- [SỬA LỖI]: Đặt Cap là 200 để khớp với các hàm bên dưới của bạn
LevelingCalculator.LevelCap = 200 

-- Bảng Cache lưu trữ Tổng EXP tích lũy (Chỉ tính 1 lần duy nhất)
local CumulativeExp = {}

-- Công thức tính EXP cần thiết cho TỪNG CẤP ĐỘ
local function GetExpRequirement(level: number)
	if level <= 10 then return 5 * level * (level + 25)
	elseif level <= 20 then return 35 * level * (level - 5)
	elseif level <= 35 then return 70 * level * (level - 13)
	elseif level <= 50 then return 185 * level * (level - 27)
	elseif level <= 80 then return 505 * level * (level - 42)
	elseif level <= 120 then return 1355 * level * (level - 66)
	elseif level <= 160 then return 2275 * level * (level - 88)
	else return 6250 * level * (level - 134)
	end
end

-- ==========================================
-- KHỞI TẠO BẢNG EXP (CHỈ CHẠY 1 LẦN KHI START)
-- ==========================================
local function InitializeTable()
	local total = 0
	CumulativeExp[0] = 0
	for i = 1, LevelingCalculator.LevelCap do
		total += GetExpRequirement(i)
		CumulativeExp[i] = total
	end
end

InitializeTable()

-- ==========================================
-- HÀM API: TÍNH CẤP ĐỘ TỪ TỔNG EXP
-- ==========================================
function LevelingCalculator.CalculateLevel(totalExp: number)
	local currentLevel = 0
	
	-- Tìm cấp độ hiện tại bằng cách tra bảng Cache (Cực nhanh)
	for i = 1, LevelingCalculator.LevelCap do
		if totalExp >= CumulativeExp[i] then
			currentLevel = i
		else
			break
		end
	end
	
	-- Nếu đạt cấp tối đa
	if currentLevel >= LevelingCalculator.LevelCap then
		return LevelingCalculator.LevelCap, 0, 0 
	end
	
	-- Tính toán lượng EXP còn thiếu
	local expForNextLevel = GetExpRequirement(currentLevel + 1)
	local expLeft = CumulativeExp[currentLevel + 1] - totalExp
	local currentProgress = expForNextLevel - expLeft -- Exp đã cày được ở cấp hiện tại
	
	-- Trả về: Cấp hiện tại, Exp dư ra ở cấp này, Exp cần để lên cấp tiếp theo
	return currentLevel, currentProgress, expForNextLevel
end

return LevelingCalculator