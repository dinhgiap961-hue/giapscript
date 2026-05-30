local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Automation")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Hệ thống cấu trúc dữ liệu bảo mật, cô lập luồng tránh trùng lặp
_G.AtomConfig = {
    SpamDan = false,
    AutoKi = false,
    AutoEarring = false,
    AutoForm = false,
    TreoBoss = false,
    RaidNext = false,
    RaidStart = false,
    Charging = false
}

local Plat = workspace:FindFirstChild("AtomPlatform")
if not Plat then
    Plat = Instance.new("Part", workspace)
    Plat.Name = "AtomPlatform"
    Plat.Size = Vector3.new(20, 1, 20)
    Plat.Anchored = true
    Plat.Transparency = 1
    Plat.CanCollide = true
end

-- Hàm quét và khóa mục tiêu quái vật chuẩn xác
local function getMonster()
    local target, dist = nil, math.huge
    local char = Plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 and not v:FindFirstChild("ForceField") then
                local d = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then 
                    dist = d
                    target = v 
                end
            end
        end
    end
    return target
end

-- Tối ưu hóa vuốt menu mượt mà trên thiết bị di động
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local mainFrame = game:GetService("CoreGui"):FindFirstChild("Atom Max Hub") or game:GetService("CoreGui"):FindFirstChild("KavoL")
            if mainFrame then
                for _, v in ipairs(mainFrame:GetDescendants()) do
                    if v:IsA("ScrollingFrame") then
                        v.CanvasSize = UDim2.new(0, 0, 0, 1200)
                        v.ScrollingEnabled = true
                    end
                end
            end
        end)
    end
end)

-- =======================================================
-- 1. FIX SPAM ĐẠN ĐUỔI: TÁCH BIỆT HOÀN TOÀN LUỒNG INPUT
-- =======================================================
Tab:NewToggle("Spam Đạn Đuổi", "Bắn đạn tự động khóa và đuổi theo quái", function(s)
    _G.AtomConfig.SpamDan = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.SpamDan do
                if not _G.AtomConfig.Charging then
                    pcall(function()
                        local target = getMonster()
                        if target and target:FindFirstChild("HumanoidRootPart") then
                            local cam = workspace.CurrentCamera
                            if cam then
                                cam.CFrame = CFrame.new(cam.CFrame.Position, target.HumanoidRootPart.Position)
                            end
                            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.04) -- Giãn cách nhẹ chống nghẽn hàng đợi phím bấm
                            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                    end)
                end
                task.wait(0.06)
            end
        end)
    end
end)

