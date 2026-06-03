local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub - Dragon Blox", "BloodTheme")
local Tab = Win:NewTab("Main")
local Section = Tab:NewSection("Dragon Blox")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- NÚT ATOM CỐ ĐỊNH
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
Btn.MouseButton1Click:Connect(function()
    Kavo:ToggleUI()
end)

-- CHO MENU KÉO THẢ
task.spawn(function()
    repeat task.wait() until CoreGui:FindFirstChild("Kavo")
    local KavoUI = CoreGui:FindFirstChild("Kavo")
    if KavoUI and KavoUI:FindFirstChild("MainFrame") then
        local main = KavoUI.MainFrame
        main.Active = true
        main.Draggable = true
    end
end)

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
                return true
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
            if v.Humanoid.Health > 0 and Plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (v.HumanoidRootPart.Position - Plr.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    target = v
                end
            end
        end
    end
    return target
end

local function isInForm()
    local char = Plr.Character
    if not char then return false end
    if string.find(char.Name, "Form") or string.find(char.Name, "SSJ") then return true end
    for _,v in pairs(char:GetChildren()) do
        if v.Name == "Aura" or v.Name == "FormAura" then return true end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _,v in pairs(head:GetChildren()) do
            if v:IsA("ParticleEmitter") or v.Name == "Hair" then return true end
        end
    end
    return false
end

local function HideName()
    local char = Plr.Character or Plr.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum.NameDisplayDistance = 0
    hum.HealthDisplayDistance = 0
    local head = char:WaitForChild("Head")
    for _, v in pairs(head:GetChildren()) do
        if v.Name == "NameTag" or v.Name == "NameBillboard" or v:IsA("BillboardGui") then
            v:Destroy()
        end
    end
    pcall(function()
        hum.DisplayName = " "
    end)
end

-- TỰ ẨN TÊN KHI LOAD
HideName()
Plr.CharacterAdded:Connect(HideName)

-- 1. Spam Energy Blast [E]
Section:NewToggle("Spam Energy Blast [E]", "Tự spam phím E", function(s)
    _G.EB = s
    while _G.EB do
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.05)
    end
end)

-- 2. Auto Click - ĐẤM LIÊN TỤC
Section:NewToggle("Auto Click", "Click chuột trái liên tục", function(s)
    _G.AutoClick = s
    while _G.AutoClick do
        VU:CaptureController()
        VU:ClickButton1(Vector2.new(0, 0))
        task.wait(0.1)
    end
end)

-- 3. Treo Cổ Boss
Section:NewToggle("Treo Cổ Boss", "Clear là đáp đất ngay", function(s)
    _G.Tp = s
    local lastPos = nil
    while _G.Tp do
        pcall(function()
            local t = getMonster()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if t and hrp and hum and not isDungeonClear() then
                if not lastPos then
                    lastPos = hrp.CFrame
                end
                hrp.CFrame = t.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                hrp.Velocity = Vector3.new(0,0,0)
                hum.PlatformStand = true
            else
                if hum then
                    hum.PlatformStand = false
                end
                if lastPos and hrp then
                    hrp.CFrame = lastPos + Vector3.new(0, 3, 0)
                    lastPos = nil
                end
            end
        end)
        task.wait()
    end
    local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end)

-- 4. Auto Form
Section:NewToggle("Auto Form", "Tự bật Form khi có", function(s)
    _G.AutoForm = s
    while _G.AutoForm do
        if not isInForm() then
            VIM:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
        end
        task.wait(1)
    end
end)

-- 5. Lock Skill Q/E/F/R
Section:NewToggle("Lock Skill Q", "Giữ chặt Q để charge", function(s)
    _G.LockQ = s
    if _G.LockQ then
        VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    else
        VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end
end)

Section:NewToggle("Lock Skill E", "Giữ chặt E để charge", function(s)
    _G.LockE = s
    if _G.LockE then
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    else
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end)

Section:NewToggle("Lock Skill F", "Giữ chặt F để charge", function(s)
    _G.LockF = s
    if _G.LockF then
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    else
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end)

