-- Thư viện UI Kavo gọn nhẹ cho Delta Mobile
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local window = library.CreateLib("Dragon Blox - Fix TP By Dex", "DarkTheme")

local tab = window:NewTab("Auto Farm")
local section = tab:NewSection("Cấu Hình Mục Tiêu")

local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HEIGHT_ABOVE = 9.22
local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
local lastActionTime = 0

local db = {
    autopunch_db = false,
    target_mob = "None"
}

-- Hàm quét quái tối ưu hóa theo cấu trúc thư mục của game trong Dex
local function getTargetMob(name)
    if name == "None" then return nil end
    
    -- Danh sách các folder chứa thực thể trong Workspace (Quét chính xác theo Dex)
    local folders = {
        workspace:FindFirstChild("NPCs"),
        workspace:FindFirstChild("Bosses"),
        workspace:FindFirstChild("Monsters"),
        workspace:FindFirstChild("Enemies"),
        workspace
    }
    
    for _, folder in pairs(folders) do
        if folder then
            -- Quét qua tất cả các con quái trong folder đó
            for _, mob in pairs(folder:GetChildren()) do
                if mob.Name:lower():find(name:lower()) then
                    -- Kiểm tra xem có phải thực thể sống không (Có Humanoid và còn máu)
                    local humanoid = mob:FindFirstChildOfClass("Humanoid")
                    local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                    
                    if hrp and humanoid and humanoid.Health > 0 then
                        return hrp -- Trả về vị trí của quái
                    end
                end
            end
        end
    end
    
    -- Trường hợp quái nằm trong một Folder con lồng nhau (Quét sâu lớp thứ 2)
    for _, folder in pairs(folders) do
        if folder then
            for _, subFolder in pairs(folder:GetChildren()) do
                if subFolder:IsA("Folder") or subFolder:IsA("Model") then
                    for _, mob in pairs(subFolder:GetChildren()) do
                        if mob.Name:lower():find(name:lower()) then
                            local humanoid = mob:FindFirstChildOfClass("Humanoid")
                            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                            if hrp and humanoid and humanoid.Health > 0 then
                                return hrp
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Vòng lặp chính xử lý Teleport liên tục theo khung hình (Heartbeat)
local mainConnection
if mainConnection then mainConnection:Disconnect() end

mainConnection = RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    local myHrp = character and character:FindFirstChild("HumanoidRootPart")
    if not myHrp or not myHrp.Parent then return end
    
    -- 1. XỬ LÝ DỊCH CHUYỂN ĐẾN QUÁI (TELEPORT GODMODE)
    if db.target_mob ~= "None" then
        local mobHrp = getTargetMob(db.target_mob)
        if mobHrp then
            -- Đưa nhân vật của bạn đứng im lơ lửng trên đầu quái đúng khoảng cách 9.22
            myHrp.CFrame = mobHrp.CFrame * CFrame.new(0, HEIGHT_ABOVE, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0) -- Triệt tiêu trọng lực rơi
        end
    end
    
    -- 2. XỬ LÝ TỰ ĐỘNG ĐẤM & XẢ CHIÊU
    if db.autopunch_db then
        local currentTime = tick()
        if currentTime - lastActionTime >= 0.25 then
            lastActionTime = currentTime
            
            task.spawn(function()
                -- Giả lập bấm Chuột trái (Đấm thường) liên tục
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                -- Tự động kích hoạt nhanh các Skill ở ô 1, 2, 3, 4
                for _, key in ipairs(skillKeys) do
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.01)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
            end)
        end
    end
end)

-- Tạo nút bật/tắt đấm trên giao diện UI
section:NewToggle("Auto Punch & Skill", "Bật/Tắt tự động tấn công", function(state)
    db.autopunch_db = state
end)

-- Tạo menu chọn quái (Đầy đủ danh sách biến mob bạn gửi ban nãy)
section:NewDropdown("Chọn Quái Để Farm", "Chọn quái muốn dịch chuyển tới", {"None", "Bandit", "Jigray", "Atom", "Puriza", "Black Karrot", "Coolest"}, function(currentOption)
    db.target_mob = currentOption
end)
