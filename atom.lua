-- FREEZE STATE V6.7 - ĐỨNG IM + NO CD + NO ANIMATION
local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V6.7 - Freeze State", "DarkTheme")
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Freeze State")

local anchored = false
local anchorPos = nil

MainSection:NewToggle("Freeze State", "Đứng im + No CD + Dame liên tục", function(s)
    _G.FreezeState = s
    anchored = s
    
    if s then
        local char = Plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then anchorPos = hrp.CFrame end
    else
        anchorPos = nil
    end
    
    -- Vòng lặp giữ nhân vật đứng im
    spawn(function()
        while anchored and _G.FreezeState do
            pcall(function()
                local char = Plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and anchorPos then
                    hrp.CFrame = anchorPos
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
            end)
            task.wait()
        end
    end)
    
    -- Vòng lặp spam damage + xóa CD
    while _G.FreezeState do
        pcall(function()
            local char = Plr.Character
            local hum = char and char:FindFirstChild("Humanoid")
            
            -- 1. XÓA COOLDOWN + ĐÓNG BĂNG TRẠNG THÁI SKILL
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    -- Xóa CD
                    if v:IsA("NumberValue") and (string.find(v.Name:lower(), "cool") or string.find(v.Name:lower(), "cd")) then
                        v.Value = 0
                    end
                    -- Đóng băng trạng thái đang đánh
                    if v:IsA("BoolValue") and (v.Name == "Attacking" or v.Name == "UsingSkill" or v.Name == "CanAttack") then
                        v.Value = true
                    end
                    -- Đóng băng form/biến hình
                    if v:IsA("BoolValue") and (string.find(v.Name:lower(), "form") or string.find(v.Name:lower(), "transform")) then
                        v.Value = true
                    end
                end
            end
            
            -- 2. BẤT TỬ + ANTI KNOCKBACK
            if hum then
                hum.Health = hum.MaxHealth
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
            
            -- 3. SPAM DAMAGE THẲNG VÀO BOSS - KHÔNG CẦN ANIMATION
            for _, remote in pairs(RS:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    for _, mob in pairs(workspace:GetDescendants()) do
                        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                            if mob.Name ~= Plr.Name and mob.Humanoid.Health > 0 then
                                -- Spam 10 damage mỗi 0.05s = 200 dps
                                for i = 1, 10 do
                                    pcall(function() remote:FireServer(mob) end)
                                    pcall(function() remote:FireServer(mob.HumanoidRootPart.Position) end)
                                    pcall(function() remote:FireServer(mob.Humanoid) end)
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.05) -- 20 lần/giây, không lag màn hình
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "V6.7";
    Text = "Đứng im + No CD + Dame không cần vung tay";
    Duration = 3;
})
