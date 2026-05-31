local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Xóa sạch GUI cũ tránh trùng lặp dữ liệu
local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("AutoBossGui")
if oldGui then oldGui:Destroy() end

-- Khởi tạo ScreenGui
local Screen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Screen.Name = "AutoBossGui"
Screen.ResetOnSpawn = false

-- ==========================================
-- THIẾT KẾ BẢNG MENU VIP GỌN GÀNG (2 NÚT CHÍNH)
-- ==========================================
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 180, 0, 160) -- Thu gọn kích thước bảng
MainFrame.Position = UDim2.new(0.8, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Thanh Tiêu Đề
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(0.75, 0, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Text = "ATOM VIP PRO V5"
TitleText.TextColor3 = Color3.fromRGB(255, 215, 0) -- Màu vàng hoàng gia
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

-- Nút Thu Nhỏ / Phóng To
local ToggleSizeBtn = Instance.new("TextButton", TitleBar)
ToggleSizeBtn.Size = UDim2.new(0, 25, 0, 25)
ToggleSizeBtn.Position = UDim2.new(1, -30, 0, 5)
ToggleSizeBtn.Text = "-"
ToggleSizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleSizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleSizeBtn.Font = Enum.Font.SourceSansBold
ToggleSizeBtn.TextSize = 16

local BtnCorner = Instance.new("UICorner", ToggleSizeBtn)
BtnCorner.CornerRadius = UDim.new(0, 5)

local ButtonContainer = Instance.new("Frame", MainFrame)
ButtonContainer.Size = UDim2.new(1, 0, 1, -35)
ButtonContainer.Position = UDim2.new(0, 0, 0, 35)
ButtonContainer.BackgroundTransparency = 1

local function CreateMenuButton(name, text, posIndex, defaultColor)
    local btn = Instance.new("TextButton", ButtonContainer)
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, 12 + (posIndex * 52))
    btn.Text = text
    btn.BackgroundColor3 = defaultColor
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    return btn
end

local BossBtn = CreateMenuButton("BossBtn", "LOCK BOSS & LƠ LỬNG: OFF", 0, Color3.fromRGB(150, 0, 0))
local FarmBtn = CreateMenuButton("FarmBtn", "XẢ ĐẠN X10 & PHÁ SKILL: OFF", 1, Color3.fromRGB(150, 0, 0))

-- Logic phóng to / thu nhỏ
local isMinimized = false
ToggleSizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 180, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        ToggleSizeBtn.Text = "+"
        ButtonContainer.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 180, 0, 160), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        ToggleSizeBtn.Text = "-"
        ButtonContainer.Visible = true
    end
end)

-- Kéo thả UI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- ==========================================
-- QUẢN LÝ TRẠNG THÁI CHỨC NĂNG
-- ==========================================
local AutoBossActive = false
local AutoFarmActive = false

BossBtn.MouseButton1Click:Connect(function()
    AutoBossActive = not AutoBossActive
    BossBtn.Text = AutoBossActive and "LOCK BOSS & LƠ LỬNG: ON" or "LOCK BOSS & LƠ LỬNG: OFF"
    BossBtn.BackgroundColor3 = AutoBossActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(150, 0, 0)
    if not AutoBossActive then
        local Char = Player.Character
        if Char then 
            local Humn = Char:FindFirstChildOfClass("Humanoid") 
            if Humn then Humn.PlatformStand = false end 
        end
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    AutoFarmActive = not AutoFarmActive
    FarmBtn.Text = AutoFarmActive and "XẢ ĐẠN X10 & PHÁ SKILL: ON" or "XẢ ĐẠN X10 & PHÁ SKILL: OFF"
    FarmBtn.BackgroundColor3 = AutoFarmActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(150, 0, 0)
end)

-- Hàm quét tìm mục tiêu Boss Atom nhanh nhất
local function FindAnyMonster()
    local targetMonster = nil
    local shortestDistance = math.huge
    local myChar = Player.Character
    
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
                if v ~= myChar and not game.Players:GetPlayerFromCharacter(v) then
                    if v:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local distance = (myChar.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            targetMonster = v
                        end
                    end
                end
            end
        end
    end
    return targetMonster
end

-- ====================================================================
-- CHỨC NĂNG 1: LƠ LỬNG KHÔNG TRUNG & KHÓA CỨNG CAMERA VÀO BOSS ATOM
-- ====================================================================
RunService.RenderStepped:Connect(function()
    local Char = Player.Character
    local Camera = Workspace.CurrentCamera
    
    if AutoBossActive then
        local Monster = FindAnyMonster()
        if Monster and Monster:FindFirstChild("HumanoidRootPart") and Char and Char:FindFirstChild("HumanoidRootPart") then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.PlatformStand = true end
            
            -- Neo giữ nhân vật lơ lửng cố định trên một góc xéo cao so với Boss (Cách 40 mét)
            local BossPos = Monster.HumanoidRootPart.Position
            local FloatPosition = BossPos + Vector3.new(20, 40, 20)
            
            Char.HumanoidRootPart.CFrame = CFrame.new(FloatPosition, BossPos)
            Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Triệt tiêu trọng lực rơi tự do
            
            -- Khóa cứng camera từ vị trí lơ lửng nhìn thẳng vào tim Boss, chống xoay
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(FloatPosition + Vector3.new(0, 5, 10), BossPos)
        else
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
end)

-- ====================================================================
-- CHỨC NĂNG 2: XẢ ĐẠN X10 SIÊU CẤP VIP PRO & ĐÓNG BĂNG SKILL & GHIM ĐẠN
-- ====================================================================
local attackRemote = ReplicatedStorage:FindFirstChild("Attack", true) or ReplicatedStorage:FindFirstChild("Skill", true) or ReplicatedStorage:FindFirstChild("UseSkill", true)

-- Kích hoạt ép luồng bypass thời gian hồi chiêu hiển thị
if setfflag then
    pcall(function() setfflag("UserSkillCooldownBypass", "True") end)
end

local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.E}

