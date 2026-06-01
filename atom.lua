-- DRAGON BLOX V2 - FULL FEATURES V5.0 - UNLOCK ALL + AUTO RAID
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Dragon Blox V2 - BYPASS", "BloodTheme")

local MainTab = Win:NewTab("Main")
local DungeonTab = Win:NewTab("Dungeon★")
local VisualTab = Win:NewTab("Visual")
local MiscTab = Win:NewTab("Misc")

local MainSection = MainTab:NewSection("Combat Features")
local DungeonSection = DungeonTab:NewSection("Dungeon Features")
local VisualSection = VisualTab:NewSection("ESP & Visual")
local MiscSection = MiscTab:NewSection("Misc Features")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- BYPASS ANTI-CHEAT TRƯỚC
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self,...)
    local method = getnamecallmethod()
    if method == "Kick" then return wait(9e9) end
    if method == "SetState" and self == Plr.Character.Humanoid then return end
    return oldNamecall(self,...)
end)

pcall(function()
    setfpscap(999)
    for _,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "AC") then
            rawset(v, "AC", function() return end)
        end
    end
end)

setreadonly(mt, true)

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
end)

-- FUNCTIONS
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
    if not gui then return false end
    local keywords = {"Play Again", "Replay", "Continue", "Next", "Retry", "Again", "Again!", "Exit", "Leave", "Claim", "Reward"}
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            if v.Visible and v.Active then
                for _, key in ipairs(keywords) do
                    if v:IsA("TextButton") and string.find(string.lower(v.Text), string.lower(key)) then
                        pcall(function() firesignal(v.MouseButton1Click) end)
                        pcall(function() firesignal(v.Activated) end)
                        return true
                    end
                    if string.find(string.lower(v.Name), string.lower(key)) then
                        pcall(function() firesignal(v.MouseButton1Click) end)
                        pcall(function() firesignal(v.Activated) end)
                        return true
                    end
                end
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

local function getAllMonsters(range)
    local mobs = {}
    if isDungeonClear() then return mobs end
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return mobs end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 and v.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d <= range then table.insert(mobs, v) end
            end
        end
    end
    return mobs
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

local function getEquippedTool()
    local char = Plr.Character
    if not char then return nil end
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Tool") then return v end
    end
    return nil
end

local function isWeaponEquipped()
    return getEquippedTool() ~= nil
end

local function equipWeapon(slot)
    slot = slot or 1
    pcall(function()
        local char = Plr.Character
        local backpack = Plr:FindFirstChild("Backpack")
        if char and backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.Name:find("Spear") or tool.Name:find("Energy") or slot == 1 then
                        char.Humanoid:EquipTool(tool)
                        task.wait(0.3)
                        return tool
                    end
                end
            end
        end
    end)
    return nil
end

-- TAB MAIN - COMBAT
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
    Plr.CharacterAdded:Connect(function() lockedForm = false; task.wait(8) end)
    while _G.AutoForm do
        local currentForm = isInForm()
        local canPress = (tick() - lastPress) > 8
        if lockedForm and not currentForm and canPress then
            task.wait(0.5)
            if not isInForm() then
                VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                lastPress = tick(); task.wait(3)
            end
        elseif not currentForm and not lockedForm and canPress then
            task.wait(1)
            if not isInForm() then
                VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                lastPress = tick(); lockedForm = true; task.wait(3)
            end
        elseif currentForm then lockedForm = true end
        task.wait(0.3)
    end
end)

MainSection:NewToggle("Auto Equip Spear", "Tự equip Energy Spear +30", function(s)
    _G.AutoEquipSpear = s
    while _G.AutoEquipSpear do
        pcall(function()
            if not isWeaponEquipped() then
                equipWeapon(1)
                task.wait(0.5)
            end
        end)
        task.wait(1)
    end
end)

MainSection:NewButton("Equip Energy Spear", "Bấm tay để equip ngay", function()
    equipWeapon(1)
end)

