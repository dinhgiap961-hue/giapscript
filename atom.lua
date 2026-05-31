-- ============================================================================
-- DRAGON BLOX V2 - ULTIMATE PREMIUM HUB (ALL-IN-ONE COMPLETE EDITION)
-- ============================================================================

-- 1. KHỞI TẠO HỆ THỐNG VÀ KIỂM TRA KẾT NỐI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V2 | Ultimate Hub", "BloodTheme")

-- Thông báo khởi chạy hệ thống thành công
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Atom System",
    Text = "Kích hoạt thành công! Bấm nút 'Atom Max' hoặc 'Right Shift' để ẩn/hiện menu.",
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
getgenv().WalkSpeedValue = 16

-- Khởi tạo các dịch vụ hệ thống Roblox cần thiết
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

-- Tự động cập nhật lại Character khi nhân vật bị reset/hồi sinh
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- ============================================================================
-- 🔘 NÚT "ATOM MAX" THU NHỎ / MỞ RỘNG MENU (DI CHUYỂN LINH HOẠT)
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
AtomButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Màu nền tối
AtomButton.BackgroundTransparency = 0.2 -- Hơi trong suốt mượt mà
AtomButton.Position = UDim2.new(0.5, -60, 0.7, 0) -- Vị trí mặc định ở giữa phía dưới màn hình
AtomButton.Size = UDim2.new(0, 120, 0, 45) -- Kích thước nút chữ nhật bo góc dài
AtomButton.Font = Enum.Font.GothamBold
AtomButton.Text = "Atom Max"
AtomButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Chữ trắng sắc nét
AtomButton.TextSize = 16.00
AtomButton.Active = true
AtomButton.Draggable = true -- Nhấn giữ để KÉO RÊ tự do trên màn hình điện thoại/PC

-- Bo góc cho nút bấm mượt mà
UICorner.CornerRadius = UDim.new(0, 12) 
UICorner.Parent = AtomButton

-- Thêm viền đỏ mờ cho nút chuẩn phong cách Dragon Blox
UIStroke.Parent = AtomButton
UIStroke.Color = Color3.fromRGB(150, 0, 0)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Logic ẩn/hiện toàn bộ Menu khi bấm vào chữ "Atom Max"
AtomButton.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
end)


-- ============================================================================
-- TAB 1: MAIN FUNCTION (CHỨC NĂNG CHÍNH - AUTO FARM, BOSS VÀ BAY CAO 30 STUDS)
-- ============================================================================
local MainTab = Window:NewTab("Main Script")
local MainSection = MainTab:NewSection("Quản Lý Auto Farm & Boss")

-- Nút kiểm tra trạng thái Boss
MainSection:NewButton("Check Boss Status", "Kiểm tra sự xuất hiện của Boss trong Server", function()
    local bossSpawned = workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Boss")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Check Boss",
        Text = bossSpawned and "Boss ĐÃ XUẤT HIỆN! Hãy bật Auto Boss ngay." or "Hiện tại chưa có Boss.",
        Duration = 4
    })
end)

