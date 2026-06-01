repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

if Plr.PlayerGui:FindFirstChild("DragonBloxV3") then
    Plr.PlayerGui.DragonBloxV3:Destroy()
end

local Gui = Instance.new("ScreenGui", Plr.PlayerGui)
Gui.Name = "DragonBloxV3"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 480, 0, 530)
Main.Position = UDim2.new(0.5, -240, 0.5, -265)
Main.BackgroundColor3 = Color3.fromRGB(90, 45, 130)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "Dragon Blox V3 - ANTI CRASH"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(70, 30, 110)

local YPos = 45
local function createBtn(name, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0.9, 0, 0, 30)
    Btn.Position = UDim2.new(0.05, 0, 0, YPos)
    Btn.Text = name .. ": OFF"
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 14
    
    local state = false
    local con = nil
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name .. (state and ": ON" or ": OFF")
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
        if con then con:Disconnect() con = nil end
        con = callback(state)
    end)
    YPos = YPos + 35
end

local function getKiPercent()
    local stats = Char:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Ki") and stats:FindFirstChild("MaxKi") then
        return (stats.Ki.Value / stats.MaxKi.Value) * 100
    end
    return 100
end

local isAttacking = false -- Check đang dùng skill

-- 1. AUTO LOCK ALL - CHỈ XOAY, KHÔNG TELE
createBtn("Auto Lock ALL - Chỉ Xoay", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                if not Char or not HRP or Hum.Health <= 0 or isAttacking then return end
                
                local closest, dist = nil, 9999
                for _, v in pairs(workspace:GetChildren()) do
                    local hum = v:FindFirstChild("Humanoid")
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp and hum and hum.Health > 0 and v.Name ~= Plr.Name and not hrp.Anchored then
                        local mag = (HRP.Position - hrp.Position).Magnitude
                        if mag < dist and mag < 200 then
                            dist = mag
                            closest = hrp
                        end
                    end
                end
                
                if closest then
                    -- Chỉ xoay mặt, không tele để tránh gãy animation
                    local lookAt = CFrame.lookAt(HRP.Position, Vector3.new(closest.Position.X, HRP.Position.Y, closest.Position.Z))
                    HRP.CFrame = HRP.CFrame:Lerp(lookAt, 0.2)
                end
            end)
        end)
    end
end)

-- 2. HITBOX 50X50
createBtn("Hitbox 50x50 - Farm xa", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    local hum = v:FindFirstChild("Humanoid")
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and v.Name ~= Plr.Name then
                        hrp.Size = Vector3.new(50, 50, 50)
                        hrp.Transparency = 0.8
                        hrp.CanCollide = false
                    end
                end
            end)
        end)
    else
        for _, v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") then
                pcall(function() v.HumanoidRootPart.Size = Vector3.new(2, 2, 1) end)
            end
        end
    end
end)

-- 3. AUTO SKILL E - CÓ KHÓA CHỐNG CRASH
createBtn("Auto Skill E + Godmode", function(on)
    if on then
        return task.spawn(function()
            while on and task.wait(0.5) do -- Delay 0.5s cho chắc
                pcall(function()
                    if not Char or Hum.Health <= 0 or isAttacking then return end
                    isAttacking = true
                    Hum.Health = Hum.MaxHealth
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.2)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.5) -- Đợi skill ra hết
                    isAttacking = false
                end)
            end)
        end)
    end
end)

-- 4. AUTO KILL BOSS ĐỨNG XA
createBtn("Auto Kill Boss - Đứng xa", function(on)
    if on then
        return RS.RenderStepped:Connect(function()
            pcall(function()
                if isAttacking then return end
                for _, boss in pairs(workspace:GetChildren()) do
                    local hum = boss:FindFirstChild("Humanoid")
                    local hrp = boss:FindFirstChild("HumanoidRootPart")
                    if boss:IsA("Model") and hum and hrp then
                        if hum.MaxHealth > 50000 and hum.Health > 0 then
                            HRP.CFrame = CFrame.lookAt(HRP.Position, hrp.Position)
                        end
                    end
                end
            end)
        end)
    end
end)

-- 5. GODMODE RIÊNG
createBtn("Godmode", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function() if Hum then Hum.Health = Hum.MaxHealth end end)
        end)
    end
end)

-- 6. AUTO PHÊ PHA GIỮ C
local dangSacKi = false
createBtn("Auto Phê Pha <20% >90%", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                if not Char or isAttacking then return end
                local kiPercent = getKiPercent()
                if kiPercent < 20 and not dangSacKi then
                    VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                    dangSacKi = true
                elseif kiPercent >= 90 and dangSacKi then
                    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                    dangSacKi = false
                end
            end)
        end)
    else
        if dangSacKi then
            VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
            dangSacKi = false
        end
    end
end)

-- 7. AUTO FORM CHỐNG SPAM
local formCooldown = false
createBtn("Auto Form - Check Form", function(on)
    if on then
        return task.spawn(function()
            while on and task.wait(0.5) do
                pcall(function()
                    if not Char or isAttacking then return end
                    local stats = Char:FindFirstChild("Stats")
                    if not stats or not stats:FindFirstChild("Form") then return end
                    
                    local dangForm = stats.Form.Value ~= "Base"
                    
                    if not dangForm and not formCooldown then
                        formCooldown = true
                        isAttacking = true
                        VIM:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                        task.wait(0.2)
                        VIM:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                        task.wait(3)
                        isAttacking = false
                        formCooldown = false
                    end
                end)
            end)
        end)
    end
end)

-- 8. AUTO NHẶT KI
createBtn("Auto Nhặt Ki", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name == "Ki" and v:IsA("Part") then
                        v.CFrame = HRP.CFrame
                    end
                end
            end)
        end)
    end
end)

-- 9. AUTO DUNGEON
createBtn("Auto Vào Dungeon", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name == "DungeonStart" and v:IsA("Part") then
                        HRP.CFrame = v.CFrame
                    end
                end
            end)
        end)
    end
end)

local Toggle = Instance.new("TextButton", Gui)
Toggle.Size = UDim2.new(0, 100, 0, 30)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.Text = "Ẩn/Hiện"
Toggle.BackgroundColor3 = Color3.fromRGB(90, 45, 130)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

Plr.CharacterAdded:Connect(function(newChar)
    Char = newChar
    HRP = newChar:WaitForChild("HumanoidRootPart")
    Hum = newChar:WaitForChild("Humanoid")
end)

print("Dragon Blox V3 - ANTI CRASH LOADED")
