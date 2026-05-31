-- ============================================================================
-- DRAGON BLOX: ATOM BOSS PINNER (STATIONARY MODE)
-- ============================================================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local BOSS_NAME = "Atom" -- Kiểm tra lại tên chính xác trong Workspace

RunService.Heartbeat:Connect(function()
    pcall(function()
        local Boss = Workspace:FindFirstChild(BOSS_NAME)
        local Character = LocalPlayer.Character
        
        if Boss and Boss:FindFirstChild("HumanoidRootPart") and Character and Character:FindFirstChild("HumanoidRootPart") then
            -- [GHIM TĨNH]: Luôn giữ nhân vật ở vị trí y = 15 đơn vị trên đầu Boss
            -- CFrame.new(0, 15, 0) tạo vị trí cố định, không di chuyển
            Character.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
            
            -- [SPAM PHÍM E]: Giả lập hành động nhấn phím thật
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end)
end)

print("--- [ATOM PINNER] ĐÃ KHÓA VỊ TRÍ ---")
