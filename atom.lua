-- ============================================================================
-- SCRIPT AUTO: GHIM ĐẦU BOSS & SPAM NHIỀU PHÍM (E, R, T, F, G,...)
-- ============================================================================

-- ĐỊNH NGHĨA CÁC PHÍM BẠN MUỐN SPAM (Thêm/Bớt tên phím ở đây)
local SkillsToSpam = {
    Enum.KeyCode.E,
    Enum.KeyCode.R,
    Enum.KeyCode.T,
    Enum.KeyCode.F
    -- Bạn có thể thêm Enum.KeyCode.G, Enum.KeyCode.Z, v.v. vào đây
}

-- [Giữ nguyên phần khai báo biến và GUI như cũ...]
local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- ... (Phần code tạo GUI và Kéo thả nút bạn giữ nguyên từ bản trước) ...
-- (Mình bỏ qua đoạn GUI để code không bị quá dài, bạn cứ chèn tiếp vào dưới)

-- Vòng lặp Spam Skill (Đã nâng cấp để spam nhiều phím)
task.spawn(function()
    while true do
        if Active then -- Biến Active từ nút bấm của bạn
            local Boss = nil
            -- Tìm Boss (Sử dụng hàm quét sâu như bản cũ)
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                    if string.find(string.lower(v.Name), "atom") or string.find(string.lower(v.Name), "max") then
                        Boss = v
                        break
                    end
                end
            end

            -- Nếu thấy Boss thì bắt đầu spam từng phím trong danh sách
            if Boss then
                for _, key in pairs(SkillsToSpam) do
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.05) -- Thời gian giữ phím
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    task.wait(0.05) -- Khoảng nghỉ ngắn giữa các phím
                end
            end
        end
        task.wait(0.2) -- Tổng thời gian chờ sau khi spam hết 1 vòng các phím
    end
end)
