-- ============================================================================
-- DRAGON BLOX: TARGET LOCK & AUTO SPAM ENGINE (Bản chuẩn)
-- ============================================================================

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- BẢNG CẤU HÌNH (THAY TÊN REMOTE Ở ĐÂY SAU KHI DÙNG SPY)
local REMOTE_NAME = "SkillEvent" -- Cần thay đúng tên sau khi dùng SimpleSpy

-- HÀM TÌM QUÁI GẦN NHẤT (KHÔNG CẦN CHỌN MỤC TIÊU)
local function GetNearestEnemy()
    local nearest = nil
    local shortestDist = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Lọc đối tượng là Quái hoặc Boss (thay tên nếu cần)
        if obj.Name == "Atom" and obj:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = obj
            end
        end
    end
    return nearest
end

-- VÒNG LẶP CHIẾN ĐẤU (Ghim mục tiêu & Spam)
task.spawn(function()
    while task.wait(0.04) do
        pcall(function()
            local target = GetNearestEnemy()
            if target then
                -- 1. Tự động Ghim vị trí (Teleport hoặc xoay mặt về phía quái)
                local hrp = LocalPlayer.Character.HumanoidRootPart
                hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
                
                -- 2. Spam Skill vào Target (Gửi Instance hoặc vị trí)
                local remote = RS:FindFirstChild(REMOTE_NAME)
                if remote then
                    -- Lưu ý: Nhiều game yêu cầu tham số là Vị trí (CFrame/Vector3) hoặc Target
                    remote:FireServer("Energy Ball", target) -- Thêm 'target' làm tham số 2
                    remote:FireServer("Ego", target)         -- để server tự khóa mục tiêu
                end
            end
        end)
    end
end)
