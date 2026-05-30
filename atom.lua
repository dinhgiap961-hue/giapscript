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

-- 1. Spam chiêu E siêu tốc độ theo FPS
Tab:NewToggle("Spam Energy Blast (E)", "Xả đạn tốc độ tối đa theo FPS", function(s)
    _G.EB = s
    if s then
        task.spawn(function()
            while _G.EB do
                if not _G.Charge then
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
                RunService.Stepped:Wait()
            end
        end)
    end
end)

-- 2. Tự động gồng Ki khi năng lượng xuống thấp (Phím G)
Tab:NewToggle("Auto Charge Ki (G)", "Tự động gồng Ki bằng phím G", function(s)
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

-- 3. Treo trên đầu Boss né skill + Tự đứng im khi xong trận
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

-- 4. TỰ ĐỘNG BẤM REPLAY/NEXT (BẢN ĐÃ SỬA LỖI - QUÉT SÂU)
Tab:NewToggle("Auto Next Raid", "Tự động kích hoạt trận mới", function(s)
    _G.Raid = s
    task.spawn(function()
        while _G.Raid do
            pcall(function()
                -- Quét diện rộng toàn bộ CoreGui và PlayerGui để tránh bỏ sót nút
                local guis = {Plr.PlayerGui, game:GetService("CoreGui")}
                for _, parent in ipairs(guis) do
                    for _, v in ipairs(parent:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.AbsoluteSize.X > 0 then
                            -- Thu thập tên nút, văn bản hiển thị để đối chiếu từ khóa công phá
                            local n = string.lower(v.Name)
                            local t = string.lower(v:IsA("TextButton") and v.Text or "")
                            
                            -- Bộ từ khóa nhận diện tất cả các kiểu nút Chơi lại / Tiếp tục trong các game Anime
                            if string.find(n, "replay") or string.find(n, "retry") or string.find(n, "again") or string.find(n, "next") or string.find(n, "teleport") or string.find(n, "start") or
                               string.find(t, "replay") or string.find(t, "retry") or string.find(t, "again") or string.find(t, "next") or string.find(t, "chơi lại") or string.find(t, "tiếp tục") then
                                
                                -- Ép kích hoạt nút bằng mọi cách (Cả lệnh nội bộ lẫn giả lập click tọa độ ảo)
                                v:Activate()
                                local pos = v.AbsolutePosition + (v.AbsoluteSize / 2)
                                VU:ClickButton1(Vector2.new(pos.X, pos.Y))
                            end
                        end
                    end
                end
            end)
            task.wait(1) -- Quét liên tục mỗi giây khi hết trận
        end
    end)
end)

-- 5. Nút sửa lỗi mất Joystick di chuyển trên điện thoại
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
