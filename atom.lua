-- [[ DRAGON BLOX COMPLETE HUB V2 ]] --
-- Cập nhật hệ thống biến toàn diện dựa trên Screenshot_20260527_131628.jpg

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Dragon Blox VN - Advanced Hub 🐉",
   LoadingTitle = "Đang đồng bộ hóa biến hệ thống...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DragonBloxVN_Config",
      FileName = "Advanced"
   }
})

-- ====================================================================
-- TRÌNH QUẢN LÝ BIẾN HỆ THỐNG CỦA GAME (GAME VARIABLES & REPLICATED STORAGE)
-- ====================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Khai báo hệ thống thư mục dữ liệu nội bộ thường gặp trong game
local PlayerData = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
local CharacterData = nil

-- Hàm khởi tạo lại dữ liệu khi nhân vật hồi sinh (Reset Biến)
local function UpdateCharacterVariables()
    local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    CharacterData = {
        Character = Char,
        Humanoid = Char:WaitForChild("Humanoid"),
        HumanoidRootPart = Char:WaitForChild("HumanoidRootPart"),
        -- Các biến quản lý chỉ số trạng thái thực tế
        Ki = Char:FindFirstChild("Ki") or (PlayerData and PlayerData:FindFirstChild("Ki")) or {Value = 100},
        MaxKi = Char:FindFirstChild("MaxKi") or (PlayerData and PlayerData:FindFirstChild("MaxKi")) or {Value = 100},
        Health = Char:FindFirstChild("Health") or Char.Humanoid.Health,
        MaxHealth = Char:FindFirstChild("MaxHealth") or Char.Humanoid.MaxHealth,
        Transforming = Char:FindFirstChild("Transforming") or Char:FindFirstChild("IsTransformed"),
        Skills = LocalPlayer:FindFirstChild("Skills") or ReplicatedStorage:FindFirstChild("Skills")
    }
end
UpdateCharacterVariables()
LocalPlayer.CharacterAdded:Connect(UpdateCharacterVariables)

-- Hệ thống cổng giao tiếp mạng (Remotes) phục vụ cơ chế Auto
local Remotes = {
    Transform = ReplicatedStorage:FindFirstChild("Transform") or ReplicatedStorage:FindFirstChild("TransformRemote") or ReplicatedStorage:FindFirstChild("Transformation"),
    ChargeKi = ReplicatedStorage:FindFirstChild("Charge") or ReplicatedStorage:FindFirstChild("ChargeKi") or ReplicatedStorage:FindFirstChild("ChargeRemote"),
    Combat = ReplicatedStorage:FindFirstChild("Combat") or ReplicatedStorage:FindFirstChild("Attack") or ReplicatedStorage:FindFirstChild("Punch"),
    SkillUse = ReplicatedStorage:FindFirstChild("UseSkill") or ReplicatedStorage:FindFirstChild("SkillRemote"),
    Heal = ReplicatedStorage:FindFirstChild("Heal") or ReplicatedStorage:FindFirstChild("HealRemote")
}

-- ====================================================================
-- BIẾN ĐIỀU KHIỂN TRẠNG THÁI VÒNG LẶP (TOGGLE STATES)
-- ====================================================================
local Flags = {
    AutoPlayAgain = false,
    AutoTransform = false,
    AutoChargeKi = false,
    AntiDieFake = false,
    AutoShoot = false,
    AutoHeal = false
}

-- TABS INTERFACE
local TabMain = Window:CreateTab("Tự Động Cày Cuốc", 4483362458)
local TabCombat = Window:CreateTab("Hỗ Trợ Chiến Đấu", 4483362458)

-- ====================================================================
-- THỰC THI CÁC TÍNH NĂNG
-- ====================================================================

-- 1. AUTO PLAY AGAIN
TabMain:CreateToggle({
   Name = "Auto Play Again (Tự động chơi lại)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoPlayAgain = Value
      task.spawn(function()
         while Flags.AutoPlayAgain do
            pcall(function()
               -- Quét tất cả các UI tìm nút chơi lại dựa trên cấu trúc Client Gui
               for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                  if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                     if string.find(string.lower(gui.Name), "again") or string.find(string.lower(gui.Name), "replay") or string.find(string.lower(gui.Text), "chơi lại") then
                        if gui.Visible then
                           -- Giả lập kích hoạt trực tiếp sự kiện nhấn nút thay vì tọa độ ảo
                           gui:Activate()
                           firesignal(gui.MouseButton1Click)
                        end
                     end
                  end
               end
            end)
            task.wait(1.5)
         end
      end)
   end,
})

-- 2. AUTO TRANSFORM
TabMain:CreateToggle({
   Name = "Auto Transform (Tự động biến hình)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoTransform = Value
      task.spawn(function()
         while Flags.AutoTransform do
            pcall(function()
               if CharacterData and not CharacterData.Transforming.Value then
                  -- Gửi lệnh biến hình trực tiếp qua Remote Event của game để tránh trễ phím
                  if Remotes.Transform and Remotes.Transform:IsA("RemoteEvent") then
                     Remotes.Transform:FireServer("Transform", "HighestForm") -- Biến hình dạng cao nhất có sẵn
                  else
                     -- Phương án dự phòng 2 nếu game bảo mật Remote
                     game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.G, false, game)
                  end
               end
            end)
            task.wait(3)
         end
      end)
   end,
})

