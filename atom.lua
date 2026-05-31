-- ============================================================================
-- SCRIPT AUTO: DI CHUYỂN, GHIM ĐẦU VÀ SPAM SKILL E
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
Btn.Draggable = true -- Có thể di chuyển nút

local Active = false
Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "AUTO BOSS: ON" or "AUTO BOSS: OFF"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Xử lý hành động
RunService.Heartbeat:Connect(function()
    if Active then
        local Char = Player.Character
        local Boss = workspace:FindFirstChild("Atom Max")
        
        if Boss and Boss:FindFirstChild("HumanoidRootPart") and Char and Char:FindFirstChild("HumanoidRootPart") then
            -- 1. Ghim lên đầu Boss
            Char.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
            
            -- 2. Ép nhân vật nhìn về phía Boss
            Char.HumanoidRootPart.CFrame = CFrame.new(Char.HumanoidRootPart.Position, Boss.HumanoidRootPart.Position)
            
            -- 3. Spam phím E (Skill Energy)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end
end)
