local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main")
local Section = Tab:NewSection("Automation")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")

-- Tạo nền tảng tàng hình chống chết lỗi
local Plat = Instance.new("Part", workspace)
Plat.Size = Vector3.new(10,1,10)
Plat.Anchored = true
Plat.Transparency = 1
Plat.CanCollide = true
Plat.CFrame = CFrame.new(0, -1000, 0)

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

local function getRaids()
    local raidsFolder = workspace:FindFirstChild("Raids") or workspace:FindFirstChild("Raid")
    if raidsFolder then
        return raidsFolder:GetChildren()
    end
    return {}
end

-- Spam Energy Blast Siêu Tốc Độ
Section:NewToggle("Spam Energy Blast (E)", "Xả đạn nhanh hơn 20%", function(s)
    _G.EB = s
    task.spawn(function()
        while _G.EB do
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait()
        end
    end)
end)

-- Treo trên đầu Boss an toàn
Section:NewToggle("Treo Trên Đầu Boss", "Bay cao an toàn", function(s)
    _G.Tp = s
    task.spawn(function()
        while _G.Tp do
            pcall(function()
                local t = getMonster()
                local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                if t and hrp then
                    local cf = t.HumanoidRootPart.CFrame * CFrame.new(0, 45, 0)
                    Plat.CFrame = cf
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = cf * CFrame.new(0, 2.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                else
                    Plat.CFrame = CFrame.new(0, -1000, 0)
                end
            end)
            task.wait(0.01)
        end
        Plat.CFrame = CFrame.new(0, -1000, 0)
    end)
end)

-- Auto Lock Skill - tự ghim vào boss
Section:NewToggle("Auto Lock Skill", "Tự ghim skill vào boss", function(s)
    _G.AutoLock = s
    task.spawn(function()
        while _G.AutoLock do
            pcall(function()
                local boss = getMonster()
                if boss then
                    if RS:FindFirstChild("LockTarget") then
                        RS.LockTarget:FireServer(boss)
                    end
                    if RS:FindFirstChild("LockSkill") then
                        RS.LockSkill:FireServer(true)
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- Auto Boss - tự đánh boss gần nhất
Section:NewToggle("Auto Boss", "Tự động đánh boss", function(s)
    _G.AutoBoss = s
    task.spawn(function()
        while _G.AutoBoss do
            pcall(function()
                local boss = getMonster()
                local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                if boss and hrp then
                    local distance = (hrp.Position - boss.HumanoidRootPart.Position).Magnitude
                    if distance < 10 then
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, 15, 0) -- bay lên né đòn
                    end
                    if RS:FindFirstChild("Attack") then
                        RS.Attack:FireServer()
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end)

-- Auto Fushi
Section:NewToggle("Auto Fushi", "Tự bật Fushi", function(s)
    _G.AutoFushi = s
    task.spawn(function()
        while _G.AutoFushi do
            pcall(function()
                if RS:FindFirstChild("Fushi") then
                    RS.Fushi:FireServer(true)
                end
            end)
            task.wait(1)
        end
    end)
end)

-- Auto Form
Section:NewToggle("Auto Form", "Tự bật Form", function(s)
    _G.AutoForm = s
    task.spawn(function()
        while _G.AutoForm do
            pcall(function()
                if RS:FindFirstChild("Form") then
                    RS.Form:FireServer(true)
                end
            end)
            task.wait(1)
        end
    end)
end)

-- Auto Next Raid
local raidIndex = 1
Section:NewToggle("Auto Next Raid", "Tự chuyển raid tiếp theo", function(s)
    _G.AutoNextRaid = s
    task.spawn(function()
        while _G.AutoNextRaid do
            pcall(function()
                local raids = getRaids()
                if #raids > 0 then
                    local raid = raids[raidIndex]
                    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                    if raid and raid:FindFirstChild("HumanoidRootPart") and hrp then
                        hrp.CFrame = raid.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                        raidIndex = raidIndex + 1
                        if raidIndex > #raids then
                            raidIndex = 1
                        end
                    end
                end
            end)
            task.wait(3) -- 3s chuyển raid 1 lần
        end
    end)
end)

-- Auto Play Raid - bật tất cả
Section:NewToggle("Auto Play Raid", "Bật full auto raid", function(s)
    _G.AutoPlay = s
    _G.EB = s
    _G.Tp = s
    _G.AutoLock = s
    _G.AutoBoss = s
    _G.AutoFushi = s
    _G.AutoForm = s
    _G.AutoNextRaid = s
end)

-- Nút Thu Nhỏ tròn bên góc trái
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50)
Btn.Position = UDim2.new(0,10,0,150)
Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom"
Btn.TextColor3 = Color3.fromRGB(255,255,255)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function()
    Kavo:ToggleUI()
end)

Section:NewButton("Thu Nhỏ Menu", "Ẩn bảng", function()
    Kavo:ToggleUI()
end)

-- Anti AFK
Plr.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
