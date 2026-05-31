-- ============================================================================
-- SCRIPT AUTO COMBAT - TỰ CHỈNH SỬA & KIỂM SOÁT
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. Tự tìm RemoteEvent tấn công (Bạn thay tên "CombatEvent" bằng tên đúng trong game nếu cần)
local CombatRemote = ReplicatedStorage:FindFirstChild("CombatEvent") 

-- 2. Hàm Tấn Công Siêu Tốc
local function FastAttack()
    if CombatRemote then
        -- Gửi lệnh tấn công trực tiếp lên Server
        CombatRemote:FireServer("E") -- Hoặc tên skill bạn muốn dùng
    end
end

-- 3. Vòng lặp tối ưu không gây lag
-- Sử dụng task.spawn để không làm treo giao diện UI
task.spawn(function()
    while true do
        if _G.AutoCombatEnabled then
            FastAttack()
        end
        task.wait(0.01) -- Độ trễ cực thấp để spam nhanh
    end
end)

-- 4. Ví dụ cách tạo UI đơn giản để bật/tắt (Dùng Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("My Custom Auto Combat", "BloodTheme")
local Tab = Window:NewTab("Combat")
local Section = Tab:NewSection("Main Settings")

Section:NewToggle("Enable Fast Attack", "Bật chế độ đánh siêu nhanh", function(state)
    _G.AutoCombatEnabled = state
end)
