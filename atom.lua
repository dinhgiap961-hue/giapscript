print("[DinhGiap Hub] Kích hoạt Bản Ngầm v18 - Khoảng cách 9.85 Studs!")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH VỊ TRÍ ĐÃ ĐƯỢC ĐỔI THÀNH 9.85 STUDS CHUẨN XÁC
local BOSS_SPAWN_POS = Vector3.new(-431.7525939941406, 1352.32275390625, 93.17485046386719)
local HEIGHT_ABOVE = 9.85 
local lastActionTime = 0
local comboIndex = 1 

-- ĐƯỜNG DẪN REMOTE CHÍNH
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")

-- CÁC THAM SỐ REMOTE TỪ SPY
local SKILL_NAME = "fushi"
local FORM_NAME = "Form"
local PUNCH_COMBO = {"\001", "\002", "\003", "\004"} 

-- Hàm quét tìm Boss
local function findLivingBoss()
    local targetHrp = nil
    local minDistance = 150
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if hrp and humanoid and humanoid.Health > 0 then
                local distance = (hrp.Position - BOSS_SPAWN_POS).Magnitude
                if distance < minDistance then
                    targetHrp = hrp
                    break
                end
            end
        end
    end
    return targetHrp
end

-- VÒNG LẶP CHÍNH: TELEPORT 9.85 STUDS + XẢ REMOTE
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    local myHrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not myHrp or not myHrp.Parent then return end
    
    local bossHrp = findLivingBoss()
    if bossHrp then
        -- Ghim vị trí chính xác cao hơn đầu Boss 9.85 Studs
        myHrp.CFrame = bossHrp.CFrame * CFrame.new(0, HEIGHT_ABOVE, 0)
        myHrp.Velocity = Vector3.new(0, 0, 0)
    else
        myHrp.CFrame = CFrame.new(BOSS_SPAWN_POS.X, BOSS_SPAWN_POS.Y + HEIGHT_ABOVE, BOSS_SPAWN_POS.Z)
        myHrp.Velocity = Vector3.new(0, 0, 0)
    end
    
    -- Tối ưu hóa hoạt ảnh
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                if track.Name ~= "Idle" and track.Name ~= "Animate" then
                    track:Stop(0)
                end
            end
        end
    end
    
    -- Tốc độ xả đòn ngầm (0.05 giây / nhịp)
    local currentTime = tick()
    if currentTime - lastActionTime >= 0.05 then 
        lastActionTime = currentTime
        task.spawn(function()
            -- 1. TỰ ĐỘNG ĐẤM COMBO NGẦM (Mã \001 -> \004)
            local currentPunch = PUNCH_COMBO[comboIndex]
            SkillRemote:FireServer(currentPunch)
            
            comboIndex = comboIndex + 1
            if comboIndex > #PUNCH_COMBO then
                comboIndex = 1
            end
            
            -- 2. TỰ ĐỘNG DÙNG CHIÊU FUSHI NGẦM
            SkillRemote:FireServer(SKILL_NAME)
            
            -- 3. TỰ ĐỘNG TÁI KÍCH HOẠT FORM BIẾN HÌNH
            SkillRemote:FireServer(FORM_NAME)
        end)
    end
end)

-- VÒNG LẶP KHÓA CAMERA VÀO BOSS
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local myHrp = character and character:FindFirstChild("HumanoidRootPart")
    local bossHrp = findLivingBoss()
    
    if myHrp and bossHrp then
        character.Humanoid.AutoRotate = false
        myHrp.CFrame = CFrame.new(myHrp.Position, Vector3.new(bossHrp.Position.X, myHrp.Position.Y, bossHrp.Position.Z))
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, bossHrp.Position)
    else
        if character and character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid.AutoRotate = true
        end
    end
end)
