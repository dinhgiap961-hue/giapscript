local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- Lưu lại đối tượng Window để điều khiển ẩn/hiện
local window = library.CreateLib("Dragon Blox - Premium Hub", "DarkTheme")

local tab = window:NewTab("Auto Farm Boss")
local section = tab:NewSection("Cấu Hình Ghim Theo Boss")

local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CẤU HÌNH TỌA ĐỘ VÀ CHIỀU CAO (11 Studs)
local BOSS_SPAWN_POS = Vector3.new(-431.7525939941406, 1352.32275390625, 93.17485046386719)
local HEIGHT_ABOVE = 11

local AutoFarmBoss = false
local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
local lastActionTime = 0
local mainConnection

-- Hàm quét tìm Boss gần tọa độ để ghim vị trí liên tục
local function findLivingBoss()
    local targetHrp = nil
    local minDistance = 150
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            
            if hrp and humanoid and humanoid.Health > 0 then
                local distance = (hrp.Position - BOSS_SPAWN_POS).Magnitude
                if distance < minDistance then
                    targetHrp = hrp
                    break
                end
            end
        end
    end
    return targetHrp
end

-- Vòng lặp core xử lý bám đuôi Boss và xả chiêu thức
local function startFarmLoop()
    if mainConnection then mainConnection:Disconnect() end
    
    mainConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmBoss then
            if mainConnection then mainConnection:Disconnect() end
            return
        end
        
        local character = LocalPlayer.Character
        local myHrp = character and character:FindFirstChild("HumanoidRootPart")
        if not myHrp or not myHrp.Parent then return end
        
        local bossHrp = findLivingBoss()
        
        if bossHrp then
            -- Ghim chặt theo vị trí di chuyển thực tế của Boss
            myHrp.CFrame = bossHrp.CFrame * CFrame.new(0, HEIGHT_ABOVE, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        else
            -- Đứng chờ lơ lửng tại điểm Spawn khi Boss chưa xuất hiện
            myHrp.CFrame = CFrame.new(BOSS_SPAWN_POS.X, BOSS_SPAWN_POS.Y + HEIGHT_ABOVE, BOSS_SPAWN_POS.Z)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Auto Đấm thường & Xả chiêu thức
        local currentTime = tick()
        if currentTime - lastActionTime >= 0.25 then
            lastActionTime = currentTime
            
            task.spawn(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                for _, key in ipairs(skillKeys) do
                    if not AutoFarmBoss then break end
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.01)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
            end)
        end
    end)
end

-- =========================================================
-- NÚT BẤM THU NHỎ GIAO DIỆN MANG TÊN "DinhGiap"
-- =========================================================
section:NewToggle("DinhGiap", "Bật để THU NHỎ / Ẩn menu giao diện", function(state)
    -- Thư viện Kavo UI hỗ trợ hàm đóng/mở UI bằng cách giả lập bấm nút đóng menu
    local coreGui = game:GetService("CoreGui")
    local kavoGui = coreGui:FindFirstChild("Kavo") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Kavo")
    
    if kavoGui then
        -- Tìm đến khung giao diện chính của menu và ẩn/hiện nó đi
        local mainFrame = kavoGui:FindFirstChild("Main")
        if mainFrame then
            mainFrame.Visible = not state -- Nếu bật nút gạt thì ẩn Frame (Visible = false) và ngược lại
        end
    end
end)

-- Nút Bật/Tắt tính năng Auto Farm chính
section:NewToggle("Auto Lock & Farm Boss (11 Studs)", "Ghim theo Boss và xả chiêu", function(state)
    AutoFarmBoss = state
    if state then
        startFarmLoop()
    else
        if mainConnection then
            mainConnection:Disconnect()
            mainConnection = nil
        end
    end
end)
