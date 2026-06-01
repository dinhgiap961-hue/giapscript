local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Dragon Blox V2", "BloodTheme")

-- CÁC TAB THEO ẢNH
local MainTab = Win:NewTab("Main")
local CheckTab = Win:NewTab("Check") 
local SupportTab = Win:NewTab("Support")
local DungeonTab = Win:NewTab("Dungeon★")
local SettingTab = Win:NewTab("Setting")
local DungeonPremTab = Win:NewTab("Dungeon Premium")
local SkillTab = Win:NewTab("Skill support")

local MainSection = MainTab:NewSection("Main Features")
local DungeonSection = DungeonTab:NewSection("Dungeon Features")
local DungeonPremSection = DungeonPremTab:NewSection("Premium Features")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

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

-- ÉP MENU RA GIỮA MÀN HÌNH + KHÓA VỊ TRÍ
task.spawn(function()
    local main = nil
    repeat
        task.wait(0.1)
        local KavoUI = CoreGui:FindFirstChild("Kavo")
        if KavoUI then main = KavoUI:FindFirstChild("MainFrame") end
    until main

    task.wait(1)
    main.Active = true
    main.Draggable = true
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 550, 0, 400) -- Tăng size cho giống ảnh

    -- Khóa vị trí mỗi 1s
    while task.wait(1) do
        if main and main.Parent then
            main.Position = UDim2.new(0.5, 0, 0.5, 0)
        else break end
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
                if string.find(v.Text, "0") then return true end
            end
            if v:IsA("TextButton") and v.Text == "Play Again" and v.Visible then return true end
        end
    end
    return false
end

local function clickPlayAgain()
    local gui = Plr:FindFirstChild("PlayerGui")
    if gui then
        for _, v in pairs(gui:GetDescendants()) do
            if v:IsA("TextButton") and v.Text == "Play Again" and v.Visible then
                pcall(function() firesignal(v.MouseButton1Click) end)
                pcall(function() firesignal(v.Activated) end)
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
        local formVal = stats:FindFirstChild("Form") or stats:FindFirstChild("Transformation")
        if formVal and formVal.Value > 0 then return true end
    end
    local leaderstats = Plr:FindFirstChild("leaderstats")
    if leaderstats then
        local power = leaderstats:FindFirstChild("Power") or leaderstats:FindFirstChild("power")
        if power and power.Value > 50000000 then return true end
    end
    for _,v in pairs(char:GetDescendants()) do
        if v.Name == "Aura" or v.Name == "SSJ" then return true end
        if v:IsA("ParticleEmitter") and v.Parent.Name == "HumanoidRootPart" and v.Enabled then return true end
    end
    return false
end

local function getKiPercent()
    local leaderstats = Plr:FindFirstChild("leaderstats")
    if leaderstats then
        local ki = leaderstats:FindFirstChild("Ki") or leaderstats:FindFirstChild("ki")
        local maxKi = leaderstats:FindFirstChild("MaxKi") or leaderstats:FindFirstChild("MaxEnergy")
        if ki and maxKi and maxKi.Value > 0 then return (ki.Value / maxKi.Value) * 100 end
    end
    return 100
end

local function getHealthPercent()
    local char = Plr.Character
    if char and char:FindFirstChild("Humanoid") then
        return (char.Humanoid.Health / char.Humanoid.MaxHealth) * 100
    end
    return 100
end

local function getWeapon()
    for _, tool in pairs(Plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = string.lower(tool.Name)
            if string.find(name, "sword") or string.find(name, "blade") or string.find(name, "katana") then
                return tool
            end
        end
    end
    return nil
end

local function isHoldingWeapon()
    local char = Plr.Character
    if not char then return false end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then return true, tool end
    end
    return false, nil
end

-- TAB MAIN
-- 1. Anti AFK
MainSection:NewToggle("Anti afk", "Chống AFK", function(s)
    _G.AntiAfk = s
end)

-- 2. Auto Skill Khi Mất Máu
MainSection:NewToggle("Auto Skill Khi Mất Máu", "Máu < 50% tự dùng skill", function(s)
    _G.AutoSkillLowHP = s
    while _G.AutoSkillLowHP do
        if getHealthPercent() < 50 then
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.2)
        end
        task.wait(0.1)
    end
end)

