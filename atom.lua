-- // HỆ THỐNG DRAGON BLOX PRO HUB - TỐI ƯU HÓA TỐC ĐỘ // --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- UI khởi tạo (Menu điều khiển)
local Gui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 200, 0, 100)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.Active = true
Main.Draggable = true

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.Text = "AUTO FARM: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)

local IsActive = false
ToggleBtn.MouseButton1Click:Connect(function()
    IsActive = not IsActive
    ToggleBtn.Text = IsActive and "AUTO FARM: ON" or "AUTO FARM: OFF"
end)

-- Core Engine (Bộ não xử lý)
local function GetRemotes()
    -- Tự động quét tìm tất cả Remote có chức năng tấn công
    local list = {}
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("attack") or v.Name:lower():find("skill")) then
            table.insert(list, v)
        end
    end
    return list
end

task.spawn(function()
    while true do
        if IsActive then
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("HumanoidRootPart") then
                for _, Monster in pairs(workspace:GetDescendants()) do
                    if Monster:IsA("Model") and Monster:FindFirstChild("Humanoid") and Monster.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(Monster) then
                        -- Tự động bay lại gần quái
                        Char.HumanoidRootPart.CFrame = Monster.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
                        
                        -- Xả Remote dồn sát thương
                        for _, Remote in pairs(GetRemotes()) do
                            for i = 1, 5 do -- Gửi 5 gói tin mỗi vòng lặp
                                pcall(function() Remote:FireServer(Monster.HumanoidRootPart.Position) end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.01) -- Độ trễ cực thấp để xả damage tối đa
    end
end)
