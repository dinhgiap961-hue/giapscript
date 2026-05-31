-- ====================================================================================================
-- ELITE HUB - AUTOMATION MASTER SCRIPT (SYNCED WITH YOUR UI)
-- CẤU TRÚC: HIGH-SPEED EXECUTION (PHỐI HỢP TỪNG KỸ NĂNG)
-- ====================================================================================================

local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [1] HÀM CLICK CHUẨN XÁC VÀO NÚT (SỬ DỤNG FIRECONNECTION)
local function EliteClick(buttonName)
    -- Dựa trên ảnh của bạn, các nút điều khiển nằm trong "ELITE HUB"
    for _, v in pairs(PlayerGui:GetDescendants()) do
        if v:IsA("GuiButton") and v.Name:lower():find(buttonName:lower()) then
            for _, connection in pairs(getconnections(v.MouseButton1Click)) do
                connection:Fire()
            end
        end
    end
end

-- [2] HÀM ĐÁNH KỸ NĂNG (TỰ ĐỘNG BẤM TỪ R1 ĐẾN R6)
local function AutoSkillCycle()
    local skills = {"R1", "R2", "R3", "R4", "R5", "R6"}
    for _, skill in ipairs(skills) do
        VIM:SendKeyEvent(true, Enum.KeyCode[skill], false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode[skill], false, game)
    end
end

-- [3] HỆ THỐNG XỬ LÝ CHÍNH (ĐÚNG NHƯ TRONG VIDEO)
task.spawn(function()
    while task.wait(0.5) do
        -- Đánh kỹ năng liên tục
        AutoSkillCycle()
        
        -- Nếu thấy nút "Leave" hoặc màn hình kết thúc, tự động chọn lại
        EliteClick("Next")
        EliteClick("Replay")
        EliteClick("Start")
    end
end)

-- [4] ĐẢM BẢO TRANSFORM & NÂNG CẤP (DỰA TRÊN ẢNH CỦA BẠN)
task.spawn(function()
    while task.wait(2) do
        -- Tự động bật Transform (L5)
        VIM:SendKeyEvent(true, Enum.KeyCode.L5, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.L5, false, game)
    end
end)

print("ELITE HUB SYNCED - SCRIPT RUNNING...")
