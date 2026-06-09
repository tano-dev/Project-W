-- File: Shared/Constants/ItemData/Consumables/init.luau

local Consumables = {}

for _, module in ipairs(script:GetDescendants()) do
	print(module)
	if module:IsA("ModuleScript") then
		print("Đang thử nạp file: " .. module:GetFullName())
		local itemData = require(module)

		if Consumables[module.Name] ~= nil then
			warn("🚨 LỖI DATA (Consumables): Trùng lặp ID Vật phẩm! Tên file: " .. module.Name)
		end

		Consumables[module.Name] = itemData
	end
end

return Consumables