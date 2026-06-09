-- File: Shared/Constants/ItemData/init.luau
local Items = require(script.Items)
local Materials = require(script.Materials)
local Consumables = require(script.Consumables)

-- Tạo một Từ điển tổng hợp (Mọi ID đều nằm ở đây)
local GlobalRegistry = {}

-- Hàm tiện ích để nạp dữ liệu vào Từ điển tổng
local function RegisterItems(itemGroup)
	for Id, templateData in pairs(itemGroup) do
		-- Kiểm tra xem ID có bị trùng lặp ở các thư mục khác nhau không
		if GlobalRegistry[Id] then
			warn("🚨 LỖI DATA TỔNG: Trùng lặp Id! " .. Id)
		end
		GlobalRegistry[Id] = templateData
	end
end

-- Nạp toàn bộ dữ liệu vào GlobalRegistry
RegisterItems(Items)
RegisterItems(Materials)
RegisterItems(Consumables)

-- Module này trả về cả dữ liệu chia nhóm lẫn dữ liệu tổng
return {
	Items = Items,
	Materials = Materials,
	Consumables = Consumables,

	-- Dùng cái này để tra cứu siêu nhanh bằng ID
	Registry = GlobalRegistry 
}