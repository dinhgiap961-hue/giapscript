local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main")
local Section = Tab:NewSection("Automation")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")

-- Hàm bấm nút ảo trên mobile
local function pressMobileButton(buttonName)
    local playerGui = Plr:WaitForChild("PlayerGui")
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            if gui.Name == buttonName or string.find(gui.Name, buttonName) then
                -- Giả lập bấm nút
                for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                    connection:Fire()
                end
                for _, connection in pairs(getconnections(gui.Activated)) do
                    connection:Fire()
                end
                return true
            end
        end
    end
    return false
end

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

-- Spam Energy Blast R1
Section:NewToggle("Spam Energy Blast (R1)", "Xả skill R1", function(s)
    _G.EB = s
    task.spawn(function()
        while _G.EB do
            pressMobileButton("R1")
            task.wait()
        end
    end)
end)

-- Treo Trên Đầu Boss
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

-- Auto Charge L2 = Fushi
Section:NewToggle("Auto Charge [L2]", "Tự charge ki", function(s)
    _G.AutoFushi = s
    task.spawn(function()
        while _G.AutoFushi do
            pressMobileButton("L2") -- Bấm nút L2
            task.wait(2) -- 2s charge 1 lần
        end
    end)
end)

-- Auto Transform L5 = Form
Section:NewToggle("Auto Transform [L5]", "Tự biến hình", function(s)
    _G.AutoForm = s
    task.spawn(function()
        while _G.AutoForm do
            pressMobileButton("L5") -- Bấm nút L5
            task.wait(4) -- 4s bấm 1 lần
        end
    end)
end)

-- Auto Đánh Thường RA
Section:NewToggle("Auto Đánh Thường [RA]", "Tự đánh", function(s)
    _G.AutoClick = s
    task.spawn(function()
        while _G.AutoClick do
            pressMobileButton("RA")
            task.wait(0.1)
        end
    end)
end)

-- Nút Thu Nhỏ
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50)
Btn.Position = UDim2.new(0,10,0,150)
Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom"
Btn.TextColor3 = Color3.fromRGB(255,255,255)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)

-- Anti AFK
Plr.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
