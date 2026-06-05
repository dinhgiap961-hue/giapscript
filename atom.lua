-- XÓA MENU CŨ NẾU CÓ ĐỂ TRÁNH XUNG ĐỘT
if game:GetService("CoreGui"):FindFirstChild("Orion") then
    game:GetService("CoreGui")["Orion"]:Destroy()
end

-- KHỞI CHẠY THƯ VIỆN ORION UI CHUYÊN DỤNG CHO MOBILE
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Tạo Cửa Sổ Menu Chính
local Window = OrionLib:MakeWindow({
    Name = "DinhGiap Hub - Dragon Blox v15", 
    HidePremium = false, 
    SaveConfig = false, 
    IntroText = "Loading DinhGiap Hub...",
    ConfigFolder = "OrionConfig"
})

-- HỆ THỐNG BIẾN CHẠY NGẦM
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local BOSS_SPAWN_POS = Vector3.new(-431.7525939941406, 1352.32275390625, 93.17485046386719)
local HEIGHT_ABOVE = 9.5 

local AutoFarmBoss = false
local LockSkillActive = false
local lastActionTime = 0
local mainConnection
local lockConnection

-- ĐƯỜNG DẪN GÓI TIN REMOTE TỪ REMOTE SPY
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")
local SKILL_NAME = "fushi"
local FORM_NAME = "Form"

-- Hàm quét tìm vị trí Boss gần tọa độ chỉ định
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

-- VÒNG LẶP TELEPORT GHIM POSITION VÀ XẢ CHIÊU REMOTE NGẦM
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
            myHrp.CFrame = bossHrp.CFrame * CFrame.new(0, HEIGHT_ABOVE, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        else
            myHrp.CFrame = CFrame.new(BOSS_SPAWN_POS.X, BOSS_SPAWN_POS.Y + HEIGHT_ABOVE, BOSS_SPAWN_POS.Z)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Chặn đứng hoạt ảnh thừa chống giật khung hình
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    if track.Name ~= "Idle" and track.Name ~= "Animate" then
                        track:Stop(0)
                    end
                end
            end
        end
        
        -- Gọi lệnh Remote xả chiêu thức trực tiếp lên Server (0.05 giây/lần)
        local currentTime = tick()
        if currentTime - lastActionTime >= 0.05 then 
            lastActionTime = currentTime
            task.spawn(function()
                SkillRemote:FireServer(SKILL_NAME)
                SkillRemote:FireServer(FORM_NAME)
            end)
        end
    end)
end

-- VÒNG LẶP KHÓA CAMERA XOAY THẲNG VÀO BOSS
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

-- TẠO CÁC NÚT CHỨC NĂNG TRÊN LỚP UI MỚI
local FarmTab = Window:NewTab({
    Name = "Auto Farm Boss",
    Icon = "rbxassetid://4483345998"
})

FarmTab:NewToggle({
    Name = "Auto Farm Pure Remote (9.5 Studs)",
    Info = "Teleport ghim vị trí Boss + Xả chiêu fushi và Form ngầm",
    Default = false,
    Callback = function(state)
        AutoFarmBoss = state
        if state then
            startFarmLoop()
        else
            if mainConnection then mainConnection:Disconnect() end
        end
    end
})

FarmTab:NewToggle({
    Name = "Lock Skill (Khóa Góc Nhìn)",
    Info = "Giữ hướng nhân vật và Camera luôn nhìn thẳng vào Boss",
    Default = false,
    Callback = function(state)
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
    end
})

-- Khởi tạo Menu thành công
OrionLib:Init()
