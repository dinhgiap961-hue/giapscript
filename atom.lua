-- DRAGON BLOX V2 - DÒ SỐ 1-100 TỰ BẤM NÚT RAID
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- TỰ ĐỘNG HẾT - KHÔNG PHÍM
local AUTO_ENERGY = true
local AUTO_PLAY_AGAIN = true
local GODMODE = true
local AUTO_LOCK = true
local FLY_HEIGHT = 45
local SCAN_MAX = 100 -- DÒ TỪ 1-100

local raidRemote, bv, currentBoss = nil, nil, nil
local currentRaidID = 0 -- 0 = chưa tìm thấy
local inRaid = false
local foundNumbers = {} -- Lưu các số vào được raid

-- TÌM TẤT CẢ REMOTE CÓ THỂ LÀ NÚT RAID
local raidRemotes = {}
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        table.insert(raidRemotes, v)
    end
end

game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "AUTO DÒ NÚT RAID",
    Text = "Brute force 1-100...",
    Duration = 5
})

local function checkInRaid()
    return workspace:FindFirstChild("UnstableGrounds")
        or workspace:FindFirstChild("Raid")
        or workspace:FindFirstChild("Dungeon")
        or workspace:FindFirstChild("RaidMap")
end

-- DÒ SỐ 1-100 ĐỂ TÌM NÚT JOIN RAID
local function scanRaidNumber()
    if currentRaidID ~= 0 then return currentRaidID end

    print("Bắt đầu dò số 1-100...")
    for i = 1, SCAN_MAX do -- DÒ 1-100
        if checkInRaid() then
            currentRaidID = i - 1
            table.insert(foundNumbers, currentRaidID)
            print("TÌM THẤY NÚT RAID:", currentRaidID)
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title="TÌM THẤY NÚT",Text="Số: "..currentRaidID,Duration=3
            })
            return currentRaidID
        end

        -- THỬ TẤT CẢ REMOTE + TẤT CẢ SỐ
        for _, remote in pairs(raidRemotes) do
            pcall(function() remote:FireServer(i) end)
            pcall(function() remote:FireServer(i, "Hard") end)
            pcall(function() remote:FireServer(i, "Easy") end)
            pcall(function() remote:FireServer(i, "Nightmare") end)
            pcall(function() remote:FireServer("Raid", i) end)
            pcall(function() remote:FireServer("Join", i) end)
            pcall(function() remote:InvokeServer(i) end)
            pcall(function() remote:InvokeServer(i, "Hard") end)
        end
        task.wait(0.2) -- 0.2s mỗi số để nhanh
    end

    -- NẾU DÒ KHÔNG RA THÌ DÙNG SỐ CŨ
    if #foundNumbers > 0 then
        currentRaidID = foundNumbers[1]
    else
        currentRaidID = 6 -- Default
    end
    return currentRaidID
end

local function joinRaid()
    local id = currentRaidID == 0 and scanRaidNumber() or currentRaidID
    -- THỬ LẠI VỚI ID ĐÃ TÌM ĐƯỢC
    for _, remote in pairs(raidRemotes) do
        pcall(function() remote:FireServer(id, "Hard") end)
        pcall(function() remote:FireServer(id) end)
        pcall(function() remote:InvokeServer(id) end)
    end
end

-- BAY LƠ LỬNG KHÔNG MẤT NÚT
local function enableFloat()
    local char = Plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or bv then return end
    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, 9e9, 0) -- CHỈ KHÓA Y
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

-- SPAM ENERGY BẰNG CÁCH ACTIVATE TOOL
local function spamEnergyBlast()
    local char = Plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")

    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name:lower(), "blast") or string.find(tool.Name:lower(), "energy") or string.find(tool.Name:lower(), "ki")) then
            pcall(function() tool:Activate() end)
            return
        end
    end

    local backpack = Plr:FindFirstChild("Backpack")
    if backpack and hum then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (string.find(tool.Name:lower(), "blast") or string.find(tool.Name:lower(), "energy")) then
                hum:EquipTool(tool)
                task.wait()
                pcall(function() tool:Activate() end)
                return
            end
        end
    end
end

-- CHẠY NGAY - KHÔNG PHÍM
spawn(function()
    scanRaidNumber() -- DÒ SỐ TRƯỚC
    joinRaid()
end)

RunService.Heartbeat:Connect(function()
    local char = Plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    -- AUTO PLAY AGAIN DÒ SỐ 1-100
    if AUTO_PLAY_AGAIN and not checkInRaid() then
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
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, FLY_HEIGHT, 0) end
    end

    if inRaid and bv then bv.Velocity = Vector3.new(0, 0, 0) end
    if hum and GODMODE then hum.Health = hum.MaxHealth hum.MaxHealth = 9e9 end

    if AUTO_ENERGY then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("NumberValue") and (string.find(v.Name:lower(), "cool") or string.find(v.Name:lower(), "cd")) then
                v.Value = 0
            end
            if v:IsA("NumberValue") and string.find(v.Name:lower(), "ki") then
                v.Value = 999999
            end
        end
    end

    if AUTO_LOCK then
        if not currentBoss or not currentBoss:FindFirstChild("Humanoid") or currentBoss.Humanoid.Health <= 0 then
            currentBoss = lockBoss()
            if not currentBoss then
                inRaid = false
                disableFloat()
            end
        end
    end

    if AUTO_ENERGY and currentBoss then
        spamEnergyBlast()
    end
end)

Plr.CharacterAdded:Connect(function()
    task.wait(3)
    if AUTO_PLAY_AGAIN then joinRaid() end
end)
