-- XÓA CÁC GUI CŨ NẾU CÓ ĐỂ TRÁNH TRÙNG LẶP NÚT BẤM
if game:GetService("CoreGui"):FindFirstChild("DinhGiap_System_Gui") then
    game:GetService("CoreGui")["DinhGiap_System_Gui"]:Destroy()
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local window = library.CreateLib("Dragon Blox - DinhGiap Hub v14", "DarkTheme")

-- SỬA LỖI HIỂN THỊ: Khởi tạo chính xác Tab và Section để không bị trống menu
local MainTab = window:NewTab("Auto Farm Boss")
local MainSection = MainTab:NewSection("Cấu Hình Treo Máy")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH TỌA ĐỘ VÀ CHIỀU CAO Ghim Boss
local BOSS_SPAWN_POS = Vector3.new(-431.7525939941406, 1352.32275390625, 93.17485046386719)
local HEIGHT_ABOVE = 9.5 

local AutoFarmBoss = false
local LockSkillActive = false
local lastActionTime = 0
local mainConnection
local lockConnection

-- ĐƯỜNG DẪN REMOTE ĐÃ TÌM ĐƯỢC
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")
local SKILL_NAME = "fushi"
local FORM_NAME = "Form"

-- =========================================================================
-- HỆ THỐNG NÚT BẤM NỔI "DinhGiap" CHUYÊN NGHIỆP TRÊN DI ĐỘNG
-- =========================================================================
library:ToggleKey(Enum.KeyCode.RightControl) -- Đặt phím gốc ẩn hiện menu

local DinhGiapGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local CornerEffect = Instance.new("UICorner")
local StrokeEffect = Instance.new("UIStroke")

DinhGiapGui.Name = "DinhGiap_System_Gui"
DinhGiapGui.Parent = game:GetService("CoreGui")
DinhGiapGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Thiết lập ngoại hình nút bấm nổi DinhGiap
ToggleButton.Name = "MainToggleButton"
ToggleButton.Parent = DinhGiapGui
ToggleButton.Size = UDim2.new(0, 90, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0) -- Xuất hiện ở phía trên góc trái, vừa tầm tay
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.Text = "DinhGiap"
ToggleButton.TextColor3 = Color3.fromRGB(255, 170, 0) -- Chữ màu vàng cam rực rỡ
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Active = true
ToggleButton.Draggable = true -- Hỗ trợ giữ ngón tay kéo đi mọi vị trí trên màn hình

CornerEffect.CornerRadius = UDim.new(0, 10) -- Bo tròn viền góc cực đẹp
CornerEffect.Parent = ToggleButton

StrokeEffect.Thickness = 1.5
StrokeEffect.Color = Color3.fromRGB(255, 170, 0) -- Đường viền neon vàng cam bao quanh nút
StrokeEffect.Parent = ToggleButton

-- Tạo hiệu ứng chuyển màu khi chạm vào nút
ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    task.wait(0.05)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 170, 0)
    
    -- Gọi lệnh đóng/mở giao diện Kavo UI ngầm
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    task.wait(0.01)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)
-- =========================================================================

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

-- VÒNG LẶP CHÍNH KHÓA POSITION & XẢ REMOTE
local function startFarmLoop()
    if mainConnection then mainConnection:Disconnect() end
    mainConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmBoss then
            if mainConnection then mainConnection:Disconnect() end
            return
        end
        local character = LocalPlayer.Character
        local myHrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not myHrp or not myHrp.Parent then return end
        
        local bossHrp = findLivingBoss()
        if bossHrp then
            myHrp.CFrame = bossHrp.CFrame * CFrame.new(0, HEIGHT_ABOVE, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        else
            myHrp.CFrame = CFrame.new(BOSS_SPAWN_POS.X, BOSS_SPAWN_POS.Y + HEIGHT_ABOVE, BOSS_SPAWN_POS.Z)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Chống lag hoạt ảnh ngầm
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
        
        -- Tốc độ xả chiêu ngầm 0.05 giây
        local currentTime = tick()
        if currentTime - lastActionTime >= 0.05 then 
            lastActionTime = currentTime
            task.spawn(function()
                SkillRemote:FireServer(SKILL_NAME)
                SkillRemote:FireServer(FORM_NAME)
            end)
        end
    end)
end

-- VÒNG LẶP LOCK CAMERA HƯỚNG BOSS
local function startLockLoop()
    if lockConnection then lockConnection:Disconnect() end
    lockConnection = RunService.RenderStepped:Connect(function()
        if not LockSkillActive then
            if lockConnection then lockConnection:Disconnect() end
            local character = LocalPlayer.Character
            if character and character:FindFirstChildOfClass("Humanoid") then
                character.Humanoid.AutoRotate = true
            end
            return
        end
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
end

-- ĐƯA CHỨC NĂNG VÀO ĐÚNG ĐỊA CHỈ TAB/SECTION ĐỂ HIỂN THỊ
MainSection:NewToggle("Auto Farm Boss Remote Ultimate", "Teleport ghim Boss, tự động hóa 100% chiêu fushi & Form biến hình ngầm", function(state)
    AutoFarmBoss = state
    if state then
        startFarmLoop()
    else
        if mainConnection then mainConnection:Disconnect() end
    end
end)

MainSection:NewToggle("Lock Skill (Khóa Mục Tiêu)", "Khóa hướng nhìn nhân vật trực diện vào Boss", function(state)
    LockSkillActive = state
    if state then
        startLockLoop()
    else
        if lockConnection then lockConnection:Disconnect() end
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid.AutoRotate = true
        end
    end
end)
