-- File: Shared/Constants/ShopData/init.luau
local ShopDatabase = {
	Registry = {},
}

-- AUTO-LOADER: Quét tất cả thương nhân cùng thư mục
local childrenToScan = #script:GetChildren() > 0 and script:GetChildren() or script.Parent:GetChildren()

for _, child in ipairs(childrenToScan) do
	if child:IsA("ModuleScript") and child ~= script then
		local success, moduleData = pcall(require, child)

		if success and type(moduleData) == "table" then
			local shopId = child.Name
			if ShopDatabase.Registry[shopId] then
				warn(string.format("⚠️ [ShopDatabase] Trùng lặp ID: %s", shopId))
			else
				ShopDatabase.Registry[shopId] = moduleData
			end
		else
			warn(string.format("❌ [ShopDatabase] Lỗi load file %s: %s", child.Name, tostring(moduleData)))
		end
	end
end

local count = 0
for _ in pairs(ShopDatabase.Registry) do
	count += 1
end
print(string.format("✅ [ShopDatabase] Đã load thành công %d Thương Nhân!", count))

function ShopDatabase.GetAll()
	return ShopDatabase.Registry
end

return ShopDatabase
