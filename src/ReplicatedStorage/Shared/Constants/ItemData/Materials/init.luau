-- File: Shared/Constants/ItemData/Materials/init.luau
-- local Types = require(...) -- Khai báo Type của Material nếu có

local Materials = {}

for _, module in ipairs(script:GetDescendants()) do
	print(module)
	if module:IsA("ModuleScript") then
		print("Đang thử nạp file: " .. module:GetFullName())
		local itemData = require(module)

		if Materials[module.Name] ~= nil then
			warn("🚨 LỖI DATA (Materials): Trùng lặp ID Vật phẩm! Tên file: " .. module.Name)
		end

		Materials[module.Name] = itemData
	end
end

return Materials