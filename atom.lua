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

    local stats = char:FindFirstChild("Stats") or char:FindFirstChild("stats") or char:FindFirstChild("Data")
    if stats then
        local formVal = stats:FindFirstChild("Form") or stats:FindFirstChild("Transformation") or stats:FindFirstChild("Mode")
        if formVal and formVal.Value > 0 then return true end
    end

    local leaderstats = Plr:FindFirstChild("leaderstats")
    if leaderstats then
        local form = leaderstats:FindFirstChild("Form") or leaderstats:FindFirstChild("Transformation")
        if form and form.Value > 0 then return true end
        local power = leaderstats:FindFirstChild("Power") or leaderstats:FindFirstChild("power")
        if power and power.Value > 10000000 then return true end
    end

    if string.find(char.Name, "SSJ") or string.find(char.Name, "Form") or string.find(char.Name, "Mystic") then return true end

    for _,v in pairs(char:GetDescendants()) do
        if v.Name == "Aura" or v.Name == "SSJ" or v.Name == "Transform" or v.Name == "Glow" then return true end
        if v:IsA("ParticleEmitter") and (v.Parent.Name == "HumanoidRootPart" or v.Parent.Name == "Torso") then
            if v.Enabled then return true end
        end
        if v:IsA("PointLight") and v.Parent.Name == "HumanoidRootPart" then return true end
    end
    return false
end

local function getKiPercent()
    local leaderstats = Plr:FindFirstChild("leaderstats")
    if leaderstats then
        local ki = leaderstats:FindFirstChild("Ki") or leaderstats:FindFirstChild("ki") or leaderstats:FindFirstChild("Energy")
        local maxKi = leaderstats:FindFirstChild("MaxKi") or leaderstats:FindFirstChild("MaxEnergy")
        if ki and maxKi and maxKi.Value > 0 then
            return (ki.Value / maxKi.Value) * 100
        end
    end

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

    local gui = Plr:FindFirstChild("PlayerGui")
    if gui then
        for _,v in pairs(gui:GetDescendants()) do
            if v:IsA("ImageLabel") and v.Name == "Ki" and v:FindFirstChild("Bar") then
                return v.Bar.Size.X.Scale * 100
            end
        end
    end
    return 100
end

local function isHoldingSword()
    local char = Plr.Character
    if not char then return false end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = string.lower(tool.Name)
            if string.find(name, "sword") or string.find(name, "blade") or string.find(name, "katana") then
                return true
            end
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

-- 6. Auto Boss [1] - Fix 100% - Tự rút kiếm
Section:NewToggle("Auto Boss [1]", "Fix 100% - Tự rút kiếm", function(s)
    _G.AutoBoss = s
    local attackRemote = findRemote("attack") or findRemote("punch") or findRemote("hit")
    local lastSwitch = 0

    while _G.AutoBoss do
        pcall(function()
            local boss = getMonster()
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if boss and hrp then
                if not isHoldingSword() and (tick() - lastSwitch) > 2 then
                    VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    lastSwitch = tick()
                    task.wait(0.3)
                end

                local distance = (hrp.Position - boss.HumanoidRootPart.Position).Magnitude
                if distance < 10 then
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 15, 0)
                end
                if attackRemote then
                    attackRemote:FireServer()
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- 7. Auto Charge [C] - Thông minh
Section:NewToggle("Auto Charge [C]", "Tự giữ C khi ki < 90%", function(s)
    _G.AutoFushi = s
    local charging = false
    while _G.AutoFushi do
        local ki = getKiPercent()

        if ki < 90 and not charging then
            VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
            charging = true
        elseif ki >= 95 and charging then
            VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
            charging = false
        end
        task.wait(0.1)
    end
    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
end)

-- 8. Auto Form [Y] - Cooldown 5s + Reset khi chết
Section:NewToggle("Auto Form [Y]", "Fix 100% - Cooldown 5s", function(s)
    _G.AutoForm = s
    local lastPress = 0
    local lastDeath = false

    Plr.CharacterAdded:Connect(function()
        lastDeath = true
        task.wait(5)
        lastDeath = false
    end)

    while _G.AutoForm do
        local canPress = (tick() - lastPress) > 5

        if not isInForm() and canPress and not lastDeath then
            task.wait(0.5)
            if not isInForm() then
                task.wait(0.5)
                if not isInForm() then
                    VIM:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                    lastPress = tick()
                    task.wait(3)
                end
            end
        end
        task.wait(0.5)
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

-- 10. MỚI: Hide Nametags
Section:NewToggle("Hide Nametags", "Ẩn tên Player_01 + boss", function(s)
    _G.HideName = s
    while _G.HideName do
        pcall(function()
            -- Ẩn tên người chơi
            for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.DisplayDistanceType = s and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
                end
            end
            -- Ẩn tên quái/boss
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") then
                    for _, gui in pairs(v.Head:GetChildren()) do
                        if gui:IsA("BillboardGui") then
                            gui.Enabled = not s
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
    -- Bật lại tên khi tắt toggle
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end
    end
end)

-- 11. Auto Play Raid
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
    _G.HideName = s
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
