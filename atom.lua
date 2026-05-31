local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Xóa sạch GUI cũ tránh trùng lặp dữ liệu
local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("AutoBossGui")
if oldGui then oldGui:Destroy() end

-- Khởi tạo ScreenGui
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Screen.Name = "AutoBossGui"
Screen.ResetOnSpawn = false

-- ==========================================
-- GIAO DIỆN MENU PHẲNG CHỐNG LAG
-- ==========================================
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 180, 0, 320)
MainFrame.Position = UDim2.new(0.8, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(0.75, 0, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Text = "ATOM BYPASS V3"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 15
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

local ToggleSizeBtn = Instance.new("TextButton", TitleBar)
ToggleSizeBtn.Size = UDim2.new(0, 25, 0, 25)
ToggleSizeBtn.Position = UDim2.new(1, -30, 0, 5)
ToggleSizeBtn.Text = "-"
ToggleSizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleSizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleSizeBtn.Font = Enum.Font.SourceSansBold
ToggleSizeBtn.TextSize = 18

local BtnCorner = Instance.new("UICorner", ToggleSizeBtn)
BtnCorner.CornerRadius = UDim.new(0, 5)

local ButtonContainer = Instance.new("Frame", MainFrame)
ButtonContainer.Size = UDim2.new(1, 0, 1, -35)
ButtonContainer.Position = UDim2.new(0, 0, 0, 35)
ButtonContainer.BackgroundTransparency = 1

local function CreateMenuButton(name, text, posIndex, defaultColor)
    local btn = Instance.new("TextButton", ButtonContainer)
    btn.Size = UDim2.new(1, -20, 0, 42)
    btn.Position = UDim2.new(0, 10, 0, 10 + (posIndex * 48))
    btn.Text = text
    btn.BackgroundColor3 = defaultColor
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    return btn
end

local FarmBtn = CreateMenuButton("FarmBtn", "AUTO FARM: OFF", 0, Color3.fromRGB(180, 40, 40))
local BossBtn = CreateMenuButton("BossBtn", "AUTO BOSS: OFF", 1, Color3.fromRGB(180, 40, 40))
local StartBtn = CreateMenuButton("StartBtn", "START RAID: OFF", 2, Color3.fromRGB(200, 100, 0))
local NextBtn = CreateMenuButton("NextBtn", "NEXT RAID: OFF", 3, Color3.fromRGB(0, 140, 140))
local PlayAgainBtn = CreateMenuButton("PlayAgainBtn", "PLAY AGAIN: OFF", 4, Color3.fromRGB(140, 140, 0))

-- Logic ẩn/hiển thị menu
local isMinimized = false
ToggleSizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 180, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        ToggleSizeBtn.Text = "+"
        ButtonContainer.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 180, 0, 320), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        ToggleSizeBtn.Text = "-"
        ButtonContainer.Visible = true
    end
end)

-- Kéo thả UI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- ==========================================
-- HỆ THỐNG LOGIC HOẠT ĐỘNG BYPASS ATOM
-- ==========================================
local AutoFarmActive = false
local AutoBossActive = false
local AutoStart = false
local AutoNext = false
local AutoPlayAgain = false

FarmBtn.MouseButton1Click:Connect(function()
    AutoFarmActive = not AutoFarmActive
    FarmBtn.Text = AutoFarmActive and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = AutoFarmActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(180, 40, 40)
end)

BossBtn.MouseButton1Click:Connect(function()
    AutoBossActive = not AutoBossActive
    BossBtn.Text = AutoBossActive and "AUTO BOSS: ON" or "AUTO BOSS: OFF"
    BossBtn.BackgroundColor3 = AutoBossActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(180, 40, 40)
    if not AutoBossActive then
        local Char = Player.Character
        if Char then local Humn = Char:FindFirstChildOfClass("Humanoid") if Humn then Humn.PlatformStand = false end end
    end
end)

StartBtn.MouseButton1Click:Connect(function()
    AutoStart = not AutoStart
    StartBtn.Text = AutoStart and "START RAID: ON" or "START RAID: OFF"
    StartBtn.BackgroundColor3 = AutoStart and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(200, 100, 0)
end)

NextBtn.MouseButton1Click:Connect(function()
    AutoNext = not AutoNext
    NextBtn.Text = AutoNext and "NEXT RAID: ON" or "NEXT RAID: OFF"
    NextBtn.BackgroundColor3 = AutoNext and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(0, 140, 140)
end)

