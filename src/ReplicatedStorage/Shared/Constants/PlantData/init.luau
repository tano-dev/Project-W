-- File: Shared/Constants/PlantDatabase/init.luau (hoặc PlantData.luau)
local PlantDatabase = {
    Registry = {},
}

-- ==========================================
-- AUTO-LOADER: CHỐNG LỖI VÒNG LẶP (CYCLIC REQUIRE)
-- ==========================================

-- Tự động quyết định quét ở đâu:
-- Nếu bạn nhét các file cây con vào BÊN TRONG script này -> dùng script:GetChildren()
-- Nếu bạn để các file cây con NGANG HÀNG với script này -> dùng script.Parent:GetChildren()
local childrenToScan = #script:GetChildren() > 0 and script:GetChildren() or script.Parent:GetChildren()

for _, child in ipairs(childrenToScan) do
    -- [QUAN TRỌNG]: Dùng `child ~= script` để CHẮC CHẮN không bao giờ tự require chính nó
    if child:IsA("ModuleScript") and child ~= script then
        
        local success, moduleData = pcall(require, child)

        if success and type(moduleData) == "table" then
            local plantId = child.Name

            if PlantDatabase.Registry[plantId] then
                warn(string.format("⚠️ [PlantDatabase] Trùng lặp ID: %s (Đường dẫn: %s)", plantId, child:GetFullName()))
            else
                PlantDatabase.Registry[plantId] = moduleData
            end
        else
            -- Nếu có lỗi, in ra lỗi chi tiết của Luau thay vì chỉ in ra thông báo chung chung
            warn(string.format("❌ [PlantDatabase] Lỗi khi load file %s. Chi tiết lỗi: %s", child.Name, tostring(moduleData)))
        end
    end
end

local count = 0
for _ in pairs(PlantDatabase.Registry) do
    count += 1
end
print(string.format("✅ [PlantDatabase] Đã load thành công %d Cây trồng!", count))

-- API lấy toàn bộ dữ liệu
function PlantDatabase.GetAll()
    return PlantDatabase.Registry
end

return PlantDatabase