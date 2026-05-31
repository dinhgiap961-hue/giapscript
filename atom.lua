-- ============================================================================
-- DRAGON BLOX V2 - V7 (FORCE ATTACK MODE - FIX ĐỨNG IM)
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- HÀM TÌM REMOTE THÔNG MINH
local function GetCombatRemote()
    -- Ưu tiên tìm các tên phổ biến trong Dragon Blox
    local names = {"CombatEvent", "SkillEvent", "Remotes", "Input", "Attack"}
    for _, name in pairs(names) do
        local remote = ReplicatedStorage:FindFirstChild(name, true)
        if remote and remote:IsA("RemoteEvent") then return remote end
    end
    return nil
end

local CombatRemote = GetCombatRemote()

-- TEST KẾT NỐI
if CombatRemote then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Success", Text="Đã tìm thấy Remote: "..CombatRemote.Name, Duration=3})
else
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Error", Text="Không tìm thấy Remote! Vui lòng F9 xem tên Remote.", Duration=5})
end

-- VÒNG LẶP ÉP ĐÁNH (KHÔNG CẦN TARGET VẪN ĐÁNH)
_G.AutoAttack = true 

task.spawn(function()
    while _G.AutoAttack do
        if CombatRemote then
            -- Ép server nhận lệnh tấn công
            pcall(function()
                CombatRemote:FireServer("E") 
                CombatRemote:FireServer("Combat")
            end)
        else
            -- Phụ trợ: Nếu không tìm thấy Remote, dùng phím ảo tốc độ cao
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
        task.wait(0.01) -- Spam nhanh nhất có thể
    end
end)
