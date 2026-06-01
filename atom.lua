local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Dragon Blox V2", "BloodTheme")

local MainTab = Win:NewTab("Main")
local DungeonTab = Win:NewTab("Dungeon★")
local MainSection = MainTab:NewSection("Main Features")
local DungeonSection = DungeonTab:NewSection("Dungeon Features")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")

-- Nút Atom
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

-- ÉP MENU RA GIỮA
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
    local stats = char:FindFirstChild("Stats") or char:FindFirstChild("stats")
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

-- TAB MAIN - 6 NÚT
MainSection:NewToggle("Auto Click", "Tự động click chuột", function(s)
    _G.AutoClick = s
    while _G.AutoClick do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        task.wait(0.1)
    end
end)

MainSection:NewToggle("Auto Beat [M]", "Tự spam phím M", function(s)
    _G.AutoBeat = s
    while _G.AutoBeat do
        VIM:SendKeyEvent(true, Enum.KeyCode.M, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.M, false, game)
        task.wait(0.15)
    end
end)

MainSection:NewToggle("Auto Form [C]", "Tự biến hình phím C - Khóa form", function(s)
    _G.AutoForm = s
    local lastPress = 0
    local lockedForm = false

    Plr.CharacterAdded:Connect(function()
        lockedForm = false
        task.wait(8)
    end)

    while _G.AutoForm do
        local currentForm = isInForm()
        local canPress = (tick() - lastPress) > 8

        if lockedForm and not currentForm and canPress then
            task.wait(0.5)
            if not isInForm() then
                VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                lastPress = tick()
                task.wait(3)
            end
        elseif not currentForm and not lockedForm and canPress then
            task.wait(1)
            if not isInForm() then
                VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                lastPress = tick()
                lockedForm = true
                task.wait(3)
            end
        elseif currentForm then
            lockedForm = true
        end
        task.wait(0.3)
    end
end)

MainSection:NewToggle("Auto Spam Energy Blast [E]", "Spam skill E liên tục", function(s)
    _G.AutoEnergyBlast = s
    local blastRemote = findRemote("blast") or findRemote("energy") or findRemote("skill")
    while _G.AutoEnergyBlast do
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            if blastRemote then
                local boss = getMonster()
                if boss then blastRemote:FireServer(boss.HumanoidRootPart.Position) end
            end
        end)
        task.wait(0.1)
    end
end)

MainSection:NewToggle("Auto Lock Skill + Bay Cổ", "Ghim skill + bay sau cổ boss", function(s)
    _G.AutoLock = s
    local lockRemote = findRemote("lock") or findRemote("target")
    while _G.AutoLock do
        pcall(function()
            local boss = getMonster()
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")

            if boss and hrp and hum then
                hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 2, -2)
                hrp.Velocity = Vector3.new(0,0,0)
                hum.PlatformStand = true

                if lockRemote then
                    lockRemote:FireServer(boss)
                end

                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end)
        task.wait(0.1)
    end
    if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
        Plr.Character.Humanoid.PlatformStand = false
    end
end)

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

-- TAB DUNGEON - 3 NÚT
local selectedSkill = "Energy Spear"
DungeonSection:NewDropdown("Chọn Kiểu Farm", "Chọn skill để farm", {"Energy Spear", "Energy Blast"}, function(currentOption)
    selectedSkill = currentOption
end)

DungeonSection:NewToggle("Auto Farm", "Farm quái theo skill đã chọn", function(s)
    _G.AutoFarm = s
    local attackRemote = findRemote("attack") or findRemote("punch") or findRemote("melee")
    local skillRemote = findRemote("skill") or findRemote("blast") or findRemote("energy")

    while _G.AutoFarm do
        pcall(function()
            local mob = getMonster()
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")

            if mob and hrp and hum then
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 2, -2)
                hrp.Velocity = Vector3.new(0,0,0)
                hum.PlatformStand = true

                if selectedSkill == "Energy Spear" then
                    -- SPAM CHÉM SIÊU NHANH 33 CLICK/S
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    if attackRemote then
                        for i = 1, 3 do
                            attackRemote:FireServer(mob)
                        end
                    end
                    task.wait(0.03)

                elseif selectedSkill == "Energy Blast" then
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    if skillRemote then
                        skillRemote:FireServer(mob.HumanoidRootPart.Position)
                    end
                    task.wait(0.1)
                end
            end
        end)
        task.wait()
    end
    if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
        Plr.Character.Humanoid.PlatformStand = false
    end
end)

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

DungeonSection:NewToggle("Godmode", "Bất tử", function(s)
    _G.Godmode = s
    while _G.Godmode do
        pcall(function()
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end)
        task.wait()
    end
end)

-- Anti AFK
Plr.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
