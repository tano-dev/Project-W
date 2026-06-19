-- File: StarterPlayerScripts/Client/ClientMain.client.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. Khởi tạo State (Dữ liệu)
local ClientDataStore = require(script.Parent.State.ClientDataStore)

-- 2. Khởi tạo Controller chính
local UIController = require(script.Parent.Controllers.UIController)

-- Đường dẫn tới thư mục chứa các module UI
local UIModulesFolder = script.Parent.Controllers.UIModules

print("🚀 [ClientMain] Đang khởi động hệ thống...")

-- Chờ dữ liệu từ Replica / Server tải về xong
ClientDataStore:WaitForReady(function(initialData)
    print("✅ [ClientMain] Dữ liệu đã tải xong. Bắt đầu khởi tạo UI!")
    
    -- 1. Khởi tạo UI Controller (Quản lý Bật/Tắt màn hình chung)
    UIController:Start()

    -- 2. TỰ ĐỘNG NẠP CÁC MODULE UI (Auto-loading)
    for _, moduleScript in ipairs(UIModulesFolder:GetChildren()) do
        -- Đảm bảo chỉ đọc các file ModuleScript
        if moduleScript:IsA("ModuleScript") then
            -- Bọc trong pcall để chống crash nếu file module bị lỗi cú pháp
            local success, uiModule = pcall(require, moduleScript)

            if success then
                -- Kiểm tra xem module đó có hàm Start() hay không
                if type(uiModule) == "table" and type(uiModule.Start) == "function" then
                    -- Chạy trong luồng riêng (task.spawn) để không cản trở luồng chính
                    task.spawn(function()
                        uiModule:Start()
                        print("✨ Đã nạp thành công Module UI: " .. moduleScript.Name)
                    end)
                else
                    warn("⚠️ Module UI [" .. moduleScript.Name .. "] không có hàm :Start() hợp lệ.")
                end
            else
                -- In ra lỗi cụ thể nếu file đó không require được
                warn("❌ Lỗi khi nạp Module UI [" .. moduleScript.Name .. "]:\n" .. tostring(uiModule))
            end
        end
    end
    
    -- 3. Tự động đóng tất cả các màn hình (chỉ giữ HUD) khi mới vào game
    UIController:HideAll()
end)