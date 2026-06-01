local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main")
local Section = Tab:NewSection("Automation")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

-- Tạo nút Thu Nhỏ trước, đợi Kavo load xong mới gắn
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AtomToggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0,50,0,50)
Btn.Position = UDim2.new(0,10,0,150)
Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom"
Btn.TextColor3 = Color3.fromRGB(255,255,255)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 16
Btn.ZIndex = 999
Btn.Parent = ScreenGui
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)

Btn.MouseButton1Click:Connect(function()
    Kavo:ToggleUI()
end)

-- Hàm tap nút mobile
local function tapButton(buttonName)
    local playerGui = Plr:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in pairs(playerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Name == buttonName and gui.Visible then
            local pos = gui.AbsolutePosition
            local size = gui.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait()
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
            return
        end
    end
end

-- Tạo nền tảng tàng hình
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
            if v.Humanoid.Health > 0 and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (v.HumanoidRootPart.Position - Plr.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; target = v end
            end
        end
    end
    return target
end

Section:NewToggle("Spam Energy Blast (R1)", "Xả skill R1", function(s)
    _G.EB = s
    while _G.EB do
        tapButton("R1")
        task.wait(0.1)
    end
end)

Section:NewToggle("Treo Trên Đầu Boss", "Bay cao an toàn", function(s)
    _G.Tp = s
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

Section:NewToggle("Auto Charge [L2]", "Tự charge ki", function(s)
    _G.AutoFushi = s
    while _G.AutoFushi do
        tapButton("L2")
        task.wait(2)
    end
end)

Section:NewToggle("Auto Transform [L5]", "Tự biến hình", function(s)
    _G.AutoForm = s
    while _G.AutoForm do
        tapButton("L5")
        task.wait(4)
    end
end)

Section:NewToggle("Auto Đánh [RA]", "Tự đánh thường", function(s)
    _G.AutoClick = s
    while _G.AutoClick do
        tapButton("RA")
        task.wait(0.1)
    end
end)

Section:NewButton("Ẩn Menu", "Thu nhỏ", function()
    Kavo:ToggleUI()
end)

-- Anti AFK
Plr.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
