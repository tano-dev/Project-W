-- File: Server/ServerMain.server.luau
local Server = script.Parent

-- Danh sách các thư mục chứa hệ thống của bạn
-- (Hãy đảm bảo đường dẫn đúng với cây thư mục của bạn)
local MODULE_FOLDERS = {
    Server.Systems
}

local function StartServer()
    print("🚀 BẮT ĐẦU KHỞI CHẠY SERVER...")
    
    local loadedModules = {}

    -- ==========================================
    -- BƯỚC 1: TỰ ĐỘNG TÌM VÀ NẠP TẤT CẢ MODULE
    -- ==========================================
    for _, folder in ipairs(MODULE_FOLDERS) do
        if not folder then continue end
        
        for _, instance in ipairs(folder:GetDescendants()) do
            if instance:IsA("ModuleScript") then
                -- Require file đó và lưu vào danh sách
                local success, module = pcall(require, instance)
                if success and type(module) == "table" then
                    table.insert(loadedModules, { Name = instance.Name, Module = module })
                else
                    warn("❌ Lỗi khi nạp module: " .. instance.Name .. " - " .. tostring(module))
                end
            end
        end
    end

    -- ==========================================
    -- BƯỚC 2: GỌI HÀM INIT (Khởi tạo nội bộ)
    -- ==========================================
    for _, data in ipairs(loadedModules) do
        if type(data.Module.Init) == "function" then
            data.Module:Init()
        end
    end

    -- ==========================================
    -- BƯỚC 3: GỌI HÀM START (Bắt đầu tương tác chéo)
    -- ==========================================
    for _, data in ipairs(loadedModules) do
        if type(data.Module.Start) == "function" then
            -- Chạy Start bằng task.spawn để nếu 1 hệ thống bị lỗi, nó không làm sập toàn bộ game
            task.spawn(function()
                data.Module:Start()
            end)
        end
    end

    print("✅ SERVER KHỞI CHẠY HOÀN TẤT VỚI " .. #loadedModules .. " MODULES!")
end

StartServer()