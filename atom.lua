-- ============================================================================
-- DRAGON BLOX V2 - PREMIUM HUB (ATOM MAX ALL-IN-ONE FINAL STANDARD EDITION)
-- ============================================================================

-- 1. KHỞI TẠO HỆ THỐNG VÀ KIỂM TRA KẾT NỐI UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Ultimate Hub", "BloodTheme")

-- Xác định chính xác khung giao diện gốc của Kavo UI để phục vụ nút Atom Max
local KavoMainGui = game:GetService("CoreGui"):FindFirstChild("Dragon Blox V2 | Ultimate Hub") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Dragon Blox V2 | Ultimate Hub")

-- Thông báo khởi chạy hệ thống thành công dưới góc màn hình
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Atom System",
    Text = "Kích hoạt thành công! Bấm nút 'Atom Max' để ẩn hoặc hiện menu.",
    Duration = 5
})

-- Các biến môi trường toàn cục điều khiển vòng lặp
getgenv().AutoFarmMobs = false
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false
getgenv().AutoStatsDestiny = false
getgenv().AutoStatsRebirth = false
getgenv().AntiAFK = true
getgenv().WalkSpeedValue = 16

-- Khởi tạo các dịch vụ hệ thống Roblox cần thiết
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local InputManager = game:GetService("VirtualInputManager")

-- Tự động cập nhật lại Character khi nhân vật bị reset hoặc hồi sinh
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- HỆ THỐNG KIỂM TRA VÀ ĐỊNH VỊ MỤC TIÊU (BOSS/QUÁI) GẦN NHẤT ĐỂ AUTO-AIM
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent ~= Character and v.Health > 0 then
                local targetHrp = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Torso")
                if targetHrp then
                    local distance = (hrp.Position - targetHrp.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = targetHrp
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ============================================================================
-- 🔘 HỆ THỐNG NÚT "ATOM MAX" THU NHỎ / MỞ RỘNG (ĐÃ FIX TÁC DỤNG 100%)
-- ============================================================================
local OpenCloseGui = Instance.new("ScreenGui")
local AtomButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

OpenCloseGui.Name = "AtomMaxToggleUI"
OpenCloseGui.Parent = CoreGui
OpenCloseGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

AtomButton.Name = "AtomMaxButton"
AtomButton.Parent = OpenCloseGui
AtomButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AtomButton.BackgroundTransparency = 0.1
AtomButton.Position = UDim2.new(0.5, -60, 0.1, 0)
AtomButton.Size = UDim2.new(0, 120, 0, 45)
AtomButton.Font = Enum.Font.GothamBold
AtomButton.Text = "Atom Max"
AtomButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AtomButton.TextSize = 16.00
AtomButton.Active = true
AtomButton.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12) 
UICorner.Parent = AtomButton

UIStroke.Parent = AtomButton
UIStroke.Color = Color3.fromRGB(150, 0, 0)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

AtomButton.MouseButton1Click:Connect(function()
    if KavoMainGui then
        KavoMainGui.Enabled = not KavoMainGui.Enabled
    else
        KavoMainGui = CoreGui:FindFirstChild("Dragon Blox V2 | Ultimate Hub") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Dragon Blox V2 | Ultimate Hub")
        if KavoMainGui then KavoMainGui.Enabled = not KavoMainGui.Enabled end
    end
end)


-- ============================================================================
-- TAB 1: MAIN FUNCTION (AUTO AIM LOCK VÀ TỰ ĐỘNG ĐÁNH KHÔNG CẦN NHẤN)
-- ============================================================================
local MainTab = Window:NewTab("Main Script")
local MainSection = MainTab:NewSection("Quản Lý Auto Farm & Boss")

-- Nút kiểm tra trạng thái Boss
MainSection:NewButton("Check Boss Status", "Kiểm tra sự xuất hiện của Boss", function()
    local bossSpawned = workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Boss")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Atom System",
        Text = bossSpawned and "Boss ĐÃ XUẤT HIỆN! Bật Auto ngay." or "Hiện tại chưa có Boss.",
        Duration = 4
    })
end)

-- Nút Reset Nhân Vật Nhanh
MainSection:NewButton("Reset Character Stats", "Đặt lại trạng thái nhân vật tức thì", function()
    if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.Health = 0 end
end)

-- Công tắc Auto Farm Quái Thường (Mobs)
MainSection:NewToggle("Auto Farm Mobs (Level)", "Tự động tiêu diệt quái theo cấp độ", function(state)
    getgenv().AutoFarmMobs = state
    if state then
        task.spawn(function()
            while getgenv().AutoFarmMobs do
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0,0))
                end)
                task.wait(0.05)
            end
        end)
    end
end)

