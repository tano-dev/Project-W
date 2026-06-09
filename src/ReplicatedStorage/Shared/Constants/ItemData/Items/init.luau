-- File: Shared/Constants/ItemData/Equipments/init.luau
local Template = require(game.ReplicatedStorage.Shared.Components.ItemTemplate)

local Equipments: { [string]: Template.ItemTemplate } = {}

-- Quét tất cả các file trong thư mục Equipments (bao gồm cả thư mục con như /Swords, /Armors)
for _, module in ipairs(script:GetDescendants()) do
	print(module)
	if module:IsA("ModuleScript") then
		print("Đang thử nạp file: " .. module:GetFullName())
		print(module)
		local itemData = require(module)

		if Equipments[module.Name] ~= nil then
			warn("🚨 LỖI DATA (Equipments): Trùng lặp ID Vật phẩm! Tên file: " .. module.Name)
		end

		Equipments[module.Name] = itemData
	end
end

return Equipments