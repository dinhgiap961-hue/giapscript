local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Khử GUI cũ
local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("PremiumAutoBossGui")
if oldGui then oldGui:Destroy() end

-- Khởi tạo ScreenGui
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Screen.Name = "PremiumAutoBossGui"
Screen.ResetOnSpawn = false

-- =======================================================
-- GIAO DIỆN CHÍNH (MAIN FRAME)
-- =======================================================
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 220, 0, 240)
MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Màu nền tối sâu
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12) -- Bo góc mịn

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 170, 255) -- Viền sáng Neon Xanh dương
MainStroke.Thickness = 1.5

-- Thanh Tiêu Đề (Title Bar)
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0

local TitleBarCorner = Instance.new("UICorner", TitleBar)
TitleBarCorner.CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "PREMIUM HUB"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

-- Nút Thu Nhỏ (Minimize Button)
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.83, 0, 0.12, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BackgroundTransparency = 1

-- Khu vực chứa các nút chức năng (Container)
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1

-- Hàm tạo Nút bấm Đẹp mắt (Custom Button Creator)
local function CreatePremiumButton(name, text, pos, color)
    local Btn = Instance.new("TextButton", Container)
    Btn.Name = name
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.Position = pos
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Btn.BackgroundColor3 = color
    Btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner", Btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    -- Hiệu ứng Hover chuột
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    return Btn
end

-- Khởi tạo 3 nút bấm cực chất
local AutoBtn = CreatePremiumButton("AutoBtn", "🔴 AUTO BOSS: OFF", UDim2.new(0, 0, 0, 0), Color3.fromRGB(230, 50, 50))
local LockBtn = CreatePremiumButton("LockBtn", "🎯 LOCK: ALL (ATOM/MAX)", UDim2.new(0, 0, 0, 55), Color3.fromRGB(45, 45, 60))
local AuraBtn = CreatePremiumButton("AuraBtn", "⚡ KILL AURA: OFF", UDim2.new(0, 0, 0, 110), Color3.fromRGB(230, 50, 50))

-- =======================================================
-- HỆ THỐNG KÉO THẢ MENU (SMOOTH DRAG)
-- =======================================================
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.1), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Thu nhỏ / Mở rộng mượt mà
local IsMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    local targetSize = IsMinimized and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 240)
    MinBtn.Text = IsMinimized and "+" or "-"
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- =======================================================
-- LOGIC HOẠT ĐỘNG (LOGIC CODES)
-- =======================================================
local Active = false
local LockMode = "ALL" -- ALL, ATOM, MAX
local AuraActive = false
local KillAuraRange = 25

-- Bật/Tắt Auto Boss
AutoBtn.MouseButton1Click:Connect(function()
    Active = not Active
    AutoBtn.Text = Active and "🟢 AUTO BOSS: ON" or "🔴 AUTO BOSS: OFF"
    TweenService:Create(AutoBtn, TweenInfo.new(0.3), {BackgroundColor3 = Active and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(230, 50, 50)}):Play()
end)

-- Bật/Tắt Kill Aura độc lập
AuraBtn.MouseButton1Click:Connect(function()
    AuraActive = not AuraActive
    AuraBtn.Text = AuraActive and "⚡ KILL AURA: ON" or "⚡ KILL AURA: OFF"
    TweenService:Create(AuraBtn, TweenInfo.new(0.3), {BackgroundColor3 = AuraActive and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(230, 50, 50)}):Play()
end)

-- Đổi chế độ Khóa mục tiêu
LockBtn.MouseButton1Click:Connect(function()
    if LockMode == "ALL" then
        LockMode = "ATOM"
        LockBtn.Text = "⚛️ LOCK: ATOM ONLY"
        TweenService:Create(LockBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 100, 220)}):Play()
    elseif LockMode == "ATOM" then
        LockMode = "MAX"
        LockBtn.Text = "🚀 LOCK: MAX ONLY"
        TweenService:Create(LockBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 0, 180)}):Play()
    else
        LockMode = "ALL"
        LockBtn.Text = "🎯 LOCK: ALL (ATOM/MAX)"
        TweenService:Create(LockBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}):Play()
    end
end)

-- Hàm quét sâu tìm Boss
local function FindBossDeep()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
            local nameLower = string.lower(v.Name)
            if LockMode == "ATOM" and string.find(nameLower, "atom") then return v
            elseif LockMode == "MAX" and string.find(nameLower, "max") then return v
            elseif LockMode == "ALL" and (string.find(nameLower, "atom") or string.find(nameLower, "max")) then return v end
        end
    end
    return nil
end

-- Vòng lặp Dịch Chuyển Gầm Đầu
RunService.Heartbeat:Connect(function()
    local Char = Player.Character
    if Active and Char and Char:FindFirstChild("HumanoidRootPart") then
        local Boss = FindBossDeep()
        if Boss and Boss:FindFirstChild("HumanoidRootPart") then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.PlatformStand = true end
            
            local TargetPos = Boss.HumanoidRootPart.Position + Vector3.new(0, 13, 0)
            Char.HumanoidRootPart.CFrame = CFrame.new(TargetPos, Boss.HumanoidRootPart.Position)
            Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            return
        end
    end
    
    -- Trả lại trạng thái đứng bình thường nếu tắt hoặc không có boss
    if Char then
        local Humanoid = Char:FindFirstChildOfClass("Humanoid")
        if Humanoid then Humanoid.PlatformStand = false end
    end
end)

-- Vòng lặp Kill Aura (Chém tự động siêu mượt)
task.spawn(function()
    while true do
        if AuraActive then
            local Char = Player.Character
            if Char and Char:FindFirstChild("HumanoidRootPart") then
                local Tool = Char:FindFirstChildOfClass("Tool")
                if Tool then
                    local Boss = FindBossDeep()
                    if Boss and Boss:FindFirstChild("HumanoidRootPart") then
                        local Distance = (Char.HumanoidRootPart.Position - Boss.HumanoidRootPart.Position).Magnitude
                        if Distance <= KillAuraRange then
                            Tool:Activate()
                        end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end)