MainSection:NewToggle("Auto Spam Energy Blast [E]", "Chỉ spam E", function(s)
    _G.AutoEnergyBlast = s
    while _G.AutoEnergyBlast do
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        task.wait(0.15)
    end
end)

MainSection:NewToggle("Auto Lock Skill", "Chỉ ghim skill vào boss", function(s)
    _G.AutoLockSkill = s
    local lockRemote = findRemote("lock") or findRemote("target")
    while _G.AutoLockSkill do
        pcall(function()
            local boss = getMonster()
            if boss and lockRemote then
                lockRemote:FireServer(boss)
            end
        end)
        task.wait(0.5)
    end
end)

MainSection:NewToggle("Auto Bay Cổ Boss", "Bay trên đỉnh đầu boss", function(s)
    _G.AutoBayCo = s
    while _G.AutoBayCo do
        pcall(function()
            local boss = getMonster()
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if boss and hrp then
                hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
                hrp.Velocity = Vector3.new(0,0,0)
            end
        end)
        task.wait(0.1)
    end
end)

MainSection:NewToggle("Auto Phê Pha V2", "Tự giữ C khi ki < 90%", function(s)
    _G.AutoFushi = s
    local charging = false
    while _G.AutoFushi do
        local ki = getKiPercent()
        if ki < 90 and not charging then
            VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game); charging = true
        elseif ki >= 95 and charging then
            VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); charging = false
        end
        task.wait(0.1)
    end
    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
end)

local killAuraRange = 50
MainSection:NewSlider("Kill Aura Range", "Bán kính Kill Aura", 500, 10, function(v)
    killAuraRange = v
end)

MainSection:NewToggle("Kill Aura", "Tự đánh quái xung quanh", function(s)
    _G.KillAura = s
    while _G.KillAura do
        pcall(function()
            local mobs = getAllMonsters(killAuraRange)
            for _, mob in ipairs(mobs) do
                for i = 1, 3 do
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end)
        task.wait(0.1)
    end
end)

-- TAB DUNGEON
local selectedAutoMode = "Strength"
DungeonSection:NewDropdown("Chọn Auto Mode", "Chọn chỉ số để farm", {"Strength", "Energy", "Defense"}, function(currentOption)
    selectedAutoMode = currentOption
end)

local selectedSkill = "Energy Spear"
DungeonSection:NewDropdown("Chọn Kiểu Farm", "Chọn skill để farm", {"Energy Spear", "Energy Blast"}, function(currentOption)
    selectedSkill = currentOption
end)

DungeonSection:NewToggle("Auto Farm", "Farm Spear - BYPASS 100%", function(s)
    _G.AutoFarm = s
    local attackRemotes = {
        findRemote("attack"), findRemote("punch"), findRemote("melee"),
        findRemote("hit"), findRemote("combat"), findRemote("damage"),
        findRemote("skill"), findRemote("ability"), findRemote("weapon")
    }

    while _G.AutoFarm do
        pcall(function()
            local tool = getEquippedTool()
            if not tool then
                tool = equipWeapon(1)
                task.wait(0.5)
            end

            local mob = getMonster()
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")

            if mob and hrp then
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
                hrp.Velocity = Vector3.new(0,0,0)

                if selectedAutoMode == "Strength" or selectedSkill == "Energy Spear" then
                    if tool then
                        for i = 1, 5 do
                            tool:Activate()
                            task.wait(0.05)
                        end
                    end
                    for _, remote in ipairs(attackRemotes) do
                        if remote then
                            pcall(function() remote:FireServer(mob) end)
                            pcall(function() remote:FireServer(mob.HumanoidRootPart) end)
                            pcall(function() remote:FireServer(mob.HumanoidRootPart.Position) end)
                            pcall(function() remote:FireServer("Punch") end)
                            pcall(function() remote:FireServer(1) end)
                        end
                    end
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)

                elseif selectedAutoMode == "Energy" or selectedSkill == "Energy Blast" then
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                elseif selectedAutoMode == "Defense" then
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    task.wait(0.2)
                end
            end
        end)
        task.wait(0.05)
    end
