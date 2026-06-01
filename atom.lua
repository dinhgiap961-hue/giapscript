local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main")
local Section = Tab:NewSection("Dragon Blox")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")

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
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)

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
            if v:IsA("TextLabel") and (string.find(v.Text, "0 Mob Left") or string.find(v.Text, "Dungeon Cleared") or string.find(v.Text, "Wave")) then
                if string.find(v.Text, "0") then return true end
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
            if v.Humanoid.Health > 0 and v.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                if Plr.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (v.HumanoidRootPart.Position - Plr.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist and d < 500 then
                        dist = d; target = v
                    end
                end
            end
        end
    end
    return target
end

local function isInForm()
    local char = Plr.Character
    if not char then return false end

    local stats = char:FindFirstChild("Stats") or char:FindFirstChild("stats")
    if stats then
        local formVal = stats:FindFirstChild("Form") or stats:FindFirstChild("Transformation")
        if formVal and formVal.Value > 0 then return true end
    end

    local leaderstats = Plr:FindFirstChild("leaderstats")
    if leaderstats then
        local form = leaderstats:FindFirstChild("Form")
        if form and form.Value > 0 then return true end
    end

    for _,v in pairs(char:GetDescendants()) do
        if v.Name == "Aura" or v.Name == "SSJ" or v.Name == "Transform" then return true end
        if v:IsA("ParticleEmitter") and v.Parent.Name == "HumanoidRootPart" then return true end
    end
    return false
end

-- HÀM LẤY % KI HIỆN TẠI
local function getKiPercent()
    -- Cách 1: Check leaderstats
    local leaderstats = Plr:FindFirstChild("leaderstats")
    if leaderstats then
        local ki = leaderstats:FindFirstChild("Ki") or leaderstats:FindFirstChild("ki") or leaderstats:FindFirstChild("Energy")
        local maxKi = leaderstats:FindFirstChild("MaxKi") or leaderstats:FindFirstChild("MaxEnergy")
        if ki and maxKi and maxKi.Value > 0 then
            return (ki.Value / maxKi.Value) * 100
        end
    end

    -- Cách 2: Check trong Character
    local char = Plr.Character
    if char then
        local stats = char:FindFirstChild("Stats") or char:FindFirstChild("stats")
        if stats then
            local ki = stats:FindFirstChild("Ki") or stats:FindFirstChild("Energy")
            local maxKi = stats:FindFirstChild("MaxKi") or stats:FindFirstChild("MaxEnergy")
            if ki and maxKi and maxKi.Value > 0 then
                return (ki.Value / maxKi.Value) * 100
            end
        end
    end

    -- Cách 3: Check GUI thanh ki
    local gui = Plr:FindFirstChild("PlayerGui")
    if gui then
        for _,v in pairs(gui:GetDescendants()) do
            if v:IsA("ImageLabel") and v.Name == "Ki" and v:FindFirstChild("Bar") then
                return v.Bar.Size.X.Scale * 100
            end
        end
    end
    return 100 -- Mặc định 100% nếu không tìm thấy
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

-- 2. Auto Click
Section:NewToggle("Auto Click", "Vừa spam skill vừa đấm", function(s)
    _G.AutoClick = s
    while _G.AutoClick do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        task.wait(0.1)
    end
end)

-- 3. Auto Beat [M]
Section:NewToggle("Auto Beat [M]", "Tự spam phím M", function(s)
    _G.AutoBeat = s
    while _G.AutoBeat do
        VIM:SendKeyEvent(true, Enum.KeyCode.M, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.M, false, game)
        task.wait(0.1)
    end
end)

-- 4. Treo Cổ Boss - Reset khi sang raid
Section:NewToggle("Treo Cổ Boss", "Clear/Sang raid là đáp đất", function(s)
    _G.Tp = s
    local lastPos = nil
    local lastRaid = nil
    while _G.Tp do
        pcall(function()
            local t = getMonster()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            local currentRaid = workspace:FindFirstChild("CurrentRaid")

            if currentRaid ~= lastRaid then
                lastPos = nil
                lastRaid = currentRaid
                if hum then hum.PlatformStand = false end
                task.wait(3)
            end

            if t and hrp and hum and not isDungeonClear() then
                if not lastPos then lastPos = hrp.CFrame end
                hrp.CFrame = t.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                hrp.Velocity = Vector3.new(0,0,0)
                hum.PlatformStand = true
            else
                if hum then hum.PlatformStand = false end
                if lastPos and hrp then
                    hrp.CFrame = lastPos + Vector3.new(0, 3, 0)
                    lastPos = nil
                end
            end
        end)
        task.wait()
    end
    local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
end)

-- 5. Auto Lock Skill
Section:NewToggle("Auto Lock Skill", "Tự ghim skill vào boss", function(s)
    _G.AutoLock = s
    local lockRemote = findRemote("lock") or findRemote("target")
    while _G.AutoLock do
        pcall(function()
            local boss = getMonster()
            if boss and lockRemote then
                lockRemote:FireServer(boss)
            end
        end)
        task.wait(0.5)
    end
end)

-- 6. Auto Boss [1] - Tự rút kiếm
Section:NewToggle("Auto Boss [1]", "Tự rút kiếm + đánh boss", function(s)
    _G.AutoBoss = s
    local attackRemote = findRemote("attack") or findRemote("punch") or findRemote("hit")
    local switched = false
    while _G.AutoBoss do
        pcall(function()
            local boss = getMonster()
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if boss and hrp then
                if not switched then
                    VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    switched = true
                    task.wait(0.2)
                end

                local distance = (hrp.Position - boss.HumanoidRootPart.Position).Magnitude
                if distance < 10 then
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 15, 0)
                end
                if attackRemote then
                    attackRemote:FireServer()
                end
            else
                switched = false
            end
        end)
        task.wait(0.1)
    end
end)

