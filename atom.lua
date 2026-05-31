local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Xóa sạch GUI cũ tránh trùng lặp dữ liệu
local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("AutoBossGui")
if oldGui then oldGui:Destroy() end

-- Khởi tạo ScreenGui
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Screen.Name = "AutoBossGui"
Screen.ResetOnSpawn = false

-- Khung chứa (Frame) - Mở rộng chiều cao lên 270 để chứa đủ các nút
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 160, 0, 270)
MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
MainFrame.BackgroundTransparency = 1

-- NÚT 1: AUTO FARM (Đứng im xả skill ghim vào quái)
local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(1, 0, 0, 50)
FarmBtn.Text = "AUTO FARM: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Font = Enum.Font.SourceSansBold
FarmBtn.TextSize = 16

-- NÚT 2: AUTO BOSS (Tự bay tới Boss + Xả skill siêu tốc x10)
local BossBtn = Instance.new("TextButton", MainFrame)
BossBtn.Size = UDim2.new(1, 0, 0, 50)
BossBtn.Position = UDim2.new(0, 0, 0, 55)
BossBtn.Text = "AUTO BOSS: OFF"
BossBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
BossBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BossBtn.Font = Enum.Font.SourceSansBold
BossBtn.TextSize = 16

-- Các nút phụ trợ màn chơi
local StartBtn = Instance.new("TextButton", MainFrame)
StartBtn.Size = UDim2.new(1, 0, 0, 50)
StartBtn.Position = UDim2.new(0, 0, 0, 110)
StartBtn.Text = "START RAID: OFF"
StartBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 16

local NextBtn = Instance.new("TextButton", MainFrame)
NextBtn.Size = UDim2.new(1, 0, 0, 50)
NextBtn.Position = UDim2.new(0, 0, 0, 165)
NextBtn.Text = "NEXT RAID: OFF"
NextBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.Font = Enum.Font.SourceSansBold
NextBtn.TextSize = 16

local PlayAgainBtn = Instance.new("TextButton", MainFrame)
PlayAgainBtn.Size = UDim2.new(1, 0, 0, 50)
PlayAgainBtn.Position = UDim2.new(0, 0, 0, 220)
PlayAgainBtn.Text = "PLAY AGAIN: OFF"
PlayAgainBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 0)
PlayAgainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayAgainBtn.Font = Enum.Font.SourceSansBold
PlayAgainBtn.TextSize = 16

-- Hệ thống di chuyển Menu bằng cách kéo thả nút AUTO FARM
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
FarmBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
FarmBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- Trạng thái logic
local AutoFarmActive = false
local AutoBossActive = false
local AutoStart = false
local AutoNext = false
local AutoPlayAgain = false

FarmBtn.MouseButton1Click:Connect(function()
    AutoFarmActive = not AutoFarmActive
    if AutoFarmActive then AutoBossActive = false; BossBtn.Text = "AUTO BOSS: OFF"; BossBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) end
    FarmBtn.Text = AutoFarmActive and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = AutoFarmActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

BossBtn.MouseButton1Click:Connect(function()
    AutoBossActive = not AutoBossActive
    if AutoBossActive then AutoFarmActive = false; FarmBtn.Text = "AUTO FARM: OFF"; FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) end
    BossBtn.Text = AutoBossActive and "AUTO BOSS: ON" or "AUTO BOSS: OFF"
    BossBtn.BackgroundColor3 = AutoBossActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

StartBtn.MouseButton1Click:Connect(function()
    AutoStart = not AutoStart
    StartBtn.Text = AutoStart and "START RAID: ON" or "START RAID: OFF"
    StartBtn.BackgroundColor3 = AutoStart and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 100, 0)
end)

NextBtn.MouseButton1Click:Connect(function()
    AutoNext = not AutoNext
    NextBtn.Text = AutoNext and "NEXT RAID: ON" or "NEXT RAID: OFF"
    NextBtn.BackgroundColor3 = AutoNext and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(0, 150, 150)
end)

PlayAgainBtn.MouseButton1Click:Connect(function()
    AutoPlayAgain = not AutoPlayAgain
    PlayAgainBtn.Text = AutoPlayAgain and "PLAY AGAIN: ON" or "PLAY AGAIN: OFF"
    PlayAgainBtn.BackgroundColor3 = AutoPlayAgain and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(120, 120, 0)
end)

