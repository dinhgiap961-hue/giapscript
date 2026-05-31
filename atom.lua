local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Reset GUI cũ nếu có
local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("AutoBossGui")
if oldGui then oldGui:Destroy() end

-- Khởi tạo ScreenGui
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Screen.Name = "AutoBossGui"
Screen.ResetOnSpawn = false

-- Khung chứa (Frame) - Đủ cho 5 nút gọn gàng
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 160, 0, 270)
MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
MainFrame.BackgroundTransparency = 1

-- Nút 1: Auto Boss (Gốc)
local Btn = Instance.new("TextButton", MainFrame)
Btn.Size = UDim2.new(1, 0, 0, 50)
Btn.Position = UDim2.new(0, 0, 0, 0)
Btn.Text = "AUTO BOSS: OFF"
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 16

-- Nút 2: Lock Mục Tiêu (Gốc)
local LockBtn = Instance.new("TextButton", MainFrame)
LockBtn.Size = UDim2.new(1, 0, 0, 50)
LockBtn.Position = UDim2.new(0, 0, 0, 55)
LockBtn.Text = "LOCK: ALL"
LockBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.SourceSansBold
LockBtn.TextSize = 16

-- Nút 3: Tự động Start Raid
local StartBtn = Instance.new("TextButton", MainFrame)
StartBtn.Size = UDim2.new(1, 0, 0, 50)
StartBtn.Position = UDim2.new(0, 0, 0, 110)
StartBtn.Text = "START RAID: OFF"
StartBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 16

-- Nút 4: Tự động Next Raid
local NextBtn = Instance.new("TextButton", MainFrame)
NextBtn.Size = UDim2.new(1, 0, 0, 50)
NextBtn.Position = UDim2.new(0, 0, 0, 165)
NextBtn.Text = "NEXT RAID: OFF"
NextBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.Font = Enum.Font.SourceSansBold
NextBtn.TextSize = 16

-- Nút 5: Tự động Play Again
local PlayAgainBtn = Instance.new("TextButton", MainFrame)
PlayAgainBtn.Size = UDim2.new(1, 0, 0, 50)
PlayAgainBtn.Position = UDim2.new(0, 0, 0, 220)
PlayAgainBtn.Text = "PLAY AGAIN: OFF"
PlayAgainBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 0)
PlayAgainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayAgainBtn.Font = Enum.Font.SourceSansBold
PlayAgainBtn.TextSize = 16

-- Hệ thống kéo thả Menu (Giữ nguyên gốc)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Btn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Trạng thái mặc định
local Active = false
local LockMode = "ALL"
local AutoStart = false
local AutoNext = false
local AutoPlayAgain = false

-- Sự kiện Click nút Auto Boss (Giữ nguyên gốc)
Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "AUTO BOSS: ON" or "AUTO BOSS: OFF"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Sự kiện Click đổi chế độ Lock (Giữ nguyên gốc)
LockBtn.MouseButton1Click:Connect(function()
    if LockMode == "ALL" then
        LockMode = "ATOM"
        LockBtn.Text = "LOCK: ATOM ONLY"
        LockBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    elseif LockMode == "ATOM" then
        LockMode = "MAX"
        LockBtn.Text = "LOCK: MAX ONLY"
        LockBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    else
        LockMode = "ALL"
        LockBtn.Text = "LOCK: ALL (ATOM/MAX)"
        LockBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

-- Sự kiện Click nút Start Raid
StartBtn.MouseButton1Click:Connect(function()
    AutoStart = not AutoStart
    StartBtn.Text = AutoStart and "START RAID: ON" or "START RAID: OFF"
    StartBtn.BackgroundColor3 = AutoStart and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 100, 0)
end)

-- Sự kiện Click nút Next Raid
NextBtn.MouseButton1Click:Connect(function()
    AutoNext = not AutoNext
    NextBtn.Text = AutoNext and "NEXT RAID: ON" or "NEXT RAID: OFF"
    NextBtn.BackgroundColor3 = AutoNext and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(0, 150, 150)
end)

-- Sự kiện Click nút Play Again
PlayAgainBtn.MouseButton1Click:Connect(function()
    AutoPlayAgain = not AutoPlayAgain
    PlayAgainBtn.Text = AutoPlayAgain and "PLAY AGAIN: ON" or "PLAY AGAIN: OFF"
    PlayAgainBtn.BackgroundColor3 = AutoPlayAgain and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(120, 120, 0)
end)