Section:NewToggle("Lock Skill R", "Giữ chặt R để charge", function(s)
    _G.LockR = s
    if _G.LockR then
        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
    else
        VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end
end)

-- 6. Auto Combo Skill
Section:NewToggle("Auto Combo Skill", "Spam Q E F R liên tục", function(s)
    _G.AutoCombo = s
    local keys = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.R}
    while _G.AutoCombo do
        for _, key in ipairs(keys) do
            if not _G.AutoCombo then break end
            VIM:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, key, false, game)
            task.wait(0.3)
        end
        task.wait(0.5)
    end
end)

-- 7. God Mode Farm
Section:NewToggle("God Mode Farm", "Đấm + Skill E cùng lúc", function(s)
    _G.GodMode = s
    while _G.GodMode do
        VU:CaptureController()
        VU:ClickButton1(Vector2.new(0, 0))
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.1)
    end
end)

-- 8. Ẩn Tên Nhân Vật
Section:NewToggle("Ẩn Tên Nhân Vật", "Ẩn tên + máu trên đầu", function(s)
    _G.HideName = s
    local char = Plr.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if _G.HideName then
        HideName()
    else
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        hum.NameDisplayDistance = 100
        hum.HealthDisplayDistance = 100
        hum.DisplayName = Plr.DisplayName
    end
end)

-- 9. Anti AFK
Section:NewToggle("Anti AFK", "Chống bị kick AFK", function(s)
    _G.AntiAFK = s
    while _G.AntiAFK do
        VU:CaptureController()
        VU:ClickButton2(Vector2.new(0,0))
        task.wait(60)
    end
end)

-- 10. WalkSpeed + JumpPower
Section:NewSlider("WalkSpeed", "Chỉnh tốc chạy", 500, 16, function(v)
    local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = v
    end
end)

Section:NewSlider("JumpPower", "Chỉnh lực nhảy", 500, 50, function(v)
    local hum = Plr.Character and Plr.Character:FindFirstChild("Humanoid")
    if hum then
        hum.JumpPower = v
    end
end)

-- 11. AUTO DUNGEON V3 - VÀO DUNGEON + BẮT ĐẦU
local DungeonSection = Tab:NewSection("Auto Dungeon")

local function VaoDungeon()
    pcall(function()
        -- Bản thường không có Knit, thử remote khác
        local remote = RS:FindFirstChild("DungeonEvent") or RS:FindFirstChild("StartDungeon")
        if remote then
            remote:FireServer("Start")
        end
    end)
end

local function BamBatDau()
    task.wait(4)
    -- CÁCH 1: FIRE PROXIMITYPROMPT
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
                print("Đã fire ProximityPrompt")
                return true
            end
        end
    end
    -- CÁCH 2: BẤM GUI BUTTON
    for _,gui in pairs(Plr.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and string.lower(gui.Text) == "bắt đầu" then
            local btn = gui:FindFirstAncestorWhichIsA("GuiButton")
            if btn and btn.Visible then
                firesignal(btn.MouseButton1Click)
                print("Đã bấm GUI Button")
                return true
            end
        end
        if gui:IsA("TextButton") and string.lower(gui.Text) == "bắt đầu" then
            firesignal(gui.MouseButton1Click)
            print("Đã bấm TextButton")
            return true
        end
    end
    -- CÁCH 3: GIẢ LẬP BẤM E
    print("Không thấy prompt, giả lập bấm E")
    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    return true
end

DungeonSection:NewButton("AUTO DUNGEON V3", "Tự vào + bắt đầu dungeon", function()
    game.StarterGui:SetCore("SendNotification",{Title="Auto Dungeon",Text="1. Đang vào lobby...",Duration=2})
    VaoDungeon()
    game.StarterGui:SetCore("SendNotification",{Title="Auto Dungeon",Text="2. Đang bấm bắt đầu...",Duration=2})
    local done = BamBatDau()
    if done then
        game.StarterGui:SetCore("SendNotification",{Title="OK",Text="Đã bấm Bắt đầu",Duration=2})
    end
end)

print("Atom Max Hub Loaded - Dragon Blox Thường")
