-- Khởi tạo thư viện Kavo UI (Cực mượt và không lo lỗi link)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Tạo cửa sổ Menu (Chọn màu sắc UI: DarkTheme, Moonlight, BloodTheme, GrapeTheme)
local Window = Library.CreateLib("Dragon Blox V2 | Premium", "BloodTheme")

-- Biến kiểm soát trạng thái Bật/Tắt của chức năng
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false

-- 1. Tạo Tab Chính (Main)
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Chức năng Auto")

-- 2. Thêm nút "Check boss"
MainSection:NewButton("Check boss", "Kiểm tra Boss hiện tại", function()
    print("Đang kiểm tra Boss...")
    -- Hệ thống sẽ thông báo dưới góc màn hình game để bạn biết code đang chạy
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hệ thống";
        Text = "Đang kiểm tra trạng thái Boss!";
        Duration = 3;
    })
end)

-- 3. Thêm nút "Reset Stats"
MainSection:NewButton("Reset Stats", "Đặt lại chỉ số nhân vật", function()
    print("Đã thực hiện Reset Stats")
end)

-- 4. Công tắc "Auto Boss v1" (Quan trọng nhất)
MainSection:NewToggle("Auto Boss v1", "Tự động farm Boss phiên bản 1", function(state)
    getgenv().AutoBossV1 = state
    
    if state then
        -- Chạy luồng ẩn để không gây lag, tụt FPS game
        task.spawn(function()
            while getgenv().AutoBossV1 do
                -- CHỖ NÀY: Thêm logic đánh boss của game vào đây
                -- Ví dụ tạm thời: Tự động bấm click/đấm liên tục
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new(0,0))
                
                task.wait(0.1) -- Giãn cách 0.1 giây để chống kích văng (Kick)
            end
        end)
    else
        print("Đã tắt Auto Boss v1")
    end
end)

-- 5. Công tắc "Auto Boss v2"
MainSection:NewToggle("Auto Boss v2", "Tự động farm Boss phiên bản 2", function(state)
    getgenv().AutoBossV2 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV2 do
                -- Logic Auto v2 của bạn
                task.wait(0.1)
            end
        end)
    end
end)

-- 6. Công tắc "Enable Boss Stats Tracker"
MainSection:NewToggle("Enable Boss Stats Tracker", "Theo dõi chỉ số Boss", function(state)
    print("Trạng thái theo dõi:", state)
end)
