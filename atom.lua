local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local window = library.CreateLib("Dragon Blox - Auto Gộp v8", "DarkTheme")

local tab = window:NewTab("Auto Farm Boss")
local section = tab:NewSection("Cấu Hình Treo Máy")

local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH TỌA ĐỘ VÀ CHIỀU CAO
local BOSS_SPAWN_POS = Vector3.new(-431.7525939941406, 1352.32275390625, 93.17485046386719)
local HEIGHT_ABOVE = 9.5 

local AutoFarmBoss = false
local LockSkillActive = false
local lastActionTime = 0
local mainConnection
local lockConnection

-- Hàm quét tìm Boss gần tọa độ spawn để ghim vị trí
local function findLivingBoss()
    local targetHrp = nil
    local minDistance = 150
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            
            if hrp and humanoid and humanoid.Health > 0 then
                local distance = (hrp.Position - BOSS_SPAWN_POS).Magnitude
                if distance < minDistance then
                    targetHrp = hrp
                    break
                end
            end
        end
    end
    return targetHrp
end

-- VÒNG LẶP CHÍNH: TELEPORT + SPAM E + TỰ ĐỘNG XÓA HOẠT ẢNH
local function startFarmLoop()
    if mainConnection then mainConnection:Disconnect() end
    
    mainConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmBoss then
            if mainConnection then mainConnection:Disconnect() end
            return
        end
        
        local character = LocalPlayer.Character
        local myHrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if not myHrp or not myHrp.Parent then return end
        
        local bossHrp = findLivingBoss()
        
        if bossHrp then
            -- 1. Ghim chặt theo vị trí di chuyển của Boss ở độ cao 9.5 studs
            myHrp.CFrame = bossHrp.CFrame * CFrame.new(0, HEIGHT_ABOVE, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        else
            -- Đứng chờ tại điểm Spawn khi Boss chưa xuất hiện
            myHrp.CFrame = CFrame.new(BOSS_SPAWN_POS.X, BOSS_SPAWN_POS.Y + HEIGHT_ABOVE, BOSS_SPAWN_POS.Z)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- 2. TỰ ĐỘNG XÓA HOẠT ẢNH SKILL NGẦM (Chạy trực tiếp bên trong vòng lặp farm)
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    -- Chặn đứng mọi hoạt ảnh gồng chiêu/đấm đá để giảm tải cho game
                    if track.Name ~= "Idle" and track.Name ~= "Animate" then
                        track:Stop(0)
                    end
                end
            end
        end
        
        -- 3. Spam Chuột trái + Phím E cực nhanh
        local currentTime = tick()
        if currentTime - lastActionTime >= 0.15 then
            lastActionTime = currentTime
            
            task.spawn(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end
    end)
end

-- VÒNG LẶP RIÊNG: KHÓA CAMERA (LOCK SKILL)
local function startLockLoop()
    if lockConnection then lockConnection:Disconnect() end
    
    lockConnection = RunService.RenderStepped:Connect(function()
        if not LockSkillActive then
            if lockConnection then lockConnection:Disconnect() end
            local character = LocalPlayer.Character
            if character and character:FindFirstChildOfClass("Humanoid") then
                character.Humanoid.AutoRotate = true
            end
            return
        end
        
        local character = LocalPlayer.Character
        local myHrp = character and character:FindFirstChild("HumanoidRootPart")
        local bossHrp = findLivingBoss()
        
        if myHrp and bossHrp then
            character.Humanoid.AutoRotate = false
            myHrp.CFrame = CFrame.new(myHrp.Position, Vector3.new(bossHrp.Position.X, myHrp.Position.Y, bossHrp.Position.Z))
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, bossHrp.Position)
        else
            if character and character:FindFirstChildOfClass("Humanoid") then
                character.Humanoid.AutoRotate = true
            end
        end
    end)
end

-- ==========================================
-- GIAO DIỆN MENU KAVO UI SAU KHI ĐÃ GỘP TỐI GIẢN
-- ==========================================

-- Bật nút này là tự động bay, tự động spam E và tự động ẩn hoạt ảnh chống lag luôn
section:NewToggle("Auto Lock & Spam E (9.5 Studs)", "Ghim Boss cách 9.5 studs, tự spam E và ẩn hoạt ảnh lag", function(state)
    AutoFarmBoss = state
    if state then
        startFarmLoop()
    else
        if mainConnection then mainConnection:Disconnect() end
    end
end)

-- Nút Khóa mục tiêu (Giữ nguyên làm nút phụ để tùy chọn hướng camera)
section:NewToggle("Lock Skill (Khóa Mục Tiêu)", "Khóa camera hướng chiêu E trực diện vào Boss", function(state)
    LockSkillActive = state
    if state then
        startLockLoop()
    else
        if lockConnection then lockConnection:Disconnect() end
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid.AutoRotate = true
        end
    end
end)
