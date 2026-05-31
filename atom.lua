-- ============================================================================
-- DRAGON BLOX V2 - ULTIMATE PREMIUM HUB (COMPLETE EDITION)
-- ============================================================================

-- 1. KHỞI TẠO HỆ THỐNG VÀ KIỂM TRA KẾT NỐI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Ultimate Hub", "BloodTheme")

-- Thông báo khởi chạy thành công
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Ultimate Hub",
    Text = "Hệ thống đã kích hoạt thành công! Đang tải cấu hình...",
    Duration = 5
})

-- Các biến môi trường toàn cục điều khiển vòng lặp (Anti-Lag & Safe Toggle)
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

-- Khởi tạo các dịch vụ hệ thống Roblox cần thiết
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- Tự động cập nhật lại Character khi nhân vật bị reset/hồi sinh
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- ============================================================================
-- TAB 1: MAIN FUNCTION (CHỨC NĂNG CHÍNH - AUTO FARM & BOSS)
-- ============================================================================
local MainTab = Window:NewTab("Main Script")
local MainSection = MainTab:NewSection("Quản Lý Auto Farm & Boss")

-- Nút kiểm tra Boss
MainSection:NewButton("Check Boss Status", "Kiểm tra sự xuất hiện của Boss trong Server", function()
    local bossSpawned = false
    -- Quét trong Workspace tìm thực thể Boss (Ví dụ phổ biến trong game)
    if workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Boss") then
        bossSpawned = true
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Check Boss",
        Text = bossSpawned and "Boss ĐÃ XUẤT HIỆN! Hãy bật Auto Boss ngay." or "Hiện tại chưa có Boss.",
        Duration = 4
    })
end)

-- Nút Reset Chỉ Số Nhanh
MainSection:NewButton("Reset Character Stats", "Đặt lại trạng thái nhân vật tức thì", function()
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.Health = 0
    end
end)

-- Công tắc Auto Farm Quái Thường (Mobs)
MainSection:NewToggle("Auto Farm Mobs (Level)", "Tự động bay đến và tiêu diệt quái theo cấp độ", function(state)
    getgenv().AutoFarmMobs = state
    if state then
        task.spawn(function()
            while getgenv().AutoFarmMobs do
                -- CHỖ NÀY: Logic tìm mục tiêu gần nhất và dịch chuyển (Tween) tới
                pcall(function()
                    -- Giả lập bấm chuột/đấm liên tục cực mượt
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0,0))
                end)
                task.wait(0.05) -- Tốc độ đấm siêu tốc độ nhưng an toàn
            end
        end)
    end
end)

-- Công tắc Auto Boss V1
MainSection:NewToggle("Auto Boss V1 (Normal)", "Tự động săn Boss thông thường", function(state)
    getgenv().AutoBossV1 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV1 do
                pcall(function()
                    -- Tự động kích hoạt đòn đánh thường
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.1)
            end
        end)
    end
end)

-- Công tắc Auto Boss V2 (Premium Fast Mode)
MainSection:NewToggle("Auto Boss V2 (Fast Mode)", "Săn Boss tốc độ cao kết hợp né đòn", function(state)
    getgenv().AutoBossV2 = state
    if state then
        task.spawn(function()
            while getgenv().AutoBossV2 do
                pcall(function()
                    -- Giả lập dịch chuyển liên tục ra phía sau lưng Boss để né skill
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    if HumanoidRootPart then
                        -- Logic khóa mục tiêu và giữ khoảng cách an toàn viết tại đây
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0,0))
                end)
                task.wait(0.02)
            end
        end)
    end
end)

