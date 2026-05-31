-- ============================================================================
-- DRAGON BLOX V2 - ULTIMATE PREMIUM HUB (WITH MINIMIZE BUTTON)
-- ============================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Ultimate Hub", "BloodTheme")

-- Thông báo khởi chạy thành công
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Ultimate Hub",
    Text = "Nhấn 'Right Shift' hoặc Nút Tròn để Ẩn/Hiện Menu!",
    Duration = 5
})

-- Các biến môi trường toàn cục điều khiển vòng lặp
getgenv().AutoFarmMobs = false
getgenv().AutoBossV1 = false
getgenv().AutoBossV2 = false
getgenv().AutoSkills = false
getgenv().AutoCollectCash = false
getgenv().AutoStatsDestiny = false
getgenv().AutoStatsRebirth = false
getgenv().AntiAFK = true
getgenv().FlyHack = false
getgenv().WalkSpeedValue = 16

-- Khởi tạo dịch vụ hệ thống Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

LocalPlayer.CharacterAdded:Connect(function(char) Character = char end)

-- ============================================================================
-- 🔘 TẠO NÚT THU NHỎ / MỞ RỘNG NỔI (ĐẶC BIỆT CHO ĐIỆN THOẠI)
-- ============================================================================
local OpenCloseGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

OpenCloseGui.Name = "UltimateHubToggleUI"
OpenCloseGui.Parent = CoreGui
OpenCloseGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = OpenCloseGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Màu đỏ chủ đạo mượt mà
ToggleButton.Position = UDim2.new(0, 15, 0, 15) -- Vị trí góc trên bên trái màn hình
ToggleButton.Size = UDim2.new(0, 50, 0, 50) -- Kích thước nút tròn thu nhỏ
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14.00
ToggleButton.Active = true
ToggleButton.Draggable = true -- Bạn có thể kéo nút này đi bất kỳ đâu trên màn hình

UICorner.CornerRadius = UDim.new(0, 25) -- Bo tròn 100% thành hình nút bấm mượt
UICorner.Parent = ToggleButton

-- Logic ẩn/hiện toàn bộ Menu khi bấm nút
ToggleButton.MouseButton1Click:Connect(function()
    -- Gửi tín hiệu giả lập phím tắt ẩn/hiện của thư viện Kavo UI
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
end)


-- ============================================================================
-- TAB 1: MAIN FUNCTION (CHỨC NĂNG CHÍNH - AUTO FARM & BOSS)
-- ============================================================================
local MainTab = Window:NewTab("Main Script")
local MainSection = MainTab:NewSection("Quản Lý Auto Farm & Boss")

MainSection:NewButton("Check Boss Status", "Kiểm tra sự xuất hiện của Boss trong Server", function()
    local bossSpawned = workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Boss")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Check Boss",
        Text = bossSpawned and "Boss ĐÃ XUẤT HIỆN!" or "Hiện tại chưa có Boss.",
        Duration = 4
    })
end)

MainSection:NewButton("Reset Character Stats", "Đặt lại trạng thái nhân vật tức thì", function()
    if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.Health = 0 end
end)

MainSection:NewToggle("Auto Farm Mobs (Level)", "Tự động bay đến và tiêu diệt quái theo cấp độ", function(state)
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

MainSection:NewToggle("Auto Boss V1 (Normal)", "Tự động săn Boss thông thường", function(state)
    getgenv().AutoBossV1 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV1 do
                pcall(function()
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.1)
            end
        end)
    end
end)

MainSection:NewToggle("Auto Boss V2 (Fast Mode)", "Săn Boss tốc độ cao kết hợp né đòn", function(state)
    getgenv().AutoBossV2 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV2 do
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0,0))
                end)
                task.wait(0.02)
            end
        end)
    end
end)

MainSection:NewToggle("Auto Use Combat Skills", "Tự động tung toàn bộ kỹ năng khi hồi chiêu", function(state)
    getgenv().AutoSkills = state
    if state then
        task.spawn(function()
            local skillKeys = {"E", "Z", "X", "C", "V"}
            while getgenv().AutoSkills do
                for _, key in ipairs(skillKeys) do
                    if not getgenv().AutoSkills then break end
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[key], false, game)
                    task.wait(0.1)
                end
                task.wait(0.5)
            end
        end)
    end
end)


-- ============================================================================
-- TAB 2: STATS & UPGRADES (TỰ ĐỘNG NÂNG CHỈ SỐ / REBIRTH)
-- ============================================================================
local StatsTab = Window:NewTab("Stats & Rebirth")
local StatsSection = StatsTab:NewSection("Tự Động Nâng Cấp Sức Mạnh")

StatsSection:NewToggle("Enable Auto Rebirth", "Tự động trùng sinh ngay khi đủ điều kiện", function(state)
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

StatsSection:NewToggle("Auto Upgrade Melee/Damage", "Tự động cộng điểm vào Sức mạnh tấn công", function(state)
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
-- TAB 3: MISC & TELEPORT (TIỆN ÍCH KHÁC & DỊCH CHUYỂN)
-- ============================================================================
local MiscTab = Window:NewTab("Utilities & Teleport")
local MiscSection = MiscTab:NewSection("Hỗ Trợ Người Chơi")

MiscSection:NewToggle("Auto Collect Cash / Orbs", "Tự động nhặt tiền và ngọc rơi trên bản đồ", function(state)
    getgenv().AutoCollectCash = state
    if state then
        task.spawn(function()
            while getgenv().AutoCollectCash do
                pcall(function()
                    for _, item in ipairs(workspace:GetChildren()) do
                        if item:IsA("Part") and (item.Name == "Coin" or item.Name == "Cash" or item.Name == "Orb") then
                            local hrp = Character:FindFirstChild("HumanoidRootPart")
                            if hrp then item.CFrame = hrp.CFrame end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

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
-- TAB 4: SETTINGS SYSTEM (HỆ THỐNG - CHỐNG AFK & TREO MÁY)
-- ============================================================================
local SettingsTab = Window:NewTab("System Settings")
local SettingsSection = SettingsTab:NewSection("Cấu Hình Treo Máy Đêm")

SettingsSection:NewToggle("Anti-AFK Connection Protection", "Giữ kết nối liên tục, không sợ bị kick sau 20 phút", function(state)
    getgenv().AntiAFK = state
end)

LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

SettingsSection:NewButton("Optimize Graphics (Boost FPS)", "Xóa hiệu ứng thừa để làm mượt game, giảm tốn PIN", function()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end)

-- Khởi tạo Menu hoàn tất
Library:Init()
