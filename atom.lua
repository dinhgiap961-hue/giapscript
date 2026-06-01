repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

-- XÓA GUI CŨ NẾU CÓ
if Plr.PlayerGui:FindFirstChild("DragonBloxV2") then
    Plr.PlayerGui.DragonBloxV2:Destroy()
end

-- TẠO GUI
local Gui = Instance.new("ScreenGui", Plr.PlayerGui)
Gui.Name = "DragonBloxV2"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 480, 0, 400)
Main.Position = UDim2.new(0.5, -240, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(90, 45, 130)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "Dragon Blox V2 - by Admin_script08"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(70, 30, 110)

-- HÀM TẠO NÚT BẬT/TẮT
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

-- 1. AUTO LOCK ATOM
createBtn("auto lock Atom", function(on)
    if on then
        return RS.RenderStepped:Connect(function()
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name:lower():find("atom") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        HRP.CFrame = CFrame.lookAt(HRP.Position, v.HumanoidRootPart.Position)
                        break
                    end
                end
            end)
        end)
    end
end)

-- 2. AUTO SKILL + GODMODE V2
createBtn("Auto Skill + Godmode V2 (Chạy Liên Tục)", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                Char.Humanoid.Health = Char.Humanoid.MaxHealth
                VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait()
                VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            end)
        end)
    end
end)

-- 3. AUTO KILL BOSS PREMIUM  
createBtn("Auto Kill Boss Premium", function(on)
    if on then
        return RS.RenderStepped:Connect(function()
            pcall(function()
                for _, boss in pairs(workspace:GetChildren()) do
                    if boss:IsA("Model") and boss:FindFirstChild("Humanoid") then
                        if boss.Humanoid.MaxHealth > 50000 and boss.Humanoid.Health > 0 then
                            HRP.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                        end
                    end
                end
            end)
        end)
    end
end)

-- 4. GODMODE
createBtn("Godmode", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function() Char.Humanoid.Health = Char.Humanoid.MaxHealth end)
        end)
    end
end)

-- 5. AUTO PHÊ PHA - NHẶT KI
createBtn("Auto phê pha", function(on)
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

-- 6. AUTO TRẤN SỈ PHOM - BẬT FORM
createBtn("Auto Trấn sỉ phom", function(on)
    if on then
        return RS.Heartbeat:Connect(function()
            pcall(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.G, false, game) -- G = form
                task.wait()
                VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game)
            end)
        end)
    end
end)

-- 7. AUTO DUNGEON V2
createBtn("Auto Start Work All Dungeon V2", function(on)
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

-- NÚT ẨN/HIỆN MENU
local Toggle = Instance.new("TextButton", Gui)
Toggle.Size = UDim2.new(0, 100, 0, 30)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.Text = "Ẩn/Hiện DB"
Toggle.BackgroundColor3 = Color3.fromRGB(90, 45, 130)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

print("Dragon Blox V2 Loaded - Đủ chức năng như ảnh")