-- Quét tìm mục tiêu gần nhất
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

-- Vòng lặp quản lý vị trí (Chỉ hoạt động khi bật AUTO BOSS)
RunService.Heartbeat:Connect(function()
    local Char = Player.Character
    if AutoBossActive then
        local Monster = FindAnyMonster()
        if Monster and Char and Char:FindFirstChild("HumanoidRootPart") then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.PlatformStand = true end
            
            -- AUTO BOSS: Tự động bay lên giữ khoảng cách 35 stud trên đầu Boss
            local TargetPos = Monster.HumanoidRootPart.Position + Vector3.new(0, 35, 0)
            Char.HumanoidRootPart.CFrame = CFrame.new(TargetPos)
            Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        else
            if Char then local Humanoid = Char:FindFirstChildOfClass("Humanoid") if Humanoid then Humanoid.PlatformStand = false end end
        end
    else
        -- Khi tắt Auto Boss hoặc bật Auto Farm thì trả lại trạng thái đứng vật lý bình thường
        if Char then local Humanoid = Char:FindFirstChildOfClass("Humanoid") if Humanoid then Humanoid.PlatformStand = false end end
    end
end)

-- Hàm hỗ trợ xả chiêu (Sử dụng Tool)
local function DischargeSkill()
    local Char = Player.Character
    if Char then
        local Tool = Char:FindFirstChildOfClass("Tool")
        if not Tool and Player:FindFirstChild("Backpack") then
            Tool = Player.Backpack:FindFirstChildOfClass("Tool")
            if Tool then Tool.Parent = Char end
        end
        if Tool then pcall(function() Tool:Activate() end) end
    end
    -- Giả lập bấm phím E xả kỹ năng phụ trợ
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- LUỒNG SPAM CHIÊU THỨC PHÂN TÁCH BIỆT (AUTO FARM VS AUTO BOSS X10)
task.spawn(function()
    while true do
        if AutoBossActive then
            local Monster = FindAnyMonster()
            if Monster then
                -- CHẾ ĐỘ AUTO BOSS: Ép vòng lặp bắn liên tục x10 lần đè lệnh trong 1 chu kỳ ngắn
                for i = 1, 10 do
                    DischargeSkill()
                end
            end
            task.wait(0.05) -- Tốc độ nhồi lệnh tối đa cho chế độ diệt Boss
        elseif AutoFarmActive then
            local Monster = FindAnyMonster()
            if Monster then
                -- CHẾ ĐỘ AUTO FARM: Chỉ đứng yên xả chiêu nhịp nhàng ghim vào quái thường
                DischargeSkill()
            end
            task.wait(0.12) -- Tốc độ farm quái thông thường ổn định thanh Ki
        else
            task.wait(0.2)
        end
    end
end)

-- [Hệ thống Auto Click UI phụ trợ]
local function ClickGuiObject(gui)
    if gui and gui.Visible and gui.AbsoluteSize.X > 0 then
        local x = gui.AbsolutePosition.X + (gui.AbsoluteSize.X / 2)
        local y = gui.AbsolutePosition.Y + (gui.AbsoluteSize.Y / 2) + 36
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        pcall(function() gui:Activate() end)
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
                        prompt:InputHoldBegin(); task.wait(0.02); prompt:InputHoldEnd()
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
                        if not string.find(name, "leave") then ClickGuiObject(gui) end
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
            local foundRewardsFrame = false
            for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextLabel") and gui.Visible and (string.find(string.lower(gui.Text), "rewards") or string.find(string.lower(gui.Text), "cleared")) then
                    foundRewardsFrame = true; break
                end
            end
            if foundRewardsFrame then
                VirtualInputManager:SendMouseButtonEvent(400, 300, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(400, 300, 0, false, game, 1)
                task.wait(0.3)
            end
            for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and gui.Parent ~= MainFrame and gui.Visible then
                    local txt = string.lower(gui.Text)
                    if string.find(txt, "again") or string.find(txt, "play") then ClickGuiObject(gui) end
                end
            end
        end
        task.wait(0.5)
    end
end)