-- 3. Auto Phê Pha V2 - Auto Charge Ki
MainSection:NewToggle("Auto Phê Pha V2", "Tự giữ C khi ki < 90%", function(s)
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

-- 4. Auto beast - Auto Form
MainSection:NewToggle("Auto beast", "Tự biến hình Y", function(s)
    _G.AutoForm = s
    local lastPress = 0
    local lockedForm = false

    Plr.CharacterAdded:Connect(function()
        lockedForm = false
        task.wait(8)
    end)

    while _G.AutoForm do
        local currentForm = isInForm()
        local canPress = (tick() - lastPress) > 10

        if not currentForm and canPress then
            task.wait(1)
            if not isInForm() then
                VIM:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                lastPress = tick()
                lockedForm = true
                task.wait(5)
            end
        elseif currentForm then
            lockedForm = true
        end
        task.wait(0.3)
    end
end)

-- 5. Auto fusion
MainSection:NewToggle("Auto fusion", "Tự hợp thể", function(s)
    _G.AutoFusion = s
    while _G.AutoFusion do
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        task.wait(10)
    end
end)

-- TAB DUNGEON
-- 6. Auto Start Work All Dungeon V2
DungeonSection:NewToggle("Auto Start Work All Dungeon V2", "Tự vào dungeon", function(s)
    _G.AutoStartDungeon = s
    local startRemote = findRemote("start") or findRemote("enter") or findRemote("dungeon")
    while _G.AutoStartDungeon do
        if startRemote then
            startRemote:FireServer()
        end
        task.wait(5)
    end
end)

-- 7. Auto Kill Boss Premium
DungeonSection:NewToggle("Auto Kill Boss Premium", "Farm boss premium", function(s)
    _G.AutoKillBoss = s
    local attackRemote = findRemote("attack") or findRemote("punch")
    local equippedWeapon = nil

    while _G.AutoKillBoss do
        pcall(function()
            local boss = getMonster()
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")

            if boss and hrp and hum then
                local holding, currentTool = isHoldingWeapon()
                if not holding then
                    local weapon = getWeapon()
                    if weapon then
                        hum:EquipTool(weapon)
                        equippedWeapon = weapon
                        task.wait(0.2)
                    end
                else
                    equippedWeapon = currentTool
                end

                if equippedWeapon and not isHoldingWeapon() then
                    hum:EquipTool(equippedWeapon)
                end

                hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                hrp.Velocity = Vector3.new(0,0,0)
                if attackRemote then attackRemote:FireServer() end
            end
        end)
        task.wait(0.1)
    end
end)

-- 8. Auto (Next Area)
DungeonSection:NewToggle("Auto (Next Area)", "Tự bấm Play Again", function(s)
    _G.AutoNextArea = s
    local playRemote = findRemote("play") or findRemote("replay") or findRemote("next")

    while _G.AutoNextArea do
        pcall(function()
            if isDungeonClear() then
                task.wait(2)
                clickPlayAgain()
                if playRemote then
                    playRemote:FireServer()
                end
                task.wait(5)
            end
        end)
        task.wait(1)
    end
end)

-- 9. Godmode
DungeonSection:NewToggle("Godmode", "Bất tử", function(s)
    _G.Godmode = s
    while _G.Godmode do
        pcall(function()
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
            end
        end)
        task.wait()
    end
end)

-- 10. auto lock Atom - Auto Lock Boss
DungeonSection:NewToggle("auto lock Atom", "Khóa boss", function(s)
    _G.AutoLockAtom = s
    local lockRemote = findRemote("lock") or findRemote("target")
    while _G.AutoLockAtom do
        pcall(function()
            local boss = getMonster()
            if boss and lockRemote then
                lockRemote:FireServer(boss)
            end
        end)
        task.wait(0.5)
    end
end)

-- TAB DUNGEON PREMIUM
-- 11. Auto Skill + Godmode V2
DungeonPremSection:NewToggle("Auto Skill + Godmode V2 (Chạy Liên Tục)", "Skill + bất tử", function(s)
    _G.AutoSkillGod = s
    while _G.AutoSkillGod do
        pcall(function()
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        task.wait(0.05)
    end
end)

-- 12. Auto equiptools dls
DungeonPremSection:NewToggle("Auto equiptools dls", "Tự cầm tool", function(s)
    _G.AutoEquipDLS = s
    local equippedWeapon = nil
    while _G.AutoEquipDLS do
        pcall(function()
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
            if hum and not isHoldingWeapon() then
                local weapon = getWeapon()
                if weapon then
                    hum:EquipTool(weapon)
                    equippedWeapon = weapon
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- 13. Auto EquipTools
DungeonPremSection:NewToggle("Auto EquipTools", "Khóa tool", function(s)
    _G.AutoEquipTools = s
    local equippedWeapon = nil
    while _G.AutoEquipTools do
        pcall(function()
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
            local holding, currentTool = isHoldingWeapon()

            if not holding then
                local weapon = getWeapon()
                if weapon then
                    hum:EquipTool(weapon)
                    equippedWeapon = weapon
                end
            else
                equippedWeapon = currentTool
            end

            if equippedWeapon and not isHoldingWeapon() then
                hum:EquipTool(equippedWeapon)
            end
        end)
        task.wait(0.1)
    end
end)

-- Anti AFK Handler
Plr.Idled:Connect(function()
    if _G.AntiAfk then
        VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)
