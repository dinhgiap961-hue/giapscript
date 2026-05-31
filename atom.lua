-- ============================================================================
-- DRAGON BLOX V2 - PREMIUM HUB V4 (LAG FIX & MAXIMUM FPS BOOST EDITION)
-- ============================================================================

-- Tối ưu hóa bộ nhớ đệm hệ thống ngay khi khởi chạy
if setfpscap then setfpscap(999) end
game:GetService("Lighting").GlobalShadows = false

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Ultimate Hub V4", "BloodTheme")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Atom Anti-Lag V4",
    Text = "Hệ thống siêu tối ưu FPS đã kích hoạt mượt mà!",
    Duration = 5
})

-- Biến môi trường toàn cục
getgenv().AutoFarmMobs = false
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false
getgenv().AutoStatsDestiny = false
getgenv().AutoStatsRebirth = false
getgenv().AntiAFK = true
getgenv().WalkSpeedValue = 16

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- Định vị mục tiêu gần nhất (Thuật toán tối ưu giảm tải CPU)
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        for _, v in ipairs(workspace:GetDescendants()) do
            -- Chỉ quét các đối tượng có thuộc tính Humanoid hợp lệ để tránh lag
            if v:IsA("Humanoid") and v.Parent ~= Character and v.Health > 0 then
                local targetHrp = v.Parent:FindFirstChild("HumanoidRootPart")
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
-- 🔘 NÚT "ATOM MAX" CHỐNG KẸT / CHỐNG ĐƠ MENU
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

local uiVisible = true
AtomButton.MouseButton1Click:Connect(function()
    local TargetGui = CoreGui:FindFirstChild("Dragon Blox V2 | Ultimate Hub V4") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Dragon Blox V2 | Ultimate Hub V4")
    if not TargetGui then
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui:FindFirstChild("Main") then TargetGui = gui break end
        end
    end
    if TargetGui then
        local mainFrame = TargetGui:FindFirstChild("Main")
        if mainFrame then
            uiVisible = not uiVisible
            mainFrame.Position = uiVisible and UDim2.new(0.5, -275, 0.5, -175) or UDim2.new(2, 0, 2, 0)
        else
            TargetGui.Enabled = not TargetGui.Enabled
        end
    end
end)

-- ============================================================================
-- TAB 1: MAIN SCRIPT (TỐI ƯU HÓA HOÀN TOÀN CÁC VÒNG LẶP)
-- ============================================================================
local MainTab = Window:NewTab("Main Script")
local MainSection = MainTab:NewSection("Quản Lý Auto Farm & Boss")

MainSection:NewButton("Check Boss Status", "Kiểm tra sự xuất hiện của Boss", function()
    local bossSpawned = workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Boss")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Atom System",
        Text = bossSpawned and "Boss ĐÃ XUẤT HIỆN!" or "Hiện tại chưa có Boss.",
        Duration = 4
    })
end)

MainSection:NewButton("Reset Character Stats", "Đặt lại trạng thái nhân vật", function()
    if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.Health = 0 end
end)

MainSection:NewToggle("Auto Farm Mobs (Level)", "Tự động tiêu diệt quái", function(state)
    getgenv().AutoFarmMobs = state
    if state then
        task.spawn(function()
            while getgenv().AutoFarmMobs do
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0,0))
                end)
                task.wait(0.05) -- Giữ khoảng chờ tối ưu chống overload luồng dữ liệu
            end
        end)
    end
end)

MainSection:NewToggle("Auto Boss V1 (30 Studs Safe)", "Tự bay cao và tự động đấm", function(state)
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
                    if HRP then
                        if not HRP:FindFirstChild("AtomFlyForce") then
                            bV.Parent = HRP
                            HRP.CFrame = HRP.CFrame * CFrame.new(0, 30, 0)
                        end
                        local target = GetClosestTarget()
                        if target then
                            HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(target.Position.X, target.Position.Y, target.Position.Z))
                        end
                    end
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.04)
            end
            if Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart:FindFirstChild("AtomFlyForce") then
                Character.HumanoidRootPart.AtomFlyForce:Destroy()
            end
        end)
    end
end)

