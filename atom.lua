-- DRAGON BLOX V2 FINAL - AUTO PLAY AGAIN DÒ SỐ 1-20
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Settings = {
    AutoEnergyBall = false,
    AutoPlayAgain = false,
    Godmode = false,
    AutoLockAtom = false,
}

local raidRemote, blastRemote, bv, currentBoss = nil, nil, nil, nil
local currentRaidID = 0 -- 0 = chưa dò
local inRaid = false

-- TÌM REMOTE
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        local n = v.Name:lower()
        if string.find(n, "raid") or string.find(n, "teleport") or string.find(n, "join") then raidRemote = v end
        if string.find(n, "blast") or string.find(n, "energy") or string.find(n, "beam") then blastRemote = v end
    end
end

-- GUI
local Gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Dragon Blox V2 - Auto Dò Số Raid"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold

local Content = Instance.new("Frame", Main)
Content.BackgroundColor3 = Color3.fromRGB(25,25,25)
Content.Position = UDim2.new(0, 130, 0, 30)
Content.Size = UDim2.new(1, -130, 1, -30)

local function createToggle(name, pos, callback)
    local Btn = Instance.new("TextButton", Content)
    Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Btn.Position = UDim2.new(0, 10, 0, pos)
    Btn.Size = UDim2.new(1, -20, 0, 30)
    Btn.Text = "   " .. name
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn)
    
    local Check = Instance.new("Frame", Btn)
    Check.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Check.Position = UDim2.new(1, -35, 0.5, -10)
    Check.Size = UDim2.new(0, 20, 0, 20)
    Instance.new("UICorner", Check)
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Check.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60,60,60)
        callback(state)
    end)
end

createToggle("Auto Energy Ball", 10, function(v) Settings.AutoEnergyBall = v end)
createToggle("Auto Play Again [DÒ SỐ 1-20]", 50, function(v) 
    Settings.AutoPlayAgain = v
    if v and currentRaidID == 0 then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="BẮT ĐẦU DÒ",Text="Dò số raid 1-20...",Duration=3})
    end
end)
createToggle("Godmode", 90, function(v) Settings.Godmode = v end)
createToggle("auto lock Atom", 130, function(v) Settings.AutoLockAtom = v end)

-- CHECK ĐÃ VÀO RAID CHƯA
local function checkInRaid()
    return workspace:FindFirstChild("UnstableGrounds") or workspace:FindFirstChild("Raid") or workspace:FindFirstChild("Dungeon")
end

-- DÒ SỐ RAID 1-20
local function scanRaidID()
    if not raidRemote or currentRaidID ~= 0 then return currentRaidID end
    
    for i = 1, 20 do
        if checkInRaid() then 
            currentRaidID = i - 1
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="TÌM THẤY RAID",Text="ID: "..currentRaidID,Duration=3})
            return currentRaidID 
        end
        
        pcall(function() raidRemote:FireServer(i, "Hard") end)
        pcall(function() raidRemote:FireServer(i) end)
        pcall(function() raidRemote:InvokeServer(i, "Hard") end)
        pcall(function() raidRemote:InvokeServer(i) end)
        task.wait(1)
    end
    
    currentRaidID = 6 -- Default nếu dò không ra
    return 6
end

local function joinRaid()
    if raidRemote then
        local id = currentRaidID == 0 and scanRaidID() or currentRaidID
        pcall(function() raidRemote:FireServer(id, "Hard") end)
        pcall(function() raidRemote:FireServer(id) end)
    end
end

-- BAY LƠ LỬNG KHÔNG MẤT NÚT DI CHUYỂN
local function enableFloat()
    local char = Plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or bv then return end
    
    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, 9e9, 0) -- CHỈ KHÓA TRỤC Y
    bv.Parent = hrp
end

local function disableFloat()
    if bv then bv:Destroy() bv = nil end
end

local function lockBoss()
    local maxHP, boss = 0, nil
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.MaxHealth > maxHP then
                maxHP = v.Humanoid.MaxHealth
                boss = v
            end
        end
    end
    return boss
end

-- LOOP
RunService.Heartbeat:Connect(function()
    local char = Plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    -- 1. AUTO PLAY AGAIN DÒ SỐ
    if Settings.AutoPlayAgain and not checkInRaid() then
        inRaid = false
        disableFloat()
        joinRaid() -- TỰ DÒ SỐ 1-20 NẾU CHƯA CÓ ID
        task.wait(3)
        return
    end
    
    -- 2. VÀO RAID -> BAY LÊN
    if checkInRaid() and not inRaid then
        inRaid = true
        task.wait(1)
        enableFloat()
        currentBoss = lockBoss()
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 45, 0) -- Chỉ set 1 lần
        end
    end
    
    -- 3. GIỮ BAY - KHÔNG SET CFRAME NỮA -> KHÔNG MẤT NÚT
    if inRaid and bv then
        bv.Velocity = Vector3.new(0, 0, 0)
    end
    
    -- 4. GODMODE + NO CD
    if hum and Settings.Godmode then hum.Health = hum.MaxHealth end
    if Settings.AutoEnergyBall then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("NumberValue") and (string.find(v.Name:lower(), "cool") or string.find(v.Name:lower(), "cd")) then
                v.Value = 0
            end
            if v:IsA("NumberValue") and string.find(v.Name:lower(), "ki") then
                v.Value = 99999
            end
        end
    end
    
    -- 5. AUTO LOCK + SPAM
    if Settings.AutoLockAtom then
        if not currentBoss or not currentBoss:FindFirstChild("Humanoid") or currentBoss.Humanoid.Health <= 0 then
            currentBoss = lockBoss()
            if not currentBoss then
                inRaid = false
                disableFloat()
            end
        end
    end
    
    if Settings.AutoEnergyBall and blastRemote and currentBoss and currentBoss:FindFirstChild("HumanoidRootPart") then
        blastRemote:FireServer(currentBoss.HumanoidRootPart.Position)
    end
end)

Plr.CharacterAdded:Connect(function()
    task.wait(3)
    if Settings.AutoPlayAgain then joinRaid() end
end)
