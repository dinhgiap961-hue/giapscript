-- AUTO Q + KILL AURA BOSS MAP 3
local Plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local BossList = {
    ["Atom X002"] = CFrame.new(3298.8, 6.7, 3295.3),
    ["Brawly X 01"] = CFrame.new(-816.6, 497.7, 1100.2),
    ["Jigray X"] = CFrame.new(-4129.4, 21.3, -4582.5),
    ["Puriza X003"] = CFrame.new(-50.2, 42.0, -8454.4),
    ["Zero"] = CFrame.new(4988.5, 14.8, -4197.0),
}

-- GUI
if game.CoreGui:FindFirstChild("BossQGUI") then game.CoreGui.BossQGUI:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BossQGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 210)
Frame.Position = UDim2.new(0, 10, 0.5, -105)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1,0,0,25)
Label.Text = "AUTO Q + KILL BOSS"
Label.TextColor3 = Color3.fromRGB(255,50,50)
Label.BackgroundColor3 = Color3.fromRGB(40,40,40)
Label.TextScaled = true
Label.Font = Enum.Font.SourceSansBold

local ChonBoss = "Atom X002"
getgenv().AutoQ = false
getgenv().KillAura = false

local UIList = Instance.new("UIListLayout", Frame)
UIList.Padding = UDim.new(0,4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

for name,cf in pairs(BossList) do
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1,-10,0,22)
    Btn.Text = name
    Btn.BackgroundColor3 = name == ChonBoss and Color3.fromRGB(0,200,0) or Color3.fromRGB(50,50,50)
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextScaled = true
    Btn.MouseButton1Click:Connect(function()
        ChonBoss = name
        for _,b in pairs(Frame:GetChildren()) do
            if b:IsA("TextButton") and b.Text ~= "BẮT ĐẦU AUTO" then
                b.BackgroundColor3 = Color3.fromRGB(50,50,50)
            end
        end
        Btn.BackgroundColor3 = Color3.fromRGB(0,200,0)
    end)
end

-- NÚT BẬT KILL AURA
local KillBtn = Instance.new("TextButton", Frame)
KillBtn.Size = UDim2.new(1,-10,0,25)
KillBtn.Text = "KILL AURA: OFF"
KillBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
KillBtn.TextColor3 = Color3.fromRGB(255,255,255)
KillBtn.TextScaled = true
KillBtn.MouseButton1Click:Connect(function()
    getgenv().KillAura = not getgenv().KillAura
    KillBtn.Text = getgenv().KillAura and "KILL AURA: ON" or "KILL AURA: OFF"
    KillBtn.BackgroundColor3 = getgenv().KillAura and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)

local StartBtn = Instance.new("TextButton", Frame)
StartBtn.Size = UDim2.new(1,-10,0,28)
StartBtn.Text = "BẮT ĐẦU AUTO"
StartBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
StartBtn.TextColor3 = Color3.fromRGB(255,255,255)
StartBtn.TextScaled = true
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.MouseButton1Click:Connect(function()
    getgenv().AutoQ = not getgenv().AutoQ
    StartBtn.Text = getgenv().AutoQ and "ĐANG CHẠY..." or "BẮT ĐẦU AUTO"
    StartBtn.BackgroundColor3 = getgenv().AutoQ and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)

-- NHẬN Q TỪ XA
function NhanQuestTuXa(tenBoss)
    pcall(function()
        for _,v in pairs(RS:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                if string.find(v.Name:lower(), "quest") or string.find(v.Name:lower(), "mission") then
                    if v:IsA("RemoteEvent") then v:FireServer(tenBoss) else v:InvokeServer(tenBoss) end
                end
            end
        end
    end)
end

-- KILL AURA
task.spawn(function()
    while task.wait() do
        if getgenv().KillAura and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                for _,mob in pairs(workspace:GetDescendants()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                        if mob.Humanoid.Health > 0 and string.find(mob.Name, string.split(ChonBoss," ")[1]) then -- Tìm boss theo tên
                            if (Plr.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude < 50 then
                                -- 1. Dí theo boss
                                Plr.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,3)

                                -- 2. Spam click đánh
                                VirtualUser:ClickButton1(Vector2.new())

                                -- 3. Fire remote đánh nếu có
                                for _,v in pairs(RS:GetDescendants()) do
                                    if v:IsA("RemoteEvent") and string.find(v.Name:lower(), "attack") or string.find(v.Name:lower(), "skill") or string.find(v.Name:lower(), "combat") then
                                        v:FireServer(mob)
                                        v:FireServer("M1") -- Đánh thường
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- AUTO LOOP Q + TP
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoQ then
            pcall(function()
                NhanQuestTuXa(ChonBoss)
                task.wait(1)
                Plr.Character.HumanoidRootPart.CFrame = BossList[ChonBoss] * CFrame.new(0,10,0) -- TP trên đầu boss
                task.wait(8) -- Đợi kill xong
            end)
        end
    end
end)

-- ANTI AFK
Plr.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

print("AUTO Q + KILL AURA ON")
