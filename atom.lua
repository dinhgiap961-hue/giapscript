-- FREEZE STATE V6.9 - KEYBIND F, NO MENU
local Plr = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local enabled = false
local anchorPos = nil
local dmgRemote = nil
local target = nil

-- Tìm remote damage 1 lần
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") and (string.find(v.Name:lower(), "damage") or string.find(v.Name:lower(), "attack")) then
        dmgRemote = v
        break
    end
end

-- Tìm boss gần nhất
local function getTarget()
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Name ~= Plr.Name and v.Humanoid.Health > 0 then
                if (v.HumanoidRootPart.Position - hrp.Position).Magnitude < 80 then
                    return v
                end
            end
        end
    end
end

-- BẬT/TẮT = PHÍM F
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        enabled = not enabled
        
        if enabled then
            local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then anchorPos = hrp.CFrame end
            target = getTarget()
            
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "ON"; 
                Text = "Đứng im + No CD + Dame boss"; 
                Duration = 2
            })
        else
            anchorPos = nil
            target = nil
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "OFF"; 
                Text = "Đã tắt"; 
                Duration = 2
            })
        end
    end
end)

-- LOOP CHÍNH
while task.wait(0.1) do
    if enabled then
        pcall(function()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            -- 1. ĐỨNG IM
            if hrp and anchorPos then
                hrp.CFrame = anchorPos
                hrp.Velocity = Vector3.new(0,0,0)
            end
            
            -- 2. NO CD + GODMODE
            if hum then
                hum.Health = hum.MaxHealth
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
            
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("NumberValue") and string.find(v.Name:lower(), "cool") then
                        v.Value = 0
                    end
                end
            end
            
            -- 3. DAME BOSS - KHÔNG ANIMATION
            if dmgRemote then
                if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
                    target = getTarget()
                end
                
                if target then
                    for i = 1, 3 do -- 3 hit/lần = 30 dps, nhẹ máy
                        pcall(function() dmgRemote:FireServer(target) end)
                    end
                end
            end
        end)
    end
end

game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "V6.9 LOADED"; 
    Text = "Bấm F để bật/tắt Freeze State"; 
    Duration = 5
})
