local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main")
local Section = Tab:NewSection("Dragon Blox")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- Nút Atom CỐ ĐỊNH
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AtomToggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0,50,0,50)
Btn.Position = UDim2.new(0,10,0,150)
Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom"
Btn.TextColor3 = Color3.fromRGB(255,255,255)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 16
Btn.ZIndex = 999
Btn.Parent = ScreenGui
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function()
    Kavo:ToggleUI()
end)

-- CHO MENU KÉO THẢ
task.spawn(function()
    repeat task.wait() until CoreGui:FindFirstChild("Kavo")
    local KavoUI = CoreGui:FindFirstChild("Kavo")
    if KavoUI and KavoUI:FindFirstChild("MainFrame") then
        local main = KavoUI.MainFrame
        main.Active = true
        main.Draggable = true
    end
end)

local function findRemote(keyword)
    for _,v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if string.find(string.lower(v.Name), string.lower(keyword)) then
                return v
            end
        end
    end
    return nil
end

local function isDungeonClear()
    local gui = Plr:FindFirstChild("PlayerGui")
    if gui then
        for _, v in pairs(gui:GetDescendants()) do
            if v:IsA("TextLabel") and (string.find(v.Text, "0 Mob Left") or string.find(v.Text, "Dungeon Cleared")) then
                return true
            end
        end
    end
    return false
end

local function getMonster()
    if isDungeonClear() then return nil end
    local target, dist = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 and Plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (v.HumanoidRootPart.Position - Plr.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    target = v
                end
            end
        end
    end
    return target
end

local function isInForm()
    local char = Plr.Character
    if not char then return false end
    if string.find(char.Name, "Form") or string.find(char.Name, "SSJ") then return true end
    for _,v in pairs(char:GetChildren()) do
        if v.Name == "Aura" or v.Name == "FormAura" then return true end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _,v in pairs(head:GetChildren()) do
            if v:IsA("ParticleEmitter") or v.Name == "Hair" then return true end
        end
    end
    return false
end

local function getRaids()
    local raidsFolder = workspace:FindFirstChild("Raids") or workspace:FindFirstChild("Raid")
    if raidsFolder then return raidsFolder:GetChildren() end
    return {}
end

-- 1. Spam Energy Blast [E]
Section:NewToggle("Spam Energy Blast [E]", "Tự spam phím E", function(s)
    _G.EB = s
    while _G.EB do
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.05)
    end
end)

-- 2. Auto Click - ĐẤM LIÊN TỤC
Section:NewToggle("Auto Click", "Vừa spam skill vừa đấm", function(s)
    _G.AutoClick = s
    while _G.AutoClick do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        task.wait(0.1)
    end
end)

-- 3. Treo Cổ Boss
Section:NewToggle("Treo Cổ Boss", "Clear là đáp đất ngay", function(s)
    _G.Tp = s
    local lastPos = nil
    while _G.Tp do
        pcall(function()
            local t = getMonster()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if t and hrp and hum and not isDungeonClear() then
                if not lastPos then
                    lastPos = hrp.CFrame
                end
                hrp.CFrame = t.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                hrp.Velocity = Vector3.new(0,0,0)
                hum.PlatformStand = true
            else
                if hum then
                    hum.PlatformStand = false
                end
                if lastPos and hrp then
                    hrp.CFrame = lastPos + Vector3.new(0, 3, 0)
                    lastPos = nil
                end
            end
        end)
        task.wait()
    end
    -- Fix kẹt trên không khi tắt
    local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end)

-- 4. Auto Form
Section:NewToggle("Auto Form", "Tự bật Form khi có", function(s)
    _G.AutoForm = s
    while _G.AutoForm do
        if not isInForm() then
            VIM:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
        end
        task.wait(1)
    end
end)

-- 5. Anti AFK
Section:NewToggle("Anti AFK", "Chống bị kick AFK", function(s)
    _G.AntiAFK = s
    while _G.AntiAFK do
        VU:CaptureController()
        VU:ClickButton2(Vector2.new(0,0))
        task.wait(60)
    end
end)

-- 6. WalkSpeed
Section:NewSlider("WalkSpeed", "Chỉnh tốc chạy", 500, 16, function(v)
    local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = v
    end
end)

-- 7. JumpPower
Section:NewSlider("JumpPower", "Chỉnh lực nhảy", 500, 50, function(v)
    local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
    if hum then
        hum.JumpPower = v
    end
end)
