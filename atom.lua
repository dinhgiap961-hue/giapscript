local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Automation")

local Plr = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")

-- Tạo nền tảng tàng hình chống chết lỗi
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

-- Spam Energy Blast Siêu Tốc Độ (Đã tăng tốc 20%, loại bỏ delay không cần thiết)
Tab:NewToggle("Spam Energy Blast (E)", "Xả đạn nhanh hơn 20%", function(s)
    _G.EB = s
    task.spawn(function()
        while _G.EB do
            -- Ép phím bấm phản hồi ngay lập tức trên từng khung hình hệ thống
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait() -- Chạy trực tiếp theo tốc độ xử lý của máy (tối đa tần suất)
        end
    end)
end)

-- Treo trên đầu Boss an toàn
Tab:NewToggle("Treo Trên Đầu Boss", "Bay cao an toàn", function(s)
    _G.Tp = s
    task.spawn(function()
        while _G.Tp do
            pcall(function()
                local t = getMonster()
                local hrp = Plr.Character.HumanoidRootPart
                if t and hrp then
                    local cf = t.HumanoidRootPart.CFrame * CFrame.new(0, 45, 0)
                    Plat.CFrame = cf
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = cf * CFrame.new(0, 2.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                else Plat.CFrame = CFrame.new(0, -1000, 0) end
            end)
            task.wait(0.01)
        end
        Plat.CFrame = CFrame.new(0, -1000, 0)
    end)
end)

-- Nút Thu Nhỏ tròn bên góc trái
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)
Tab:NewButton("Thu Nhỏ Menu", "Ẩn bảng", function() Kavo:ToggleUI() end)

-- Anti AFK
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