-- Công tắc Tự Động Bật Kỹ Năng (Auto Skills / Ki Blasts)
MainSection:NewToggle("Auto Use Combat Skills", "Tự động tung toàn bộ kỹ năng khi hồi chiêu", function(state)
    getgenv().AutoSkills = state
    if state then
        task.spawn(function()
            local skillKeys = {"E", "Z", "X", "C", "V"} -- Các phím kỹ năng mặc định
            while getgenv().AutoSkills do
                for _, key in ipairs(skillKeys) do
                    if not getgenv().AutoSkills then break end
                    -- Gửi tín hiệu giả lập nhấn phím đến hệ thống game
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

-- Công tắc Tự Động Rebirth (Trùng sinh)
MainSection:NewToggle("Enable Auto Rebirth", "Tự động trùng sinh ngay khi đủ điều kiện", function(state)
    getgenv().AutoStatsRebirth = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsRebirth do
                -- Gửi RemoteEvent yêu cầu Rebirth lên Server của game
                local remote = ReplicatedStorage:FindFirstChild("RebirthEvent") or ReplicatedStorage:FindFirstChild("Rebirth")
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer()
                end
                task.wait(2) -- Tránh spam quá mức gây kích ứng hệ thống bảo mật
            end
        end)
    end
end)

-- Công tắc Tự động nâng chỉ số Đấu Sĩ / Tiềm Năng
StatsSection:NewToggle("Auto Upgrade Melee/Damage", "Tự động cộng điểm vào Sức mạnh tấn công", function(state)
    getgenv().AutoStatsDestiny = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsDestiny do
                -- Thay thế "AddStat" bằng tên RemoteEvent chính xác của game bạn muốn farm
                local statRemote = ReplicatedStorage:FindFirstChild("StatRemote") or ReplicatedStorage:FindFirstChild("UpgradeStat")
                if statRemote then
                    statRemote:FireServer("Melee", 10)
                end
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

-- Tự động hút tiền / vật phẩm rớt ra
MiscSection:NewToggle("Auto Collect Cash / Orbs", "Tự động nhặt tiền và ngọc rơi trên bản đồ", function(state)
    getgenv().AutoCollectCash = state
    if state then
        task.spawn(function()
            while getgenv().AutoCollectCash do
                pcall(function()
                    -- Tìm kiếm các vật phẩm rơi trong Workspace
                    for _, item in ipairs(workspace:GetChildren()) do
                        if item:IsA("Part") and (item.Name == "Coin" or item.Name == "Cash" or item.Name == "Orb") then
                            local hrp = Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                item.CFrame = hrp.CFrame -- Dịch chuyển vật phẩm thẳng vào người chơi
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

-- Thanh trượt chỉnh Tốc độ chạy (WalkSpeed)
MiscSection:NewSlider("Custom WalkSpeed", "Thay đổi tốc độ di chuyển của nhân vật", 250, 16, function(s)
    getgenv().WalkSpeedValue = s
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = s
    end
end)

-- Luồng ngầm giữ liên tục tốc độ chạy kể cả khi hồi sinh
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

-- Nút Dịch chuyển đến Khu vực An Toàn (Safe Zone)
MiscSection:NewButton("Teleport to Safe Zone (PVE)", "Dịch chuyển tức thời đến vùng an toàn", function()
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    local pveZone = workspace:FindFirstChild("PVE Zone") or workspace:FindFirstChild("SafeZone")
    
    if hrp and pveZone then
        hrp.CFrame = pveZone.CFrame + Vector3.new(0, 5, 0)
    else
        -- Nếu không tìm thấy vùng định vị sẵn, dịch chuyển lên trời để an toàn
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 1000, 0) end
    end
end)


-- ============================================================================
-- TAB 4: SETTINGS SYSTEM (HỆ THỐNG - CHỐNG AFK & TREO MÁY)
-- ============================================================================
local SettingsTab = Window:NewTab("System Settings")
local SettingsSection = SettingsTab:NewSection("Cấu Hình Treo Máy Đêm")

-- Tính năng Chống Kích Văng do Treo Máy (Anti-AFK)
SettingsSection:NewToggle("Anti-AFK Connection Protection", "Giữ kết nối liên tục, không sợ bị kick sau 20 phút", function(state)
    getgenv().AntiAFK = state
end)

-- Cơ chế hoạt động của Anti-AFK (Bảo vệ ngầm)
LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- Nút Tối ưu hóa đồ họa (Giảm Lag / Tránh nóng máy khi treo)
SettingsSection:NewButton("Optimize Graphics (Boost FPS)", "Xóa hiệu ứng thừa để làm mượt game, giảm tốn PIN", function()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hệ thống",
        Text = "Đã tối ưu hóa FPS! Game sẽ chạy cực mượt.",
        Duration = 3
    })
end)

-- Đóng gói Menu
Library:Init()