-- HÀM LOGIC CHÍNH: ÉP VIÊN ĐẠN CHỌN MỤC TIÊU VÀ GHIM CHẶT VÀO QUÁI
local function ForceBulletToMonster(bullet, monsterRoot)
    if not bullet:IsA("BasePart") or bullet:FindFirstChild("AtomPinned") then return end
    if bullet.Anchored and bullet.Transparency == 1 then return end -- Bỏ qua các part tàng hình nền map
    
    -- Tạo đánh dấu tránh quét lặp
    local marker = Instance.new("BoolValue", bullet)
    marker.Name = "AtomPinned"
    
    -- Tắt vật lý cản trở ngay lập tức để đạn bay xuyên vật cản đến Boss
    bullet.CanCollide = false
    
    -- Ép đạn đổi CFrame (vị trí + hướng) bay thẳng vào tim Boss trong 0.05 giây
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(bullet, tweenInfo, {CFrame = monsterRoot.CFrame})
    tween:Play()
    
    tween.Completed:Connect(function()
        if monsterRoot and monsterRoot.Parent and bullet and bullet.Parent then
            bullet.Anchored = false
            -- Tạo mối hàn ghim chặt đạn dính hẳn vào quái vật
            local weld = Instance.new("WeldConstraint", monsterRoot)
            weld.Part0 = monsterRoot
            weld.Part1 = bullet
            
            -- Tự hủy đạn sau 3 giây để giải phóng bộ nhớ máy
            game:GetService("Debris"):AddItem(bullet, 3)
        end
    end)
end

-- Vòng lặp quản lý AutoFarm + Xả đạn x10 + Cưỡng chế ghim mục tiêu
task.spawn(function()
    while true do
        if AutoFarmActive then
            local Monster = FindAnyMonster()
            if Monster and Monster:FindFirstChild("HumanoidRootPart") then
                local targetPos = Monster.HumanoidRootPart.Position
                local monsterRoot = Monster.HumanoidRootPart
                local myChar = Player.Character
                
                -- SỬA LỖI: LUỒNG QUÉT SÂU (GETDESCENDANTS) - BẮT BẰNG ĐƯỢC MỌI VIÊN ĐẠN VỪA SINH RA QUANH BẠN
                task.spawn(function()
                    for _, child in pairs(Workspace:GetDescendants()) do
                        -- Kiểm tra nếu là Part, không thuộc người chơi, không thuộc quái vật
                        if child:IsA("BasePart") and not child:IsDescendantOf(myChar) and not child:IsDescendantOf(Monster.Parent) then
                            -- Nếu viên đạn xuất hiện trong bán kính 150 mét xung quanh bạn
                            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                local dist = (child.Position - myChar.HumanoidRootPart.Position).Magnitude
                                if dist < 150 then
                                    -- Ép viên đạn này chọn mục tiêu là con quái hiện tại
                                    ForceBulletToMonster(child, monsterRoot)
                                end
                            end
                        end
                    end
                end)
                
                -- LUỒNG XẢ ĐẠN X10 (MULTICAST CHỒNG GÓI TIN LÊN SERVER)
                if attackRemote and attackRemote:IsA("RemoteEvent") then
                    for i = 1, 10 do
                        attackRemote:FireServer(targetPos)
                        attackRemote:FireServer({["Target"] = Monster, ["Position"] = targetPos, ["Hit"] = true, ["DamageMultipier"] = 10})
                    end
                end
                
                -- LUỒNG PHÁ ĐÓNG BĂNG SKILL KHÔNG HỒI GIÂY
                for k = 1, #skillKeys do
                    VirtualInputManager:SendKeyEvent(true, skillKeys[k], false, game)
                    VirtualInputManager:SendKeyEvent(false, skillKeys[k], false, game)
                end
                
                task.wait(0.005)
            else
                task.wait(0.1)
            end
        else
            task.wait(0.3)
        end
    end
end)
