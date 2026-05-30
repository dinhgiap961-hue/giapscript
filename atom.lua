local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Automation")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local Plat = Instance.new("Part", workspace)
Plat.Size = Vector3.new(10,1,10) Plat.Anchored = true Plat.Transparency = 1 Plat.CanCollide = true

local function getMonster()
    local target, dist = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 then
                local d = (v.HumanoidRootPart.Position - Plr.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; target = v end
            end
        end
    end
    return target
end

-- =======================================================
-- ÉP MENU KAVO PHẢI VUỐT ĐƯỢC MƯỢT MÀ TRÊN ĐIỆN THOẠI
-- =======================================================
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            local mainFrame = coreGui:FindFirstChild("Atom Max Hub") or coreGui:FindFirstChild("KavoL")
            if mainFrame then
                for _, v in ipairs(mainFrame:GetDescendants()) do
                    if v:IsA("ScrollingFrame") then
                        v.CanvasSize = UDim2.new(0, 0, 0, 1500)
                        v.ScrollingEnabled = true
                        v.ScrollBarThickness = 8
                    end
                end
            end
        end)
    end
end)

-- 1. Spam Đạn Đuổi (E) tự định vị quái
Tab:NewToggle("Spam Đạn Đuổi", "Bắn đạn tự động khóa và đuổi theo quái", function(s)
    _G.EB = s
    if s then
        task.spawn(function()
            while _G.EB do
                if not _G.Charge then
                    pcall(function()
                        local target = getMonster()
                        if target and target:FindFirstChild("HumanoidRootPart") then
                            local cam = workspace.CurrentCamera
                            if cam then
                                cam.CFrame = CFrame.new(cam.CFrame.Position, target.HumanoidRootPart.Position)
                            end
                        end
                    end)
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
                RunService.Stepped:Wait()
            end
        end)
    end
end)

