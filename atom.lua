-- AUTO DUNGEON V3 + LOCK BOSS VIP
local Plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- ========= PHẦN DUNGEON V3 GIỮ NGUYÊN =========
local function VaoDungeon()
    pcall(function()
        RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DungeonLobbyService"):WaitForChild("RF"):WaitForChild("StartDungeon"):InvokeServer()
    end)
end

local function BamBatDau()
    task.wait(4)
    for _,prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local text = string.lower(prompt.ActionText..prompt.ObjectText..prompt.Name)
            if string.find(text, "bắt") or string.find(text, "start") then
                if prompt.Parent and prompt.Parent:IsA("BasePart") then
                    Plr.Character.HumanoidRootPart.CFrame = prompt.Parent.CFrame
                    task.wait(0.5)
                end
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                fireproximityprompt(prompt)
                return true
            end
        end
    end
    for _,gui in pairs(Plr.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and string.lower(gui.Text) == "bắt đầu" then
            local btn = gui:FindFirstAncestorWhichIsA("GuiButton")
            if btn and btn.Visible then
                firesignal(btn.MouseButton1Click)
                return true
            end
        end
        if gui:IsA("TextButton") and string.lower(gui.Text) == "bắt đầu" then
            firesignal(gui.MouseButton1Click)
            return true
        end
    end
    VIM:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, "E", false, game)
    return true
end
-- ========= HẾT DUNGEON V3 =========

local AutoLock = false
local AutoSkill = false
local AutoPunch = false
local AutoKi = false
local CurrentTarget = nil

-- GUI
if game.CoreGui:FindFirstChild("AutoDungeonPro") then game.CoreGui.AutoDungeonPro:Destroy() end
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "AutoDungeonPro"

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(0, 180, 0, 200)
Frame.Position = UDim2.new(0, 10, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

local function TaoNut(text, y, color)
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1,-10,0,30)
    Btn.Position = UDim2.new(0,5,0,y)
    Btn.Text = text..": OFF"
    Btn.BackgroundColor3 = color
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.SourceSansBold
    return Btn
end

local DungeonBtn = TaoNut("AUTO DUNGEON V3", 5, Color3.fromRGB(255,100,0))
local LockBtn = TaoNut("AUTO LOCK BOSS", 40, Color3.fromRGB(200,0,200))
local SkillBtn = TaoNut("AUTO SKILL 1234", 75, Color3.fromRGB(0,150,255))
local PunchBtn = TaoNut("AUTO PUNCH", 110, Color3.fromRGB(200,0,0))
local KiBtn = TaoNut("AUTO KI [E]", 145, Color3.fromRGB(0,100,200))

DungeonBtn.MouseButton1Click:Connect(function()
    DungeonBtn.Text = "1. VÀO LOBBY..."
    VaoDungeon()
    DungeonBtn.Text = "2. BẤM BẮT ĐẦU..."
    BamBatDau()
    task.wait(1)
    DungeonBtn.Text = "AUTO DUNGEON V3: DONE"
    DungeonBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
end)

-- 2. AUTO LOCK BOSS VIP - ƯU TIÊN BOSS
local function GetBoss()
    local ganNhat, kc = nil, 1e9
    local boss = nil

    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 and not game.Players:GetPlayerFromCharacter(v) then
                -- ƯU TIÊN 1: Tên có "Boss", "boss", "BOSS"
                if string.find(string.lower(v.Name), "boss") then
                    return v
                end

                -- ƯU TIÊN 2: Máu cao nhất = boss
                if v.Humanoid.MaxHealth > 1000 then
                    if not boss or v.Humanoid.MaxHealth > boss.Humanoid.MaxHealth then
                        boss = v
                    end
                end

                -- ƯU TIÊN 3: Gần nhất
                local mag = (Plr.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if mag < kc and mag < 150 then
                    kc = mag
                    ganNhat = v
                end
            end
        end
    end
    return boss or ganNhat
end

LockBtn.MouseButton1Click:Connect(function()
    AutoLock = not AutoLock
    if AutoLock then
        LockBtn.Text = "AUTO LOCK BOSS: ON"
        LockBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
        task.spawn(function()
            while AutoLock do
                if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                    if not CurrentTarget or not CurrentTarget:FindFirstChild("Humanoid") or CurrentTarget.Humanoid.Health <= 0 then
                        CurrentTarget = GetBoss()
                    end

                    if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") then
                        -- TP sau lưng + nhìn vào boss liên tục
                        local root = Plr.Character.HumanoidRootPart
                        local targetRoot = CurrentTarget.HumanoidRootPart
                        root.CFrame = CFrame.new(targetRoot.Position + targetRoot.CFrame.LookVector * -5, targetRoot.Position)
                    end
                end
                RunService.Heartbeat:Wait() -- Lock mỗi frame cho mượt
            end
        end)
    else
        LockBtn.Text = "AUTO LOCK BOSS: OFF"
        LockBtn.BackgroundColor3 = Color3.fromRGB(200,0,200)
        CurrentTarget = nil
        end
