-- ============================================================================
-- SCRIPT GIẢ LẬP GÕ PHÍM (KHÔNG CẦN TÌM REMOTE)
-- ============================================================================
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer

-- Gán phím chiêu thức của bạn ở đây
local SkillKey = Enum.KeyCode.E 

RunService.Heartbeat:Connect(function()
    local Boss = workspace:FindFirstChild("Atom")
    if Boss and Boss:FindFirstChild("HumanoidRootPart") and Player.Character then
        -- 1. Bay thẳng lên đầu
        Player.Character.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
        
        -- 2. Giả lập bấm phím chiêu thức
        VirtualInputManager:SendKeyEvent(true, SkillKey, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, SkillKey, false, game)
    end
end)
