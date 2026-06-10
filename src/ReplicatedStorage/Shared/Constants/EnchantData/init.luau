-- File: Shared/Constants/EnchantData/init.luau
local EnchantDatabase = {
    Registry = {}, -- Nơi chứa toàn bộ dữ liệu thô của Enchant
}

-- ==========================================
-- 1. AUTO-LOADER: DÙNG TÊN FILE LÀM TÊN ENCHANT
-- ==========================================
for _, child in ipairs(script:GetDescendants()) do
    -- Chỉ xử lý các ModuleScript
    if child:IsA("ModuleScript") then
        local success, moduleData = pcall(require, child)

        if success and type(moduleData) == "table" then
            -- [SỬA ĐỔI CỐT LÕI]: Lấy trực tiếp tên của File làm ID
            local enchantId = child.Name

            if EnchantDatabase.Registry[enchantId] then
                -- Dùng GetFullName() để báo lỗi rõ ràng đường dẫn nếu lỡ tạo 2 file trùng tên ở 2 thư mục
                warn(
                    string.format(
                        "⚠️ [EnchantDatabase] Trùng lặp ID: %s (Đường dẫn: %s)",
                        enchantId,
                        child:GetFullName()
                    )
                )
            else
                EnchantDatabase.Registry[enchantId] = moduleData
            end
        else
            warn(string.format("❌ [EnchantDatabase] Lỗi khi load file %s", child.Name))
        end
    end
end

local count = 0
for _ in pairs(EnchantDatabase.Registry) do
    count += 1
end
print(string.format("✅ [EnchantDatabase] Đã load thành công %d Enchants!", count))

-- ==========================================
-- 2. API HỖ TRỢ TRUY VẤN (Giúp EnchantSystem gọn gàng hơn)
-- ==========================================

-- Lấy toàn bộ Enchant
function EnchantDatabase.GetAll()
    return EnchantDatabase.Registry
end

-- Lọc Enchant theo Hệ (Attribute) của viên Rune
function EnchantDatabase.GetByAttribute(runeAttribute: string?)
    local filtered = {}

    for id, data in pairs(EnchantDatabase.Registry) do
        -- Nếu Rune là "Chaos", nó sẽ vơ vét MỌI HỆ
        -- Nếu không, nó chỉ lấy Hệ tương ứng của Rune VÀ các bùa hệ Trung tính (nil)
        if runeAttribute == "Chaos" or data.Attribute == runeAttribute or data.Attribute == nil then
            filtered[id] = data
        end
    end

    return filtered
end

return EnchantDatabase