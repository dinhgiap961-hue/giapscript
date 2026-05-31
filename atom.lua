local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Reset GUI cũ nếu có
local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("AutoBossGui")
if oldGui then oldGui:Destroy() end

-- Khởi tạo ScreenGui
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Screen.Name = "AutoBossGui"
Screen.ResetOnSpawn = false

-- Khung chứa (Frame) để quản lý việc kéo thả
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 160, 0, 105)
MainFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
MainFrame.BackgroundTransparency = 1

-- Nút Auto Boss
local Btn = Instance.new("TextButton", MainFrame)
Btn.Size = UDim2.new(1, 0, 0, 50)
Btn.Position = UDim2.new(0, 0, 0, 0)
Btn.Text = "AUTO BOSS: OFF"
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 16

-- Nút Lock Mục Tiêu (Hỗ trợ cả Atom và Max)
local LockBtn = Instance.new("TextButton", MainFrame)
LockBtn.Size = UDim2.new(1, 0, 0, 50)
LockBtn.Position = UDim2.new(0, 0, 0, 55)
LockBtn.Text = "LOCK: ALL"
LockBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Màu xám (quét hết)
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.SourceSansBold
LockBtn.TextSize = 16

-- Hệ thống kéo thả Menu
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
local LockMode = "ALL" -- Có 3 chế độ: "ALL", "ATOM", "MAX"

-- Sự kiện Click nút Auto Boss
Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "AUTO BOSS: ON" or "AUTO BOSS: OFF"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Sự kiện Click đổi chế độ Lock (ALL -> ATOM -> MAX -> lặp lại)
LockBtn.MouseButton1Click:Connect(function()
    if LockMode == "ALL" then
        LockMode = "ATOM"
        LockBtn.Text = "LOCK: ATOM ONLY"
        LockBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Xanh dương
    elseif LockMode == "ATOM" then
        LockMode = "MAX"
        LockBtn.Text = "LOCK: MAX ONLY"
        LockBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200) -- Màu tím
    else
        LockMode = "ALL"
        LockBtn.Text = "LOCK: ALL (ATOM/MAX)"
        LockBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Xám bình thường
    end
end)

-- HÀM QUÉT SÂU (Xử lý thông minh theo bộ lọc nút bấm)
local function FindBossDeep()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
            local nameLower = string.lower(v.Name)
            
            if LockMode == "ATOM" then
                -- Chỉ tìm Boss có chữ "atom"
                if string.find(nameLower, "atom") then return v end
            elseif LockMode == "MAX" then
                -- Chỉ tìm Boss có chữ "max"
                if string.find(nameLower, "max") then return v end
            else
                -- Chế độ ALL: Tìm bất kỳ con nào xuất hiện trước
                if string.find(nameLower, "atom") or string.find(nameLower, "max") then 
                    return v 
                end
            end
        end
    end
    return nil
end

-- Vòng lặp Dịch Chuyển & Ghim Đầu
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

-- Vòng lặp Spam Phím E
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
