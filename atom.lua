local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- Đổi tên tiêu đề cửa sổ chính thành DinhGiap Hub cho đồng bộ
local window = library.CreateLib("Dragon Blox - DinhGiap Hub v13", "DarkTheme")

local tab = window:NewTab("Auto Farm Boss")
local section = tab:NewSection("Cấu Hình Treo Máy")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH TỌA ĐỘ VÀ CHIỀU CAO
local BOSS_SPAWN_POS = Vector3.new(-431.7525939941406, 1352.32275390625, 93.17485046386719)
local HEIGHT_ABOVE = 9.5 

local AutoFarmBoss = false
local LockSkillActive = false
local lastActionTime = 0
local mainConnection
local lockConnection

-- ĐƯỜNG DẪN REMOTE VÀ CÁC THAM SỐ LẤY TỪ REMOTE SPY
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")
local SKILL_NAME = "fushi"  -- Chiêu thức tấn công của bạn
local FORM_NAME = "Form"    -- Trạng thái biến hình tăng sức mạnh

-- =========================================================================
-- TẠO NÚT BẤM TRÒN "DinhGiap" TRÊN MÀN HÌNH ĐỂ THU NHỎ / MỞ LẠI MENU KAVO
-- =========================================================================
-- Thiết lập phím tắt ẩn/hiện mặc định của Kavo là nút này
library:ToggleKey(Enum.KeyCode.RightControl) 

local ScreenGui = Instance.new("ScreenGui")
local MenuButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- Đặt tên cho GUI tránh bị game quét
ScreenGui.Name = "DinhGiap_Gui_Protected"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Cấu hình thuộc tính nút bấm DinhGiap
MenuButton.Name = "DinhGiapButton"
MenuButton.Parent = ScreenGui
MenuButton.Size = UDim2.new(0, 80, 0, 35) -- Kích thước nút bấm
MenuButton.Position = UDim2.new(0, 15, 0, 15) -- Vị trí nút ở góc trên bên trái màn hình
MenuButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Màu nền xám đen cực ngầu
MenuButton.Text = "DinhGiap"
MenuButton.TextColor3 = Color3.fromRGB(255, 170, 0) -- Màu chữ vàng cam nổi bật
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.TextSize = 16
MenuButton.Active = true
MenuButton.Draggable = true -- Bạn có thể dùng tay kéo nút này đi bất kỳ đâu trên màn hình cho đỡ vướng

UICorner.CornerRadius = UDim.new(0, 8) -- Bo tròn góc nút bấm cho đẹp
UICorner.Parent = MenuButton

-- Xử lý hành động khi ấn vào nút DinhGiap trên màn hình
MenuButton.MouseButton1Click:Connect(function()
    -- Giả lập nhấn phím ẩn/hiện của thư viện Kavo UI để thu nhỏ hoặc mở menu
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    task.wait(0.01)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)
-- =========================================================================

-- Hàm quét tìm Boss gần tọa độ spawn để ghim vị trí
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

-- VÒNG LẶP CHÍNH: TELEPORT + KHÓA ANIMATION + SPAM REMOTE (SKILL & FORM)
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
        
        -- TỰ ĐỘNG KHÓA HOẠT ẢNH CHỐNG LAG VÀ TRÀN BỘ NHỚ
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
        
        -- XẢ HÀM REMOTE SIÊU TỐC ĐỘ (0.05 GIÂY / LẦN)
        local currentTime = tick()
        if currentTime - lastActionTime >= 0.05 then 
            lastActionTime = currentTime
            
            task.spawn(function()
                -- 1. Kích hoạt chiêu thức "fushi" đấm Boss liên tục ngầm
                SkillRemote:FireServer(SKILL_NAME)
                
                -- 2. Kích hoạt trạng thái "Form" tự động vận sức biến hình ngầm
                SkillRemote:FireServer(FORM_NAME)
            end)
        end
    end)
end

-- VÒNG LẶP RIÊNG: KHÓA CAMERA (LOCK SKILL)
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

-- MENU KAVO UI TRÊN DELTA MOBILE
section:NewToggle("Auto Farm Boss Remote Ultimate", "Teleport ghim Boss, tự động hóa 100% chiêu fushi & Form biến hình ngầm", function(state)
    AutoFarmBoss = state
    if state then
        startFarmLoop()
    else
        if mainConnection then mainConnection:Disconnect() end
    end
end)

section:NewToggle("Lock Skill (Khóa Mục Tiêu)", "Khóa hướng nhìn nhân vật trực diện vào Boss", function(state)
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
