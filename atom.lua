-- ============================================================================
-- DRAGON BLOX V2 - V8: FORCE ENERGY BLAST (FIXED)
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. Tìm RemoteEvent chuyên biệt cho chiêu thức
local function GetAbilityRemote()
    -- Thử quét tất cả các Remote trong ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("skill") or v.Name:lower():find("ability")) then
            return v
        end
    end
    return nil
end

local AbilityRemote = GetAbilityRemote()

-- 2. Hàm ép bắn vào mục tiêu (Fix đứng im)
_G.AutoEnergyBlast = true 

task.spawn(function()
    while _G.AutoEnergyBlast do
        if AbilityRemote then
            -- Lấy vị trí quái/boss gần nhất
            local targetHrp = nil
            local dist = 9e9
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Humanoid") and v.Parent ~= LocalPlayer.Character and v.Health > 0 then
                    local hrp = v.Parent:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if d < dist then dist = d; targetHrp = hrp end
                    end
                end
            end

            -- Bắn chiêu vào mục tiêu tìm được
            if targetHrp then
                pcall(function()
                    -- Cấu trúc: FireServer(Tên_Chiêu, Vị_Trí_Mục_Tiêu)
                    AbilityRemote:FireServer("Energy Blast", targetHrp.Position)
                end)
            end
        end
        task.wait(0.2) -- Thời gian hồi chiêu Energy Blast
    end
end)
