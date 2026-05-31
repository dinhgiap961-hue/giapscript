-- ============================================================================
-- DRAGON BLOX V2 - MINIMALIST HIGH-SPEED AUTO BOSS ONLY
-- ============================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Ultra Light", "BloodTheme")

-- Biến toàn cục
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

LocalPlayer.CharacterAdded:Connect(function(char) Character = char end)

-- Hàm tìm mục tiêu tối ưu hóa cực nhẹ
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

local MainTab = Window:NewTab("Auto Boss")
local MainSection = MainTab:NewSection("Minimalist Attack Mode")

-- Auto Boss V1
MainSection:NewToggle("Auto Boss V1 (Hover + Auto Hit)", "Bay cao và tự đánh", function(state)
    getgenv().AutoBossV1 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV1 do
                pcall(function()
                    local HRP = Character:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        HRP.Velocity = Vector3.new(0, 50, 0)
                        local target = GetClosestTarget()
                        if target then HRP.CFrame = CFrame.new(HRP.Position, target.Position) end
                    end
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.03)
            end
        end)
    end
end)

-- Auto Boss V2 (Spam E cực nhanh)
MainSection:NewToggle("Auto Boss V2 (Extreme Spam E)", "Tốc độ spam tối đa, không lag", function(state)
    getgenv().AutoBossV2 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV2 do
                task.defer(function()
                    pcall(function()
                        local HRP = Character:FindFirstChild("HumanoidRootPart")
                        local target = GetClosestTarget()
                        if HRP and target then
                            HRP.CFrame = target.CFrame * CFrame.new(0, 0, 5)
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

Library:Init()
