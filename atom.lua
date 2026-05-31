-- ============================================================================
-- SCRIPT AUTO: DI CHUYỂN, GHIM ĐẦU VÀ SPAM SKILL E (ĐÃ SỬA LỖI)
-- ============================================================================
local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Tạo nút bấm trên màn hình
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
local Btn = Instance.new("TextButton", Screen)
Btn.Size = UDim2.new(0, 150, 0, 50)
Btn.Position = UDim2.new(0.8, 0, 0.4, 0)
Btn.Text = "AUTO BOSS: OFF"
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

-- Khiến nút có thể kéo thả (Fix thuộc tính Draggable cũ đã bị lỗi thời)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
Btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Btn.Position
    end
end)
Btn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Btn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local Active = false
Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "AUTO BOSS: ON" or "AUTO BOSS: OFF"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- 1. XỬ LÝ DỊCH CHUYỂN VÀ GHIM ĐẦU (Chạy mượt theo khung hình)
RunService.Heartbeat:Connect(function()
    if Active then
        local Char = Player.Character
        local Boss = workspace:FindFirstChild("Atom Max")
        
        if Boss and Boss:FindFirstChild("HumanoidRootPart") and Char and Char:FindFirstChild("HumanoidRootPart") then
            -- Tính toán vị trí trên đầu Boss 15 studs
            local TargetPosition = Boss.HumanoidRootPart.Position + Vector3.new(0, 15, 0)
            
            -- Dịch chuyển và ép nhìn thẳng xuống Boss cùng lúc
            Char.HumanoidRootPart.CFrame = CFrame.new(TargetPosition, Boss.HumanoidRootPart.Position)
            
            -- Tắt vận tốc để nhân vật không bị rơi hoặc rung lắc
            Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 2. XỬ LÝ SPAM PHÍM E (Chạy luồng riêng biệt, không gây lag)
task.spawn(function()
    while true do
        if Active then
            local Boss = workspace:FindFirstChild("Atom Max")
            if Boss and Boss:FindFirstChild("HumanoidRootPart") then
                -- Nhấn phím E
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                -- Thả phím E
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
        task.wait(0.1) -- Khoảng cách giữa các lần spam tuyệt chiêu (Có thể chỉnh lại)
    end
end)
