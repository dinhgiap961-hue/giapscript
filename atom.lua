-- ============================================================================
-- DRAGON BLOX: INJECTOR ENGINE (PHIÊN BẢN ÉP LỆNH)
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- HÀM ÉP LỆNH VÀO SERVER (DÙNG ĐỂ THỬ TẤT CẢ CÁC KIỂU TRUYỀN DỮ LIỆU)
local function ForceFire(remote, skillName, target)
    pcall(function()
        -- Thử kiểu 1: Truyền tên chiêu + mục tiêu là Instance
        remote:FireServer(skillName, target)
        
        -- Thử kiểu 2: Truyền tên chiêu + tọa độ của mục tiêu (CFrame)
        remote:FireServer(skillName, target.HumanoidRootPart.CFrame)
        
        -- Thử kiểu 3: Truyền tên chiêu + Mouse Position (Một số game bắt buộc dùng cái này)
        remote:FireServer(skillName, target.HumanoidRootPart.Position)
    end)
end

-- VÒNG LẶP CHIẾN ĐẤU CỐT LÕI
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            -- 1. Quét tìm tất cả Remote có tên liên quan đến "Skill" hoặc "Combat"
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name:lower():find("skill") or obj.Name:lower():find("combat")) then
                    
                    -- 2. Quét mục tiêu "Atom"
                    for _, v in pairs(game.Workspace:GetDescendants()) do
                        if v.Name == "Atom" and v:FindFirstChild("HumanoidRootPart") then
                            
                            -- 3. ÉP LỆNH
                            ForceFire(obj, "Energy Ball", v)
                            ForceFire(obj, "Ego", v)
                            
                            -- Ghim nhân vật vào vị trí quái để đảm bảo trúng (nếu cần)
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        end
                    end
                end
            end
        end)
    end
end)
