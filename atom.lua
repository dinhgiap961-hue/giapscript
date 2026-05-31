-- ============================================================================
-- DRAGON BLOX: ATOM PINNER UI - HỆ THỐNG GIAO DIỆN & GHIM TRỰC TIẾP
-- ============================================================================

-- Tải thư viện UI (Kavo)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Atom Boss Master", "DarkTheme")

-- Biến cấu hình
getgenv().PinnerSettings = {
    Enabled = false,
    Offset = 15 -- Khoảng cách trên đầu Boss
}

-- Tạo Tab
local Tab = Window:NewTab("Chiến đấu")
local Section = Tab:NewSection("Công cụ Atom Boss")

-- Toggle Ghim
Section:NewToggle("Ghim trên đầu Boss", "Đứng im trên đầu Atom", function(state)
    getgenv().PinnerSettings.Enabled = state
end)

-- Thanh chỉnh độ cao (để tránh bị boss đẩy)
Section:NewSlider("Độ cao (Offset)", "Điều chỉnh vị trí", 5, 50, function(s)
    getgenv().PinnerSettings.Offset = s
end)

-- Nút đóng mở menu có sẵn trong Kavo UI (Góc trên cùng bên phải)

-- [ENGINE CHÍNH - GHIM VỊ TRÍ & SPAM PHÍM]
game:GetService("RunService").Heartbeat:Connect(function()
    if getgenv().PinnerSettings.Enabled then
        pcall(function()
            local Boss = game:GetService("Workspace"):FindFirstChild("Atom")
            local Character = game:GetService("Players").LocalPlayer.Character
            
            if Boss and Boss:FindFirstChild("HumanoidRootPart") and Character and Character:FindFirstChild("HumanoidRootPart") then
                -- Ghim tĩnh tuyệt đối
                Character.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().PinnerSettings.Offset, 0)
                
                -- Spam phím E
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end)
    end
end)
