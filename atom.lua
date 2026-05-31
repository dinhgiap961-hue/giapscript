-- ============================================================================
-- SCRIPT AUTO ENERGY BLAST (CHỈ SPAM CHIÊU NÀY)
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HÀM TỰ DÒ TÌM REMOTE ĐẶC BIỆT CHO CHIÊU THỨC
local function GetAbilityRemote()
    -- Danh sách các tên Remote thường thấy cho skill
    local possibleRemotes = {"CombatEvent", "SkillEvent", "AbilityEvent", "Input"}
    
    for _, name in pairs(possibleRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name, true)
        if remote and remote:IsA("RemoteEvent") then 
            return remote 
        end
    end
    return nil
end

local AbilityRemote = GetAbilityRemote()

-- BẬT/TẮT TỰ ĐỘNG
_G.AutoEnergyBlast = true 

task.spawn(function()
    while _G.AutoEnergyBlast do
        if AbilityRemote then
            pcall(function()
                -- Thay "EnergyBlast" bằng tên chiêu thức trong game nếu cần
                -- Nếu game dùng phím, hãy để là "Q" hoặc tên chiêu của nó
                AbilityRemote:FireServer("EnergyBlast") 
            end)
        end
        -- Tốc độ spam chiêu (0.1s là an toàn để không bị lỗi cooldown skill)
        task.wait(0.1) 
    end
end)
