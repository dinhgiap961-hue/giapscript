local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Super-Lock", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Atom Core VIP")

local Plr = game:GetService("Players").LocalPlayer
local RepStore = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

_G.AtomConfig = {
    FlyAboveBoss = false,
    SpamDan = false,
    AutoKi = false
}

-- Hàm quét lấy mục tiêu quái vật/boss chuẩn xác từ mã nguồn tối ưu
local function getAbsoluteBoss()
    local target = nil
    local minDist = math.huge
    local char = Plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 and not v:FindFirstChild("ForceField") then
                local dist = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = v
                end
            end
        end
    end
    return target
end

-- =======================================================
-- ĐƯA CÁC TÍNH NĂNG VIP VÀO MENU BẤM BẬT/TẮT
-- =======================================================

-- 1. Nút bật/tắt Bay Cao Trên Đầu Boss (25 studs)
Tab:NewToggle("Auto Fly Above Boss", "Bay cao 25 studs né mọi chiêu AoE và bám sát Boss", function(s)
    _G.AtomConfig.FlyAboveBoss = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.FlyAboveBoss do
                pcall(function()
                    local char = Plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local boss = getAbsoluteBoss()
                    
                    if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then
                        -- Đóng băng vận tốc rơi tự do
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        
                        -- Ghim chặt nhân vật trên đỉnh đầu Boss, xoay người nhìn thẳng xuống
                        local bossPos = boss.HumanoidRootPart.Position
                        hrp.CFrame = CFrame.new(bossPos + Vector3.new(0, 25, 0), bossPos)
                    end
                end)
                RunService.Heartbeat:Wait() -- Chạy mượt theo khung hình game
            end
        end)
    end
end)

-- 2. Nút bật/tắt Ghim Đạn Thẳng Vào Boss (Atom Lock)
Tab:NewToggle("Spam Đạn Ghim Thẳng Boss", "Khóa cứng camera từ trên cao, ép đạn nổ thẳng vào Boss", function(s)
    _G.AtomConfig.SpamDan = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.SpamDan do
                pcall(function()
                    local boss = getAbsoluteBoss()
                    if boss and boss:FindFirstChild("HumanoidRootPart") then
                        local bossPos = boss.HumanoidRootPart.Position
                        
                        -- Khóa cứng Camera nhìn thẳng xuống Boss từ trên cao
                        if workspace.CurrentCamera then
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, bossPos)
                        end
                        
                        -- Gửi tọa độ bắn thẳng lên Server game
                        local remotes = RepStore:FindFirstChild("Remotes")
                        if remotes then
                            local blast = remotes:FindFirstChild("EnergyBlast") or remotes:FindFirstChild("AttackRemote") or remotes:FindFirstChild("KiBlast")
                            if blast then
                                blast:FireServer(bossPos)
                            end
                        end
                        
                        -- Ép hệ thống tự động kích hoạt nút Skill hình tròn trên Mobile
                        local pGui = Plr:FindFirstChild("PlayerGui")
                        if pGui then
                            for _, gui in ipairs(pGui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled then
                                    for _, btn in ipairs(gui:GetDescendants()) do
                                        if (btn:IsA("ImageButton") or btn:IsA("TextButton")) and btn.Visible then
                                            local name = string.lower(btn.Name)
                                            if string.find(name, "skill") or string.find(name, "blast") or string.find(name, "attack") or string.find(name, "slot1") or name == "e" then
                                                btn:Activate()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.02) -- Tốc độ nã đạn siêu tốc
            end
        end)
    end
end)

-- 3. Nút bật/tắt Tự Động Gồng Ki
Tab:NewToggle("Auto Charge Ki", "Tự động gồng Ki khi năng lượng xuống thấp", function(s)
    _G.AtomConfig.AutoKi = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoKi do
                pcall(function()
                    local char = Plr.Character
                    if char then
                        local Ki = char:FindFirstChild("Ki") or char:FindFirstChild("Energy") or Plr:FindFirstChild("Stats"):FindFirstChild("Ki")
                        if Ki and Ki.Value < (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.15 then
                            local remotes = RepStore:FindFirstChild("Remotes")
                            local charge = remotes and (remotes:FindFirstChild("ChargeKi") or remotes:FindFirstChild("Charge"))
                            if charge then
                                charge:FireServer(true)
                                repeat task.wait(0.1) until Ki.Value >= Ki.MaxKi.Value or not _G.AtomConfig.AutoKi
                                charge:FireServer(false)
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

-- Tạo nút tròn màu đỏ có chữ "Atom" trên màn hình để ẩn/hiện Menu khi cần
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)

-- Anti-AFK tránh bị out game khi treo máy
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
