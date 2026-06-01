-- DRAGON BLOX V2 - DÒ NÚT START GÓC PHẢI + LOCK ATOM DÍNH ĐẦU BOSS
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Settings = {
    AutoEnergyBall = false,
    AutoPlayAgain = false,
    Godmode = false,
    AutoLockAtom = false,
    FlyHeight = 45
}

local allRemotes = {}
local startButtonID = 0 -- NÚT START DƯỚI GÓC PHẢI
local skillIDs = {1,2,3,4,5,6,7,8}
local inRaid = false
local isScanningStart = false

-- LOCK ATOM VARS
local currentBoss = nil
local lockConnection = nil
local alignPos, alignOri = nil, nil

for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        table.insert(allRemotes, v)
    end
end

-- GUI
local Gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
Gui.Name = "DragonBloxV2"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.Size = UDim2.new(0, 550, 0, 350)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local TitleBar = Instance.new("Frame", Main)
TitleBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TitleBar)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Dragon Blox V2 - Start Góc Phải + Lock Atom"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -7)
CloseBtn.Size = UDim2.new(0, 14, 0, 14)
CloseBtn.Text = ""
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local Content = Instance.new("ScrollingFrame", Main)
Content.BackgroundColor3 = Color3.fromRGB(25,25,25)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.Size = UDim2.new(1, -20, 1, -55)
Content.ScrollBarThickness = 4

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 8)

local function createLabel(text)
    local Label = Instance.new("TextLabel", Content)
    Label.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Label.Size = UDim2.new(1, -16, 0, 40)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.TextSize = 12
    Label.TextWrapped = true
    Instance.new("UICorner", Label).CornerRadius = UDim.new(0, 6)
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 16)
    return Label
end

local StatusLabel = createLabel("Status: Chờ bật Auto Play Again")
local StartLabel = createLabel("Nút Start Góc Phải: Chưa dò")
local BossLabel = createLabel("Boss: Chưa lock")

local function createToggle(name, callback)
    local Btn = Instance.new("TextButton", Content)
    Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Btn.Size = UDim2.new(1, -16, 0, 35)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = "  "..name
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Check = Instance.new("Frame", Btn)
    Check.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Check.Position = UDim2.new(1, -45, 0.5, -10)
    Check.Size = UDim2.new(0, 20, 0, 20)
    Instance.new("UICorner", Check).CornerRadius = UDim.new(0, 4)

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Check.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60,60,60)
        callback(state)
    end)
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 16)
end

local function checkInRaid()
    return workspace:FindFirstChild("UnstableGrounds") or workspace:FindFirstChild("Raid") or workspace:FindFirstChild("Dungeon")
end

-- TÌM BOSS MÁU TO NHẤT
local function findBoss()
    local maxHP, boss = 0, nil
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= Plr.Name then
            local hum = v.Humanoid
            if hum.Health > 0 and hum.MaxHealth > maxHP and hum.MaxHealth > 1000 then
                maxHP = hum.MaxHealth
                boss = v
            end
        end
    end
    return boss
end

-- LOCK ATOM: DÍNH CỨNG LÊN ĐẦU BOSS
local function startLockAtom()
    local char = Plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    if alignPos then alignPos:Destroy() end
    if alignOri then alignOri:Destroy() end
    if lockConnection then lockConnection:Disconnect() end
    
    local att0 = Instance.new("Attachment", hrp)
    local att1 = Instance.new("Attachment", workspace.Terrain)
    
    alignPos = Instance.new("AlignPosition", hrp)
    alignPos.Attachment0 = att0
    alignPos.Attachment1 = att1
    alignPos.RigidityEnabled = true
    alignPos.MaxForce = 9e9
    
    alignOri = Instance.new("AlignOrientation", hrp)
    alignOri.Attachment0 = att0
    alignOri.RigidityEnabled = true
    alignOri.MaxTorque = 9e9
    
    lockConnection = RunService.RenderStepped:Connect(function()
        if not Settings.AutoLockAtom then
            stopLockAtom()
            return
        end
        
        if not currentBoss or not currentBoss.Parent or not currentBoss:FindFirstChild("Humanoid") or currentBoss.Humanoid.Health <= 0 then
            currentBoss = findBoss()
        end
        
        if currentBoss and currentBoss:FindFirstChild("HumanoidRootPart") then
            local bossHRP = currentBoss.HumanoidRootPart
            att1.WorldPosition = bossHRP.Position + Vector3.new(0, Settings.FlyHeight, 0)
            alignOri.CFrame = CFrame.lookAt(hrp.Position, bossHRP.Position)
            BossLabel.Text = "Boss: "..currentBoss.Name.." - LOCKED"
        else
            BossLabel.Text = "Boss: Đang tìm..."
        end
    end)
