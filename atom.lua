-- PHƯƠNG PHÁP DI CHUYỂN TỰ ĐỘNG (VƯỢT ANTI-CHEAT)
local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Tạo nút
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
local Btn = Instance.new("TextButton", Screen)
Btn.Size = UDim2.new(0, 120, 0, 60)
Btn.Position = UDim2.new(0.8, 0, 0.4, 0)
Btn.Text = "AUTO WALK: OFF"
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

local Active = false
Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "AUTO WALK: ON" or "AUTO WALK: OFF"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Phương pháp di chuyển bằng Humanoid:MoveTo()
RunService.Heartbeat:Connect(function()
    if Active and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local Boss = workspace:FindFirstChild("Atom Max")
        if Boss and Boss:FindFirstChild("HumanoidRootPart") then
            -- Tự động đi tới Boss thay vì dịch chuyển tức thời
            Player.Character.Humanoid:MoveTo(Boss.HumanoidRootPart.Position)
            
            -- Ép dùng chiêu
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end
end)
