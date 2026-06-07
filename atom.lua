local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SkillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillRemote")
local CurrentCamera = Workspace.CurrentCamera

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
-- HÀM TÌM 1 MỤC TIÊU GẦN NHẤT (QUÉT SÂU HƠN ĐỂ TRÁNH SÓT)
-- =======================================================
local function GetClosestMonster()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestMonster = nil
    local shortestDistance = math.huge
    
    -- Quét toàn bộ Descendants để chắc chắn tìm thấy quái nếu game giấu trong Folder
    for _, obj in pairs(workspace:GetDescendants()) do
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
-- VÒNG LẶP COMBO CHUẨN ĐỊNH DẠNG SIMPLESPY (CHỐNG LAG)
-- =======================================================
task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local target = GetClosestMonster()
            
            if target and target:FindFirstChild("HumanoidRootPart") then
                local hrp = target.HumanoidRootPart
                local myCFrame = char.HumanoidRootPart.CFrame
                local camCFrame = CurrentCamera.CFrame
                
                -- Định dạng lại tọa độ Aim theo vector.create chuẩn của game
                local customAim = vector.create(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
                
                -- --- COMBO SKILL 1: ĐẤM (SkillId = "1") ---
                SkillRemote:FireServer({
                    ["Camera"] = camCFrame, -- Thêm Camera để bypass check ảo
                    ["SkillId"] = "1",
                    ["Began"] = true,
                    ["CFrame"] = myCFrame,
                    ["Typ\208\181"] = 1,
                    ["Aim"] = customAim,
                    ["Target"] = target
                })
                
                -- Giãn cách nhỏ giữa 2 skill để không làm nghẽn packet của server
                task.wait(0.06)
                
                -- --- COMBO SKILL 2: ENERGY (SkillId = "101") ---
                SkillRemote:FireServer({
                    ["Camera"] = camCFrame,
                    ["SkillId"] = "101",
                    ["Began"] = true,
                    ["CFrame"] = myCFrame,
                    ["Typ\208\181"] = 1,
                    ["Aim"] = customAim,
                    ["Target"] = target
                })
            end
        end
        -- Tốc độ lặp lại combo (0.12 giây một lần là tối ưu nhất)
        task.wait(0.12)
    end
end)
