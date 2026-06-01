-- DRAGON BLOX V6.1 - AUTO UNSTABLE GROUNDS HARD BYPASS
local Plr = game:GetService("Players").LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- BYPASS ANTICHEAT
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self,...)
        if getnamecallmethod() == "Kick" then return wait(9e9) end
        return oldNamecall(self,...)
    end)
end)

-- LOAD KAVO UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V6.1 - UG HARD", "DarkTheme")

-- TABS
local MainTab = Window:NewTab("Main")
local RaidTab = Window:NewTab("Raid")
local StatsTab = Window:NewTab("Stats")

local MainSection = MainTab:NewSection("Auto Farm")
local RaidSection = RaidTab:NewSection("Auto Raid")
local StatsSection = StatsTab:NewSection("Auto Stats")

-- FUNCTIONS
local function getMonster()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 then return v end
        end
    end
end

local function getEquippedTool()
    local char = Plr.Character
    if char then return char:FindFirstChildOfClass("Tool") end
end

local function equipWeapon(slot)
    slot = slot or 1
    local char = Plr.Character
    local backpack = Plr:FindFirstChild("Backpack")
    if char and backpack then
        local tool = backpack:GetChildren()[slot]
        if tool and tool:IsA("Tool") then
            char.Humanoid:EquipTool(tool)
            return tool
        end
    end
end

local function findRemote(name)
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") and string.find(string.lower(v.Name), string.lower(name)) then
            return v
        end
    end
end

-- 1. GODMODE V2
MainSection:NewToggle("Godmode V2", "Bất tử 100%", function(s)
    _G.GodV2 = s
    while _G.GodV2 do
        pcall(function()
            local char = Plr.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = char.Humanoid.MaxHealth
            end
        end)
        task.wait()
    end
end)

-- 2. AUTO FORM
MainSection:NewToggle("Auto Form", "Tự biến hình C", function(s)
    _G.AutoForm = s
    while _G.AutoForm do
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
        end)
        task.wait(2)
    end
end)

-- 3. AUTO ATTACK SPEAR
MainSection:NewToggle("Auto Attack Spear", "Spam Spear nhanh", function(s)
    _G.AutoSpear = s
    while _G.AutoSpear do
        pcall(function()
            local tool = getEquippedTool()
            if tool then
                for i = 1, 10 do tool:Activate() task.wait(0.02) end
            end
        end)
        task.wait()
    end
end)

-- 4. AUTO UNSTABLE GROUNDS HARD
RaidSection:NewToggle("Auto UG Hard", "Farm Unstable Grounds Hard vô hạn", function(s)
    _G.AutoUGH = s
    local difficulty = "Hard"

    while _G.AutoUGH do
        pcall(function()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local gui = Plr:FindFirstChild("PlayerGui")
            if not hrp or not gui then return end

            local dungeonUI = nil
            for _, v in pairs(gui:GetDescendants()) do
                if v.Name == "Dungeons" or v.Name == "DungeonGui" then
                    dungeonUI = v
                    break
                end
            end

            -- Ở LOBBY -> CHỌN UG HARD + START
            if dungeonUI and dungeonUI:FindFirstChild("ScrollingFrame") then
                -- Chọn Unstable Grounds
                for _, mapBtn in pairs(dungeonUI.ScrollingFrame:GetDescendants()) do
                    if mapBtn:IsA("TextButton") or mapBtn:IsA("ImageButton") then
                        local btnText = mapBtn.Text or (mapBtn:FindFirstChild("TextLabel") and mapBtn.TextLabel.Text) or mapBtn.Name
                        if string.find(string.lower(btnText), "unstable grounds") then
                            pcall(function() firesignal(mapBtn.MouseButton1Click) end)
                            pcall(function() firesignal(mapBtn.Activated) end)
                            task.wait(0.5)
                            break
                        end
                    end
                end

                -- Chọn Hard
                for _, diffBtn in pairs(dungeonUI:GetDescendants()) do
                    if diffBtn:IsA("TextButton") and diffBtn.Text == difficulty then
                        pcall(function() firesignal(diffBtn.MouseButton1Click) end)
                        task.wait(0.3)
                        break
                    end
                end

                -- Bấm Start
                for _, startBtn in pairs(dungeonUI:GetDescendants()) do
                    if startBtn:IsA("TextButton") and startBtn.Text == "Start" and startBtn.Visible then
                        pcall(function() firesignal(startBtn.MouseButton1Click) end)
                        task.wait(5)
                        break
                    end
                end

            -- TRONG RAID -> FARM BOSS
            else
                local boss = getMonster()
                if boss then
                    hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
                    hrp.Velocity = Vector3.new(0,0,0)

                    local tool = getEquippedTool() or equipWeapon(1)
                    if tool then
                        for i = 1, 12 do tool:Activate() task.wait(0.015) end
                    end

                    local dmgRemote = findRemote("damage") or findRemote("attack") or findRemote("skill")
                    if dmgRemote then
                        for i = 1, 10 do
                            pcall(function() dmgRemote:FireServer(boss) end)
                            pcall(function() dmgRemote:FireServer(boss.HumanoidRootPart) end)
                        end
                    end
                else
                    -- XONG RAID -> LEAVE
                    for _, v in pairs(gui:GetDescendants()) do
                        if v:IsA("TextButton") and v.Visible then
                            local t = string.lower(v.Text)
                            if t == "leave" or t == "play again" or t == "claim" or t == "continue" then
                                pcall(function() firesignal(v.MouseButton1Click) end)
                                task.wait(3)
                                break
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- 5. AUTO STATS
StatsSection:NewToggle("Auto Melee", "Cộng Melee", function(s)
    _G.AutoMelee = s
    while _G.AutoMelee do
        pcall(function()
            local args = {"Melee", 1}
            for _, v in pairs(RS:GetDescendants()) do
                if v:IsA("RemoteEvent") and string.find(v.Name, "Stat") then
                    v:FireServer(unpack(args))
                end
            end
        end)
        task.wait(0.1)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Dragon Blox V6.1";
    Text = "Bật: Godmode + Auto Form + Auto UG Hard";
    Duration = 5;
})
