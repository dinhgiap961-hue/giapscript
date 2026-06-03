-- AUTO DUNGEON V3 + AUTO PUNCH FIX V2
local Plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local function VaoDungeon()
    pcall(function()
        RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DungeonLobbyService"):WaitForChild("RF"):WaitForChild("StartDungeon"):InvokeServer()
    end)
end

local function BamBatDau()
    task.wait(4)
    for _,prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local text = string.lower(prompt.ActionText..prompt.ObjectText..prompt.Name)
            if string.find(text, "bắt") or string.find(text, "start") then
                if prompt.Parent and prompt.Parent:IsA("BasePart") then
                    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = prompt.Parent.CFrame end
                    task.wait(0.5)
                end
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                fireproximityprompt(prompt)
                return true
            end
        end
    end
    for _,gui in pairs(Plr.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and string.lower(gui.Text) == "bắt đầu" then
            local btn = gui:FindFirstAncestorWhichIsA("GuiButton")
            if btn and btn.Visible then firesignal(btn.MouseButton1Click) return true end
        end
        if gui:IsA("TextButton") and string.lower(gui.Text) == "bắt đầu" then firesignal(gui.MouseButton1Click) return true end
    end
    VIM:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, "E", false, game)
    return true
end

-- GUI
if game.CoreGui:FindFirstChild("AutoDungeonV3") then game.CoreGui.AutoDungeonV3:Destroy() end
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "AutoDungeonV3"

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
    if done then game.StarterGui:SetCore("SendNotification",{Title="OK",Text="Đã bấm Bắt đầu",Duration=2}) end
    task.wait(1)
    Btn.Text = "AUTO DUNGEON V3"
end)

-- FIX AUTO PUNCH V2 - TRUYỀN CFrame
local AutoPunch = false
local PunchBtn = Instance.new("TextButton", Gui)
PunchBtn.Size = UDim2.new(0, 180, 0, 40)
PunchBtn.Position = UDim2.new(0, 10, 0.5, 25)
PunchBtn.Text = "AUTO PUNCH: OFF"
PunchBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
PunchBtn.TextColor3 = Color3.fromRGB(255,255,255)
PunchBtn.TextScaled = true
PunchBtn.Font = Enum.Font.SourceSansBold

local PunchRemote = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("CombatService"):WaitForChild("RF"):WaitForChild("Punch")

PunchBtn.MouseButton1Click:Connect(function()
    AutoPunch = not AutoPunch
    if AutoPunch then
        PunchBtn.Text = "AUTO PUNCH: ON"
        PunchBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.spawn(function()
            while AutoPunch do
                local char = Plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function()
                        -- Chốt: Truyền CFrame của m vào, hết lỗi nil Position
                        local args = {
                            [1] = 1, -- 1 = tay trái, 2 = tay phải
                            [2] = hrp.CFrame -- Fake vị trí chuột = vị trí m đứng
                        }
                        PunchRemote:InvokeServer(unpack(args))
                    end)
                end
                task.wait(0.2) -- Để 0.2s cho đỡ lag, game này spam nhanh nó kick
            end
        end)
    else
        PunchBtn.Text = "AUTO PUNCH: OFF"
        PunchBtn.BackgroundColor3 = Color3.fromRGB(200
