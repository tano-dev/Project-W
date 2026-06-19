-- File: StarterPlayerScripts/Client/State/ClientDataStore.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Với Service mặc định, GetService là tốt nhất
local Players = game:GetService("Players")

-- Phải chờ từng thư mục load xong thay vì dùng dấu chấm:

local ReplicaClientModule = require(game.ReplicatedStorage.Shared.Utilities.ReplicaClient) -- Dùng để lắng nghe dữ liệu từ Server

local ClientDataStore = {
	Data = nil,
	_replica = nil,
	_isReady = false,
	_onReadyCallbacks = {},
}

-- ==========================================
-- KHỞI TẠO LẮNG NGHE TỪ SERVER
-- ==========================================
ReplicaClientModule.OnNew("PlayerData", function(replica)
	if replica.Tags.UserId == Players.LocalPlayer.UserId then
		ClientDataStore._replica = replica
		ClientDataStore.Data = replica.Data
		ClientDataStore._isReady = true

		print("🎯 [ClientDataStore] Dữ liệu người chơi đã sẵn sàng!")

		-- Kích hoạt toàn bộ các Component UI đang chờ dữ liệu
		for _, callback in ipairs(ClientDataStore._onReadyCallbacks) do
			task.spawn(callback, ClientDataStore.Data)
		end
		table.clear(ClientDataStore._onReadyCallbacks)
	end
end)

ReplicaClientModule.RequestData()

-- ==========================================
-- API DÀNH CHO UI & CLIENT SYSTEMS
-- ==========================================

-- 1. Chờ dữ liệu Load xong (Tránh lỗi UI load nhanh hơn mạng)
function ClientDataStore:WaitForReady(callback)
	if self._isReady then
		task.spawn(callback, self.Data)
	else
		table.insert(self._onReadyCallbacks, callback)
	end
end

-- 2. Lấy dữ liệu tĩnh ngay lập tức
function ClientDataStore:Get(path: { string }?)
	if not self._isReady then
		return nil
	end
	if not path then
		return self.Data
	end

	local current = self.Data
	for _, key in ipairs(path) do
		if current[key] ~= nil then
			current = current[key]
		else
			return nil
		end
	end
	return current
end

-- 3. LẮNG NGHE CHỈ SỐ ĐƠN LẺ (Level, Vàng, Exp Nghề...)
-- Path ví dụ: {"Currencies", "Coin"} hoặc {"Professions", "Crafting"}
function ClientDataStore:ListenToValue(path: { string }, callback: (newValue: any, oldValue: any) -> ())
	self:WaitForReady(function()
		self._replica:OnSet(path, callback)
		callback(self:Get(path), nil) -- Kích hoạt ngay lần đầu để UI cập nhật số hiện tại
	end)
end

-- 4. [SIÊU HÀM] LẮNG NGHE BỘ SƯU TẬP (Túi đồ, Đất trồng cây, Quests)
-- Xử lý hoàn hảo mọi ngóc ngách cập nhật từ Server
function ClientDataStore:ListenToCollection(basePath: { string }, callbacks: table)
	self:WaitForReady(function()
		-- 4A. Kích hoạt OnAdded cho toàn bộ dữ liệu CÓ SẴN khi mới vào game
		local currentData = self:Get(basePath)
		if currentData and callbacks.OnAdded then
			for key, val in pairs(currentData) do
				callbacks.OnAdded(val, key)
			end
		end

		-- 4B. Lắng nghe thay đổi theo thời gian thực
		self._replica:OnChange(function(action, changePath, param1, param2)
			-- Kiểm tra xem sự thay đổi có thuộc basePath này không
			for i, key in ipairs(basePath) do
				if changePath[i] ~= key then
					return
				end
			end

			-- Tính khoảng cách độ sâu từ basePath đến vị trí bị thay đổi
			local depthDiff = #changePath - #basePath

			-- TRƯỜNG HỢP 1: Thay đổi trực tiếp trên mảng (Thêm/Xóa đồ bằng TableInsert/Remove)
			if depthDiff == 0 then
				if action == "TableInsert" and callbacks.OnAdded then
					callbacks.OnAdded(param1, param2) -- param1: Item Data, param2: Index
				elseif action == "TableRemove" and callbacks.OnRemoved then
					callbacks.OnRemoved(param1, param2)
				end

			-- TRƯỜNG HỢP 2: Ghi đè hoặc xóa hẳn 1 Key (Ví dụ: Trồng cây, Nhổ cây, Ghi đè UpdateItemData)
			elseif depthDiff == 1 and action == "Set" then
				local indexKey = changePath[#changePath]
				local newValue = param1

				if newValue == nil then
					-- Bị xóa bằng Set nil (Farming thu hoạch/nhổ cây) [cite: 41, 44]
					if callbacks.OnRemoved then
						callbacks.OnRemoved(nil, indexKey)
					end
				else
					-- Cập nhật hoặc đè mới (Enchant, Upgrade đổi State đồ) [cite: 29, 106]
					if callbacks.OnUpdated then
						callbacks.OnUpdated(newValue, indexKey)
					end
				end

			-- TRƯỜNG HỢP 3: Sửa thông số sâu bên trong (Ví dụ: Số lượng vật phẩm bị trừ khi Craft đồ)
			elseif depthDiff > 1 and action == "Set" then
				local indexKey = changePath[#basePath + 1]
				local updatedTopLevelData = self:Get(basePath)[indexKey]

				-- Bắn ngược cục Data bự ra ngoài cho UI tự vẽ lại dòng đó
				if callbacks.OnUpdated then
					callbacks.OnUpdated(updatedTopLevelData, indexKey)
				end
			end
		end)
	end)
end

return ClientDataStore
