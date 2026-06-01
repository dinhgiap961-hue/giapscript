-- DRAGON BLOX V2 - FIX LOCK KHÔNG CHUI ĐẤT
local Plr = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

getgenv().DBV2 = getgenv().DBV2 or {
    AutoSkill = false,
    AutoReplay = false,
    Godmode = false,
    LockBoss = false,
    Running = true,
    MenuVisible = true,
    FlyHeight = 50 -- CHIỀU CAO BAY
}

-- KNIT
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local SkillController = Knit.GetController("SkillController") or Knit.GetController("SkillManager") or Knit.GetController("CombatController")

-- XÓA GUI CŨ
if game.CoreGui:FindFirstChild("DBV2_GUI") then game.CoreGui.DBV2_GUI:Destroy() end
if game.CoreGui:FindFirstChild("DBV2_Toggle") then game.CoreGui.DBV2_Toggle:Destroy() end

-- NÚT DB
local ToggleGui = Instance.new("ScreenGui", game.CoreGui)
ToggleGui.Name = "DBV2_Toggle"

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

-- GUI
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "DBV2_GUI"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 320, 0, 300)
Main.Position = UDim2.new(0, 50, 0, 70)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "DBV2 KNIT | Controller: "..(SkillController and "OK" or "FAIL")
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(138,43,226)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

local DebugLabel = Instance.new("TextLabel", Main)
DebugLabel.Position = UDim2.new(0, 10, 0, 35)
DebugLabel.Size = UDim2.new(1, -20, 0, 70)
DebugLabel.Text = "DEBUG: Đang chờ..."
DebugLabel.TextColor3 = Color3.fromRGB(255,255,0)
DebugLabel.BackgroundTransparency = 1
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextSize = 11
DebugLabel.TextWrapped = true
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugLabel.TextYAlignment = Enum.TextYAlignment.Top

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

-- LOCK BOSS - FIX CHUI ĐẤT
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
    bp.MaxForce = Vector3.new(9e9,9e9,9e9)
    bp.P = 10000
    bp.D = 1000

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(9e9,9e9)
    bg.P = 10000
    bg.D = 1000

    conn = RunService.Heartbeat:Connect(function()
        if not getgenv().DBV2.LockBoss then lockBoss(false) return end
        local boss = getBoss()
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            local bpos = boss.HumanoidRootPart.Position

            -- RAYCAST XUỐNG ĐẤT ĐỂ KHÔNG CHUI
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {boss, char}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local rayResult = workspace:Raycast(bpos, Vector3.new(0, -500, 0), raycastParams)
            local groundY = rayResult and rayResult.Position.Y or bpos.Y

            -- BAY CAO HƠN MẶT ĐẤT 50 STUD
            local targetY = math.max(bpos.Y + getgenv().DBV2.FlyHeight, groundY + getgenv().DBV2.FlyHeight)
            local targetPos = Vector3.new(bpos.X, targetY, bpos.Z)

            bp.Position = targetPos
            bg.CFrame = CFrame.new(hrp.Position, bpos)

            DebugLabel.Text = "LOCK: "..boss.Name.."\nHP: "..math.floor(boss.Humanoid.Health).."\nY: "..math.floor(targetPos.Y)
        else
            DebugLabel.Text = "DEBUG: Đang tìm boss..."
        end
    end)
end

-- BẤM NÚT SKILL THẬT
local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight}

local function spamSkill()
    local boss = getBoss()
    if not boss then
        DebugLabel.Text = "DEBUG: Không có boss"
        return
    end

    local bpos = boss.HumanoidRootPart.Position
    local char = Plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local oldCF = hrp.CFrame

    -- BẮN TỪ 8 GÓC NGOÀI MAP
    for i = 1, 8 do
        local ang = (i/8) * math.pi * 2
        local x = math.cos(ang) * 600
        local z = math.sin(ang) * 600
        local spawnPos = bpos + Vector3.new(x, 150, z)

        hrp.CFrame = CFrame.new(spawnPos, bpos)
        task.wait()

        VIM:SendKeyEvent(true, skillKeys[i], false, game)
        task.wait(0.03)
        VIM:SendKeyEvent(false, skillKeys[i], false, game)

        if SkillController and SkillController.Fire then
            pcall(function() SkillController:Fire("EnergyBlast", spawnPos, bpos) end)
        end
    end

    hrp.CFrame = oldCF -- VỀ LẠI VỊ TRÍ CŨ
    DebugLabel.Text = "DEBUG: Đã bắn 8 góc\nBoss: "..boss.Name
end

-- AUTO REPLAY
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

-- NÚT
mkBtn(110, "Skill Ngoài Map", function(v) getgenv().DBV2.AutoSkill = v end)
mkBtn(145, "Auto Play Again", function(v) getgenv().DBV2.AutoReplay = v end)
mkBtn(180, "Godmode", function(v) getgenv().DBV2.Godmode = v end)
mkBtn(215, "Lock Boss", function(v) getgenv().DBV2.LockBoss = v lockBoss(v) end)

-- SLIDER CHIỀU CAO
local HeightLabel = Instance.new("TextLabel", Main)
HeightLabel.Position = UDim2.new(0, 10, 0, 250)
HeightLabel.Size = UDim2.new(1, -20, 0, 20)
HeightLabel.Text = "Chiều cao bay: "..getgenv().DBV2.FlyHeight
HeightLabel.TextColor3 = Color3.new(1,1,1)
HeightLabel.BackgroundTransparency = 1
HeightLabel.Font = Enum.Font.Gotham
HeightLabel.TextSize = 12

local HeightSlider = Instance.new("TextButton", Main)
HeightSlider.Position = UDim2.new(0, 10, 0, 270)
HeightSlider.Size = UDim2.new(1, -20, 0, 20)
HeightSlider.Text = "Tăng/Giảm"
HeightSlider.TextColor3 = Color3.new(1,1,1)
HeightSlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
HeightSlider.Font = Enum.Font.Gotham
Instance.new("UICorner", HeightSlider)

HeightSlider.MouseButton1Click:Connect(function()
    getgenv().DBV2.FlyHeight = getgenv().DBV2.FlyHeight == 50 and 100 or 50
    HeightLabel.Text = "Chiều cao bay: "..getgenv().DBV2.FlyHeight
end)

local Close = Instance.new("TextButton", Main)
Close.Position = UDim2.new(1, -25, 0, 5)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(255,0,0)
Close.MouseButton1Click:Connect(function() getgenv().DBV2.Running = false Gui:Destroy() ToggleGui:Destroy() end)

-- LOOP
spawn(function()
    while getgenv().DBV2.Running and task.wait(0.2) do
        if not Plr.Character then continue end
        local hum = Plr.Character:FindFirstChild("Humanoid")

        if getgenv().DBV2.Godmode and hum then
            hum.MaxHealth = 9e9
            hum.Health = 9e9
        end

        if getgenv().DBV2.AutoReplay and not workspace:FindFirstChild("UnstableGrounds") then
            if clickReplay() then task.wait(3) end
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
