local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom God-Speed Melee V6", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Bypass Fast Melee Mode")

local Plr = game:GetService("Players").LocalPlayer
local RepStore = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

_G.AtomConfig = {
    FlyAboveBoss = false,
    SuperFastMelee = false,
    AutoKi = false,
    AutoForm = false
}

-- Hàm quét lấy mục tiêu Boss/Quái chuẩn xác
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
-- CORE TÍNH NĂNG: ĐẤM THƯỜNG BYPASS + FLY 30CM
-- =======================================================

-- 1. Bay siêu sát trên đầu Boss (30cm - Khoảng cách bắt buộc để đấm trúng)
Tab:NewToggle("Auto Fly Above Boss (30cm)", "Ghim sát rạt trên đầu để tầm đánh Melee chạm trúng Boss", function(s)
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
                        local bossPos = boss.HumanoidRootPart.Position
                        -- Ép đứng cực sát để bảo đảm khoảng cách đấm vật lý ăn sát thương
                        hrp.CFrame = CFrame.new(bossPos + Vector3.new(0, 1.0, 0), bossPos)
                    end
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end
end)

-- 2. TÍNH NĂNG ĐẤM THƯỜNG SIÊU NHANH BYPASS (FAST MELEE V6)
Tab:NewToggle("ULTRA FAST MELEE (BYPASS)", "Bật đấm thường siêu tốc bỏ qua giới hạn hoạt ảnh", function(s)
    _G.AtomConfig.SuperFastMelee = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.SuperFastMelee do
                pcall(function()
                    local char = Plr.Character
                    local boss = getAbsoluteBoss()
                    
                    if char and boss and boss:FindFirstChild("HumanoidRootPart") then
                        -- BƯỚC 1: Tự động lôi vũ khí đấm thường (Combat/Punch) ra tay
                        local backpack = Plr:FindFirstChild("Backpack")
                        if backpack then
                            local combatTool = backpack:FindFirstChild("Combat") or backpack:FindFirstChild("Punch") or backpack:FindFirstChild("Melee") or backpack:FindFirstChild("Combat V2")
                            if combatTool and char:目標 không có vũ khí trên tay thì tự đeo vào
                            then
                                char.Humanoid:EquipTool(combatTool)
                            end
                        end
                        
                        -- BƯỚC 2: Ép hoạt ảnh vung tay liên tục bằng cách kích hoạt Tool trực tiếp
                        local currentTool = char:FindFirstChildOfClass("Tool")
                        if currentTool then
                            currentTool:Activate()
                        end
                        
                        -- BƯỚC 3: Giả lập click chuột trái/chạm màn hình cảm ứng siêu tốc với tần suất cao
                        VU:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        VU:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        
                        -- BƯỚC 4: Bắn lệnh gọi đấm thẳng lên Server dự phòng (Gửi 3 luồng liên tiếp)
                        local remotes = RepStore:FindFirstChild("Remotes") or RepStore:FindFirstChild("Events")
                        if remotes then
                            local punchRemote = remotes:FindFirstChild("Attack") or remotes:FindFirstChild("Combat") or remotes:FindFirstChild("Punch")
                            if punchRemote then
                                punchRemote:FireServer()
                                punchRemote:FireServer()
                            end
                        end
                    end
                end)
                -- Sử dụng vòng lặp RenderStepped để đẩy tốc độ bấm nút lên nhanh nhất theo FPS của máy bạn
                RunService.RenderStepped:Wait()
            end
        end)
    end
end)

-- =======================================================
-- TỰ ĐỘNG BỔ TRỢ (AUTO FORM & AUTO KI)
-- =======================================================

Tab:NewToggle("Auto Forms", "Tự động hóa trạng thái biến hình mạnh nhất", function(s)
    _G.AtomConfig.AutoForm = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoForm do
                pcall(function()
                    local char = Plr.Character
                    if char and not (char:FindFirstChild("Transformed") or char:FindFirstChild("ActiveForm")) then
                        local remotes = RepStore:FindFirstChild("Remotes")
                        local remote = remotes and (remotes:FindFirstChild("Transform") or remotes:FindFirstChild("TransformRemote")) or RepStore:FindFirstChild("TransformRemote")
                        if remote then remote:FireServer("EquipCurrentForm") end
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)

Tab:NewToggle("Auto Charge Ki", "Tự động gồng Ki siêu tốc khi cạn năng lượng", function(s)
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
                                repeat task.wait(0.05) until Ki.Value >= Ki.MaxKi.Value or not _G.AtomConfig.AutoKi
                                charge:FireServer(false)
                            else
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
                task.wait(0.3)
            end
        end)
    end
end)

-- Nút tròn "Atom" ẩn hiện menu màu đỏ
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)

-- Anti-AFK tránh mất kết nối
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
