local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Khởi tạo các Remote cần thiết
local SkillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillRemote")
local CurrentCamera = Workspace.CurrentCamera

-- Đường dẫn Remote tự động Start Dungeon
local StartDungeonRF = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("DungeonLobbyService")
    :WaitForChild("RF")
    :WaitForChild("StartDungeon")

-- Tìm Remote Interact 
local InteractRemote = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("Interact") 
    or ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillRemote").Parent:FindFirstChild("Interact")

-- Chờ nhân vật load hoàn chỉnh
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:FindFirstChild("Animator")

-- DANH SÁCH CÁC VẬT THỂ BỊ CẤM QUÉT TRÚNG (Bổ sung các thứ gây bay lỗi ngoài map)
local BlacklistNames = {
    ["Terrain"] = true,
    ["Dragon"] = true, -- Con rồng khổng lồ ở nền map
    ["Lobby"] = true,
    ["Map"] = true,
    ["Stage"] = true,
    ["Effect"] = true,
    ["VFX"] = true
}

-- 1. Vô hiệu hóa hoạt ảnh triệt để (Bỏ delay vung tay)
if Animator then Animator.Parent = nil end

-- HOOK BYPASS COOLDOWN CHUẨN
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if self == SkillRemote and method == "FireServer" then
        if args[1] and type(args[1]) == "table" then
            args[1]["Time"] = 0
            args[1]["IsValid"] = true
        end
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- =======================================================
-- LUỒNG THỨ 1: TỰ ĐỘNG START VÀ VÀO RAID/DUNGEON LIÊN TỤC
-- =======================================================
task.spawn(function()
    while true do
        pcall(function()
            -- Tự động gọi lệnh Start màn chơi mới bằng Knit
            StartDungeonRF:InvokeServer()
            
            -- Tự động gửi lệnh tương tác 'true' qua màn/nhặt rương khi hết màn
            if InteractRemote then
                InteractRemote:FireServer(true)
            end
        end)
        task.wait(1.5) -- Tốc độ bấm nút chuyển màn cực nhanh
    end
end)

-- =======================================================
-- LUỒNG THỨ 2: GHIM MẶT BOSS & KHÓA CHỐNG BAY RA KHỎI MAP
-- =======================================================
RunService.Heartbeat:Connect(function()
    local currentCharacter = LocalPlayer.Character
    if not currentCharacter or not currentCharacter:FindFirstChild("HumanoidRootPart") then return end
    
    local myHumanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
    local targetFound = false
    
    for _, obj in pairs(workspace:GetDescendants()) do
        -- LỌC QUÁI SIÊU CHẶT CHẼ: Loại bỏ hoàn toàn vật thể thuộc Blacklist
        if obj:IsA("Model") and obj ~= currentCharacter and not BlacklistNames[obj.Name] then
            
            local targetHumanoid = obj:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and targetHumanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                -- QUY TRÌNH CHỐNG QUÁI ẢO: Quái thật bắt buộc phải có MaxHealth lớn hơn 100 (để tránh các vùng hitbox ẩn của game)
                if hrp and targetHumanoid.MaxHealth > 100 then
                    
                    targetFound = true -- Tìm thấy quái thực thể thật sự hiển thị
                    
                    -- Khóa trạng thái lơ lửng khi có quái để thực hiện đấm
                    if myHumanoid then 
                        myHumanoid.PlatformStand = true 
                    end
                    
                    -- Vị trí ghim trên mắt Boss chuẩn xác (Cao hơn 4.5 studs, cách mặt 3.5 studs)
                    local targetFacePos = hrp.Position + (hrp.CFrame.LookVector * 3.5) + Vector3.new(0, 4.5, 0)
                    
                    currentCharacter.HumanoidRootPart.CFrame = CFrame.new(targetFacePos, hrp.Position)
                    currentCharacter.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
                    
                    -- Đồng bộ dữ liệu Aim & Camera từ SimpleSpy
                    local camCFrame = CurrentCamera.CFrame
                    local targetPos = hrp.Position
                    local customAim = vector.create(targetPos.X, targetPos.Y, targetPos.Z)
                    
                    -- Xả skill song song tốc độ cao không delay
                    task.spawn(function()
                        for _, id in pairs({"1", "101"}) do 
                            SkillRemote:FireServer({
                                ["Camera"] = camCFrame,  
                                ["SkillId"] = id,
                                ["Began"] = true,
                                ["CFrame"] = hrp.CFrame, 
                                ["Aim"] = customAim,  
                                ["Target"] = obj,        
                                ["Typ\208\181"] = 1
                            })
                        end
                    end)
                    break 
                end
            end
        end
    end
    
    -- XỬ LÝ KHI HẾT SẠCH QUÁI (HẠ CÁNH AN TOÀN ĐỂ ẤN NÚT START)
    if not targetFound then
        if myHumanoid then
            myHumanoid.PlatformStand = false -- Trả nhân vật về trạng thái đi đứng bình thường trên mặt đất
        end
        -- Triệt tiêu hoàn toàn mọi lực quán tính đẩy để nhân vật rơi thẳng xuống sàn sảnh
        currentCharacter.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    
    task.wait(0.1)
end)
