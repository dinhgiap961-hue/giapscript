-- Khởi tạo thư viện Kavo UI siêu nhẹ cho Điện thoại
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local window = library.CreateLib("Dragon Blox Premium Hub", "DarkTheme")

-- Khai báo dịch vụ hệ thống Roblox
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Chiều cao né đòn an toàn từ ảnh gốc
local HEIGHT_ABOVE = 9.22
local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
local lastActionTime = 0

-- 1. KHỞI TẠO BẢNG CẤU HÌNH TOÀN BỘ BIẾN (Đồng bộ theo dữ liệu JSON của bạn)
local db = {
    autopunch_db = false,
    autotpnearbyjigraymobs_db = false,
    autotpnearbyatombossmobs_db = false,
    autotpnearbypurizabossmobs_db = false,
    autotpnearbybanditmobs_db = false,
    autotpnearbyblackkarrotbossmobs_db = false,
    autotpnearbycoolestbossmobs_db = false,
    autorebirth_db = false
}

-- Vòng lặp Core xử lý toàn bộ Logic Farm & Godmode liên tục
local mainConnection
local function startMainLoop()
    if mainConnection then mainConnection:Disconnect() end
    
    mainConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        
        -- Xác định mục tiêu quái cần tìm dựa vào nút bạn đang bật
        local targetName = nil
        if db.autotpnearbyjigraymobs_db then targetName = "Jigray"
        elseif db.autotpnearbyatombossmobs_db then targetName = "Atom"
        elseif db.autotpnearbypurizabossmobs_db then targetName = "Puriza"
        elseif db.autotpnearbybanditmobs_db then targetName = "Bandit"
        elseif db.autotpnearbyblackkarrotbossmobs_db then targetName = "Black Karrot"
        elseif db.autotpnearbycoolestbossmobs_db then targetName = "Coolest"
        end
        
        -- Nếu có bật Teleport farm quái
        if targetName then
            local bossFolder = workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Monsters") or workspace
            for _, mob in pairs(bossFolder:GetChildren()) do
                if mob.Name:lower():find(targetName:lower()) then
                    local mobHrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("PrimaryPart")
                    local mobHumanoid = mob:FindFirstChildOfClass("Humanoid")
                    
                    if mobHrp and mobHumanoid and mobHumanoid.Health > 0 then
                        -- Dịch chuyển Godmode lơ lửng trên đầu quái
                        hrp.CFrame = mobHrp.CFrame * CFrame.new(0, HEIGHT_ABOVE, 0)
                        hrp.Velocity = Vector3.new(0, 0, 0) -- Giữ cố định không bị rơi
                        break
                    end
                end
            end
        end
        
        -- Tự động bấm Đấm và Xả Skill (Nếu đang bật autopunch_db)
        if db.autopunch_db then
            local currentTime = tick()
            if currentTime - lastActionTime >= 0.3 then -- Tốc độ đánh
                lastActionTime = currentTime
                
                task.spawn(function()
                    -- Giả lập click chuột trái/Đấm thường
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    
                    -- Chu kỳ bấm các chiêu 1, 2, 3, 4
                    for _, key in ipairs(skillKeys) do
                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                        task.wait(0.02)
                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                    end
                end)
            end
        end
        
        -- Tự động Rebirth (Nếu bật autorebirth_db)
        if db.autorebirth_db then
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Package") 
                and game:GetService("ReplicatedStorage").Package:FindFirstChild("Events")
                and game:GetService("ReplicatedStorage").Package.Events:FindFirstChild("Rebirth")
            if remote then
                remote:InvokeServer()
            end
        end
    end)
end

-- 2. XÂY DỰNG GIAO DIỆN MENU (TABS & TOGGLES)

-- Tab 1: Chiến đấu (Combat)
local combatTab = window:NewTab("Combat")
local combatSection = combatTab:NewSection("Tấn công")

combatSection:NewToggle("Auto Punch & Skill", "Tự động Đấm và xả chiêu liên tục", function(state)
    db.autopunch_db = state
    startMainLoop()
end)

combatSection:NewToggle("Auto Rebirth", "Tự động Trùng sinh khi đủ điều kiện", function(state)
    db.autorebirth_db = state
    startMainLoop()
end)

-- Tab 2: Tự động Farm Quái/Boss (Auto Farm)
local farmTab = window:NewTab("Auto Farm")
local farmSection = farmTab:NewSection("Chọn mục tiêu (Chỉ bật 1 quái)")

farmSection:NewToggle("Farm Jigray Mobs", "Teleport Godmode đến Jigray", function(state)
    db.autotpnearbyjigraymobs_db = state
    startMainLoop()
end)

farmSection:NewToggle("Farm Atom Boss", "Teleport Godmode đến Atom Boss", function(state)
    db.autotpnearbyatombossmobs_db = state
    startMainLoop()
end)

farmSection:NewToggle("Farm Puriza Boss", "Teleport Godmode đến Puriza", function(state)
    db.autotpnearbypurizabossmobs_db = state
    startMainLoop()
end)

farmSection:NewToggle("Farm Bandit Mobs", "Teleport Godmode đến Bandit", function(state)
    db.autotpnearbybanditmobs_db = state
    startMainLoop()
end)

farmSection:NewToggle("Farm Black Karrot", "Teleport Godmode đến Black Karrot", function(state)
    db.autotpnearbyblackkarrotbossmobs_db = state
    startMainLoop()
end)

farmSection:NewToggle("Farm Coolest Boss", "Teleport Godmode đến Coolest Boss", function(state)
    db.autotpnearbycoolestbossmobs_db = state
    startMainLoop()
end)
