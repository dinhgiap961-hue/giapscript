local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Ultimate Hub", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Boss Killer Ultimate")

local Plr = game:GetService("Players").LocalPlayer
local RepStore = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

_G.AtomConfig = {
    FlyAboveBoss = false,
    SpamDan = false,
    AutoKi = false,
    AutoForm = false
}

-- Hàm quét lấy mục tiêu Boss/Quái chính xác nhất
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
-- CÁC CHỨC NĂNG CHÍNH THEO YÊU CẦU
-- =======================================================

-- 1. Bay sát trên đầu Boss đúng 30cm (Khoảng 1.5 studs để đạn nổ trực diện)
Tab:NewToggle("Auto Fly Above Boss (30cm)", "Bay siêu sát trên đầu Boss để tối đa sát thương", function(s)
    _G.AtomConfig.FlyAboveBoss = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.FlyAboveBoss do
                pcall(function()
                    local char = Plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local boss = getAbsoluteBoss()
                    
                    if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        -- 30cm tương đương khoảng 1.5 studs trong không gian Roblox
                        local bossPos = boss.HumanoidRootPart.Position
                        hrp.CFrame = CFrame.new(bossPos + Vector3.new(0, 1.5, 0), bossPos)
                    end
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end
end)

-- 2. Auto Lock Kỹ Năng + Spam Energy Blast
Tab:NewToggle("Spam Skill Energy Blast", "Lock cứng mục tiêu và nã Energy Blast liên tục", function(s)
    _G.AtomConfig.SpamDan = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.SpamDan do
                pcall(function()
                    local boss = getAbsoluteBoss()
                    if boss and boss:FindFirstChild("HumanoidRootPart") then
                        local bossPos = boss.HumanoidRootPart.Position
                        
                        -- LOCK SKILL: Khóa cứng góc nhìn Camera thẳng vào tâm Boss
                        if workspace.CurrentCamera then
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, bossPos)
                        end
                        
                        -- SPAM ENERGY BLAST (Cơ chế Remote)
                        local remotes = RepStore:FindFirstChild("Remotes")
                        if remotes then
                            local blast = remotes:FindFirstChild("EnergyBlast") or remotes:FindFirstChild("AttackRemote") or remotes:FindFirstChild("KiBlast")
                            if blast then
                                blast:FireServer(bossPos)
                            end
                        end
                        
                        -- SPAM ENERGY BLAST (Cơ chế Click UI Mobile dự phòng)
                        local pGui = Plr:FindFirstChild("PlayerGui")
                        if pGui then
                            for _, gui in ipairs(pGui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled then
                                    for _, btn in ipairs(gui:GetDescendants()) do
                                        if (btn:IsA("ImageButton") or btn:IsA("TextButton")) and btn.Visible then
                                            local name = string.lower(btn.Name)
                                            if string.find(name, "blast") or string.find(name, "energy") or name == "e" or string.find(name, "slot1") then
                                                btn:Activate()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.02) -- Tốc độ xả đạn cực hạn
            end
        end)
    end
end)

-- 3. Auto Forms (Tự động biến hình trạng thái mạnh nhất)
Tab:NewToggle("Auto Forms", "Tự động kích hoạt Form biến hình tăng chỉ số", function(s)
    _G.AtomConfig.AutoForm = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoForm do
                pcall(function()
                    local char = Plr.Character
                    if char and not (char:FindFirstChild("Transformed") or char:FindFirstChild("ActiveForm")) then
                        local remotes = RepStore:FindFirstChild("Remotes")
                        local remote = remotes and (remotes:FindFirstChild("Transform") or remotes:FindFirstChild("TransformRemote")) or RepStore:FindFirstChild("TransformRemote")
                        if remote then 
                            remote:FireServer("EquipCurrentForm") 
                        end
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)

-- 4. Auto Ki (Tự động gồng Ki khi cạn năng lượng)
Tab:NewToggle("Auto Charge Ki", "Tự động gồng Ki khi năng lượng dưới 20%", function(s)
    _G.AtomConfig.AutoKi = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoKi do
                pcall(function()
                    local char = Plr.Character
                    if char then
                        local Ki = char:FindFirstChild("Ki") or char:FindFirstChild("Energy") or Plr:FindFirstChild("Stats"):FindFirstChild("Ki")
                        if Ki and Ki.Value < (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.20 then
                            local remotes = RepStore:FindFirstChild("Remotes")
                            local charge = remotes and (remotes:FindFirstChild("ChargeKi") or remotes:FindFirstChild("Charge"))
                            if charge then
                                charge:FireServer(true)
                                repeat task.wait(0.1) until Ki.Value >= Ki.MaxKi.Value or not _G.AtomConfig.AutoKi
                                charge:FireServer(false)
                            else
                                -- Click nút Gồng Ki trên màn hình nếu không tìm thấy Remote
                                local pGui = Plr:FindFirstChild("PlayerGui")
                                if pGui then
                                    for _, v in ipairs(pGui:GetDescendants()) do
                                        if (v:IsA("ImageButton") or v:IsA("TextButton")) and v.Visible and (string.find(string.lower(v.Name), "charge") or v.Name == "g") then
                                            v:Activate()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

-- =======================================================
-- HỆ THỐNG ĐIỀU KHIỂN & CHỐNG TREO MÁY
-- =======================================================

-- Tạo nút tròn "Atom" màu đỏ ẩn/hiện Menu
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)

-- Anti-AFK chống ngắt kết nối
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
