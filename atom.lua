-- ============================================================================
-- GUI VIP TỰ CHỦ (KHÔNG CẦN TẢI THƯ VIỆN NGOÀI)
-- ============================================================================
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = true

-- Nút Thu nhỏ/Mở rộng (Nút VIP)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
ToggleBtn.Text = "MENU"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Các biến chức năng
local AutoBoss = false
local AutoSkill = false

-- Hàm tạo nút bấm trong Menu
local function AddButton(name, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0.1 * #MainFrame:GetChildren(), 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.MouseButton1Click:Connect(callback)
end

AddButton("AUTO BOSS (ON/OFF)", function() AutoBoss = not AutoBoss end)
AddButton("AUTO SKILL (ON/OFF)", function() AutoSkill = not AutoSkill end)

-- Vòng lặp chính xử lý logic
RunService.Heartbeat:Connect(function()
    local Char = game.Players.LocalPlayer.Character
    local Boss = workspace:FindFirstChild("Atom Max")
    
    if AutoBoss and Boss and Char then
        Char.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
    end
    
    if AutoSkill and Char then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end)
