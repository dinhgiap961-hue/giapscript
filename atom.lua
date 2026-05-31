-- ============================================================================
-- DRAGON BLOX: ULTIMATE AUTOMATION SUITE (FULL VERSION)
-- ĐÃ TÍCH HỢP HỆ THỐNG ĐIỀU KHIỂN & CHỐNG LỖI CẤP CAO
-- ============================================================================

-- [MODULE 1: CẤU HÌNH & DỊCH VỤ CỐT LÕI]
local Core = {
    Services = {
        RS = game:GetService("ReplicatedStorage"),
        PLRS = game:GetService("Players"),
        WS = game:GetService("Workspace"),
        RSVC = game:GetService("RunService"),
        VIM = game:GetService("VirtualInputManager"),
        VU = game:GetService("VirtualUser")
    },
    Settings = {
        AutoCombat = true,
        AutoTarget = true,
        TargetName = "Atom",
        CombatRate = 0.05,
        Skills = {"Energy Ball", "Ego", "Energy Blast"}
    }
}

-- [MODULE 2: TÌM KIẾM REMOTE THÔNG MINH - CHỐNG LỖI NIL]
local function GetCombatRemote()
    local Keywords = {"Combat", "Skill", "Ability", "Action"}
    local SearchPaths = {Core.Services.RS, Core.Services.RS:FindFirstChild("Remotes")}
    
    for _, path in pairs(SearchPaths) do
        if path then
            for _, obj in pairs(path:GetDescendants()) do
                for _, word in pairs(Keywords) do
                    if obj:IsA("RemoteEvent") and obj.Name:lower():find(word:lower()) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- [MODULE 3: HỆ THỐNG ĐIỀU HƯỚNG MỤC TIÊU]
local function MoveToTarget()
    local LocalPlayer = Core.Services.PLRS.LocalPlayer
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    
    for _, obj in pairs(Core.Services.WS:GetDescendants()) do
        if obj.Name == Core.Settings.TargetName and obj:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 5, 8)
            break
        end
    end
end

-- [MODULE 4: CHỐNG KICK AFK]
Core.Services.PLRS.LocalPlayer.Idled:Connect(function()
    Core.Services.VU:CaptureController()
    Core.Services.VU:ClickButton2(Vector2.new(0, 0))
end)

-- [MODULE 5: CÔNG CỤ TỐI ƯU HIỆU SUẤT (DỌN RÁC)]
task.spawn(function()
    while true do
        task.wait(60)
        collectgarbage("collect")
    end
end)

-- [MODULE 6: HEARTBEAT ENGINE (KHÔNG ĐỨNG YÊN)]
Core.Services.RSVC.Heartbeat:Connect(function()
    if not Core.Settings.AutoCombat then return end
    
    pcall(function()
        if Core.Settings.AutoTarget then
            MoveToTarget()
        end
        
        local Remote = GetCombatRemote()
        if Remote then
            for _, SkillName in pairs(Core.Settings.Skills) do
                Remote:FireServer(SkillName)
            end
        else
            -- Dự phòng phím E
            Core.Services.VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            Core.Services.VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end)
end)

-- [MODULE 7: KHỞI TẠO HỆ THỐNG]
print("--- [SYSTEM] DRAGON BLOX ULTIMATE KHỞI CHẠY ---")
print("--- [VERSION] 1.0.0 | STATUS: RUNNING ---")

-- Nếu script này vẫn không tự nhận diện được chiêu, 
-- Hãy nhìn vào dòng lệnh Print trên Console (F9) 
-- xem nó có báo 'None' hay không để biết đường thay tên Remote.
