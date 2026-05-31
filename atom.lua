-- ============================================================================
-- DRAGON BLOX ULTIMATE SCRIPT V12 - FULL AUTOMATION
-- HỆ THỐNG TỰ ĐỘNG KHÔNG CẦN GIÁM SÁT
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- BẢNG CẤU HÌNH HỆ THỐNG
getgenv().UltimateSettings = {
    AutoSkills = {"Energy Ball", "Ego", "Energy Blast"},
    TargetName = "Atom",
    CombatInterval = 0.05,
    AutoUpgrade = true,
    RebirthThreshold = 1000 -- Điểm cần để Auto Rebirth
}

-- 1. HỆ THỐNG TÌM KIẾM ĐA TẦNG (TỰ PHÁT HIỆN REMOTE MỚI)
local function FindActiveRemote(keywords)
    for _, path in pairs({ReplicatedStorage, ReplicatedStorage:FindFirstChild("Remotes")}) do
        if path then
            for _, obj in pairs(path:GetDescendants()) do
                for _, key in pairs(keywords) do
                    if obj:IsA("RemoteEvent") and obj.Name:lower():find(key:lower()) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local MainCombatRemote = FindActiveRemote({"Skill", "Combat", "Ability"})

-- 2. HỆ THỐNG TỰ ĐỘNG NÂNG CẤP & TRÙNG SINH
local function AutoManagement()
    pcall(function()
        if getgenv().UltimateSettings.AutoUpgrade then
            local upgradeRemote = FindActiveRemote({"Stat", "Upgrade"})
            if upgradeRemote then upgradeRemote:FireServer("Melee", 1) end
        end
    end)
end

-- 3. VÒNG LẶP CỐT LÕI (DÙNG RUNSERVICE ĐỂ ĐẢM BẢO TỐC ĐỘ)
RunService.Heartbeat:Connect(function()
    if not getgenv().Running then return end
    
    pcall(function()
        -- Khóa mục tiêu (Lock Target)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == getgenv().UltimateSettings.TargetName and obj:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
                    break
                end
            end
        end

        -- Spam Skill
        if MainCombatRemote then
            for _, skill in pairs(getgenv().UltimateSettings.AutoSkills) do
                MainCombatRemote:FireServer(skill)
            end
        end
    end)
end)

-- 4. HỆ THỐNG QUẢN LÝ TÀI NGUYÊN & KHỞI CHẠY
getgenv().Running = true
task.spawn(function()
    while getgenv().Running do
        AutoManagement()
        task.wait(2) -- Quản lý nâng cấp mỗi 2 giây
    end
end)

-- 5. ANTI-AFK CHUYÊN SÂU
LocalPlayer.Idled:Connect(function()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
end)

print("--- [ULTIMATE V12] KHỞI CHẠY THÀNH CÔNG ---")
