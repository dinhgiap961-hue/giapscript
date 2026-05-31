-- SỬ DỤNG PLAYERGUI (VƯỢT RÀO CẤM COREGUI)
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Screen = Instance.new("ScreenGui", PlayerGui)
Screen.Name = "ProMenu"
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Btn = Instance.new("TextButton", Screen)
Btn.Size = UDim2.new(0, 120, 0, 60)
Btn.Position = UDim2.new(0.8, 0, 0.4, 0)
Btn.Text = "AUTO BOSS: OFF"
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Active = true
Btn.Draggable = true -- Có thể kéo thả bằng tay

local Active = false
Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "AUTO BOSS: ON" or "AUTO BOSS: OFF"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Vòng lặp tối ưu không gây lag
game:GetService("RunService").Heartbeat:Connect(function()
    if Active then
        local Boss = workspace:FindFirstChild("Atom Max")
        if Boss and Boss:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
            -- Bấm phím chiêu thức
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        end
    end
end)
