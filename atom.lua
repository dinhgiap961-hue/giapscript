-- DRAGON BLOX V2 - SKILL NGOÀI MAP + NÚT ẨN HIỆN MENU
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

getgenv().DBV2 = getgenv().DBV2 or {
    AutoSkill = false,
    AutoReplay = false,
    Godmode = false,
    LockBoss = false,
    Running = true,
    MenuVisible = true
}

-- TÌM REMOTE SKILL
local SkillRemote = nil
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") and (v.Name:lower():find("skill") or v.Name:lower():find("attack") or v.Name:lower():find("combat") or v.Name:lower():find("blast")) then
        SkillRemote = v
        break
    end
end
if not SkillRemote then
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then SkillRemote = v break end
    end
end

-- XÓA GUI CŨ
if game.CoreGui:FindFirstChild("DBV2_GUI") then game.CoreGui.DBV2_GUI:Destroy() end
if game.CoreGui:FindFirstChild("DBV2_Toggle") then game.CoreGui.DBV2_Toggle:Destroy() end

-- NÚT BẬT/TẮT MENU - GÓC TRÁI TRÊN
local ToggleGui = Instance.new("ScreenGui", game.CoreGui)
ToggleGui.Name = "DBV2_Toggle"
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton", ToggleGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
ToggleBtn.Text = "DB"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 18
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- GUI CHÍNH
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "DBV2_GUI"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 300, 0, 250)
Main.Position = UDim2.new(0, 50, 0, 70)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "DBV2 | Remote: "..(SkillRemote and SkillRemote.Name or "NONE")
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(138,43,226)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

local function mkBtn(y, txt, cb)
    local b = Instance.new("TextButton", Main)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Text = " [OFF] "..txt
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.Font = Enum.Font.Gotham
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)

    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        b.Text = (on and " [ON] " or " [OFF] ")..txt
        b.BackgroundColor3 = on and Color3.fromRGB(0,170,255) or Color3.fromRGB(40,40,40)
        cb(on)
    end)
end

-- BẤM NÚT DB ĐỂ ẨN/HIỆN MENU
ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().DBV2.MenuVisible = not getgenv().DBV2.MenuVisible
    Main.Visible = getgenv().DBV2.MenuVisible
end)

-- TÌM BOSS
local function getBoss()
    local maxHP, boss = 0, nil
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= Plr.Name then
            local h = v.Humanoid
            if h.Health > 0 and h.MaxHealth > maxHP and h.MaxHealth > 1000 then
                maxHP = h.MaxHealth
                boss = v
            end
        end
    end
    return boss
end

-- LOCK BOSS
local bp, bg, conn
local function lockBoss(on)
    local char = Plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if not on then
        if bp then bp:Destroy() bp = nil end
        if bg then bg:Destroy() bg = nil end
        if conn then conn:Disconnect() conn = nil end
        return
    end

    bp = Instance.new("BodyPosition", hrp)
    bp.MaxForce = Vector3.new(9e9,9e9)
    bp.P = 10000

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(9e9,9e9)
    bg.P = 10000

    conn = RunService.Heartbeat:Connect(function()
        if not getgenv().DBV2.LockBoss then lockBoss(false) return end
        local boss = getBoss()
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            local bpos = boss.HumanoidRootPart.Position
            bp.Position = bpos + Vector3.new(0, 45, 0)
            bg.CFrame = CFrame.new(hrp.Position, bpos)
        end
    end)
end

-- CLICK PLAY AGAIN
local function clickReplay()
    for _, v in pairs(Plr.PlayerGui:GetDescendants()) do
        if v:IsA("TextButton") and v.Visible then
            local t = v.Text:lower()
            if t:find("play again") or t:find("replay") or t:find("restart") then
                firesignal(v.MouseButton1Click)
                return true
            end
        end
    end
    return false
end

-- SPAM SKILL TỪ NGOÀI MAP
local function spamSkill()
    if not SkillRemote then return end
    local boss = getBoss()
    if not boss or not boss:FindFirstChild("HumanoidRootPart") then return end
    local bpos = boss.HumanoidRootPart.Position

    -- 4 GÓC NGOÀI MAP
    for i = 1, 4 do
        local ang = (i/4) * math.pi * 2
        local x = math.cos(ang) * 600
        local z = math.sin(ang) * 600
        local spawnPos = bpos + Vector3.new(x, 150, z)
        local spawnCF = CFrame.new(spawnPos, bpos)

        pcall(function() SkillRemote:FireServer("EnergyBlast", spawnCF, bpos) end)
        pcall(function() SkillRemote:FireServer("Blast", spawnCF, bpos) end)
        pcall(function() SkillRemote:FireServer("Skill1", spawnCF, bpos) end)
        pcall(function() SkillRemote:FireServer("Skill2", spawnCF, bpos) end)
        pcall(function() SkillRemote:FireServer("Skill3", spawnCF, bpos) end)
        pcall(function() SkillRemote:FireServer("Skill4", spawnCF, bpos) end)
        pcall(function() SkillRemote:FireServer(spawnCF, bpos) end)
    end
end

-- NÚT
mkBtn(40, "Skill Ngoài Map", function(v) getgenv().DBV2.AutoSkill = v end)
mkBtn(75, "Auto Play Again", function(v) getgenv().DBV2.AutoReplay = v end)
mkBtn(110, "Godmode", function(v) getgenv().DBV2.Godmode = v end)
mkBtn(145, "Lock Boss", function(v) getgenv().DBV2.LockBoss = v lockBoss(v) end)

local Close = Instance.new("TextButton", Main)
Close.Position = UDim2.new(1, -25, 0, 5)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(255,0,0)
Close.MouseButton1Click:Connect(function() getgenv().DBV2.Running = false Gui:Destroy() ToggleGui:Destroy() end)

-- LOOP
spawn(function()
    while getgenv().DBV2.Running and task.wait(0.1) do
        if not Plr.Character then continue end
        local hum = Plr.Character:FindFirstChild("Humanoid")

        if getgenv().DBV2.AutoReplay and not workspace:FindFirstChild("UnstableGrounds") then
            clickReplay()
            task.wait(3)
        end

        if getgenv().DBV2.Godmode and hum then
            hum.MaxHealth = 9e9
            hum.Health = 9e9
        end

        if getgenv().DBV2.AutoSkill then
            for _, v in pairs(Plr.Character:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:lower():find("cool") or v.Name:lower():find("cd")) then
                    v.Value = 0
                end
            end
            spamSkill()
        end
    end
end)

print(" Done! Bấm nút DB góc trái để ẩn/hiện menu")
