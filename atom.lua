-- ATOM SUPER-LOCK VIP (OPTIMIZED FROM SOURCE)
local Plr = game:GetService("Players").LocalPlayer
local RepStore = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Khởi tạo cấu hình chạy ngầm siêu tốc
getgenv().AtomMaster = {
    FlyHigh = true,
    SuperLock = true,
    AutoKi = true,
    Height = 25 -- Độ cao tối ưu để né mọi chiêu AoE của Boss
}

-- Hàm tìm Boss/Quái chuẩn xác nhất hệ mặt trời
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

-- 1. VÒNG LẶP CORE: BAY TRÊN ĐẦU BOSS (FARM NHƯ THẦN)
task.spawn(function()
    while getgenv().AtomMaster.FlyHigh do
        pcall(function()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local boss = getAbsoluteBoss()
            
            if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then
                -- Đóng băng vận tốc rơi tự do để tránh giật lag camera
                hrp.Velocity = Vector3.new(0, 0, 0)
                
                -- Ghim chặt nhân vật trên đỉnh đầu Boss, xoay người nhìn thẳng xuống rốn nó
                local bossPos = boss.HumanoidRootPart.Position
                hrp.CFrame = CFrame.new(bossPos + Vector3.new(0, getgenv().AtomMaster.Height, 0), bossPos)
            end
        end)
        RunService.Heartbeat:Wait() -- Chạy theo khung hình game để mượt 100% không bị rơi
    end
end)

-- 2. VÒNG LẶP CORE: ATOM SUPER-LOCK (GHIM ĐẠN KHÔNG TRƯỢT PHÁT NÀO)
task.spawn(function()
    while getgenv().AtomMaster.SuperLock do
        pcall(function()
            local boss = getAbsoluteBoss()
            if boss and boss:FindFirstChild("HumanoidRootPart") then
                local bossPos = boss.HumanoidRootPart.Position
                
                -- Khóa cứng Camera của bạn nhìn thẳng vào Boss từ trên cao xuống
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, bossPos)
                end
                
                -- Thực thi gửi lệnh bắn đạn liên tục theo tọa độ Boss
                local remotes = RepStore:FindFirstChild("Remotes")
                if remotes then
                    local blast = remotes:FindFirstChild("EnergyBlast") or remotes:FindFirstChild("AttackRemote") or remotes:FindFirstChild("KiBlast")
                    if blast then
                        blast:FireServer(bossPos)
                    end
                end
                
                -- Ép hệ thống giao diện Mobile tự động click nút Skill hình tròn
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
        task.wait(0.02) -- Tốc độ spam đạn tia chớp
    end
end)

-- 3. VÒNG LẶP CORE: TỰ ĐỘNG GỒNG KI KHI HẾT NĂNG LƯỢNG
task.spawn(function()
    while getgenv().AtomMaster.AutoKi do
        pcall(function()
            local char = Plr.Character
            if char then
                local Ki = char:FindFirstChild("Ki") or char:FindFirstChild("Energy") or Plr:FindFirstChild("Stats"):FindFirstChild("Ki")
                if Ki and Ki.Value < (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.15 then
                    local remotes = RepStore:FindFirstChild("Remotes")
                    local charge = remotes and (remotes:FindFirstChild("ChargeKi") or remotes:FindFirstChild("Charge"))
                    if charge then
                        charge:FireServer(true)
                        repeat task.wait(0.1) until Ki.Value >= Ki.MaxKi.Value or not getgenv().AtomMaster.AutoKi
                        charge:FireServer(false)
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- Chống AFK kích văng game từ Server
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
print("--- [ATOM SUPER-LOCK LOADED SUCCESS] ---")