-- HÀM QUÉT SÂU BOSS (Giữ nguyên gốc 100%)
local function FindBossDeep()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
            local nameLower = string.lower(v.Name)
            
            if LockMode == "ATOM" then
                if string.find(nameLower, "atom") then return v end
            elseif LockMode == "MAX" then
                if string.find(nameLower, "max") then return v end
            else
                if string.find(nameLower, "atom") or string.find(nameLower, "max") then 
                    return v 
                end
            end
        end
    end
    return nil
end

-- Vòng lặp Dịch Chuyển & Ghim Đầu (Giữ nguyên gốc 100%)
RunService.Heartbeat:Connect(function()
    if Active then
        local Char = Player.Character
        local Boss = FindBossDeep()
        
        if Boss and Char and Char:FindFirstChild("HumanoidRootPart") then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.PlatformStand = true end
            
            local TargetPos = Boss.HumanoidRootPart.Position + Vector3.new(0, 15, 0)
            Char.HumanoidRootPart.CFrame = CFrame.new(TargetPos, Boss.HumanoidRootPart.Position)
            Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        else
            local Char = Player.Character
            if Char then
                local Humanoid = Char:FindFirstChildOfClass("Humanoid")
                if Humanoid then Humanoid.PlatformStand = false end
            end
        end
    else
        local Char = Player.Character
        if Char then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.PlatformStand = false end
        end
    end
end)

-- Vòng lặp Spam Phím E (Giữ nguyên gốc 100%)
task.spawn(function()
    while true do
        if Active then
            local Boss = FindBossDeep()
            if Boss then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
        task.wait(0.2)
    end
end)

-- HÀM ÉP CƠ CHẾ CLICK ẢO VÀO UI (Hỗ trợ gọi kết nối sự kiện trực tiếp không qua tọa độ)
local function ForceClickButton(searchKey)
    for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Parent ~= MainFrame and gui.Visible then
            local txt = string.lower(gui.Text)
            local name = string.lower(gui.Name)
            
            if string.find(txt, searchKey) or string.find(name, searchKey) then
                -- Cách 1: Mô phỏng nhấp chuột ảo theo tọa độ (Dự phòng)
                local x = gui.AbsolutePosition.X + (gui.AbsoluteSize.X / 2)
                local y = gui.AbsolutePosition.Y + (gui.AbsoluteSize.Y / 2) + 36
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                
                -- Cách 2: Ép hệ thống kích hoạt trực tiếp môi trường liên kết nút (Bypass tọa độ)
                pcall(function()
                    gui:Activate() -- Hàm gốc của Roblox kích hoạt sự kiện .Activated
                end)
                
                -- Cách 3: Kích hoạt thông qua giả lập chọn mục tiêu trên GUI của game
                pcall(function()
                    local oldSelected = GuiService.SelectedObject
                    GuiService.SelectedObject = gui
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait(0.02)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    GuiService.SelectedObject = oldSelected
                end)
                return true
            end
        end
    end
    return false
end

-- VÒNG LẶP: TỰ ĐỘNG START RAID TỪ XA VÀ TỰ ĐỘNG
task.spawn(function()
    while true do
        if AutoStart then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    if string.find(string.lower(prompt.ObjectText), "start") or string.find(string.lower(prompt.ActionText), "start") then
                        prompt.MaxActivationDistance = math.huge
                        prompt.RequiresLineOfSight = false
                        
                        -- Đồng bộ cả lệnh gọi hàm trực tiếp và giữ nút ảo từ xa
                        pcall(function()
                            fireproximityprompt(prompt) -- Nếu Executor hỗ trợ hàm này
                        end)
                        prompt:InputHoldBegin()
                        task.wait(0.02)
                        prompt:InputHoldEnd()
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- VÒNG LẶP: TỰ ĐỘNG NEXT RAID (Quét cả chữ "next" và chữ "leave" ở góc trên màn hình)
task.spawn(function()
    while true do
        if AutoNext then
            ForceClickButton("next")
            ForceClickButton("leave")
        end
        task.wait(0.5)
    end
end)

-- VÒNG LẶP: TỰ ĐỘNG PLAY AGAIN (Quét chữ "again" và chữ "play" trên UI màn hình)
task.spawn(function()
    while true do
        if AutoPlayAgain then
            ForceClickButton("again")
            ForceClickButton("play")
        end
        task.wait(0.5)
    end
end)
