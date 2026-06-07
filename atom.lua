local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")

-- Hook để bỏ qua kiểm tra cooldown
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if self == SkillRemote and method == "FireServer" then
        args[1]["Time"] = 0
        args[1]["IsValid"] = true
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- AUTO SKILL CHUẨN (Tự động tung chiêu)
RunService.Heartbeat:Connect(function()
    -- Tìm quái
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
            if obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Gửi lệnh tung chiêu thức 101
                    -- Nhiều game cần phải có thông số 'Began' là false ngay từ đầu để tránh gồng
                    SkillRemote:FireServer({
                        ["SkillId"] = "101",
                        ["Began"] = false,  -- Đổi từ true sang false để bỏ qua gồng
                        ["CFrame"] = LocalPlayer.Character.HumanoidRootPart.CFrame,
                        ["Aim"] = hrp.Position,
                        ["Target"] = obj,
                        ["Typ\208\181"] = 1
                    })
                    
                    -- Thêm một lệnh kích hoạt nếu cần thiết (tùy game)
                    SkillRemote:FireServer({
                        ["SkillId"] = "101",
                        ["Began"] = true, -- Kích hoạt đòn đánh
                        ["CFrame"] = LocalPlayer.Character.HumanoidRootPart.CFrame,
                        ["Aim"] = hrp.Position,
                        ["Target"] = obj,
                        ["Typ\208\181"] = 1
                    })
                end
            end
        end
    end
    task.wait(0.5) -- Delay để không làm crash game
end)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")

-- Hook để bỏ qua kiểm tra cooldown
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if self == SkillRemote and method == "FireServer" then
        args[1]["Time"] = 0
        args[1]["IsValid"] = true
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- AUTO SKILL CHUẨN (Tự động tung chiêu)
RunService.Heartbeat:Connect(function()
    -- Tìm quái
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
            if obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Gửi lệnh tung chiêu thức 101
                    -- Nhiều game cần phải có thông số 'Began' là false ngay từ đầu để tránh gồng
                    SkillRemote:FireServer({
                        ["SkillId"] = "101",
                        ["Began"] = false,  -- Đổi từ true sang false để bỏ qua gồng
                        ["CFrame"] = LocalPlayer.Character.HumanoidRootPart.CFrame,
                        ["Aim"] = hrp.Position,
                        ["Target"] = obj,
                        ["Typ\208\181"] = 1
                    })
                    
                    -- Thêm một lệnh kích hoạt nếu cần thiết (tùy game)
                    SkillRemote:FireServer({
                        ["SkillId"] = "101",
                        ["Began"] = true, -- Kích hoạt đòn đánh
                        ["CFrame"] = LocalPlayer.Character.HumanoidRootPart.CFrame,
                        ["Aim"] = hrp.Position,
                        ["Target"] = obj,
                        ["Typ\208\181"] = 1
                    })
                end
            end
        end
    end
    task.wait(0.5) -- Delay để không làm crash game
end)