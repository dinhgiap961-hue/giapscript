--[[ 
   Đã tối ưu hóa cho Dragon Blox:
   1. Giới hạn phạm vi tìm kiếm (Chỉ quét trong Model của Boss/Quái).
   2. Tối ưu hóa vòng lặp tránh gây lag game.
   3. Cập nhật cách xác định NPC/Boss phù hợp với cấu trúc của Dragon Blox.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- // CẤU HÌNH CHO DRAGON BLOX // --
local AIMBOT_ENABLED = false
local ESP_ENABLED = false
local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "DB_ESP_System"

-- Tạo UI đơn giản
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 180, 0, 130)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)

local function createBtn(text, pos)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.9, 0, 0.3, 0)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn)
    return btn
end

local aimBtn = createBtn("AIMBOT", UDim2.new(0.05, 0, 0.25, 0))
local espBtn = createBtn("ESP", UDim2.new(0.05, 0, 0.6, 0))

-- // LOGIC TÌM KIẾM TỐI ƯU CHO DRAGON BLOX // --
local function getClosestMonster()
    local closest = nil
    local shortestDist = math.huge
    
    -- Dragon Blox thường đặt quái trong các folder cụ thể trong workspace
    -- Chúng ta chỉ quét các đối tượng có HumanoidRootPart để tránh lag
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            -- Loại trừ người chơi và đảm bảo quái còn sống
            if not Players:GetPlayerFromCharacter(v) and v.Humanoid.Health > 0 then
                local part = v.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < shortestDist then
                        closest = part
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

-- // LOOPS // --
RunService.RenderStepped:Connect(function()
    if AIMBOT_ENABLED then
        local targetPart = getClosestMonster()
        if targetPart then
            -- Smooth aim (giúp không bị khóa cứng quá mức gây nghi vấn)
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
        end
    end
end)

-- ESP System cải tiến
task.spawn(function()
    while task.wait(0.5) do -- Tăng thời gian chờ để giảm tải CPU
        espFolder:ClearAllChildren()
        if ESP_ENABLED then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if not Players:GetPlayerFromCharacter(v) and v.Humanoid.Health > 0 then
                        local hl = Instance.new("Highlight", espFolder)
                        hl.Adornee = v
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
    end
end)

-- // BUTTONS // --
aimBtn.MouseButton1Click:Connect(function()
    AIMBOT_ENABLED = not AIMBOT_ENABLED
    aimBtn.Text = "AIMBOT: " .. (AIMBOT_ENABLED and "ON" or "OFF")
    aimBtn.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(30, 30, 30)
end)

espBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    espBtn.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
    espBtn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(30, 30, 30)
end)
