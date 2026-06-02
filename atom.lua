-- AUTO Q HỘI ĐỒNG -> NHẬN Q TỪ XA + TP BOSS
local Plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local BossList = {
    ["Atom X002"] = CFrame.new(3298.8, 6.7, 3295.3),
    ["Brawly X 01"] = CFrame.new(-816.6, 497.7, 1100.2),
    ["Jigray X"] = CFrame.new(-4129.4, 21.3, -4582.5),
    ["Puriza X003"] = CFrame.new(-50.2, 42.0, -8454.4),
    ["Zero"] = CFrame.new(4988.5, 14.8, -4197.0),
}

-- GUI CHỌN BOSS
if game.CoreGui:FindFirstChild("BossQGUI") then game.CoreGui.BossQGUI:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BossQGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0, 10, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0

local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1,0,0,25)
Label.Text = "BOSS MAP 3 - REMOTE Q"
Label.TextColor3 = Color3.fromRGB(255,200,0)
Label.BackgroundColor3 = Color3.fromRGB(40,40,40)
Label.TextScaled = true
Label.Font = Enum.Font.SourceSansBold
Label.LayoutOrder = 0

local ChonBoss = "Atom X002"
getgenv().AutoQ = false

local UIList = Instance.new("UIListLayout", Frame)
UIList.Padding = UDim.new(0,5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

for name,cf in pairs(BossList) do
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1,-10,0,22)
    Btn.Text = name
    Btn.BackgroundColor3 = name == ChonBoss and Color3.fromRGB(0,200,0) or Color3.fromRGB(50,50,50)
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.SourceSansBold
    Btn.LayoutOrder = 1
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

local StartBtn = Instance.new("TextButton", Frame)
StartBtn.Size = UDim2.new(1,-10,0,28)
StartBtn.Text = "BẮT ĐẦU AUTO"
StartBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
StartBtn.TextColor3 = Color3.fromRGB(255,255,255)
StartBtn.TextScaled = true
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.LayoutOrder = 10
StartBtn.MouseButton1Click:Connect(function()
    getgenv().AutoQ = not getgenv().AutoQ
    StartBtn.Text = getgenv().AutoQ and "ĐANG CHẠY..." or "BẮT ĐẦU AUTO"
    StartBtn.BackgroundColor3 = getgenv().AutoQ and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)

-- HÀM NHẬN Q TỪ XA
function NhanQuestTuXa(tenBoss)
    pcall(function()
        -- Cách 1: Fire remote nhận Q nếu game có
        for _,v in pairs(RS:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                if string.find(v.Name:lower(), "quest") or string.find(v.Name:lower(), "mission") or string.find(v.Name:lower(), "accept") then
                    if v:IsA("RemoteEvent") then
                        v:FireServer(tenBoss) -- Thử gửi tên boss
                        v:FireServer("Strax") -- Thử gửi tên NPC
                        v:FireServer("Map3") -- Thử gửi map
                    else
                        v:InvokeServer(tenBoss)
                    end
                end
            end
        end

        -- Cách 2: Bấm GUI nếu nó load sẵn
        task.wait(0.5)
        for _,gui in pairs(Plr.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and gui.Visible then
                if string.find(gui.Text:lower(), "chấp nhận") or string.find(gui.Text:lower(), "accept") then
                    firesignal(gui.MouseButton1Click)
                end
            end
        end
    end)
end

-- AUTO LOOP
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoQ then
            pcall(function()
                -- 1. NHẬN Q TỪ XA, KHỎI TP TỚI STRAX
                NhanQuestTuXa(ChonBoss)
                task.wait(1)

                -- 2. TP THẲNG TỚI BOSS
                Plr.Character.HumanoidRootPart.CFrame = BossList[ChonBoss] * CFrame.new(0,5,0)
                game.StarterGui:SetCore("SendNotification",{Title="Auto Q Remote",Text="Đã nhận Q + TP: "..ChonBoss,Duration=3})
                task.wait(6)
            end)
        end
    end
end)

print("BẢN REMOTE Q: KHỎI TP TỚI STRAX")
