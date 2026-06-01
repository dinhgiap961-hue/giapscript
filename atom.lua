-- DRAGON BLOX V2 FULL AUTO SỐ - RAID + SKILL DÙNG SỐ HẾT
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Settings = {
    AutoEnergyBall = true,  -- Dò số 1-100 để spam skill
    AutoPlayAgain = true,   -- Dò số 1-100 để vào raid
    Godmode = true,
    AutoLockAtom = true,
    FlyHeight = 45,
    ScanMax = 100
}

local allRemotes = {}
local skillRemotes = {}
local raidRemotes = {}
local bv, currentBoss = nil, nil
local currentRaidID = 0
local skillIDs = {} -- Lưu các số spam skill được
local inRaid = false

-- QUÉT TẤT CẢ REMOTE
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        table.insert(allRemotes, v)
        local n = v.Name:lower()
        if string.find(n, "raid") or string.find(n, "teleport") or string.find(n, "join") or string.find(n, "dungeon") then 
            table.insert(raidRemotes, v)
        end
        if string.find(n, "skill") or string.find(n, "attack") or string.find(n, "ability") or string.find(n, "move") or string.find(n, "blast") or string.find(n, "ki") then
            table.insert(skillRemotes, v)
        end
    end
end

-- GUI FULL GIỐNG ẢNH
local Gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
Gui.Name = "DragonBloxV2"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Name = "Main"
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
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Dragon Blox V2 - Full Auto Số"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 189, 68)
MinBtn.Position = UDim2.new(1, -90, 0.5, -7)
MinBtn.Size = UDim2.new(0, 14, 0, 14)
MinBtn.Text = ""
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -7)
CloseBtn.Size = UDim2.new(0, 14, 0, 14)
CloseBtn.Text = ""
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local TabFrame = Instance.new("Frame", Main)
TabFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.Size = UDim2.new(0, 140, 1, -35)

local TabLayout = Instance.new("UIListLayout", TabFrame)
TabLayout.Padding = UDim.new(0, 5)

local Content = Instance.new("ScrollingFrame", Main)
Content.BackgroundColor3 = Color3.fromRGB(25,25,25)
Content.Position = UDim2.new(0, 140, 0, 35)
Content.Size = UDim2.new(1, -140, 1, -35)
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 8)

local function createTab(name, icon)
    local Tab = Instance.new("TextButton", TabFrame)
    Tab.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Tab.Size = UDim2.new(1, -10, 0, 35)
    Tab.Font = Enum.Font.GothamSemibold
    Tab.Text = icon.." "..name
    Tab.TextColor3 = Color3.fromRGB(200,200,200)
    Tab.TextSize = 13
    Tab.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 6)
    return Tab
end

createTab("Main", "🏠")
createTab("Dungeon", "🗡️")
createTab("Farm", "⚔️")
createTab("Setting", "⚙️")

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

local StatusLabel = createLabel("Status: Đang dò số raid 1-100...")
local RaidLabel = createLabel("Raid ID: Chưa tìm thấy")
local SkillLabel = createLabel("Skill ID: Đang dò...")

-- NÚT THU NHỎ
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 550, 0, 35)}):Play()
        TabFrame.Visible = false
        Content.Visible = false
    else
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 550, 0, 350)}):Play()
        task.wait(0.3)
        TabFrame.Visible = true
        Content.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

-- DÒ SỐ RAID 1-100
local function checkInRaid()
    return workspace:FindFirstChild("UnstableGrounds") or workspace:FindFirstChild("Raid") or workspace:FindFirstChild("Dungeon")
end

local function scanRaidNumber()
    if currentRaidID ~= 0 then return currentRaidID end
    StatusLabel.Text = "Status: Brute force số 1-100..."

    for i = 1, Settings.ScanMax do
        if checkInRaid() then
            currentRaidID = i - 1
            RaidLabel.Text = "Raid ID: "..currentRaidID.." ✓"
            return currentRaidID
        end

        -- THỬ TẤT CẢ REMOTE + TẤT CẢ SỐ
        for _, remote in pairs(allRemotes) do
            pcall(function() remote:FireServer(i) end)
            pcall(function() remote:FireServer(i, "Hard") end)
            pcall(function() remote:FireServer("Raid", i) end)
            pcall(function() remote:InvokeServer(i) end)
        end
        task.wait(0.15)
    end

    currentRaidID = 6
    RaidLabel.Text = "Raid ID: 6 (Default)"
    return 6
end

-- DÒ SỐ SKILL 1-100
local function scanSkillNumbers()
    if #skillIDs > 0 then return end
    StatusLabel.Text = "Status: Dò số skill 1-100..."
    
    for i = 1, Settings.ScanMax do
        for _, remote in pairs(allRemotes) do
            -- NẾU FIRE MÀ KHÔNG LỖI THÌ LÀ SKILL
            local success = pcall(function() remote:FireServer(i) end)
            if success then
                table.insert(skillIDs, i)
                SkillLabel.Text = "Skill ID: "..table.concat(skillIDs, ", ")
            end
            pcall(function() remote:FireServer("Skill", i) end)
            pcall(function() remote:FireServer(i, Vector3.new()) end)
        end
        task.wait(0.1)
    end
    
    if #skillIDs == 0 then
        skillIDs = {1, 2, 3, 4, 5} -- Default
        SkillLabel.Text = "Skill ID: 1,2,3,4,5 (Default)"
    end
end

local function joinRaid()
    local id = currentRaidID == 0 and scanRaidNumber() or currentRaidID
    for _, remote in pairs(allRemotes) do
        pcall(function() remote:FireServer(id, "Hard") end)
        pcall(function() remote:FireServer(id) end)
    end
end

local function spamSkills()
    if #skillIDs == 0 then scanSkillNumbers() end
    -- SPAM TẤT CẢ SỐ SKILL TÌM ĐƯỢC
    for _, skillID in pairs(skillIDs) do
        for _, remote in pairs(allRemotes) do
            pcall(function() remote:FireServer(skillID) end)
            pcall(function() remote:FireServer(skillID, Vector3.new()) end)
            pcall(function() remote:FireServer("Skill", skillID) end)
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

-- AUTO CHẠY KHI EXECUTE
spawn(function()
    scanRaidNumber()
    scanSkillNumbers()
    joinRaid()
end)

RunService.Heartbeat:Connect(function()
    local char = Plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    if Settings.AutoPlayAgain and not checkInRaid() then
        inRaid = false
        disableFloat()
        joinRaid()
        task.wait(2)
        return
    end

    if checkInRaid() and not inRaid then
        inRaid = true
        task.wait(1)
        enableFloat()
        currentBoss = lockBoss()
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, Settings.FlyHeight, 0) end
        StatusLabel.Text = "Status: Đang farm raid"
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

    if Settings.AutoLockAtom then
        if not currentBoss or not currentBoss:FindFirstChild("Humanoid") or currentBoss.Humanoid.Health <= 0 then
            currentBoss = lockBoss()
            if not currentBoss then
                inRaid = false
                disableFloat()
                StatusLabel.Text = "Status: Clear raid"
            end
        end
    end

    -- SPAM SKILL BẰNG SỐ
    if Settings.AutoEnergyBall and currentBoss then
        spamSkills()
    end
end)

Plr.CharacterAdded:Connect(function()
    task.wait(3)
    if Settings.AutoPlayAgain then joinRaid() end
end)
