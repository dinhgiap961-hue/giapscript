-- Khởi tạo thư viện UI (Sử dụng Orion Library - một thư viện rất mượt và phổ biến)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Tạo Cửa sổ Menu chính (Window)
local Window = OrionLib:MakeWindow({
    Name = "Dragon Blox V2 | Premium", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "DragonBloxConfig"
})

-- Biến lưu trạng thái bật/tắt của Auto Boss
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false

-- Tạo một Tab chức năng chính
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Lần lượt thêm các Nút và Tính năng vào Tab

-- 1. Nút Kiểm tra Boss (Button)
MainTab:AddButton({
    Name = "Check boss",
    Callback = function()
        print("Đang kiểm tra Boss...")
        -- Thêm logic kiểm tra boss của bạn ở đây
    end
})

-- 2. Nút Reset Chỉ số
MainTab:AddButton({
    Name = "Reset Stats",
    Callback = function()
        print("Đã reset chỉ số!")
    end
})

--- Vạch phân cách trực quan
MainTab:AddParagraph("Tính năng tự động","Bật các tính năng dưới đây để auto farm")

-- 3. Công tắc Auto Boss V1 (Toggle)
MainTab:AddToggle({
    Name = "Auto boss V1",
    Default = false,
    Callback = function(Value)
        getgenv().AutoBossV1 = Value
        if Value then
            -- Chạy vòng lặp Auto Boss V1 một cách mượt mà (chạy ngầm)
            task.spawn(function()
                while getgenv().AutoBossV1 do
                    print("Đang auto đánh Boss V1...")
                    -- Logic tự động dịch chuyển/tấn công Boss viết ở đây
                    task.wait(0.1) -- Tránh bị crash game
                end
            end)
        end
    end    
})

-- 4. Công tắc Auto Boss V2
MainTab:AddToggle({
    Name = "Auto boss V2",
    Default = false,
    Callback = function(Value)
        getgenv().AutoBossV2 = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoBossV2 do
                    print("Đang auto đánh Boss V2...")
                    task.wait(0.1)
                end
            end)
        end
    end    
})

-- 5. Bật theo dõi trạng thái Boss
MainTab:AddToggle({
    Name = "Enable Boss Stats Tracker",
    Default = false,
    Callback = function(Value)
        print("Trạng thái Tracker:", Value)
    end    
})

-- Khởi tạo Menu hoàn tất
OrionLib:Init()
