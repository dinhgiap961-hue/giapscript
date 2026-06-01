-- DRAGON BLOX V2 - DEBUG + REMOTE SPY + SKILL NGOÀI MAP
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

getgenv().DBV2 = getgenv().DBV2 or {
    AutoSkill = false,
    AutoReplay = false,
    Godmode = false,
    LockBoss = false,
    Running = true,
    MenuVisible = true,
    Debug = true -- BẬT DEBUG
}

-- IN TẤT CẢ REMOTE RA ĐỂ MÀY CHỌN
print("=== TẤT CẢ REMOTE TRONG GAME ===")
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        print("Remote: "..v.Name.." | Path: "..v:GetFullName())
    end
end
print("=== COPY TÊN REMOTE SKILL VÀO DƯỚI ===")

-- MÀY TỰ ĐIỀN TÊN REMOTE VÀO ĐÂY SAU KHI XEM LOG
local SkillRemote = RS:FindFirstChild("SkillEvent") or RS:FindFirstChild("CombatRemote") or RS:FindFirstChild("Attack") -- SỬA TÊN REMOTE Ở ĐÂY

if not SkillRemote then
    warn("ĐÉO TÌM THẤY REMOTE SKILL - CHECK LOG Ở TRÊN RỒI SỬA TÊN")
end

-- XÓA GUI CŨ
if game.CoreGui:FindFirstChild("DBV2_GUI") then game.CoreGui.DBV2_GUI:Destroy() end
if game.CoreGui:FindFirstChild("DBV2_Toggle") then game.CoreGui.DBV2_Toggle:Destroy() end

-- NÚT BẬT/TẮT MENU
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

-- GUI CHÍNH
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "DBV2_GUI"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 350, 0, 300)
Main.Position = UDim2.new(0, 50, 0, 70)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "DBV2 | Remote: "..(SkillRemote and SkillRemote.Name or "CHƯA CÓ")
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(138,43,226)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

local DebugLabel = Instance.new("TextLabel", Main)
DebugLabel.Position = UDim2.new(0, 10, 0, 35)
DebugLabel.Size = UDim2.new(1, -20, 0, 60)
DebugLabel.Text = "DEBUG: Chờ bật skill..."
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

-- SPAM SKILL NGOÀI MAP - CÓ DEBUG
local function spamSkill()
    if not SkillRemote then 
        DebugLabel.Text = "DEBUG: CHƯA CÓ REMOTE SKILL!\nCheck console F9 để xem tên remote"
        return 
    end
    
    local boss = getBoss()
    if not boss or not boss:FindFirstChild("HumanoidRootPart") then 
        DebugLabel.Text = "DEBUG: KHÔNG TÌM THẤY BOSS"
        return 
    end
    
    local bpos = boss.HumanoidRootPart.Position
    local char = Plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- SPAWN TỪ 4 GÓC
    local successCount = 0
    for i = 1, 4 do
        local ang = (i/4) * math.pi * 2
        local x = math.cos(ang) * 600
        local z = math.sin(ang) * 600
        local spawnPos = bpos + Vector3.new(x, 150, z)
        local spawnCF = CFrame.new(spawnPos, bpos)

        -- THỬ TỪNG KIỂU FIRE
        local s1 = pcall(function() SkillRemote:FireServer("EnergyBlast", spawnCF, bpos) end)
        local s2 = pcall(function() SkillRemote:FireServer("Blast", spawnCF, bpos) end)
        local s3 = pcall(function() SkillRemote:FireServer(spawnCF, bpos) end)
        local s4 = pcall(function() SkillRemote:FireServer(boss, "EnergyBlast") end)
        local s5 = pcall(function() SkillRemote:FireServer(boss) end)
        
        if s1 or s2 or s3 or s4 or s5 then successCount = successCount + 1 end
    end
    
    DebugLabel.Text = "DEBUG: Đã fire "..successCount.."/4 hướng\nRemote: "..SkillRemote.Name.."\nBoss: "..boss.Name.."\nPos: "..math.floor(bpos.X)..","..math.floor(bpos.Z)
end

-- NÚT
mkBtn(100, "Skill Ngoài Map", function(v) getgenv().DBV2.AutoSkill = v end)
mkBtn(135, "Auto Play Again", function(v) getgenv().DBV2.AutoReplay = v end)
mkBtn(170, "Godmode", function(v) getgenv().DBV2.Godmode = v end)
mkBtn(205, "Lock Boss", function(v) getgenv().DBV2.LockBoss = v lockBoss(v) end)

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

print("=== DBV2 LOADED ===")
print("1. Bấm F9 xem console")
print("2. Copy tên Remote Skill từ log")
print("3. Sửa dòng 25: local SkillRemote = RS:FindFirstChild('TÊN_REMOTE')")
print("4. Execute lại script")