-- 3. AUTO HỒI KI KHI HẾT (AUTO CHARGE)
TabMain:CreateToggle({
   Name = "Auto Hồi Ki khi hết",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoChargeKi = Value
      task.spawn(function()
         while Flags.AutoChargeKi do
            pcall(function()
               if CharacterData and CharacterData.Ki.Value < (CharacterData.MaxKi.Value * 0.2) then
                  -- Kích hoạt trạng thái gồng Ki bằng cách gửi gói tin liên tục lên Server
                  if Remotes.ChargeKi and Remotes.ChargeKi:IsA("RemoteEvent") then
                     Remotes.ChargeKi:FireServer(true)
                     while CharacterData.Ki.Value < CharacterData.MaxKi.Value and Flags.AutoChargeKi do
                        task.wait(0.2)
                     end
                     Remotes.ChargeKi:FireServer(false)
                  else
                     -- Phương án dự phòng bằng giả lập giữ phím C
                     game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.C, false, game)
                     while CharacterData.Ki.Value < CharacterData.MaxKi.Value and Flags.AutoChargeKi do task.wait(0.5) end
                     game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.C, false, game)
                  end
               end
            end)
            task.wait(1)
         end
      end)
   end,
})

-- 4. ANTI DIE FAKE (BẤT TỬ)
TabCombat:CreateToggle({
   Name = "Anti Die Fake (Chống chết)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AntiDieFake = Value
      task.spawn(function()
         while Flags.AntiDieFake do
            pcall(function()
               if CharacterData and CharacterData.Humanoid.Health > 0 and CharacterData.Humanoid.Health < (CharacterData.Humanoid.MaxHealth * 0.25) then
                  -- Đóng băng hoặc can thiệp trực tiếp vào trạng thái nhân vật cục bộ để chặn chết
                  CharacterData.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                  CharacterData.Humanoid.Health = CharacterData.Humanoid.MaxHealth
               end
            end)
            task.wait(0.05) -- Tần suất quét cực cao để tránh chết đột tử
         end
      end)
   end,
})

-- 5. AUTO BẮN CHIÊU / AUTO ATTACK
TabCombat:CreateToggle({
   Name = "Auto Bắn / Tấn Công",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoShoot = Value
      task.spawn(function()
         while Flags.AutoShoot do
            pcall(function()
               -- Tìm Boss hoặc Quái vật gần nhất có nhiều máu nhất
               local Target = nil
               local MinDistance = 600
               for _, obj in pairs(workspace:GetChildren()) do
                  if obj:FindFirstChild("Humanoid") and obj.Name ~= LocalPlayer.Name and obj.Humanoid.Health > 0 then
                     local Root = obj:FindFirstChild("HumanoidRootPart")
                     if Root and CharacterData then
                        local Distance = (Root.Position - CharacterData.HumanoidRootPart.Position).Magnitude
                        if Distance < MinDistance then
                           Target = obj
                           MinDistance = Distance
                        end
                     end
                  end
               end

               -- Thực hiện tấn công nếu tìm thấy mục tiêu
               if Target and CharacterData then
                  -- Khóa mục tiêu nhìn thẳng vào Boss
                  CharacterData.HumanoidRootPart.CFrame = CFrame.new(CharacterData.HumanoidRootPart.Position, Target.HumanoidRootPart.Position)
                  
                  -- Gửi lệnh sử dụng kỹ năng bắn sóng năng lượng (Ki Blast) thông qua biến Skill có sẵn
                  if Remotes.SkillUse then
                     Remotes.SkillUse:FireServer("KiBlast", Target.HumanoidRootPart.Position)
                  elseif Remotes.Combat then
                     Remotes.Combat:FireServer()
                  else
                     -- Sử dụng phím tắt nếu game chặn hoàn toàn
                     game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                  end
               end
            end)
            task.wait(0.2)
         end
      end)
   end,
})

-- 6. AUTO HỒI MÁU (AUTO HEAL)
TabCombat:CreateToggle({
   Name = "Auto Hồi Máu (Auto Heal)",
   CurrentValue = false,
   Callback = function(Value)
      Flags.AutoHeal = Value
      task.spawn(function()
         while Flags.AutoHeal do
            pcall(function()
               if CharacterData and CharacterData.Humanoid.Health < (CharacterData.Humanoid.MaxHealth * 0.6) then
                  -- Kích hoạt hàm hồi phục qua Remote của lớp nhân vật hoặc phím tắt
                  if Remotes.Heal then
                     Remotes.Heal:FireServer()
                  else
                     game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.X, false, game)
                  end
               end
            end)
            task.wait(1.5)
         end
      end)
   end,
})

-- THÔNG BÁO HOÀN TẤT ĐỒNG BỘ
Rayfield:Notify({
   Title = "Hệ Thống Đã Sẵn Sàng!",
   Content = "Đã tích hợp toàn bộ các biến cấu trúc của Dragon Blox.",
   Duration = 6,
   Image = 4483362458,
})
