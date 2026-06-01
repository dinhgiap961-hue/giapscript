repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

if Plr.PlayerGui:FindFirstChild("DragonBloxV2") then
    Plr.PlayerGui.DragonBloxV2:Destroy()
end

local Gui = Instance.new("ScreenGui", Plr.PlayerGui)
Gui.Name = "DragonBloxV2"
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
Title.Text = "Dragon Blox V2 - FINAL"
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

-- Hàm lấy % Ki
local function getKiPercent()
    local stats = Char:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Ki") and stats:FindFirstChild("MaxKi") then
        return (stats.Ki.Value / stats.MaxKi.Value) * 100
    end
    return 100
end

-- 1. AUTO LOCK ALL + DÍ THEO QUÁI
local bodyGyro, bodyPos
createBtn("Auto Lock ALL - Dí theo", function(on)
    if on then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 5000
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.Parent = HRP
        
        bodyPos = Instance.new("BodyPosition")
        bodyPos.P = 10000
        bodyPos.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyPos.Parent = HRP
        
        return RS.Heartbeat:Connect(function()
            pcall(function()
                local closest, dist = nil, 9999
                for _, v in pairs(workspace:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Name ~= Plr.Name then
                        local mag = (HRP.Position - v.HumanoidRootPart.Position).Magnitude
                        if mag < dist and mag < 200 then
                            dist = mag
                            closest = v
                        end
                    end
                end
                
                if closest then
                    local targetPos = closest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    bodyGyro.CFrame = CFrame.lookAt(HRP.Position, closest.HumanoidRootPart.Position)
                    bodyPos.Position = targetPos.Position
                else
                    bodyPos.Position = HRP.Position
                end
            end)
        end)
    else
        if bodyGyro then bodyGyro:Destroy() end
        if bodyPos then bodyPos:Destroy() end
    end
end)

-- 2. HITBOX 50X50
createBtn("Hitbox 50x50 - Farm xa", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        if v.Name ~= Plr.Name then
                            v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            v.HumanoidRootPart.Transparency = 0.8
                            v.HumanoidRootPart.CanCollide = false
                        end
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

-- 3. AUTO SKILL E + GODMODE
createBtn("Auto Skill E + Godmode", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                Char.Humanoid.Health = Char.Humanoid.MaxHealth
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end)
    end
end)

-- 4. AUTO KILL BOSS ĐỨNG XA
createBtn("Auto Kill Boss - Đứng xa", function(on)
    if on then
        return RS.RenderStepped:Connect(function()
            pcall(function()
                for _, boss in pairs(workspace:GetChildren()) do
                    if boss:IsA("Model") and boss:FindFirstChild("Humanoid") then
                        if boss.Humanoid.MaxHealth > 50000 and boss.Humanoid.Health > 0 then
                            HRP.CFrame = CFrame.lookAt(HRP.Position, boss.HumanoidRootPart.Position)
                            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
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
            pcall(function() Char.Humanoid.Health = Char.Humanoid.MaxHealth end)
        end)
    end
end)

-- 6. AUTO PHÊ PHA GIỮ C - FIX CHUẨN
local dangSacKi = false
createBtn("Auto Phê Pha <20% >90%", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                local kiPercent = getKiPercent()
                if kiPercent < 20 and not dangSacKi then
                    VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                    dangSacKi = true
                    print("Ki < 20% -> Giữ C")
                elseif kiPercent >= 90 and dangSacKi then
                    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                    dangSacKi = false
                    print("Ki > 90% -> Nhả C")
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

-- 7. AUTO FORM THÔNG MINH - CHỐNG SPAM
local formCooldown = false
createBtn("Auto Form - Check Form", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                local stats = Char:FindFirstChild("Stats")
                if not stats or not stats:FindFirstChild("Form") then return end
                
                local dangForm = stats.Form.Value ~= "Base"
                
                if not dangForm and not formCooldown then
                    formCooldown = true
                    print("Chưa có form -> Bấm Y")
                    VIM:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                    task.wait(0.2)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                    task.wait(3) -- Delay 3s chống spam
                    formCooldown = false
                elseif dangForm then
                    print("Đã có form:", stats.Form.Value)
                end
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

print("Dragon Blox V2 - FULL FIXED ĐÃ LOAD")
