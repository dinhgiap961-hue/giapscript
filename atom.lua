-- CƠ CHẾ TẤN CÔNG SIÊU TỐC ĐỘ (SERVER-SIDE BOMBARDMENT)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Tìm RemoteEvent chuyên dùng để tấn công (Cần thay đổi tên nếu game cập nhật)
local CombatRemote = ReplicatedStorage:FindFirstChild("CombatEvent") or ReplicatedStorage:FindFirstChild("SkillEvent")

getgenv().FastAttack = true -- Bật chế độ tấn công siêu nhanh

task.spawn(function()
    while getgenv().FastAttack do
        pcall(function()
            local target = nil -- Bạn có thể thêm hàm tìm quái gần nhất ở đây
            
            -- Gửi lệnh tấn công liên tục vào máy chủ
            if CombatRemote then
                -- Gửi dữ liệu tấn công trực tiếp, không qua hoạt ảnh phím E
                CombatRemote:FireServer("E", target) 
                CombatRemote:FireServer("Attack", target)
            end
        end)
        -- Tốc độ spam: 0.0000001 giây/lần (Tùy thuộc vào giới hạn của Server)
        task.wait(0.001) 
    end
end)