-- 2. Tự động gồng Ki khi năng lượng xuống thấp
Tab:NewToggle("Auto Charge Ki", "Tự động gồng Ki khi cạn năng lượng", function(s)
    _G.AtomConfig.AutoKi = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoKi do
                pcall(function()
                    local char = Plr.Character
                    if char then
                        local Ki = char:FindFirstChild("Ki") or char:FindFirstChild("Energy") or Plr:FindFirstChild("Stats"):FindFirstChild("Ki")
                        if Ki and Ki.Value < (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.15 then
                            _G.AtomConfig.Charging = true
                            VIM:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                            repeat task.wait(0.2) until not _G.AtomConfig.AutoKi or (Ki.Value >= (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.95)
                            VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                            _G.AtomConfig.Charging = false
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

-- 3. Auto Bông Tai bằng Remote Event độc lập (Đã fix lỗi nhảy loạn chiêu)
Tab:NewToggle("Auto Bông Tai", "Tự động đeo bông tai Potara giải phóng sức mạnh", function(s)
    _G.AtomConfig.AutoEarring = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoEarring do
                pcall(function()
                    local char = Plr.Character
                    if char then
                        local IsFused = char:FindFirstChild("Fused") or char:FindFirstChild("Fusion") or Plr:FindFirstChild("Status"):FindFirstChild("Fused")
                        if not IsFused then
                            local storage = game:GetService("ReplicatedStorage")
                            local remote = storage:FindFirstChild("Remotes") and storage.Remotes:FindFirstChild("Potara") or storage:FindFirstChild("FusionRemote")
                            if remote then
                                remote:FireServer(true)
                            end
                        end
                    end
                end)
                task.wait(4) -- Giãn cách rộng để không xung đột với luồng bắn đạn
            end
        end)
    end
end)

-- 4. Auto Form bằng Remote Event độc lập (Đã fix lỗi nhảy loạn chiêu)
Tab:NewToggle("Auto Form", "Tự động lên trạng thái biến hình mạnh nhất", function(s)
    _G.AtomConfig.AutoForm = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoForm do
                pcall(function()
                    local char = Plr.Character
                    if char then
                        local IsTransformed = char:FindFirstChild("Transformed") or char:FindFirstChild("Form") or char:FindFirstChild("ActiveForm")
                        if not IsTransformed then
                            local storage = game:GetService("ReplicatedStorage")
                            local remote = storage:FindFirstChild("Remotes") and storage.Remotes:FindFirstChild("Transform") or storage:FindFirstChild("TransformRemote")
                            if remote then
                                remote:FireServer("EquipCurrentForm")
                            end
                        end
                    end
                end)
                task.wait(4)
            end
        end)
    end
end)

-- =======================================================
-- 3. FIX TREO ĐẦU BOSS: KHÓA CỨNG ĐỨNG IM KHI KẾT THÚC TRẬN
-- =======================================================
Tab:NewToggle("Treo Trên Đầu Boss", "Giữ khoảng cách an toàn, đứng im tuyệt đối khi hết quái", function(s)
    _G.AtomConfig.TreoBoss = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.TreoBoss do
                pcall(function()
                    local t = getMonster()
                    local char = Plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if t and t:FindFirstChild("HumanoidRootPart") and hrp then
                        hrp.Anchored = false
                        -- Đặt vị trí cố định cao hơn quái 45 block để tránh lỗi dập dềnh văng lên trời
                        local staticCF = t.HumanoidRootPart.CFrame
                        local cf = staticCF * CFrame.new(0, 45, 0)
                        
                        Plat.CFrame = cf
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.CFrame = cf * CFrame.new(0, 2, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    else
                        -- Khi không có quái (Xong trận/Chờ hồi sinh): Khóa cứng nhân vật đứng im tuyệt đối
                        Plat.CFrame = CFrame.new(0, -1000, 0)
                        if hrp then 
                            hrp.Velocity = Vector3.new(0, 0, 0) 
                            hrp.Anchored = true -- Bật thuộc tính vật lý đứng im của Roblox
                        end
                    end
                end)
                task.wait(0.02)
            end
            pcall(function()
                if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
                    Plr.Character.HumanoidRootPart.Anchored = false 
                end
                Plat.CFrame = CFrame.new(0, -1000, 0)
            end)
        end)
    end
end)

-- =======================================================
-- 2. FIX AUTO NEXT RAID: BẤM THEO ĐƯỜNG DẪN UI GỐC CỦA GAME
-- =======================================================
Tab:NewToggle("Auto Next Raid", "Tự động tạo phòng hoặc bấm tiếp tục từ UI hệ thống", function(s)
    _G.AtomConfig.RaidNext = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.RaidNext do
                pcall(function()
                    local pGui = Plr:FindFirstChild("PlayerGui")
                    if pGui then
                        -- Hướng xử lý 1: Kích hoạt trực tiếp bảng Dungeon UI phòng chờ chính
                        local dungUI = pGui:FindFirstChild("DungeonUI") or pGui:FindFirstChild("RaidUI") or pGui:FindFirstChild("MainGui")
                        if dungUI then
                            for _, btn in ipairs(dungUI:GetDescendants()) do
                                if btn:IsA("TextButton") and btn.Visible and (string.find(string.lower(btn.Name), "create") or string.find(string.lower(btn.Text), "tạo")) then
                                    btn:Activate()
                                    VU:ClickButton1(Vector2.new(btn.AbsolutePosition.X + btn.AbsoluteSize.X/2, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y/2))
                                end
                            end
                        end
                        
                        -- Hướng xử lý 2: Quét toàn bộ nút bấm hệ thống dự phòng trường hợp đổi tên màn hình
                        for _, v in ipairs(pGui:GetDescendants()) do
                            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible and v.AbsoluteSize.X > 0 then
                                local t = string.lower(v:IsA("TextButton") and v.Text or "")
                                local n = string.lower(v.Name)
                                if string.find(t, "create") or string.find(n, "create") or string.find(t, "tạo") or string.find(t, "next") or string.find(n, "next") or string.find(t, "leave") or string.find(n, "leave") then
                                    v:Activate()
                                    VU:ClickButton1(Vector2.new(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2))
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- =======================================================
-- 2. FIX AUTO START RAID: BẤM THEO ĐƯỜNG DẪN UI GỐC CỦA GAME
-- =======================================================
Tab:NewToggle("Auto Start Raid", "Tự động nhấn Sẵn sàng hoặc Vào trận lập tức", function(s)
    _G.AtomConfig.RaidStart = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.RaidStart do
                pcall(function()
                    local pGui = Plr:FindFirstChild("PlayerGui")
                    if pGui then
                        -- Hướng xử lý 1: Ưu tiên kích hoạt thẳng từ cụm UI sảnh chính của Dragon Blox V2
                        local pveUI = pGui:FindFirstChild("DungeonUI") or pGui:FindFirstChild("LobbyUI") or pGui:FindFirstChild("MainGui")
                        if pveUI then
                            for _, btn in ipairs(pveUI:GetDescendants()) do
                                if btn:IsA("TextButton") and btn.Visible and (string.find(string.lower(btn.Name), "start") or string.find(string.lower(btn.Text), "bắt đầu")) then
                                    btn:Activate()
                                    VU:ClickButton1(Vector2.new(btn.AbsolutePosition.X + btn.AbsoluteSize.X/2, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y/2))
                                end
                            end
                        end
                        
                        -- Hướng xử lý 2: Quét toàn bộ nút bấm hệ thống dự phòng trường hợp đổi tên màn hình
                        for _, v in ipairs(pGui:GetDescendants()) do
                            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible and v.AbsoluteSize.X > 0 then
                                local t = string.lower(v:IsA("TextButton") and v.Text or "")
                                local n = string.lower(v.Name)
                                if string.find(t, "start") or string.find(n, "start") or string.find(t, "bắt đầu") or string.find(t, "ready") or string.find(n, "ready") or string.find(t, "play") or string.find(t, "join") then
                                    v:Activate()
                                    VU:ClickButton1(Vector2.new(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2))
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- 8. Nút sửa lỗi ẩn nút di chuyển màn hình cảm ứng
Tab:NewButton("Hiện Nút Di Chuyển", "Khắc phục lỗi mất thanh điều hướng ảo", function()
    pcall(function()
        local tg = Plr.PlayerGui:FindFirstChild("TouchGui")
        if tg then tg.Enabled = false task.wait(0.1) tg.Enabled = true end
    end)
end)

-- Thiết lập bảng điều khiển thu gọn nhanh chóng
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)
Tab:NewButton("Thu Nhỏ Menu", "Ẩn giao diện chính của bản Hack", function() Kavo:ToggleUI() end)

-- Ngăn chặn văng game do treo máy lâu (Anti-AFK)
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