-- 7. ĐÃ FIX: Auto Charge [C] - Thông minh
Section:NewToggle("Auto Charge [C]", "Tự giữ C khi ki < 90%", function(s)
    _G.AutoFushi = s
    local charging = false
    while _G.AutoFushi do
        local ki = getKiPercent()

        if ki < 90 and not charging then
            -- Hết ki -> bắt đầu giữ C
            VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
            charging = true
        elseif ki >= 95 and charging then
            -- Đầy ki -> nhả C
            VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
            charging = false
        end
        task.wait(0.1)
    end
    -- Tắt toggle thì nhả C luôn
    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
end)

-- 8. Auto Form [Y] - Thông minh
Section:NewToggle("Auto Form [Y]", "Thông minh - hết form mới bấm", function(s)
    _G.AutoForm = s
    while _G.AutoForm do
        if not isInForm() then
            task.wait(1)
            if not isInForm() then
                VIM:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                task.wait(3)
            end
        end
        task.wait(1)
    end
end)

-- 9. Auto Next Raid
local raidIndex = 1
Section:NewToggle("Auto Next Raid", "Tự chuyển raid tiếp theo", function(s)
    _G.AutoNextRaid = s
    while _G.AutoNextRaid do
        pcall(function()
            local raids = getRaids()
            if #raids > 0 then
                local raid = raids[raidIndex]
                local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                if raid and raid:FindFirstChild("HumanoidRootPart") and hrp then
                    hrp.CFrame = raid.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    raidIndex = raidIndex + 1
                    if raidIndex > #raids then raidIndex = 1 end
                end
            end
        end)
        task.wait(3)
    end
end)

-- 10. Auto Play Raid
Section:NewToggle("Auto Play Raid", "Bật full auto", function(s)
    _G.AutoPlay = s
    _G.EB = s
    _G.Tp = s
    _G.AutoLock = s
    _G.AutoBoss = s
    _G.AutoFushi = s
    _G.AutoForm = s
    _G.AutoNextRaid = s
    _G.AutoClick = s
    _G.AutoBeat = s
end)

Section:NewButton("Ẩn Menu", "Thu nhỏ", function()
    Kavo:ToggleUI()
end)

-- Anti AFK
Plr.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
