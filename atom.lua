-- FREEZE CAST V6.6 - ĐỨNG IM SPAM DAMAGE
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V6.6 - Freeze Cast", "DarkTheme")
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Freeze Cast")

local frozenPos = nil
local targetBoss = nil

-- HÀM TÌM BOSS GẦN NHẤT
local function getNearestBoss()
    local char = Plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local minDist = 100
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            if v.Name ~= Plr.Name and v.Humanoid.Health > 0 then
                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    nearest = v
                    minDist = dist
                end
            end
        end
    end
    return nearest
end

-- HÀM TÌM REMOTE DAMAGE
local function getDamageRemote()
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local name = v.Name:lower()
            if string.find(name, "damage") or string.find(name, "attack") or 
               string.find(name, "hit") or string.find(name, "punch") then
                return v
            end
        end
    end
    return nil
end

MainSection:NewToggle("Freeze Cast", "Đứng im + Spam damage không animation", function(s)
    _G.FreezeCast = s
    
    if s then
        local char = Plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then 
            frozenPos = hrp.CFrame -- Lưu vị trí để đóng băng
            targetBoss = getNearestBoss() -- Lock boss gần nhất
        end
    else
        frozenPos = nil
        targetBoss = nil
    end
    
    local dmgRemote = getDamageRemote()
    
    while _G.FreezeCast do
        pcall(function()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            -- 1. ĐÓNG BĂNG NHÂN VẬT TẠI CHỖ
            if hrp and frozenPos then
                hrp.CFrame = frozenPos
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            
            -- 2. ANTI KNOCKBACK + BẤT TỬ
            if hum then
                hum.Health = hum.MaxHealth
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum.PlatformStand = false
            end
            
            -- 3. XÓA COOLDOWN SKILL
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("NumberValue") and string.find(v.Name:lower(), "cool") then
                        v.Value = 0
                    end
                    if v:IsA("BoolValue") and string.find(v.Name:lower(), "attack") then
                        v.Value = true
                    end
                end
            end
            
            -- 4. SPAM DAMAGE - KHÔNG CẦN ANIMATION
            if dmgRemote then
                -- Nếu boss cũ chết thì tìm boss mới
                if not targetBoss or not targetBoss:FindFirstChild("Humanoid") or targetBoss.Humanoid.Health <= 0 then
                    targetBoss = getNearestBoss()
                end
                
                -- Spam damage lên boss
                if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") then
                    for i = 1, 20 do -- 20 hit/lần
                        pcall(function() dmgRemote:FireServer(targetBoss) end)
                        pcall(function() dmgRemote:FireServer(targetBoss.HumanoidRootPart) end)
                        pcall(function() dmgRemote:FireServer(targetBoss.Humanoid) end)
                    end
                end
            end
        end)
        task.wait(0.05) -- 20 lần/giây = 400 damage/s, không lag
    end
end)

MainSection:NewButton("Unfreeze", "Bỏ đóng băng", function()
    frozenPos = nil
    targetBoss = nil
end)

MainSection:NewButton("Lock Boss Mới", "Chọn lại boss gần nhất", function()
    targetBoss = getNearestBoss()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Locked";
        Text = targetBoss and "Đã lock: " .. targetBoss.Name or "Không thấy boss";
        Duration = 2;
    })
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "V6.6 LOADED";
    Text = "Bật Freeze Cast để đứng im one shot boss";
    Duration = 3;
})