PlayAgainBtn.MouseButton1Click:Connect(function()
    AutoPlayAgain = not AutoPlayAgain
    PlayAgainBtn.Text = AutoPlayAgain and "PLAY AGAIN: ON" or "PLAY AGAIN: OFF"
    PlayAgainBtn.BackgroundColor3 = AutoPlayAgain and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(140, 140, 0)
end)

local function FindAnyMonster()
    local targetMonster = nil
    local shortestDistance = math.huge
    local myChar = Player.Character
    
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
                if v ~= myChar and not game.Players:GetPlayerFromCharacter(v) then
                    if v:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local distance = (myChar.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            targetMonster = v
                        end
                    end
                end
            end
        end
    end
    return targetMonster
end

-- VÒNG LẶP DỊCH CHUYỂN AN TOÀN QUA MẶT SERVER (HỢP PHÁP HOÁ KHOẢNG CÁCH CHIÊU)
RunService.Heartbeat:Connect(function()
    local Char = Player.Character
    if AutoBossActive or AutoFarmActive then
        local Monster = FindAnyMonster()
        if Monster and Char and Char:FindFirstChild("HumanoidRootPart") then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.PlatformStand = true end
            
            -- Đứng ngay dưới chân của Boss (Cách 5 mét để hợp lệ hóa khoảng cách kiểm tra của Server)
            local TargetPos = Monster.HumanoidRootPart.Position + Vector3.new(0, -5, 0)
            Char.HumanoidRootPart.CFrame = CFrame.new(TargetPos, Monster.HumanoidRootPart.Position)
            Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ====================================================================
-- HỆ THỐNG XẢ ĐÒN ĐỒNG BỘ (VỪA REMOTE VỪA PHÍM ẢO NHẸ)
-- ====================================================================
local attackRemote = ReplicatedStorage:FindFirstChild("Attack", true) or ReplicatedStorage:FindFirstChild("Skill", true) or ReplicatedStorage:FindFirstChild("UseSkill", true)

if setfflag then
    pcall(function() setfflag("UserSkillCooldownBypass", "True") end)
end

local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.E}

task.spawn(function()
    while true do
        if AutoBossActive or AutoFarmActive then
            local Monster = FindAnyMonster()
            if Monster and Monster:FindFirstChild("HumanoidRootPart") then
                local targetPos = Monster.HumanoidRootPart.Position
                
                -- Luồng 1: Bắn Remote lấy vị trí trực diện
                if attackRemote and attackRemote:IsA("RemoteEvent") then
                    attackRemote:FireServer(targetPos)
                    attackRemote:FireServer({["Target"] = Monster, ["Position"] = targetPos})
                end
                
                -- Luồng 2: Nhấp phím nhẹ định kỳ để đánh lừa hệ thống Key Check của Atom Boss
                for i = 1, #skillKeys do
                    VirtualInputManager:SendKeyEvent(true, skillKeys[i], false, game)
                    VirtualInputManager:SendKeyEvent(false, skillKeys[i], false, game)
                end
                
                -- Tốc độ lặp tối ưu
                if AutoBossActive and AutoFarmActive then
                    task.wait(0.01)
                else
                    task.wait(0.03)
                end
            else
                task.wait(0.2)
            end
        else
            task.wait(0.3)
        end
    end
end)

-- ====================================================================
-- CHỨC NĂNG PHỤ TRỢ RAID (CLICK AN TOÀN)
-- ====================================================================
local function SafeActivateButton(gui)
    if gui and gui.Visible and gui.Parent ~= MainFrame then
        pcall(function() gui:Activate() end)
        local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
        for _, eventName in pairs(events) do
            if gui[eventName] then
                pcall(function()
                    for _, connection in pairs(getconnections(gui[eventName])) do
                        connection:Fire()
                    end
                end)
            end
        end
    end
end

task.spawn(function()
    while true do
        if AutoStart then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    if string.find(string.lower(prompt.ObjectText), "start") or string.find(string.lower(prompt.ActionText), "start") then
                        prompt.MaxActivationDistance = math.huge; prompt.RequiresLineOfSight = false
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if AutoNext then
            for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
                if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Parent ~= MainFrame and gui.Visible and gui.AbsolutePosition.Y > 150 then
                    local txt = gui:IsA("TextButton") and string.lower(gui.Text) or ""
                    local name = string.lower(gui.Name)
                    if string.find(txt, "start") or string.find(name, "start") then
                        if not string.find(name, "leave") then SafeActivateButton(gui) end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if AutoPlayAgain then
            for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and gui.Parent ~= MainFrame and gui.Visible then
                    local txt = string.lower(gui.Text)
                    if string.find(txt, "again") or string.find(txt, "play") then 
                        SafeActivateButton(gui) 
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)
