local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Automation")

local Plr = game:GetService("Players").LocalPlayer
local RepStore = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")

_G.AtomConfig = {
    SpamDan = false,
    AutoKi = false,
    AutoEarring = false,
    AutoForm = false,
    RaidNext = false,
    RaidStart = false
}

-- Tìm mục tiêu quái vật gần nhất để định vị sát thương
local function getMonster()
    local target, dist = nil, math.huge
    local char = Plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Name ~= Plr.Name then
            if v.Humanoid.Health > 0 and not v:FindFirstChild("ForceField") then
                local d = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then 
                    dist = d
                    target = v 
                end
            end
        end
    end
    return target
end

-- =======================================================
-- 1. XOÁ XOAY CAM - CHỈ CẦN TUNG SKILL LÀ TỰ TRÚNG QUÁI
-- =======================================================
Tab:NewToggle("Spam Đạn Đuổi", "Nhân vật đứng im, sát thương tự động nổ trên người quái", function(s)
    _G.AtomConfig.SpamDan = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.SpamDan do
                pcall(function()
                    local target = getMonster()
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        -- Không xoay camera, gửi thẳng tọa độ quái vào Server để đạn tự tìm đến trúng 100%
                        local attackRemote = RepStore:FindFirstChild("Remotes") and RepStore.Remotes:FindFirstChild("EnergyBlast") or RepStore:FindFirstChild("AttackRemote")
                        if attackRemote then
                            attackRemote:FireServer(target.HumanoidRootPart.Position)
                        else
                            -- Phương án dự phòng nếu game chặn Remote
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.02)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                    else
                        -- Khi hết quái, khóa cứng nhân vật đứng im tại chỗ để nhận thưởng an toàn
                        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                            Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                            Plr.Character.HumanoidRootPart.Anchored = true
                        end
                    end
                end)
                task.wait(0.05)
            end
            -- Tắt hack thì mở khóa di chuyển bình thường
            if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                Plr.Character.HumanoidRootPart.Anchored = false
            end
        end)
    end
end)

-- 2. Tự động gồng Ki khi cạn năng lượng
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

-- 3. Auto Bông Tai (Luồng độc lập hoàn toàn - Không lo loạn phím)
Tab:NewToggle("Auto Bông Tai", "Tự động kích hoạt bông tai Potara qua hệ thống", function(s)
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
                task.wait(4)
            end
        end)
    end
end)

-- 4. Auto Form (Luồng độc lập hoàn toàn - Không lo loạn phím)
Tab:NewToggle("Auto Form", "Tự động lên trạng thái biến hình mạnh nhất", function(s)
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
                task.wait(4)
            end
        end)
    end
end)

-- 5. Auto Next Raid (Sửa lỗi kẹt màn hình nhận thưởng)
Tab:NewToggle("Auto Next Raid", "Tự động qua màn kế tiếp sử dụng hệ thống gọi từ xa", function(s)
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
                    
                    -- Kích hoạt tất cả nút bấm "Next", "Leave", "Tạo phòng" có trên màn hình
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

-- 6. Auto Start Raid (Sửa lỗi phòng chờ kẹt trận)
Tab:NewToggle("Auto Start Raid", "Tự động bắt đầu trận đấu ngay khi vào sảnh phòng chờ", function(s)
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
                    
                    -- Tự động click kích hoạt nút sảnh chờ ảo
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

-- Nút hỗ trợ hiển thị lại nút di chuyển cảm ứng bị ẩn lỗi
Tab:NewButton("Hiện Nút Di Chuyển", "Khắc phục lỗi mất thanh điều hướng ảo", function()
    pcall(function()
        local tg = Plr.PlayerGui:FindFirstChild("TouchGui")
        if tg then tg.Enabled = false task.wait(0.1) tg.Enabled = true end
    end)
end)

-- Nút điều khiển ẩn/hiện bảng menu Kavo chính
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)
Tab:NewButton("Thu Nhỏ Menu", "Bấm để ẩn bảng giao diện chính", function() Kavo:ToggleUI() end)

-- Kích hoạt chống treo máy tự động chống văng game (Anti-AFK)
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