-- 2. Tự động gồng Ki khi năng lượng xuống thấp (Phím G)
Tab:NewToggle("Auto Charge Ki", "Tự động gồng Ki khi cạn năng lượng", function(s)
    _G.AutoKi = s
    task.spawn(function()
        while _G.AutoKi do
            pcall(function()
                local char = Plr.Character
                local Ki = char:FindFirstChild("Ki") or char:FindFirstChild("Energy") or Plr:FindFirstChild("Stats"):FindFirstChild("Ki")
                if Ki and Ki.Value < (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.15 then
                    _G.Charge = true
                    VIM:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                    repeat task.wait(0.1) until Ki.Value >= (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.95 or not _G.AutoKi
                    VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                    _G.Charge = false
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- =======================================================
-- SỬA LỖI: AUTO BÔNG TAI SỬ DỤNG REMOTE EVENT (KHÔNG DÙNG PHÍM BẤM)
-- =======================================================
Tab:NewToggle("Auto Bông Tai", "Tự động kích hoạt bông tai Potara qua hệ thống", function(s)
    _G.AutoEarring = s
    task.spawn(function()
        while _G.AutoEarring do
            pcall(function()
                local char = Plr.Character
                local IsFused = char:FindFirstChild("Fused") or char:FindFirstChild("Fusion") or Plr:FindFirstChild("Status"):FindFirstChild("Fused")
                
                -- Nếu kiểm tra thấy chưa hợp thể, kích hoạt trực tiếp bằng Remote của game
                if not IsFused then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Potara") or game:GetService("ReplicatedStorage"):FindFirstChild("FusionRemote")
                    if remote then
                        remote:FireServer(true)
                    else
                        -- Phương án dự phòng nếu không tìm thấy Remote độc lập
                        VIM:SendKeyEvent(true, Enum.KeyCode.H, false, game)
                        task.wait(0.05)
                        VIM:SendKeyEvent(false, Enum.KeyCode.H, false, game)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)

-- =======================================================
-- SỬA LỖI: AUTO FORM SỬ DỤNG REMOTE EVENT (KHÔNG DÙNG PHÍM BẤM)
-- =======================================================
Tab:NewToggle("Auto Form", "Tự động kích hoạt trạng thái biến hình", function(s)
    _G.AutoForm = s
    task.spawn(function()
        while _G.AutoForm do
            pcall(function()
                local char = Plr.Character
                local IsTransformed = char:FindFirstChild("Transformed") or char:FindFirstChild("Form") or char:FindFirstChild("ActiveForm")
                
                -- Nếu kiểm tra thấy chưa biến hình, gọi trực tiếp lệnh từ Server để lên Form
                if not IsTransformed then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Transform") or game:GetService("ReplicatedStorage"):FindFirstChild("TransformRemote")
                    if remote then
                        remote:FireServer("EquipCurrentForm")
                    else
                        -- Phương án dự phòng nếu không tìm thấy Remote độc lập
                        VIM:SendKeyEvent(true, Enum.KeyCode.V, false, game)
                        task.wait(0.05)
                        VIM:SendKeyEvent(false, Enum.KeyCode.V, false, game)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)

-- 5. Treo trên đầu Boss né skill + Tự đứng im khi xong trận
Tab:NewToggle("Treo Trên Đầu Boss", "Bay cao an toàn, đứng im khi hết quái", function(s)
    _G.Tp = s
    task.spawn(function()
        while _G.Tp do
            pcall(function()
                local t = getMonster()
                local hrp = Plr.Character.HumanoidRootPart
                if t and hrp then
                    hrp.Anchored = false
                    local cf = t.HumanoidRootPart.CFrame * CFrame.new(0, 45, 0)
                    Plat.CFrame = cf
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = cf * CFrame.new(0, 2.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                else
                    Plat.CFrame = CFrame.new(0, -1000, 0)
                    if hrp then hrp.Velocity = Vector3.new(0,0,0) hrp.Anchored = true end
                end
            end)
            task.wait(0.01)
        end
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then Plr.Character.HumanoidRootPart.Anchored = false end
        Plat.CFrame = CFrame.new(0, -1000, 0)
    end)
end)

-- 6. Tự động tạo phòng mới khi bị sút về sảnh PVE
Tab:NewToggle("Auto Next Raid", "Tự động tạo phòng mới khi bị sút về sảnh PVE", function(s)
    _G.RaidNext = s
    task.spawn(function()
        while _G.RaidNext do
            pcall(function()
                local pGui = Plr:FindFirstChild("PlayerGui")
                if pGui then
                    for _, v in ipairs(pGui:GetDescendants()) do
                        if v:IsA("TextButton") and v.Visible then
                            local txt = string.lower(v.Text)
                            local name = string.lower(v.Name)
                            if string.find(txt, "create") or string.find(name, "create") or string.find(txt, "tạo") then
                                v:Activate()
                                VU:ClickButton1(Vector2.new(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2))
                            end
                        end
                    end
                end
            end)
            task.wait(1.5)
        end
    end)
end)

-- 7. Tự bấm nút Bắt đầu/Sẵn sàng để vào trận
Tab:NewToggle("Auto Start Raid", "Tự bấm nút Bắt đầu/Sẵn sàng để vào trận", function(s)
    _G.RaidStart = s
    task.spawn(function()
        while _G.RaidStart do
            pcall(function()
                local pGui = Plr:FindFirstChild("PlayerGui")
                if pGui then
                    for _, v in ipairs(pGui:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                            local txt = string.lower(v:IsA("TextButton") and v.Text or "")
                            local name = string.lower(v.Name)
                            if string.find(txt, "start") or string.find(name, "start") or string.find(txt, "bắt đầu") or string.find(txt, "ready") or string.find(txt, "sẵn sàng") then
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
end)

-- 8. Nút sửa lỗi mất Joystick di chuyển trên điện thoại
Tab:NewButton("Hiện Nút Di Chuyển", "Fix lỗi ẩn mất nút di chuyển", function()
    pcall(function()
        local tg = Plr.PlayerGui:FindFirstChild("TouchGui")
        if tg then tg.Enabled = false task.wait(0.1) tg.Enabled = true end
    end)
end)

-- Tạo nút Icon tròn phụ "Atom" ở góc màn hình
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)
Tab:NewButton("Thu Nhỏ Menu", "Bấm để ẩn bảng chính", function() Kavo:ToggleUI() end)

-- Kích hoạt chống treo máy (Anti-AFK) tự động
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
