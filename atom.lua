-- ============================================================================
-- DRAGON BLOX: GIAO DIỆN & ĐỘNG CƠ TỰ ĐỘNG (FULL GÓI)
-- ============================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dragon Blox V1.4 - Control Panel", "DarkTheme")

-- BẢNG CẤU HÌNH GỐC
getgenv().Settings = {
    AutoSkills = false,
    AutoLock = false,
    Target = "Atom"
}

local Tab = Window:NewTab("Menu Chính")
local Section = Tab:NewSection("Công Cụ Tự Động")

Section:NewToggle("Auto Skill (Spam)", "Tự động kích hoạt chiêu", function(state)
    getgenv().Settings.AutoSkills = state
end)

Section:NewToggle("Auto Lock Target", "Khóa vào Atom", function(state)
    getgenv().Settings.AutoLock = state
end)

-- [CƠ CHẾ ĐỘNG CƠ CỐT LÕI - PHẦN NÀY QUYẾT ĐỊNH NÓ CÓ CHẠY HAY KHÔNG]
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            -- Phần 1: Tự động tìm Remote (Nếu script không chạy, thay "SkillEvent" bằng tên trong SimpleSpy)
            local CombatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("SkillEvent") 
            
            if getgenv().Settings.AutoSkills and CombatRemote then
                CombatRemote:FireServer("Energy Ball")
                CombatRemote:FireServer("Ego")
            end

            -- Phần 2: Cơ chế bám đuổi (Lock)
            if getgenv().Settings.AutoLock then
                local player = game:GetService("Players").LocalPlayer
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                    if v.Name == getgenv().Settings.Target and v:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
                    end
                end
            end
        end)
    end
end)

-- [ANTI-AFK ĐỂ KHÔNG BỊ KICK]
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
end)
