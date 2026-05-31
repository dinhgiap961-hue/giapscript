-- ============================================================================
-- DRAGON BLOX V2 - FULL AUTOMATIC REMOTE-FINDER V6
-- ============================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Full Auto V6", "BloodTheme")

-- Biến điều khiển
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false
getgenv().AutoRebirth = false
getgenv().AutoUpgrade = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- HÀM TỰ DÒ TÌM REMOTE (TỰ FIX LỖI KHI GAME CẬP NHẬT)
local function FindCombatRemote()
    local path = {ReplicatedStorage, ReplicatedStorage:FindFirstChild("Remotes")}
    for _, container in pairs(path) do
        if container then
            for _, v in pairs(container:GetChildren()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("combat") or v.Name:lower():find("skill") or v.Name:lower():find("input")) then
                    return v
                end
            end
        end
    end
    return nil
end

-- Tìm Boss
local function GetClosestTarget()
    local closest, dist = nil, 9e9
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= LocalPlayer.Character and v.Health > 0 then
            local tHrp = v.Parent:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local d = (hrp.Position - tHrp.Position).Magnitude
                if d < dist then closest, dist = tHrp, d end
            end
        end
    end
    return closest
end

-- TAB: CHỨC NĂNG
local MainTab = Window:NewTab("Auto Combat")
local Section = MainTab:NewSection("Full Functions")

Section:NewToggle("Auto Boss V1 (Bay 30 Studs)", "Bay cao 30 studs", function(state)
    getgenv().AutoBossV1 = state
    task.spawn(function()
        while getgenv().AutoBossV1 do
            local target = GetClosestTarget()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if target and hrp then
                hrp.CFrame = target.CFrame * CFrame.new(0, 30, 0)
                local remote = FindCombatRemote()
                if remote then remote:FireServer("E", target.Position) end
            end
            task.wait(0.05)
        end
    end)
end)

Section:NewToggle("Auto Boss V2 (Spam Siêu Tốc)", "Spam không độ trễ", function(state)
    getgenv().AutoBossV2 = state
    task.spawn(function()
        while getgenv().AutoBossV2 do
            local target = GetClosestTarget()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if target and hrp then
                hrp.CFrame = target.CFrame * CFrame.new(0, 30, 0)
                local remote = FindCombatRemote()
                if remote then 
                    remote:FireServer("E", target.Position)
                    remote:FireServer("Skill_E", target.Position)
                end
            end
            task.wait(0.01)
        end
    end)
end)

Section:NewToggle("Auto Rebirth", "Tự trùng sinh", function(state)
    getgenv().AutoRebirth = state
    task.spawn(function()
        while getgenv().AutoRebirth do
            local remote = ReplicatedStorage:FindFirstChild("Rebirth") or ReplicatedStorage:FindFirstChild("RebirthEvent")
            if remote then remote:FireServer() end
            task.wait(2)
        end
    end)
end)

Section:NewToggle("Auto Upgrade Melee", "Tự nâng Melee", function(state)
    getgenv().AutoUpgrade = state
    task.spawn(function()
        while getgenv().AutoUpgrade do
            local remote = ReplicatedStorage:FindFirstChild("StatRemote") or ReplicatedStorage:FindFirstChild("UpgradeStat")
            if remote then remote:FireServer("Melee", 1) end
            task.wait(0.1)
        end
    end)
end)

Library:Init()
