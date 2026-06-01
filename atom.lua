-- ULTRA PUNCH V6.4 - NO CD + FREEZE + ANTI KNOCKBACK
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- BYPASS
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self,...)
        if getnamecallmethod() == "Kick" then return wait(9e9) end
        return oldNamecall(self,...)
    end)
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V6.4 - God Punch", "DarkTheme")
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("God Mode Punch")

local frozenPos = nil

-- 1. GOD PUNCH - NO CD + ĐÓNG BĂNG SKILL
MainSection:NewToggle("God Punch", "Đấm vô hạn + đóng băng skill", function(s)
    _G.GodPunch = s
    
    -- Đóng băng vị trí khi bật
    if s then
        local char = Plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then frozenPos = hrp.CFrame end
    else
        frozenPos = nil
    end
    
    while _G.GodPunch do
        pcall(function()
            local char = Plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            local tool = char and char:FindFirstChildOfClass("Tool")
            
            -- ĐÓNG BĂNG NHÂN VẬT TẠI CHỖ
            if hrp and frozenPos then
                hrp.CFrame = frozenPos
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            
            -- ANTI KNOCKBACK
            if hum then
                hum.PlatformStand = false
                hum.Sit = false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
            
            -- XÓA COOLDOWN SKILL
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("NumberValue") and (v.Name == "Cooldown" or v.Name == "CD" or string.find(v.Name, "Cool")) then
                        v.Value = 0
                    end
                    if v:IsA("BoolValue") and (v.Name == "CanAttack" or v.Name == "Attacking") then
                        v.Value = true
                    end
                end
            end
            
            -- ULTRA FAST PUNCH
            if tool then
                for i = 1, 100 do -- 100 hit mỗi frame
                    tool:Activate()
                end
            end
            
            -- SPAM DAMAGE REMOTE - PHÁ TẤT CẢ
            for _, remote in pairs(RS:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    -- Đấm boss + quái
                    for _, mob in pairs(workspace:GetDescendants()) do
                        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Name ~= Plr.Name then
                            if mob.Humanoid.Health > 0 then
                                for i = 1, 5 do
                                    pcall(function() remote:FireServer(mob) end)
                                    pcall(function() remote:FireServer(mob.HumanoidRootPart) end)
                                end
                            end
                        end
                        
                        -- Phá vật cản
                        if mob:IsA("Part") or mob:IsA("MeshPart") or mob:IsA("UnionOperation") then
                            if mob.Name == "Rock" or mob.Name == "Wall" or mob.Name == "Barrier" or 
                               mob.Name == "Obstacle" or string.find(mob.Name, "Destructible") or
                               mob.Name == "Stone" or mob.Name == "Block" then
                                pcall(function() remote:FireServer(mob) end)
                            end
                        end
                    end
                end
            end
        end)
        RunService.Heartbeat:Wait() -- Chạy mỗi frame = nhanh nhất
    end
end)

-- 2. UNFREEZE - BỎ ĐÓNG BĂNG
MainSection:NewButton("Unfreeze", "Bỏ đóng băng di chuyển", function()
    frozenPos = nil
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Unfrozen";
        Text = "Di chuyển bình thường";
        Duration = 2;
    })
end)

-- 3. BREAK ALL INSTANT
MainSection:NewButton("Break All Now", "Phá hết vật cản ngay", function()
    pcall(function()
        for _, remote in pairs(RS:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                        pcall(function() remote:FireServer(v) end)
                    end
                end
            end
        end
    end)
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "V6.4 LOADED";
    Text = "Bật God Punch để đứng im đấm nát map";
    Duration = 5;
})