-- Nút Reset Chỉ Số Nhanh
MainSection:NewButton("Reset Character Stats", "Đặt lại trạng thái nhân vật tức thì để hồi máu/vị trí", function()
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.Health = 0
    end
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

-- Công tắc Auto Boss V1 tích hợp chức năng Tự Động Bay Cao 30 Studs Né Skill (2-trong-1)
MainSection:NewToggle("Auto Boss V1 (Fly 30 Studs)", "Tự động đấm và nhấc bổng nhân vật lên cao 30 studs né skill", function(state)
    getgenv().AutoBossV1 = state
    
    if state then
        task.spawn(function()
            -- Khởi tạo lực bay ngầm kiên cố để cố định vị trí trên không
            local bV = Instance.new("BodyVelocity")
            bV.Name = "AtomFlyForce"
            bV.Velocity = Vector3.new(0, 0, 0) -- Khóa chặt không cho rơi tự do
            bV.MaxForce = Vector3.new(0, math.huge, 0) -- Áp dụng lực nâng tuyệt đối lên trục Y
            
            while getgenv().AutoBossV1 do
                pcall(function()
                    local HRP = Character:FindFirstChild("HumanoidRootPart")
                    local Humanoid = Character:FindFirstChild("Humanoid")
                    
                    if HRP and Humanoid then
                        -- Nếu chưa có lực bay, tiến hành kích hoạt và đẩy nhân vật lên cao
                        if not HRP:FindFirstChild("AtomFlyForce") then
                            bV.Parent = HRP
                            -- Đẩy nhân vật vút lên cao ĐÚNG 30 STUDS so với vị trí đứng hiện tại để né chiêu dập đất
                            HRP.CFrame = HRP.CFrame * CFrame.new(0, 30, 0)
                        end
                        
                        -- Chuyển trạng thái Physics để đấm liên tục khi lơ lửng không bị khựng hoạt ảnh
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                    
                    -- Giả lập click chuột/tấn công liên hồi vào Boss cực mượt
                    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.04) -- Tốc độ vung chiêu siêu tốc độ
            end
            
            -- Xóa lực bay khi tắt công tắc để nhân vật rơi xuống đất an toàn
            local TargetForce = Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart:FindFirstChild("AtomFlyForce")
            if TargetForce then 
                TargetForce:Destroy() 
            end
            if Character:FindFirstChild("Humanoid") then
                Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    else
        print("Đã tắt Auto Boss V1 - Nhân vật đáp đất.")
    end
end)

-- Công tắc Auto Boss V2 (Premium Fast Mode)
MainSection:NewToggle("Auto Boss V2 (Fast Mode)", "Săn Boss tốc độ cao kết hợp né đòn cận chiến", function(state)
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

-- Công tắc Tự Động Bật Kỹ Năng (Auto Skills / Ki Blasts)
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
-- TAB 2: STATS & UPGRADES (TỰ ĐỘNG NÂNG CHỈ SỐ / TRÙNG SINH)
-- ============================================================================
local StatsTab = Window:NewTab("Stats & Rebirth")
local StatsSection = StatsTab:NewSection("Tự Động Nâng Cấp Sức Mạnh")

-- Công tắc Tự Động Rebirth (Trùng sinh)
StatsSection:NewToggle("Enable Auto Rebirth", "Tự động trùng sinh ngay khi đủ điều kiện", function(state)
    getgenv().AutoStatsRebirth = state
    if state then
        task.spawn(function()
            while getgenv().AutoStatsRebirth do
                local remote = ReplicatedStorage:FindFirstChild("RebirthEvent") or ReplicatedStorage:FindFirstChild("Rebirth")
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer()
                end
                task.wait(2)
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
-- TAB 3: MISC & TELEPORT (TIỆN ÍCH KHÁC & DỊCH CHUYỂN TỐC ĐỘ)
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
                    for _, item in ipairs(workspace:GetChildren()) do
                        if item:IsA("Part") and (item.Name == "Coin" or item.Name == "Cash" or item.Name == "Orb") then
                            local hrp = Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                item.CFrame = hrp.CFrame
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
end)

-- Luồng duy trì tốc độ chạy liên tục
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
-- TAB 4: SETTINGS SYSTEM (HỆ THỐNG - CHỐNG AFK TREO ĐÊM MƯỢT MÀ)
-- ============================================================================
local SettingsTab = Window:NewTab("System Settings")
local SettingsSection = SettingsTab:NewSection("Cấu Hình Treo Máy Đêm")

-- Tính năng Chống Kích Văng do Treo Máy (Anti-AFK)
SettingsSection:NewToggle("Anti-AFK Connection Protection", "Giữ kết nối liên tục, không sợ bị kích sau 20 phút", function(state)
    getgenv().AntiAFK = state
end)

-- Cơ chế bảo vệ ngầm của Anti-AFK
LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- Nút Tối ưu hóa đồ họa (Giảm lag máy cực tốt khi cắm đêm)
SettingsSection:NewButton("Optimize Graphics (Boost FPS)", "Xóa hiệu ứng thừa để làm mượt game, giảm tốn PIN", function()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end)

-- Khởi tạo Menu hoàn tất
Library:Init()
