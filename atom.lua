-- ============================================================================
-- GUI SIÊU CẤP: ATOM MAX PRO FARMER
-- ============================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow({ Title = "ATOM MAX VIP | Dragon V2", Center = true, AutoShow = true })

local Tab = Window:AddTab("Main Farming")
local Group = Tab:AddLeftGroupbox("Auto Boss")

-- Các biến trạng thái
getgenv().AutoFarm = false

-- Chức năng Ghim & Đánh
Group:AddToggle("AutoBoss", { Text = "Auto Kill Boss Atom Max", Default = false, Callback = function(v)
    getgenv().AutoFarm = v
end })

game:GetService("RunService").Heartbeat:Connect(function()
    if getgenv().AutoFarm then
        local Boss = workspace:FindFirstChild("Atom Max")
        local Char = game.Players.LocalPlayer.Character
        if Boss and Boss:FindFirstChild("HumanoidRootPart") and Char and Char:FindFirstChild("HumanoidRootPart") then
            -- Ghim vị trí
            Char.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
            -- Spam kỹ năng (giả lập phím E)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        end
    end
end)

Library:Notify("Đã nạp GUI VIP thành công!")
