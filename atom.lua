-- Vòng lặp quản lý AutoFarm + Xả đạn x10 + Cưỡng chế ghim mục tiêu (TỐI ƯU TỐC ĐỘ)
task.spawn(function()
    while true do
        if AutoFarmActive then
            local Monster = FindAnyMonster()
            if Monster and Monster:FindFirstChild("HumanoidRootPart") then
                local monsterRoot = Monster.HumanoidRootPart
                local myChar = Player.Character
                
                -- 1. QUÉT & GHIM CỰC NHANH
                -- Dùng luồng chạy song song để không làm nghẽn server
                task.spawn(function()
                    for _, child in pairs(Workspace:GetDescendants()) do
                        -- Điều kiện nhận diện đạn: Phải là Part, không phải người, không phải quái, không phải nền
                        if child:IsA("BasePart") and child.Name ~= "Terrain" and not child:IsDescendantOf(myChar) and not child:IsDescendantOf(Monster.Parent) then
                            if child.Size.Magnitude < 10 and not child:FindFirstChild("AtomPinned") then
                                -- ÉP CẤU HÌNH ĐẠN ĐỂ GHIM ĐƯỢC
                                child.Anchored = false 
                                child.CanCollide = false
                                
                                local marker = Instance.new("BoolValue", child)
                                marker.Name = "AtomPinned"
                                
                                -- Hút đạn về quái tức thì
                                child.CFrame = monsterRoot.CFrame
                                
                                -- Ghim chặt vào quái
                                local weld = Instance.new("WeldConstraint", monsterRoot)
                                weld.Part0 = monsterRoot
                                weld.Part1 = child
                                
                                game:GetService("Debris"):AddItem(child, 2)
                            end
                        end
                    end
                end)
                
                -- 2. XẢ ĐẠN X10 (Dùng loop nhỏ để dồn gói tin)
                if attackRemote then
                    for i = 1, 10 do
                        attackRemote:FireServer(monsterRoot.Position)
                    end
                end
                
                -- 3. PHÁ COOLDOWN
                for _, key in pairs(skillKeys) do
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
                
                -- KHÔNG DÙNG TASK.WAIT ĐỂ ĐẠN RA NHANH NHẤT CÓ THỂ
                RunService.RenderStepped:Wait() 
            else
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
    end
end)
