local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Khởi tạo các Remote cần thiết
local SkillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillRemote")
local CurrentCamera = Workspace.CurrentCamera

-- Đường dẫn Remote tự động Start Dungeon
local StartDungeonRF = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("DungeonLobbyService")
    :WaitForChild("RF")
    :WaitForChild("StartDungeon")

-- Tìm Remote Interact 
local InteractRemote = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("Interact") 
    or ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillRemote").Parent:FindFirstChild("Interact")

-- Chờ nhân vật load hoàn chỉnh
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:FindFirstChild("Animator")

-- 1. Vô hiệu hóa hoạt ảnh triệt để (Bỏ delay vung tay)
if Animator then Animator.Parent = nil end

-- HOOK BYPASS COOLDOWN CHUẨN
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if self == SkillRemote and method == "FireServer" then
        if args[1] and type(args[1]) == "table" then
            args[1]["Time"] = 0
            args[1]["IsValid"] = true
        end
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- =======================================================
-- LUỒNG THỨ 1: THẦN TỐC TỰ ĐỘNG CHUYỂN RAID LIÊN TỤC (KHÔNG HOÃN)
-- =======================================================
task.spawn(function()
    -- Bật cái là ép qua màn/vào trận mới ngay lập tức
    while true do
        pcall(function()
            -- Spam lệnh bắt đầu Raid trực tiếp lên Server Knit (Bypas thời gian chờ UI)
            StartDungeonRF:InvokeServer()
            
            -- Đồng thời spam lệnh tương tác để nhặt rương / qua màn nhanh khi Boss chết
            if InteractRemote then
                InteractRemote:FireServer(true)
            end
        end)
        task.wait(0.5) -- Tốc độ quét 0.5 giây/lần. Cứ hở ra là game tự động ném ông vào Raid mới!
    end
end)

-- =======================================================
-- LUỒNG THỨ 2: GHIM MẶT BOSS VÀ XẢ SKILL KHÔNG LAG
-- =======================================================
task.spawn(function()
    while true do
        local currentCharacter = LocalPlayer.Character
        if currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
            
            local myHumanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
            local myPos = currentCharacter.HumanoidRootPart.Position
            local targetFound = false
            
            -- Quét nhanh thực thể động trong trận
            local allObjects = workspace:GetDescendants()
            for i = 1, #allObjects do
                local obj = allObjects[i]
                
                if obj:IsA("Model") and obj ~= currentCharacter and obj.Name ~= "Terrain" then
                    local targetHumanoid = obj:FindFirstChildOfClass("Humanoid")
                    
                    if targetHumanoid and targetHumanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                        local hrp = obj:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Đo khoảng cách thực tế (Bỏ qua những con rồng trang trí nền ở quá xa)
                            local distance = (myPos - hrp.Position).Magnitude
                            if distance <= 150 and targetHumanoid.MaxHealth > 100 then
                                
                                targetFound = true
                                
                                if myHumanoid then 
                                    myHumanoid.PlatformStand = true 
                                end
                                
                                -- Đưa vị trí lên tầm trán/mắt Boss cố định
                                local targetFacePos = hrp.Position + (hrp.CFrame.LookVector * 3.5) + Vector3.new(0, 4.5, 0)
                                currentCharacter.HumanoidRootPart.CFrame = CFrame.new(targetFacePos, hrp.Position)
                                currentCharacter.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
                                
                                -- Đồng bộ gói tin SimpleSpy
                                local camCFrame = CurrentCamera.CFrame
                                local targetPos = hrp.Position
                                local customAim = vector.create(targetPos.X, targetPos.Y, targetPos.Z)
                                
                                -- Xả combo đấm + energy bàn thờ không delay
                                task.spawn(function()
                                    SkillRemote:FireServer({
                                        ["Camera"] = camCFrame,  
                                        ["SkillId"] = "1",
                                        ["Began"] = true,
                                        ["CFrame"] = hrp.CFrame, 
                                        ["Aim"] = customAim,  
                                        ["Target"] = obj,        
                                        ["Typ\208\181"] = 1
                                    })
                                    SkillRemote:FireServer({
                                        ["Camera"] = camCFrame,  
                                        ["SkillId"] = "101",
                                        ["Began"] = true,
                                        ["CFrame"] = hrp.CFrame, 
                                        ["Aim"] = customAim,  
                                        ["Target"] = obj,        
                                        ["Typ\208\181"] = 1
                                    })
                                end)
                                break 
                            end
                        end
                    end
                end
            end
            
            -- Hạ cánh an toàn dưới sàn đấu nếu hết sạch quái để chờ game chuyển màn
            if not targetFound then
                if myHumanoid then
                    myHumanoid.PlatformStand = false
                end
                currentCharacter.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
        RunService.Heartbeat:Wait()
    end
end)
