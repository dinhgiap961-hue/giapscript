local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Khởi tạo Remote từ code của bạn
local SkillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillRemote")

-- =======================================================
-- HOOK METHOD (BỎ QUA COOLDOWN & KIỂM TRA HỢP LỆ)
-- =======================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if self == SkillRemote and method == "FireServer" then
        if args[1] and type(args[1]) == "table" then
            args[1]["Time"] = 0
            args[1]["IsValid"] = true
        end
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- Khử GUI cũ nếu có
local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("PremiumAutoBossGui")
if oldGui then oldGui:Destroy() end

-- Khởi tạo ScreenGui
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Screen.Name = "PremiumAutoBossGui"
Screen.ResetOnSpawn = false

-- =======================================================
-- GIAO DIỆN CHÍNH (MAIN FRAME - DARK NEON)
-- =======================================================
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 220, 0, 240)
MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 1.5

-- Thanh Tiêu Đề (Title Bar)
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0

local TitleBarCorner = Instance.new("UICorner", TitleBar)
TitleBarCorner.CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "PREMIUM HUB VIP"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

-- Nút Thu Nhỏ (Minimize)
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.83, 0, 0.12, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BackgroundTransparency = 1

-- Container chứa các nút
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1

-- Hàm tạo nút custom
local function CreatePremiumButton(name, text, pos, color)
    local Btn = Instance.new("TextButton", Container)
    Btn.Name = name
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.Position = pos
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Btn.BackgroundColor3 = color
    Btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner", Btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    return Btn
end

-- Menu 3 Chức Năng Đã Đồng Bộ Logic Mới
local AutoBtn = CreatePremiumButton("AutoBtn", "🔴 AUTO TELE MONSTER: OFF", UDim2.new(0, 0, 0, 0), Color3.fromRGB(230, 50, 50))
local SkillBtn = CreatePremiumButton("SkillBtn", "🔥 AUTO SKILL 101: OFF", UDim2.new(0, 0, 0, 55), Color3.fromRGB(230, 50, 50))
local AuraBtn = CreatePremiumButton("AuraBtn", "⚡ KILL AURA TOOL: OFF", UDim2.new(0, 0, 0, 110), Color3.fromRGB(230, 50, 50))

-- System Kéo Thả Menu (Smooth Drag)
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.1), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Thu nhỏ/Mở rộng
local IsMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    local targetSize = IsMinimized and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 240)
    MinBtn.Text = IsMinimized and "+" or "-"
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- =======================================================
-- TRẠNG THÁI & THÔNG SỐ HOẠT ĐỘNG
-- =======================================================
local Active = false
local SkillActive = false
local AuraActive = false
local KillAuraRange = 25

-- Event Bật/Tắt Auto Tele Boss/Quái
AutoBtn.MouseButton1Click:Connect(function()
    Active = not Active
    AutoBtn.Text = Active and "🟢 AUTO TELE MONSTER: ON" or "🔴 AUTO TELE MONSTER: OFF"
    TweenService:Create(AutoBtn, TweenInfo.new(0.3), {BackgroundColor3 = Active and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(230, 50, 50)}):Play()
end)

-- Event Bật/Tắt Auto Skill 101
SkillBtn.MouseButton1Click:Connect(function()
    SkillActive = not SkillActive
    SkillBtn.Text = SkillActive and "🔥 AUTO SKILL 101: ON" or "🔥 AUTO SKILL 101: OFF"
    TweenService:Create(SkillBtn, TweenInfo.new(0.3), {BackgroundColor3 = SkillActive and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(230, 50, 50)}):Play()
end)

-- Event Bật/Tắt Kill Aura Gần
AuraBtn.MouseButton1Click:Connect(function()
    AuraActive = not AuraActive
    AuraBtn.Text = AuraActive and "⚡ KILL AURA TOOL: ON" or "⚡ KILL AURA TOOL: OFF"
    TweenService:Create(AuraBtn, TweenInfo.new(0.3), {BackgroundColor3 = AuraActive and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(230, 50, 50)}):Play()
end)

-- HÀM TÌM QUÁI MỚI (Đã thay thế toàn bộ code lọc Atom/Max bằng code của bạn cung cấp)
local function FindTargetMonster()
    local Char = Player.Character
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= Char then
            if obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                if obj:FindFirstChild("HumanoidRootPart") then
                    return obj -- Trả về quái hợp lệ đầu tiên tìm thấy
                end
            end
        end
    end
    return nil
end

-- =======================================================
-- CÁC VÒNG LẶP HOẠT ĐỘNG (LOOP SYSTEMS)
-- =======================================================

-- 1. Vòng lặp Dịch Chuyển Gầm Đầu (Theo logic tìm quái diện rộng mới)
RunService.Heartbeat:Connect(function()
    local Char = Player.Character
    if Active and Char and Char:FindFirstChild("HumanoidRootPart") then
        local Monster = FindTargetMonster()
        if Monster then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.PlatformStand = true end
            
            local TargetPos = Monster.HumanoidRootPart.Position + Vector3.new(0, 13, 0)
            Char.HumanoidRootPart.CFrame = CFrame.new(TargetPos, Monster.HumanoidRootPart.Position)
            Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            return
        end
    end
    
    if Char then
        local Humanoid = Char:FindFirstChildOfClass("Humanoid")
        if Humanoid then Humanoid.PlatformStand = false end
    end
end)

-- 2. VÒNG LẶP SPAM SKILL REMOTE TỰ ĐỘNG THEO YÊU CẦU
task.spawn(function()
    while true do
        if SkillActive then
            local Char = Player.Character
            if Char and Char:FindFirstChild("HumanoidRootPart") then
                -- Quét và xả skill thẳng vào toàn bộ quái trong workspace theo code của bạn
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= Char then
                        if obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                            local hrp = obj:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                SkillRemote:FireServer({
                                    ["SkillId"] = "101",
                                    ["Began"] = false,
                                    ["CFrame"] = Char.HumanoidRootPart.CFrame,
                                    ["Aim"] = hrp.Position,
                                    ["Target"] = obj,
                                    ["Type"] = 1
                                })
                                
                                SkillRemote:FireServer({
                                    ["SkillId"] = "101",
                                    ["Began"] = true,
                                    ["CFrame"] = Char.HumanoidRootPart.CFrame,
                                    ["Aim"] = hrp.Position,
                                    ["Target"] = obj,
                                    ["Type"] = 1
                                })
                            end
                        end
                    end
                end
            end
            task.wait(0.5) -- Delay 0.5 giây chuẩn từ code gốc của bạn để tránh crash game
        else
            task.wait(0.2)
        end
    end
end)

-- 3. Vòng lặp Kill Aura Tool (Hỗ trợ chém thêm bằng vũ khí khi đứng gần quái đang Tele)
task.spawn(function()
    while true do
        if AuraActive then
            local Char = Player.Character
            if Char and Char:FindFirstChild("HumanoidRootPart") then
                local Tool = Char:FindFirstChildOfClass("Tool")
                if Tool then
                    local Monster = FindTargetMonster()
                    if Monster then
                        local Distance = (Char.HumanoidRootPart.Position - Monster.HumanoidRootPart.Position).Magnitude
                        if Distance <= KillAuraRange then
                            Tool:Activate()
                        end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end)