-- Auto Boss V1: Tự bay cao 30 Studs + Khóa Aim cứng hướng thẳng vào Boss + Tự đấm trúng liên tục không cần nhấn
MainSection:NewToggle("Auto Boss V1 (30 Studs + Auto Aim)", "Tự bay cao, tự Aim khóa mục tiêu và tự đấm liên tục", function(state)
    getgenv().AutoBossV1 = state
    
    if state then
        task.spawn(function()
            local bV = Instance.new("BodyVelocity")
            bV.Name = "AtomFlyForce"
            bV.Velocity = Vector3.new(0, 0, 0)
            bV.MaxForce = Vector3.new(0, math.huge, 0)
            
            while getgenv().AutoBossV1 do
                pcall(function()
                    local HRP = Character:FindFirstChild("HumanoidRootPart")
                    local Humanoid = Character:FindFirstChild("Humanoid")
                    
                    if HRP and Humanoid then
                        if not HRP:FindFirstChild("AtomFlyForce") then
                            bV.Parent = HRP
                            HRP.CFrame = HRP.CFrame * CFrame.new(0, 30, 0)
                        end
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                        
                        -- HỆ THỐNG SILENT AIM: Khóa chặt hướng nhân vật và Camera vào Boss gần nhất
                        local target = GetClosestTarget()
                        if target then
                            HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(target.Position.X, target.Position.Y, target.Position.Z))
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
                        end
                    end
                    -- Tự động xả đấm (Không cần người chơi nhấn màn hình)
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.04)
            end
            
            local TargetForce = Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart:FindFirstChild("AtomFlyForce")
            if TargetForce then TargetForce:Destroy() end
            if Character:FindFirstChild("Humanoid") then Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end)
    end
end)

-- Auto Boss V2: Tự động xoay Aim hướng chiêu + Chỉ Spam duy nhất phím E siêu tốc độ, tự trúng 100% không cần nhấn
MainSection:NewToggle("Auto Boss V2 (Auto Aim + Spam phím E)", "Tự động Aim trúng đích và tự Spam duy nhất chiêu E", function(state)
    getgenv().AutoBossV2 = state
    
    if state then
        task.spawn(function()
            while getgenv().AutoBossV2 do
                pcall(function()
                    local HRP = Character:FindFirstChild("HumanoidRootPart")
                    local target = GetClosestTarget()
                    
                    -- HỆ THỐNG SILENT AIM: Tự bẻ hướng chiêu thức bay thẳng vào Boss
                    if HRP and target then
                        HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(target.Position.X, target.Position.Y, target.Position.Z))
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
                    end
                    
                    -- Tự động spam gửi tín hiệu nhấn/nhả phím E kịch khung tốc độ
                    InputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.01)
                    InputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                task.wait(0.03) -- Chu kỳ vòng lặp siêu ngắn giúp phím E được kích hoạt liên tục không ngừng nghỉ
            end
        end)
    end
end)


-- ============================================================================
-- TAB 2: STATS & UPGRADES (TỰ ĐỘNG NÂNG CHỈ SỐ / TRÙNG SINH)
-- ============================================================================
local StatsTab = Window:NewTab("Stats & Rebirth")
local StatsSection = StatsTab:NewSection("Tự Động Nâng Cấp Sức Mạnh")

StatsSection:NewToggle("Enable Auto Rebirth", "Tự động trùng sinh khi đủ điều kiện", function(state)
    getgenv().AutoStatsRebirth = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsRebirth do
                local remote = ReplicatedStorage:FindFirstChild("RebirthEvent") or ReplicatedStorage:FindFirstChild("Rebirth")
                if remote and remote:IsA("RemoteEvent") then remote:FireServer() end
                task.wait(2)
            end
        end)
    end
end)

StatsSection:NewToggle("Auto Upgrade Melee/Damage", "Tự động cộng điểm vào chỉ số tấn công", function(state)
    getgenv().AutoStatsDestiny = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsDestiny do
                local statRemote = ReplicatedStorage:FindFirstChild("StatRemote") or ReplicatedStorage:FindFirstChild("UpgradeStat")
                if statRemote then statRemote:FireServer("Melee", 10) end
                task.wait(0.5)
            end
        end)
    end
end)


-- ============================================================================
-- TAB 3: MISC SYSTEM & TELEPORT (TIỆN ÍCH TỐC ĐỘ DI CHUYỂN)
-- ============================================================================
local MiscTab = Window:NewTab("Utilities & Speed")
local MiscSection = MiscTab:NewSection("Hỗ Trợ Người Chơi")

MiscSection:NewSlider("Custom WalkSpeed", "Thay đổi tốc độ di chuyển của nhân vật", 250, 16, function(s)
    getgenv().WalkSpeedValue = s
end)

task.spawn(function()
    while true do
        if Character and Character:FindFirstChild("Humanoid") then
            if Character.Humanoid.WalkSpeed ~= getgenv().WalkSpeedValue then
                Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
            end
        end
        task.wait(1)
    end
end)


-- ============================================================================
-- TAB 4: SETTINGS SYSTEM (CẤU HÌNH AN TOÀN TREO MÁY ĐÊM)
-- ============================================================================
local SettingsTab = Window:NewTab("System Settings")
local SettingsSection = SettingsTab:NewSection("Cấu Hình Treo Máy Đêm")

SettingsSection:NewToggle("Anti-AFK Connection Protection", "Giữ kết nối liên tục, không sợ bị kích", function(state)
    getgenv().AntiAFK = state
end)

LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

SettingsSection:NewButton("Optimize Graphics (Boost FPS)", "Xóa hiệu ứng kỹ năng thừa để làm mượt game", function()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end)

Library:Init()
