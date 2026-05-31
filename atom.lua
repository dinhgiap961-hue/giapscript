local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Win = Kavo.CreateLib("Atom Max Hub", "BloodTheme")
local Tab = Win:NewTab("Main"):NewSection("Atom Auto-Lock (High Fly)")

local Plr = game:GetService("Players").LocalPlayer
local RepStore = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")

_G.AtomConfig = {
    FlyAboveBoss = false,
    SpamDan = false,
    AutoKi = false,
    AutoEarring = false,
    AutoForm = false,
    RaidNext = false,
    RaidStart = false
}

-- Hàm quét lấy mục tiêu quái vật/boss gần nhất
local function getTargetMonster()
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
-- TÍNH NĂNG CHÍNH: BAY CAO + GHIM ĐẠN TRỰC DIỆN (ATOM LOCK)
-- =======================================================

-- 1. Tự động bay cao hẳn lên trên đầu Boss (Khoảng cách an toàn tuyệt đối)
Tab:NewToggle("Auto Fly High Above Boss", "Bay cao lên thêm để né chiêu boss và khóa góc nhìn xuống", function(s)
    _G.AtomConfig.FlyAboveBoss = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.FlyAboveBoss do
                pcall(function()
                    local char = Plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local target = getTargetMonster()
                    
                    if hrp and target and target:FindFirstChild("HumanoidRootPart") then
                        -- Triệt tiêu hoàn toàn lực rơi tự do
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        
                        -- Tăng độ cao lên 22 studs và xoay người hướng thẳng xuống mục tiêu
                        local targetPos = target.HumanoidRootPart.Position
                        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 22, 0), targetPos)
                    end
                end)
                task.wait(0.01) -- Duy trì liên tục để không bị rơi rớt khi boss di chuyển
            end
        end)
    end
end)

-- 2. Spam Đạn Ghim Thẳng Vào Boss (Atom Lock)
Tab:NewToggle("Spam Đạn Ghim Thẳng Boss", "Khóa mục tiêu từ trên cao, ép đạn cắm thẳng xuống Boss", function(s)
    _G.AtomConfig.SpamDan = s
    if s then
        task.spawn(function()
            while _G.AtomConfig.SpamDan do
                pcall(function()
                    local target = getTargetMonster()
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        local targetPos = target.HumanoidRootPart.Position
                        
                        -- Khóa góc camera nhìn thẳng xuống Boss để hướng đạn không bị lệch
                        if workspace.CurrentCamera then
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)
                        end
                        
                        -- CƠ CHẾ 1: Bắn tọa độ trực tiếp thông qua Remote mạng của Game
                        local attackRemote = RepStore:FindFirstChild("Remotes") and (RepStore.Remotes:FindFirstChild("EnergyBlast") or RepStore.Remotes:FindFirstChild("AttackRemote"))
                        if attackRemote then
                            attackRemote:FireServer(targetPos)
                        end
                        
                        -- CƠ CHẾ 2: Kích hoạt trực tiếp hệ thống nút kỹ năng hình tròn cảm ứng
                        local pGui = Plr:FindFirstChild("PlayerGui")
                        if pGui then
                            for _, gui in ipairs(pGui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled then
                                    for _, btn in ipairs(gui:GetDescendants()) do
                                        if (btn:IsA("ImageButton") or btn:IsA("TextButton")) and btn.Visible then
                                            local name = string.lower(btn.Name)
                                            if string.find(name, "skill") or string.find(name, "blast") or string.find(name, "attack") or string.find(name, "slot1") or name == "e" then
                                                btn:Activate()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.03) -- Tốc độ xả đạn liên tục siêu tốc
            end
        end)
    end
end)

-- =======================================================
-- CÁC TÍNH NĂNG BỔ TRỢ KHÁC (GIỮ NGUYÊN ỔN ĐỊNH)
-- =======================================================

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
                task.wait(0.5)
            end
        end)
    end
end)

Tab:NewToggle("Auto Bông Tai", "Tự động đeo bông tai Potara tăng sức mạnh", function(s)
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

Tab:NewToggle("Auto Form", "Tự động hóa trạng thái biến hình", function(s)
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

Tab:NewToggle("Auto Next Raid", "Tự động nhận thưởng và qua màn", function(s)
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

Tab:NewToggle("Auto Start Raid", "Tự động Ready sảnh chờ nhanh", function(s)
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

-- Tạo nút thu nhỏ Menu
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("KavoL") or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0,50,0,50) Btn.Position = UDim2.new(0,10,0,150) Btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Btn.Text = "Atom" Btn.TextColor3 = Color3.fromRGB(255,255,255) Btn.Font = Enum.Font.SourceSansBold Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,25)
Btn.MouseButton1Click:Connect(function() Kavo:ToggleUI() end)

-- Anti-AFK
Plr.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
