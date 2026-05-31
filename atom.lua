-- CẤU TRÚC TẤN CÔNG TRỰC TIẾP (Bypass ghim đạn)
task.spawn(function()
    while true do
        if AutoFarmActive then
            local Monster = FindAnyMonster()
            if Monster and Monster:FindFirstChild("HumanoidRootPart") then
                local targetPos = Monster.HumanoidRootPart.Position
                
                -- ĐỘT PHÁ: Bỏ qua việc ghim vật thể, gửi trực tiếp gói tin sát thương
                -- Đây là cách các tool mạnh thường dùng
                if attackRemote then
                    -- Gửi liên tục đến tọa độ của quái, không cần quan tâm viên đạn có bay trúng hay không
                    for i = 1, 5 do
                        attackRemote:FireServer(targetPos) 
                        -- Nếu game yêu cầu thêm thông số, bạn thêm vào đây
                    end
                end
                
                -- Phá cooldown skill để spam liên tục
                for _, key in pairs(skillKeys) do
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
            end
        end
        task.wait(0.05) -- Tốc độ ổn định, tránh bị server "đá" vì quá nhanh
    end
end)