end)

DungeonSection:NewToggle("Auto (Next Area)", "Tự bấm Play Again", function(s)
    _G.AutoNextArea = s
    local playRemotes = {
        findRemote("play"), findRemote("replay"), findRemote("next"),
        findRemote("continue"), findRemote("retry"), findRemote("restart"),
        findRemote("dungeon"), findRemote("start"), findRemote("again")
    }

    while _G.AutoNextArea do
        pcall(function()
            if isDungeonClear() then
                task.wait(1.5)
                clickPlayAgain()
                task.wait(0.5)
                for _, remote in ipairs(playRemotes) do
                    if remote then
                        pcall(function() remote:FireServer() end)
                        pcall(function() remote:FireServer("Next") end)
                        pcall(function() remote:FireServer("Play") end)
                        pcall(function() remote:FireServer("Replay") end)
                        pcall(function() remote:FireServer(true) end)
                        pcall(function() remote:FireServer(1) end)
                    end
                end
                task.wait(5)
            end
        end)
        task.wait(1)
    end
end)

DungeonSection:NewToggle("Auto Raid FULL", "Tự tìm + vào Raid + Farm - 0 cần làm gì", function(s)
    _G.AutoRaidFull = s

    local raidRemotes = {
        findRemote("raid"), findRemote("enter"), findRemote("join"),
        findRemote("portal"), findRemote("teleport"), findRemote("dungeon"),
        findRemote("start"), findRemote("instance")
    }

    while _G.AutoRaidFull do
        pcall(function()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local inRaid = false
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "RaidMap" or v.Name == "DungeonMap" or v.Name == "InstanceMap" then
                    if (v.Position - hrp.Position).Magnitude < 1000 then
                        inRaid = true
                        break
                    end
                end
            end

            if not inRaid then
                local portalFound = false
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("Model") then
                        local name = string.lower(v.Name)
                        if string.find(name, "raid") or string.find(name, "portal") or
                           string.find(name, "dungeon") or string.find(name, "gate") or
                           string.find(name, "enter") or string.find(name, "zone") then

                            portalFound = true
                            local targetCFrame = nil
                            if v:IsA("Model") then
                                local portalPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
                                if portalPart then targetCFrame = portalPart.CFrame end
                            else
                                targetCFrame = v.CFrame
                            end

                            if targetCFrame then
                                hrp.CFrame = targetCFrame * CFrame.new(0, 5, 0)
                                task.wait(0.5)

                                for _, remote in ipairs(raidRemotes) do
                                    if remote then
                                        pcall(function() remote:FireServer() end)
                                        pcall(function() remote:FireServer(v) end)
                                        pcall(function() remote:FireServer(v.Name) end)
                                        pcall(function() remote:FireServer("Raid") end)
                                        pcall(function() remote:FireServer("Enter") end)
                                        pcall(function() remote:FireServer(1) end)
                                        pcall(function() remote:FireServer(true) end)
                                    end
                                end
                                        
                                for _, prompt in ipairs(workspace:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") and (prompt.Parent.Position - hrp.Position).Magnitude < 20 then
                                        pcall(function() fireproximityprompt(prompt) end)
                                    end
                                end
                                
                                task.wait(3) -- Đợi tele
                                break
                            end
                        end
                    end
                end
                
                -- Nếu không thấy portal thì spam remote tạo raid
                if not portalFound then
                    for _, remote in ipairs(raidRemotes) do
                        if remote then
                            pcall(function() remote:FireServer("Create") end)
                            pcall(function() remote:FireServer("Start") end)
                            pcall(function() remote:FireServer("Solo") end)
                        end
                    end
                    task.wait(2)
                end

            -- 2. Ở TRONG RAID RỒI -> FARM
            else
                local boss = getMonster()
                if boss then
                    hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
                    hrp.Velocity = Vector3.new(0,0,0)
                    
                    local tool = getEquippedTool()
                    if not tool then tool = equipWeapon(1) end
                    
                    -- Spam Spear 100%
                    if tool then
                        for i = 1, 8 do
                            tool:Activate()
                            task.wait(0.03)
                        end
                    end
                    
                    -- Spam remote damage
                    local dmgRemote = findRemote("damage") or findRemote("attack") or findRemote("skill")
                    if dmgRemote then
                        for i = 1, 5 do
                            pcall(function() dmgRemote:FireServer(boss) end)
                            pcall(function() dmgRemote:FireServer(boss.HumanoidRootPart) end)
                        end
                    end
                else
                    clickPlayAgain()
                    task.wait(2)
                end
            end
        end)
        task.wait(0.3)
    end
end)

DungeonSection:NewToggle("Godmode V2", "Bất tử - BYPASS", function(s)
    _G.Godmode = s
    while _G.Godmode do
        pcall(function()
            local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end)
        task.wait()
    end
end)

-- TAB VISUAL - ESP
VisualSection:NewToggle("ESP Boss", "Nhìn thấy boss qua tường", function(s)
    _G.ESPBoss = s
    while _G.ESPBoss do
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if v.Humanoid.Health > 0 and v.Name ~= Plr.Name then
                        if not v:FindFirstChild("ESP_Highlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP_Highlight"
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.Parent = v
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:FindFirstChild("ESP_Highlight") then
            v.ESP_Highlight:Destroy()
        end
    end
end)

VisualSection:NewToggle("ESP Player", "Nhìn thấy người chơi khác", function(s)
    _G.ESPPlayer = s
    while _G.ESPPlayer do
        pcall(function()
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Plr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not player.Character:FindFirstChild("ESP_Player") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Player"
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.7
                        highlight.Parent = player.Character
                    end
                end
            end
        end)
        task.wait(1)
    end
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ESP_Player") then
            player.Character.ESP_Player:Destroy()
        end
    end
end)

VisualSection:NewToggle("Fullbright", "Sáng toàn map", function(s)
    _G.Fullbright = s
    if s then
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        for _,v in pairs(lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                v:Destroy()
            end
        end
    end
end)

-- TAB MISC
local Noclip = nil
local function NoclipLoop()
    if Plr.Character then
        for _, part in pairs(Plr.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end

MiscSection:NewToggle("Noclip", "Xuyên tường", function(s)
    if s then
        Noclip = RunService.Stepped:Connect(NoclipLoop)
    else
        if Noclip then Noclip:Disconnect() end
    end
end)

MiscSection:NewToggle("Anti AFK", "Chống bị kick AFK", function(s)
    _G.AntiAFK = s
    while _G.AntiAFK do
        VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(30)
    end
end)

MiscSection:NewButton("Rejoin Server", "Vào lại server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, Plr)
end)

MiscSection:NewButton("Server Hop", "Đổi server khác", function()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/".. game.PlaceId.. "/servers/Public?sortOrder=Desc&limit=100")
    local data = game:GetService("HttpService"):JSONDecode(req)
    for _, v in pairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            table.insert(servers, v.id)
        end
    end
    if #servers > 0 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Plr)
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Server Hop";
            Text = "Không tìm thấy server nào khác!";
            Duration = 3;
        })
    end
end)

MiscSection:NewButton("Copy Discord", "Copy link Discord", function()
    setclipboard("https://discord.gg/dragonblox")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Discord";
        Text = "Đã copy link Discord!";
        Duration = 3;
    })
end)

MiscSection:NewButton("Destroy GUI", "Xóa menu", function()
    Kavo:DestroyUI()
    if CoreGui:FindFirstChild("AtomToggle") then
        CoreGui.AtomToggle:Destroy()
    end
end)

Plr.Idled:Connect(function()
    if _G.AntiAFK then return end
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Dragon Blox V5.0 BYPASS";
    Text = "Đã phá hết anti-cheat! Auto Raid FULL hoạt động";
    Duration = 5;
})
