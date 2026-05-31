-- ============================================================================
-- DRAGON BLOX V2 - PREMIUM HUB FULL VERSION (FIXED: 30 STUDS ABOVE HEAD)
-- ============================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Ultimate Hub Full", "BloodTheme")

-- Các biến môi trường
getgenv().AutoFarmMobs = false
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false
getgenv().AutoStatsDestiny = false
getgenv().AutoStatsRebirth = false
getgenv().AntiAFK = true
getgenv().WalkSpeedValue = 16

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

LocalPlayer.CharacterAdded:Connect(function(char) Character = char end)

local function GetClosestTarget()
    local closest, dist = nil, math.huge
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= Character and v.Health > 0 then
            local tHrp = v.Parent:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local d = (hrp.Position - tHrp.Position).Magnitude
                if d < dist then closest, dist = tHrp, d end
            end
        end
    end
    return closest
end

-- ============================================================================
-- TAB 1: MAIN FUNCTION
-- ============================================================================
local MainTab = Window:NewTab("Main Script")
local MainSection = MainTab:NewSection("Quản Lý Auto Boss & Farm")

MainSection:NewToggle("Auto Boss V1 (Hover 30 Studs Above)", "Bay cao trên đầu Boss và tự đánh", function(state)
    getgenv().AutoBossV1 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV1 do
                pcall(function()
                    local HRP = Character:FindFirstChild("HumanoidRootPart")
                    local target = GetClosestTarget()
                    if HRP and target then
                        HRP.CFrame = target.CFrame * CFrame.new(0, 30, 0)
                        HRP.Velocity = Vector3.new(0, 0, 0)
                    end
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.03)
            end
        end)
    end
end)

MainSection:NewToggle("Auto Boss V2 (Ultra Spam E)", "Spam chiêu E tốc độ cao", function(state)
    getgenv().AutoBossV2 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV2 do
                task.defer(function()
                    pcall(function()
                        local HRP = Character:FindFirstChild("HumanoidRootPart")
                        local target = GetClosestTarget()
                        if HRP and target then
                            HRP.CFrame = target.CFrame * CFrame.new(0, 30, 0)
                            local skillRemote = ReplicatedStorage:FindFirstChild("CombatEvent") or ReplicatedStorage:FindFirstChild("SkillEvent")
                            if skillRemote then
                                skillRemote:FireServer("E", target.Position)
                            else
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end
                        end
                    end)
                end)
                task.wait(0.01)
            end
        end)
    end
end)

-- ============================================================================
-- TAB 2: STATS & REBIRTH
-- ============================================================================
local StatsTab = Window:NewTab("Stats & Rebirth")
local StatsSection = StatsTab:NewSection("Tự Động Nâng Cấp")

StatsSection:NewToggle("Enable Auto Rebirth", "Tự động trùng sinh", function(state)
    getgenv().AutoStatsRebirth = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsRebirth do
                local remote = ReplicatedStorage:FindFirstChild("RebirthEvent") or ReplicatedStorage:FindFirstChild("Rebirth")
                if remote and remote:IsA("RemoteEvent") then remote:FireServer() end
                task.wait(2)
            end
        end)
    end
end)

StatsSection:NewToggle("Auto Upgrade Melee", "Tự động nâng chỉ số tấn công", function(state)
    getgenv().AutoStatsDestiny = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsDestiny do
                local statRemote = ReplicatedStorage:FindFirstChild("StatRemote") or ReplicatedStorage:FindFirstChild("UpgradeStat")
                if statRemote then statRemote:FireServer("Melee", 10) end
                task.wait(0.5)
            end
        end)
    end
end)

-- ============================================================================
-- TAB 3: UTILITIES & SETTINGS
-- ============================================================================
local MiscTab = Window:NewTab("Utilities")
local MiscSection = MiscTab:NewSection("Công Cụ Hỗ Trợ")

MiscSection:NewSlider("WalkSpeed", "Tốc độ di chuyển", 250, 16, function(s) getgenv().WalkSpeedValue = s end)
MiscSection:NewToggle("Anti-AFK", "Chống thoát game", function(state) getgenv().AntiAFK = state end)

LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

MiscSection:NewButton("Optimize Graphics", "Xóa hiệu ứng thừa làm mượt game", function()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end)
end)

Library:Init()
