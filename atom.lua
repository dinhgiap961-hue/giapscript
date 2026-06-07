local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillRemote")

-- =======================================================
-- HOOK METHOD (BỎ QUA COOLDOWN)
-- =======================================================
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
-- HÀM TÌM 1 MỤC TIÊU GẦN NHẤT (TỐI ƯU HÓA PHẦN CỨNG)
-- =======================================================
local function GetClosestMonster()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestMonster = nil
    local shortestDistance = math.huge -- Vô hạn
    
    -- Sử dụng GetChildren thay vì GetDescendants để giảm tải cho CPU
    for _, obj in pairs(workspace:GetChildren()) do
        -- Nếu quái nằm trong thư mục ẩn, bạn có thể đổi thành workspace.Enemies:GetChildren() nếu biết tên thư mục
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= char then
            if obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestMonster = obj
                    end
                end
            end
        end
    end
    return closestMonster
end

-- =======================================================
-- VÒNG LẶP SPAM SKILL THÔNG MINH (CHỐNG LAG SERVER)
-- =======================================================
task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local target = GetClosestMonster() -- Chỉ lấy duy nhất 1 con quái gần nhất
            
            if target then
                local hrp = target:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Gửi lệnh gồng chiêu thức (Began = false)
                    SkillRemote:FireServer({
                        ["SkillId"] = "1",
                        ["Began"] = false,
                        ["CFrame"] = char.HumanoidRootPart.CFrame,
                        ["Aim"] = hrp.Position,
                        ["Target"] = target,
                        ["Type"] = 1
                    })
                    
                    -- Chờ một khoảng cực ngắn (giảm tải packet gửi song song)
                    task.wait(0.02) 
                    
                    -- Gửi lệnh kích hoạt đòn đánh (Began = true)
                    SkillRemote:FireServer({
                        ["SkillId"] = "101",
                        ["Began"] = true,
                        ["CFrame"] = char.HumanoidRootPart.CFrame,
                        ["Aim"] = hrp.Position,
                        ["Target"] = target,
                        ["Type"] = 1
                    })
                end
            end
        end
        -- Khoảng nghỉ giữa mỗi đợt combo (0.1 giây là tốc độ hoàn hảo để vừa nhanh vừa không lag)
        task.wait(0.1) 
    end
end)
