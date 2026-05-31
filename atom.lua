-- ====================================================================================================
-- DRAGON BLOX ELITE HUB V16 - FULL AUTOMATION (TRANSFORM + FUSION)
-- ====================================================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RenderStepped")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- UI (Giữ nguyên gọn nhẹ)
local Main = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", Main)
Frame.Size = UDim2.new(0, 200, 0, 350) Frame.Position = UDim2.new(0.5, 0, 0.2, 0)
Frame.Active = true Frame.Draggable = true Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local Settings = {Lock = false, Farm = false, Raid = false, Trans = false, Fusion = false}

local function AddBtn(n, k)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(0.9, 0, 0, 40) b.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45 - 40)
    b.Text = n .. ": OFF"
    b.MouseButton1Click:Connect(function() Settings[k] = not Settings[k] b.Text = n .. ": " .. (Settings[k] and "ON" or "OFF") end)
end
AddBtn("LOCK-BOSS", "Lock") AddBtn("AUTO-FARM", "Farm") AddBtn("AUTO-RAID", "Raid")
AddBtn("TRANSFORM", "Trans") AddBtn("FUSION", "Fusion")

-- LOGIC
game:GetService("RunService").RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end

    -- Target Lock
    local target = nil
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("boss") then
            target = v break
        end
    end

    if Settings.Lock and target then
        local pos = target.HumanoidRootPart.Position
        Char.HumanoidRootPart.CFrame = CFrame.new(Char.HumanoidRootPart.Position, Vector3.new(pos.X, Char.HumanoidRootPart.Position.Y, pos.Z))
    end

    -- Auto Farm
    if Settings.Farm then
        local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six}
        for _, k in pairs(keys) do VIM:SendKeyEvent(true, k, false, game) task.wait(0.05) VIM:SendKeyEvent(false, k, false, game) end
    end
end)

-- AUTO ACTIONS (TRANSFORM, FUSION, RAID)
task.spawn(function()
    while task.wait(1) do
        -- Auto Transform (G)
        if Settings.Trans then VIM:SendKeyEvent(true, Enum.KeyCode.G, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game) end
        
        -- Auto Fusion (Quét nút Fusion trong UI)
        if Settings.Fusion then
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") and v.Text:lower():find("fusion") then
                    VIM:MouseButton1Click(v.AbsolutePosition + Vector2.new(v.AbsoluteSize.X/2, v.AbsoluteSize.Y/2))
                end
            end
        end

        -- Raid & Next
        if Settings.Raid then
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and (v.Name:lower():find("start") or v.Name:lower():find("next")) then
                    VIM:MouseButton1Click(v.AbsolutePosition + Vector2.new(v.AbsoluteSize.X/2, v.AbsoluteSize.Y/2))
                end
            end
        end
    end
end)