end

local function stopLockAtom()
    if lockConnection then lockConnection:Disconnect() lockConnection = nil end
    if alignPos then alignPos:Destroy() alignPos = nil end
    if alignOri then alignOri:Destroy() alignOri = nil end
    currentBoss = nil
    BossLabel.Text = "Boss: Tắt lock"
end

-- DÒ SỐ NÚT START DƯỚI GÓC PHẢI
local function scanStartButton()
    if startButtonID ~= 0 or isScanningStart then return startButtonID end
    isScanningStart = true
    StatusLabel.Text = "Status: Đang dò NÚT START GÓC PHẢI 1-100..."
    StartLabel.Text = "Nút Start Góc Phải: Đang dò..."

    for i = 1, 100 do
        if checkInRaid() or not Settings.AutoPlayAgain then
            if checkInRaid() then
                startButtonID = i - 1
                StartLabel.Text = "Nút Start Góc Phải: "..startButtonID.." ✓"
                StatusLabel.Text = "Status: Vào raid thành công"
            end
            isScanningStart = false
            return startButtonID
        end

        -- ƯU TIÊN REMOTE CÓ CHỮ START/UNSTABLE
        for _, remote in pairs(allRemotes) do
            local rn = remote.Name:lower()
            if string.find(rn, "start") or string.find(rn, "unstable") or string.find(rn, "raid") or string.find(rn, "join") then
                pcall(function() remote:FireServer(i) end)
                pcall(function() remote:FireServer(i, "Hard") end)
                pcall(function() remote:FireServer("Start", i) end)
            end
        end
        
        for _, remote in pairs(allRemotes) do
            pcall(function() remote:FireServer(i) end)
        end
        task.wait(0.15)
    end

    startButtonID = 6 -- DEFAULT UNSTABLE GROUNDS THƯỜNG LÀ 6
    StartLabel.Text = "Nút Start Góc Phải: 6 (Default)"
    isScanningStart = false
    return 6
end

local function clickStartButton()
    if startButtonID == 0 then return end
    for _, remote in pairs(allRemotes) do
        pcall(function() remote:FireServer(startButtonID) end)
        pcall(function() remote:FireServer(startButtonID, "Hard") end)
        pcall(function() remote:FireServer("Start", startButtonID) end)
    end
end

local function spamSkillsRight()
    for _, skillID in pairs(skillIDs) do
        for _, remote in pairs(allRemotes) do
            pcall(function() remote:FireServer(skillID) end)
        end
    end
end

createToggle("Auto Energy Ball [SPAM SKILL PHẢI]", function(v) 
    Settings.AutoEnergyBall = v
end)

createToggle("Auto Play Again [DÒ NÚT START GÓC PHẢI]", function(v) 
    Settings.AutoPlayAgain = v
    if v and not inRaid and not isScanningStart and startButtonID == 0 then
        scanStartButton()
    end
end)

createToggle("Godmode", function(v) 
    Settings.Godmode = v 
    if v and Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
        Plr.Character.Humanoid.MaxHealth = 9e9
        Plr.Character.Humanoid.Health = 9e9
    end
end)

createToggle("auto lock Atom [DÍNH ĐẦU BOSS]", function(v) 
    Settings.AutoLockAtom = v 
    if v then
        startLockAtom()
    else
        stopLockAtom()
    end
end)

CloseBtn.MouseButton1Click:Connect(function() 
    stopLockAtom()
    Gui:Destroy() 
end)

RunService.Heartbeat:Connect(function()
    local char = Plr.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")

    local nowInRaid = checkInRaid()
    
    if Settings.AutoPlayAgain and not nowInRaid and not isScanningStart and startButtonID ~= 0 then
        inRaid = false
        clickStartButton()
        task.wait(2)
        return
    end

    if nowInRaid and not inRaid then
        inRaid = true
        StatusLabel.Text = "Status: Đang farm raid"
    end

    if not nowInRaid and inRaid then
        inRaid = false
        stopLockAtom()
        StatusLabel.Text = "Status: Hết raid"
    end

    if hum and Settings.Godmode then 
        hum.Health = hum.MaxHealth 
    end

    if Settings.AutoEnergyBall then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("NumberValue") and (string.find(v.Name:lower(), "cool") or string.find(v.Name:lower(), "cd")) then
                v.Value = 0
            end
            if v:IsA("NumberValue") and string.find(v.Name:lower(), "ki") then
                v.Value = 999999
            end
        end
        spamSkillsRight()
    end
end)

Plr.CharacterAdded:Connect(function()
    task.wait(3)
    if Settings.AutoPlayAgain and startButtonID ~= 0 then clickStartButton() end
    if Settings.AutoLockAtom then startLockAtom() end
end)
