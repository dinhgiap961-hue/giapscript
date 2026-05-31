local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Automation (Bring Mob Version)")

local Plr = game:GetService("Players").LocalPlayer
local RepStore = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")

_G.AtomConfig = {
    BringMob = false,
    SpamDan = false,
    AutoKi = false,
    AutoEarring = false,
    AutoForm = false,
    RaidNext = false,
    RaidStart = false
}

-- Hàm gom quái về vị trí trước mặt người chơi
local function doBringMob()
    local char = Plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bringTargetPos = hrp.CFrame * CFrame.new(0, 0, -6)

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 and not v:FindFirstChild("ForceField") then
                v.HumanoidRootPart.Anchored = true
                v.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                v.HumanoidRootPart.CFrame = bringTargetPos
            end
        end
    end
end

-- =======================================================
-- TÍNH NĂNG CHÍNH: GOM QUÁI + ĐỨNG IM XẢ SKILL
-- =======================================================

-- 1. Bật Gom Quái & Khóa Vị Trí Nhân Vật
Tab:NewToggle("Auto Bring Mob (Gom Quái)", "Gom toàn bộ quái về trước mặt và khóa vị trí đứng im", function(s)
    _G.AtomConfig.BringMob = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.BringMob do
                pcall(function()
                    local char = Plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Anchored = true
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        doBringMob()
                    end
                end)
                task.wait(0.02)
            end
            pcall(function()
                if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                    Plr.Character.HumanoidRootPart.Anchored = false
                end
            end)
        end)
    end
end)

-- 2. Spam Đạn Đuổi (Phương pháp trang bị công cụ tự động kích hoạt)
Tab:NewToggle("Spam Đạn Đuổi", "Tự động kích hoạt chiêu thức từ xa vào vị trí gom quái", function(s)
    _G.AtomConfig.SpamDan = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.SpamDan do
                pcall(function()
                    local char = Plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if char and hrp then
                        local targetPos = (hrp.CFrame * CFrame.new(0, 0, -6)).Position
                        
                        -- Thử tìm Remote gốc của hệ thống trước
                        local attackRemote = RepStore:FindFirstChild("Remotes") and (RepStore.Remotes:FindFirstChild("EnergyBlast") or RepStore.Remotes:FindFirstChild("AttackRemote"))
                        if attackRemote then
                            attackRemote:FireServer(targetPos)
                        else
                            -- Nếu Remote bị đổi tên, tự động trang bị Tool đạn trong balo để kích hoạt chiêu thức
                            local tool = Plr.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
                            if tool then
                                if tool.Parent ~= char then
                                    tool.Parent = char -- Trang bị công cụ lên tay
                                end
                                tool:Activate() -- Kích hoạt kỹ năng tấn công của công cụ
                            end
                            
                            -- Giả lập nhấn phím kỹ năng dự phòng cho phiên bản Mobile
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.02)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
end)

-- 3. Tự động gồng Ki khi cạn năng lượng
Tab:NewToggle("Auto Charge Ki", "Tự động gồng Ki khi cạn năng lượng", function(s)
    _G.AtomConfig.AutoKi = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoKi do
                pcall(function()
                    local char = Plr.Character
                    if char then
                        local Ki = char:FindFirstChild("Ki") or char:FindFirstChild("Energy") or Plr:FindFirstChild("Stats"):FindFirstChild("Ki")
                        if Ki and Ki.Value < (Ki:FindFirstChild("MaxKi") and Ki.MaxKi.Value or 100) * 0.20 then
                            local chargeRemote = RepStore:FindFirstChild("Remotes") and RepStore.Remotes:FindFirstChild("ChargeKi")
                            if chargeRemote then
                                chargeRemote:FireServer(true)
                                repeat task.wait(0.2) until Ki.Value >= Ki.MaxKi.Value or not _G.AtomConfig.AutoKi
                                chargeRemote:FireServer(false)
                            else
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.G, false, game)
                                repeat task.wait(0.2) until Ki.Value >= Ki.MaxKi.Value or not _G.AtomConfig.AutoKi
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.G, false, game)
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

-- 4. Auto Bông Tai (Chạy ngầm tách biệt)
Tab:NewToggle("Auto Bông Tai", "Tự động đeo bông tai qua hệ thống mạng", function(s)
    _G.AtomConfig.AutoEarring = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoEarring do
                pcall(function()
                    local char = Plr.Character
                    if char and not (char:FindFirstChild("Fused") or char:FindFirstChild("Fusion")) then
                        local remote = RepStore:FindFirstChild("Remotes") and RepStore.Remotes:FindFirstChild("Potara") or RepStore:FindFirstChild("FusionRemote")
                        if remote then remote:FireServer(true) end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end)

-- 5. Auto Form (Chạy ngầm tách biệt)
Tab:NewToggle("Auto Form", "Tự động hóa trạng thái biến hình tối thượng", function(s)
    _G.AtomConfig.AutoForm = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.AutoForm do
                pcall(function()
                    local char = Plr.Character
                    if char and not (char:FindFirstChild("Transformed") or char:FindFirstChild("ActiveForm")) then
                        local remote = RepStore:FindFirstChild("Remotes") and RepStore.Remotes:FindFirstChild("Transform") or RepStore:FindFirstChild("TransformRemote")
                        if remote then remote:FireServer("EquipCurrentForm") end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end)

-- 6. Auto Next Raid
Tab:NewToggle("Auto Next Raid", "Tự động nhấn chuyển màn nhanh chóng", function(s)
    _G.AtomConfig.RaidNext = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.RaidNext do
                pcall(function()
                    local dungeonRemote = RepStore:FindFirstChild("Remotes") and (RepStore.Remotes:FindFirstChild("DungeonRemote") or RepStore.Remotes:FindFirstChild("RaidEvent"))
                    if dungeonRemote then
                        dungeonRemote:FireServer("NextRaid")
                        dungeonRemote:FireServer("ClaimRewards")
                    end
                    
                    local pGui = Plr:FindFirstChild("PlayerGui")
                    if pGui then
                        for _, v in ipairs(pGui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Visible then
                                local t = string.lower(v.Text)
                                local n = string.lower(v.Name)
                                if string.find(t, "create") or string.find(n, "create") or string.find(t, "tạo") or string.find(t, "next") or string.find(n, "next") or string.find(t, "leave") or string.find(n, "leave") then
                                    v:Activate()
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- 7. Auto Start Raid
Tab:NewToggle("Auto Start Raid", "Tự động bắt đầu trận sảnh chờ", function(s)
    _G.AtomConfig.RaidStart = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.RaidStart do
                pcall(function()
                    local lobbyRemote = RepStore:FindFirstChild("Remotes") and (RepStore.Remotes:FindFirstChild("LobbyRemote") or RepStore.Remotes:FindFirstChild("StartGame"))
                    if lobbyRemote then
                        lobbyRemote:InvokeServer("StartMatch")
                        lobbyRemote:FireServer("Ready")
                    end
                    
                    local pGui = Plr:FindFirstChild("PlayerGui")
                    if pGui then
                        for _, v in ipairs(pGui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Visible then
                                local t = string.lower(v.Text)
                                local n = string.lower(v.Name)
                                if string.find(t, "start") or string.find(n, "start") or string.find(t, "bắt đầu") or string.find(t, "ready") or string.find(n, "ready") or string.find(t, "play") or string.find(t, "join") then
                                    v:Activate()
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- Nút điều khiển ẩn/hiện bảng menu Kavo chính
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)

-- Kích hoạt chống treo máy tự động chống văng game (Anti-AFK)
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
