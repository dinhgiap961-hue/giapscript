-- ENERGY BLAST FREEZE SKILL V7.1 - KEYBIND G
local Plr = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local enabled = false
local flyPos = nil
local blastRemote = nil
local currentBoss = nil

-- TÌM REMOTE ENERGY BLAST
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local n = v.Name:lower()
        if string.find(n, "blast") or string.find(n, "energy") or string.find(n, "beam") or string.find(n, "ki") then
            blastRemote = v
            print("Found Energy Blast Remote:", v.Name)
            break
        end
    end
end

-- AUTO LOCK BOSS
local function lockBoss()
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Name ~= Plr.Name and v.Humanoid.Health > 0 then
                return v
            end
        end
    end
end

-- BẬT/TẮT = PHÍM G
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        enabled = not enabled
        if enabled then
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then flyPos = hrp.CFrame + Vector3.new(0, 35, 0) end
            currentBoss = lockBoss()
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="FREEZE BLAST ON",Text="No CD + Đứng im",Duration=2})
        else
            flyPos = nil
            currentBoss = nil
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="OFF",Text="Đã tắt",Duration=1})
        end
    end
end)

-- THREAD 1: ĐÓNG BĂNG NHÂN VẬT + ĐÓNG BĂNG SKILL NO CD
RunService.Heartbeat:Connect(function()
    if enabled then
        pcall(function()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            -- 1. ĐÓNG BĂNG VỊ TRÍ TRÊN CAO
            if hrp and flyPos then
                hrp.CFrame = flyPos
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
            
            -- 2. ĐÓNG BĂNG SKILL - NO CD VĨNH VIỄN
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    -- XÓA TẤT CẢ COOLDOWN
                    if v:IsA("NumberValue") and (string.find(v.Name:lower(), "cool") or string.find(v.Name:lower(), "cd") or string.find(v.Name:lower(), "delay")) then
                        v.Value = 0
                    end
                    -- KHÓA TRẠNG THÁI ĐANG DÙNG SKILL
                    if v:IsA("BoolValue") and (string.find(v.Name:lower(), "skill") or string.find(v.Name:lower(), "attack") or string.find(v.Name:lower(), "blast") or string.find(v.Name:lower(), "using")) then
                        v.Value = true
                    end
                    -- KHÓA MANA/KI KHÔNG TỤT
                    if v:IsA("NumberValue") and (string.find(v.Name:lower(), "mana") or string.find(v.Name:lower(), "ki") or string.find(v.Name:lower(), "energy")) then
                        v.Value = v.MaxValue or 9999
                    end
                end
            end
            
            -- 3. GODMODE
            if hum then
                hum.Health = hum.MaxHealth
                hum.MaxHealth = math.huge
            end
        end)
    end
end)

-- THREAD 2: SPAM ENERGY BLAST KHÔNG HỒI CHIÊU
while task.wait(0.03) do -- 33 lần/giây
    if enabled then
        pcall(function()
            if not currentBoss or not currentBoss:FindFirstChild("Humanoid") or currentBoss.Humanoid.Health <= 0 then
                currentBoss = lockBoss()
            end
            
            if blastRemote and currentBoss and currentBoss:FindFirstChild("HumanoidRootPart") then
                local pos = currentBoss.HumanoidRootPart.Position
                -- SPAM 3 KIỂU ARG PHỔ BIẾN NHẤT CỦA ENERGY BLAST
                pcall(function() blastRemote:FireServer(pos) end) -- Kiểu 1: Chỉ vị trí
                pcall(function() blastRemote:FireServer(currentBoss) end) -- Kiểu 2: Target Model
                pcall(function() blastRemote:FireServer("EnergyBlast", pos) end) -- Kiểu 3: Tên skill + pos
            end
        end)
    end
end
