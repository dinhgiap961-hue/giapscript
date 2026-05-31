-- ====================================================================================================
-- DRAGON BLOX ELITE HUB V3 - FULL SYSTEM (ANTI-LAG & OPTIMIZED)
-- ====================================================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- [HỆ THỐNG GIAO DIỆN MỞ RỘNG]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 500)
MainFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ELITE HUB - PERFORMANCE MODE"
Title.TextColor3 = Color3.new(1, 1, 1)

local Settings = {Fly = false, Farm = false, Raid = false, Transform = false, AntiLag = false}

local function CreateButton(text, settingKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, #MainFrame:GetChildren() * 55 - 50)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text .. ": OFF"
    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.Text = text .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    end)
end

CreateButton("FLY-HIGH", "Fly")
CreateButton("AUTO-FARM", "Farm")
CreateButton("AUTO-RAID", "Raid")
CreateButton("TRANSFORM", "Transform")
CreateButton("ANTI-LAG", "AntiLag") -- Chế độ giảm lag cho máy yếu

-- [HỆ THỐNG GIẢM LAG (FEED LAG ENGINE)]
local function EnableAntiLag()
    if Settings.AntiLag then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            end
            if v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then
                v:Destroy()
            end
        end
        UserSettings().GameSettings.GraphicsQualityLevel = 1
    end
end

-- [BỘ XỬ LÝ REMOTE ĐA NĂNG]
local function SendAttack(targetPos)
    local remotes = {"Attack", "Skill", "Combat", "Fire", "Click"}
    for _, name in pairs(remotes) do
        local remote = ReplicatedStorage:FindFirstChild(name, true)
        if remote then
            pcall(function() remote:FireServer(targetPos) end)
        end
    end
end

-- [VÒNG LẶP LOGIC CHÍNH]
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end

    if Settings.AntiLag then EnableAntiLag() end

    if Settings.Fly then
        Char.HumanoidRootPart.CFrame = CFrame.new(Char.HumanoidRootPart.Position.X, 600, Char.HumanoidRootPart.Position.Z)
        Char.HumanoidRootPart.Anchored = true
    else
        Char.HumanoidRootPart.Anchored = false
    end

    if Settings.Farm then
        local target = nil
        local minDist = 99999
        for _, v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v ~= Char and v.Name:lower():find("boss") then
                local dist = (Char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < minDist then minDist = dist; target = v end
            end
        end
        if target then
            SendAttack(target.HumanoidRootPart.Position)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.HumanoidRootPart.Position)
        end
    end
end)

-- [HỆ THỐNG PHỤ TRỢ]
task.spawn(function()
    while task.wait(0.3) do
        if Settings.Raid then
            for _, v in pairs(CoreGui:GetDescendants()) do
                if v:IsA("TextButton") and (v.Text:lower():find("start") or v.Text:lower():find("next") or v.Text:lower():find("again")) then
                    VirtualInputManager:MouseButton1Click(Vector2.new(0,0))
                end
            end
        end
        if Settings.Transform then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
        end
    end
end)