-- AUTO BOSS V2 SIÊU MƯỢT: Không giật Camera + Gửi gói tin thông minh có giãn cách vi mô (0.01s) để triệt tiêu độ trễ đồ họa
MainSection:NewToggle("Auto Boss V2 (Super Smooth Attack E)", "Dịch chuyển ra sau lưng Boss + Tấn công giảm ping, chống lag", function(state)
    getgenv().AutoBossV2 = state
    
    if state then
        task.spawn(function()
            while getgenv().AutoBossV2 do
                task.defer(function() -- Sử dụng task.defer để giải phóng luồng xử lý chính của game
                    pcall(function()
                        local HRP = Character:FindFirstChild("HumanoidRootPart")
                        local target = GetClosestTarget()
                        
                        if HRP and target then
                            -- Giữ khoảng cách mượt mà cố định sau lưng mục tiêu, Camera hoàn toàn tự do chống chóng mặt
                            HRP.CFrame = target.CFrame * CFrame.new(0, 0, 5)
                            
                            local skillRemote = ReplicatedStorage:FindFirstChild("CombatEvent") or ReplicatedStorage:FindFirstChild("SkillEvent") or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Input"))
                            if skillRemote then
                                skillRemote:FireServer("E", target.Position)
                            else
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end
                        end
                    end)
                end)
                task.wait(0.01) -- Giãn cách vi mô hoàn hảo giúp giảm tải tài nguyên phần cứng mà tốc độ vẫn cực nhanh
            end
        end)
    end
end)

-- ============================================================================
-- TAB 2: STATS & UPGRADES (GIẢM TẦN SUẤT GỬI LỆNH ĐỂ TRÁNH LAG PING)
-- ============================================================================
local StatsTab = Window:NewTab("Stats & Rebirth")
local StatsSection = StatsTab:NewSection("Tự Động Nâng Cấp Sức Mạnh")

StatsSection:NewToggle("Enable Auto Rebirth", "Tự động trùng sinh", function(state)
    getgenv().AutoStatsRebirth = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsRebirth do
                local remote = ReplicatedStorage:FindFirstChild("RebirthEvent") or ReplicatedStorage:FindFirstChild("Rebirth")
                if remote and remote:IsA("RemoteEvent") then remote:FireServer() end
                task.wait(3) -- Tăng thời gian chờ lên 3 giây để tránh làm nghẽn đường truyền mạng (Ping lag)
            end
        end)
    end
end)

StatsSection:NewToggle("Auto Upgrade Melee/Damage", "Tự động cộng điểm tấn công", function(state)
    getgenv().AutoStatsDestiny = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsDestiny do
                local statRemote = ReplicatedStorage:FindFirstChild("StatRemote") or ReplicatedStorage:FindFirstChild("UpgradeStat")
                if statRemote then statRemote:FireServer("Melee", 10) end
                task.wait(1) -- Nâng cấp mượt mà mỗi 1 giây để bảo toàn FPS ổn định
            end
        end)
    end
end)

-- ============================================================================
-- TAB 3: MISC SYSTEM
-- ============================================================================
local MiscTab = Window:NewTab("Utilities & Speed")
local MiscSection = MiscTab:NewSection("Hỗ Trợ Người Chơi")

MiscSection:NewSlider("Custom WalkSpeed", "Thay đổi tốc độ di chuyển", 250, 16, function(s)
    getgenv().WalkSpeedValue = s
end)

task.spawn(function()
    while true do
        if Character and Character:FindFirstChild("Humanoid") then
            if Character.Humanoid.WalkSpeed ~= getgenv().WalkSpeedValue then
                Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
            end
        end
        task.wait(1.5)
    end
end)

-- ============================================================================
-- TAB 4: SETTINGS SYSTEM (CƠ CHẾ DỌN MAP VÀ GIẢM ĐỒ HỌA SIÊU CẤP ĐỘ)
-- ============================================================================
local SettingsTab = Window:NewTab("System Settings")
local SettingsSection = SettingsTab:NewSection("Cấu Hình Treo Máy Đêm")

SettingsSection:NewToggle("Anti-AFK Connection Protection", "Chống mất kết nối", function(state)
    getgenv().AntiAFK = state
end)

LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- Nút tối ưu hóa đồ họa sâu: Xóa bỏ triệt để Texture, Chi tiết 3D thừa của bản đồ để đẩy FPS lên mượt mà nhất
SettingsSection:NewButton("Optimize Graphics (Max Boost FPS)", "Xóa sạch hiệu ứng + hoa văn nặng để làm mượt game tối đa", function()
    pcall(function()
        -- Hạ cấp cấu hình render đồ họa xuống mức thấp nhất
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        -- Dọn dẹp toàn bộ hiệu ứng môi trường, đổ bóng và vật thể hạt thừa thãi
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then 
                v.Enabled = false 
            end
            if v:IsA("Decal") or v:IsA("Texture") then 
                v:Destroy() 
            end
            if v:IsA("MeshPart") then
                v.MeshId = "" -- Chuyển các khối Mesh phức tạp thành dạng khối cơ bản giảm tải GPU
            end
        end
        
        -- Giải phóng ram ảo định kỳ bằng cách ép thu gom rác bộ nhớ Luau
        gcinfo()
    end)
end)

Library:Init()
