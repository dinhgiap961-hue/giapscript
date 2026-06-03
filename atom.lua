-- AUTO DUNGEON V3 - QUÉT SẠCH + GIẢ LẬP E + AUTO ĐẤM
local Plr = game.Players.LocalPlayer 
local RS = game:GetService("ReplicatedStorage") 
local VIM = game:GetService("VirtualInputManager") 

local function VaoDungeon() 
    pcall(function() 
        RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DungeonLobbyService"):WaitForChild("RF"):WaitForChild("StartDungeon"):InvokeServer() 
    end) 
end 

local function BamBatDau() 
    task.wait(4) -- Đợi 4s cho load hết 
    -- CÁCH 1: FIRE PROXIMITYPROMPT 
    for _,prompt in pairs(workspace:GetDescendants()) do 
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then 
            local text = string.lower(prompt.ActionText..prompt.ObjectText..prompt.Name) 
            if string.find(text, "bắt") or string.find(text, "start") then 
                -- TP tới sát prompt 
                if prompt.Parent and prompt.Parent:IsA("BasePart") then 
                    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = prompt.Parent.CFrame end
                    task.wait(0.5) 
                end 
                prompt.HoldDuration = 0 
                prompt.RequiresLineOfSight = false 
                fireproximityprompt(prompt) 
                print("Đã fire ProximityPrompt") 
                return true 
            end 
        end 
    end 
    -- CÁCH 2: BẤM GUI BUTTON 
    for _,gui in pairs(Plr.PlayerGui:GetDescendants()) do 
        if gui:IsA("TextLabel") and string.lower(gui.Text) == "bắt đầu" then 
            local btn = gui:FindFirstAncestorWhichIsA("GuiButton") 
            if btn and btn.Visible then 
                firesignal(btn.MouseButton1Click) 
                print("Đã bấm GUI Button") 
                return true 
            end 
        end 
        if gui:IsA("TextButton") and string.lower(gui.Text) == "bắt đầu" then 
            firesignal(gui.MouseButton1Click) 
            print("Đã bấm TextButton") 
            return true 
        end 
    end 
    -- CÁCH 3: GIẢ LẬP BẤM E - CHỐT HẠ 
    print("Không thấy prompt, giả lập bấm E") 
    VIM:SendKeyEvent(true, "E", false, game) 
    task.wait(0.1) 
    VIM:SendKeyEvent(false, "E", false, game) 
    return true 
end 

-- GUI 
if game.CoreGui:FindFirstChild("AutoDungeonV3") then game.CoreGui.AutoDungeonV3:Destroy() end 
local Gui = Instance.new("ScreenGui", game.CoreGui) 
Gui.Name = "AutoDungeonV3" 

-- NÚT DUNGEON
local Btn = Instance.new("TextButton", Gui) 
Btn.Size = UDim2.new(0, 180, 0, 40) 
Btn.Position = UDim2.new(0, 10, 0.5, -20) 
Btn.Text = "AUTO DUNGEON V3" 
Btn.BackgroundColor3 = Color3.fromRGB(255, 100, 0) 
Btn.TextColor3 = Color3.fromRGB(255,255,255) 
Btn.TextScaled = true 
Btn.Font = Enum.Font.SourceSansBold 

Btn.MouseButton1Click:Connect(function() 
    Btn.Text = "1. VÀO LOBBY..." 
    VaoDungeon() 
    Btn.Text = "2. BẤM BẮT ĐẦU..." 
    local done = BamBatDau() 
    if done then 
        game.StarterGui:SetCore("SendNotification",{Title="OK",Text="Đã bấm Bắt đầu",Duration=2}) 
    end 
    task.wait(1) 
    Btn.Text = "AUTO DUNGEON V3" 
end) 

-- THÊM NÚT AUTO ĐẤM
local AutoPunch = false
local PunchBtn = Instance.new("TextButton", Gui)
PunchBtn.Size = UDim2.new(0, 180, 0, 40)
PunchBtn.Position = UDim2.new(0, 10, 0.5, 25) -- Nằm dưới nút dungeon
PunchBtn.Text = "AUTO PUNCH: OFF"
PunchBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
PunchBtn.TextColor3 = Color3.fromRGB(255,255,255)
PunchBtn.TextScaled = true
PunchBtn.Font = Enum.Font.SourceSansBold

PunchBtn.MouseButton1Click:Connect(function()
    AutoPunch = not AutoPunch
    if AutoPunch then
        PunchBtn.Text = "AUTO PUNCH: ON"
        PunchBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.spawn(function()
            while AutoPunch do
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait()
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(0.08) -- Tốc độ đấm, 0.08 là nhanh
            end
        end)
    else
        PunchBtn.Text = "AUTO PUNCH: OFF"
        PunchBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

print("V3: Thử 3 cách - Prompt -> GUI -> Giả lập E + Auto Punch")
