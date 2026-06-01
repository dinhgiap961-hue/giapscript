-- DRAGON BLOX V2 - AUTO DÒ NÚT START + SKILL SỐ - CHỈ CHẠY KHI BẬT NÚT
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/dinhgiap961-hue/giapscript/main/atom.lua"))()

local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Settings = {
    AutoEnergyBall = false,
    AutoPlayAgain = false,
    Godmode = false,
    AutoLockAtom = false,
    FlyHeight = 45,
    RaidMode = "Hard"
}

local allRemotes = {}
local bv, currentBoss = nil, nil
local startButtonID = 0
local skillIDs = {1, 2, 3, 4, 5}
local inRaid = false
local isScanningStart = false

for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        table.insert(allRemotes, v)
    end
end

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
Title.Text = "Dragon Blox V2 - Auto Dò Nút Start"
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
local StartLabel = createLabel("Nút Start ID: Chưa dò")
local SkillLabel = createLabel("Skill ID: 1,2,3,4,5")

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

local function scanStartButton()
    if startButtonID ~= 0 or isScanningStart then return startButtonID end
    isScanningStart = true
    StatusLabel.Text = "Status: Đang dò số nút START 1-100..."
    StartLabel.Text = "Nút Start ID: Đang dò..."

    for i = 1, 100 do
        if checkInRaid() or not Settings.AutoPlayAgain then
            if checkInRaid() then
                startButtonID = i - 1
                StartLabel.Text = "Nút Start ID: "..startButtonID.." ✓"
                StatusLabel.Text = "Status: Vào raid thành công"
            end
            isScanningStart = false
            return startButtonID
        end

        for _, remote in pairs(allRemotes) do
            pcall(function() remote:FireServer(i) end)
            pcall(function() remote:FireServer(i, Settings.RaidMode) end)
            pcall(function() remote:FireServer(i, "UnstableGrounds") end)
            pcall(function() remote:FireServer("Start", i) end)
        end
        task.wait(0.15)
    end

    startButtonID = 47
    StartLabel.Text = "Nút Start ID: 47 (Default)"
    isScanningStart = false
    return 47
end

local function scanSkillNumbers()
    StatusLabel.Text = "Status: Đang dò số skill 1-100..."
    local found = {}
    
    for i = 1, 100 do
        if not Settings.AutoEnergyBall then break end
        for _, remote in pairs(allRemotes) do
            local success = pcall(function() remote:FireServer(i) end)
            if success and not table.find(found, i) then
                table.insert(found, i)
                SkillLabel.Text = "Skill ID: "..table.concat(found, ", ")
            end
        end
        task.wait(0.05)
    end
    
    if #found > 0 then skillIDs = found end
end

local function clickStartButton()
    if startButtonID == 0 then return end
    for _, remote in pairs(allRemotes) do
        pcall(function() remote:FireServer(startButtonID, Settings.RaidMode) end)
        pcall(function() remote:FireServer(startButtonID) end)
    end
end

local function spamSkills()
    for _, skillID in pairs(skillIDs) do
        for _, remote in pairs(allRemotes) do
            pcall(function() remote:FireServer(skillID) end)
        end
    end
end

local function enableFloat()
    local char = Plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or bv then return end
    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, 9e9, 0)
    bv.Parent = hrp
end

local function disableFloat()
    if bv then bv:Destroy() bv = nil end
end

local function lockBoss()
    local maxHP, boss = 0, nil
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= Plr.Name then
            if v.Humanoid.MaxHealth > maxHP then
                maxHP = v.Humanoid.MaxHealth
                boss = v
            end
        end
    end
    return boss
end

createToggle("Auto Energy Ball [DÒ SỐ SKILL]", function(v) 
    Settings.AutoEnergyBall = v
    if v then scanSkillNumbers() end
end)

createToggle("Auto Play Again [DÒ NÚT START]", function(v) 
    Settings.AutoPlayAgain = v
    if v and not inRaid and not isScanningStart and startButtonID == 0 then
        scanStartButton()
    end
end)

createToggle("Godmode", function(v) Settings.Godmode = v end)
createToggle("auto lock Atom", function(v) Settings.AutoLockAtom = v end)

CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

RunService.Heartbeat:Connect(function()
    local char = Plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    local nowInRaid = checkInRaid()
    local hasBoss = false
    
    if nowInRaid then
        currentBoss = lockBoss()
        hasBoss = currentBoss ~= nil and currentBoss:FindFirstChild("Humanoid") and currentBoss.Humanoid.Health > 0
    end

    -- HẾT RAID + BẬT AUTO + CÓ ID NÚT START -> BẤM LẠI
    if Settings.AutoPlayAgain and not nowInRaid and not isScanningStart and startButtonID ~= 0 then
        inRaid = false
        disableFloat()
        clickStartButton()
        task.wait(2)
        return
    end

    if nowInRaid and not inRaid then
        inRaid = true
        task.wait(1)
        enableFloat()
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, Settings.FlyHeight, 0) end
        StatusLabel.Text = "Status: Đang farm raid"
    end

    if not nowInRaid and inRaid then
        inRaid = false
        disableFloat()
        currentBoss = nil
        StatusLabel.Text = "Status: Hết raid"
    end

    if inRaid and bv then bv.Velocity = Vector3.new(0, 0, 0) end
    if hum and Settings.Godmode then hum.Health = hum.MaxHealth hum.MaxHealth = 9e9 end

    if Settings.AutoEnergyBall then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("NumberValue") and (string.find(v.Name:lower(), "cool") or string.find(v.Name:lower(), "cd")) then
                v.Value = 0
            end
            if v:IsA("NumberValue") and string.find(v.Name:lower(), "ki") then
                v.Value = 999999
            end
        end
    end

    if Settings.AutoEnergyBall and hasBoss then
        spamSkills()
    end
end)

Plr.CharacterAdded:Connect(function()
    task.wait(3)
    if Settings.AutoPlayAgain and startButtonID ~= 0 then clickStartButton() end
end)
