-- [[ DRAGON BLOX SCRIPT HUB ]] --
-- Các tính năng dựa theo yêu cầu trong ảnh Screenshot_20260527_131628.jpg

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Dragon Blox VN Hub 🐉",
   LoadingTitle = "Đang tải Script...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DragonBloxVN",
      FileName = "Config"
   }
})

-- TABS
local TabMain = Window:CreateTab("Tính năng chính", 4483362458)
local TabCombat = Window:CreateTab("Chiến đấu & Boss", 4483362458)

-- VARIABLES (TRẠNG THÁI TÍNH NĂNG)
local AutoPlayAgain = false
local AutoTransform = false
local AutoChargeKi = false
local AntiDieFake = false
local AutoShoot = false
local AutoHeal = false

-- 1. AUTO PLAY AGAIN
TabMain:CreateToggle({
   Name = "Auto Play Again (Tự động chơi lại)",
   CurrentValue = false,
   Callback = function(Value)
      AutoPlayAgain = Value
      task.spawn(function()
         while AutoPlayAgain do
            -- Giả lập logic tìm và nhấn nút Replay/Play Again khi boss chết hoặc màn chơi kết thúc
            pcall(function()
               local ReplayBtn = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PlayAgain", true) or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Replay", true)
               if ReplayBtn and ReplayBtn.Visible then
                  -- Nhấp vào nút
                  local virtualUser = game:GetService("VirtualUser")
                  virtualUser:CaptureController()
                  virtualUser:ClickButton1(Vector2.new(ReplayBtn.AbsolutePosition.X + (ReplayBtn.AbsoluteSize.X/2), ReplayBtn.AbsolutePosition.Y + (ReplayBtn.AbsoluteSize.Y/2)))
               end
            end)
            task.wait(2)
         end
      end)
   end,
})

-- 2. AUTO TRANSFORM
TabMain:CreateToggle({
   Name = "Auto Transform (Tự động biến hình)",
   CurrentValue = false,
   Callback = function(Value)
      AutoTransform = Value
      task.spawn(function()
         while AutoTransform do
            pcall(function()
               -- Gửi tín hiệu biến hình lên Server game (Phím tắt mặc định thường là G hoặc T tuỳ phiên bản)
               game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.G, false, game)
            end)
            task.wait(5) -- Đợi hồi chiêu biến hình
         end
      end)
   end,
})

-- 3. AUTO HỒI KI (CHARGE KI)
TabMain:CreateToggle({
   Name = "Auto Hồi Ki khi hết (Auto Charge)",
   CurrentValue = false,
   Callback = function(Value)
      AutoChargeKi = Value
      task.spawn(function()
         while AutoChargeKi do
            pcall(function()
               -- Kiểm tra thanh năng lượng (Ki/Energy) của người chơi
               local Character = game.Players.LocalPlayer.Character
               -- Thay "Ki" bằng tên thuộc tính chính xác trong game nếu có thay đổi
               if Character and Character:FindFirstChild("Ki") and Character.Ki.Value < 20 then 
                  -- Giữ phím gồng Ki (Thường là phím C)
                  game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.C, false, game)
                  while Character.Ki.Value < Character.MaxKi.Value and AutoChargeKi do
                     task.wait(0.5)
                  end
                  game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.C, false, game)
               end
            end)
            task.wait(1)
         end
      end)
   end,
})

-- 4. ANTI DIE FAKE (Bất tử / Khóa máu giả lập)
TabCombat:CreateToggle({
   Name = "Anti Die Fake (Chống chết / Bất tử)",
   CurrentValue = false,
   Callback = function(Value)
      AntiDieFake = Value
      task.spawn(function()
         while AntiDieFake do
            pcall(function()
               local Humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
               if Humanoid and Humanoid.Health > 0 and Humanoid.Health < 30 then
                  -- Khi máu quá thấp, tạm thời đổi trạng thái hoặc gửi gói tin để tránh bị tính là đã chết
                  Humanoid.Health = Humanoid.MaxHealth
               end
            end)
            task.wait(0.1)
         end
      end)
   end,
})

-- 5. AUTO BẮN / AUTO ATTACK
TabCombat:CreateToggle({
   Name = "Auto Bắn / Đánh Boss",
   CurrentValue = false,
   Callback = function(Value)
      AutoShoot = Value
      task.spawn(function()
         while AutoShoot do
            pcall(function()
               -- Tìm kiếm quái hoặc Boss gần nhất để tự động dùng kỹ năng/bắn chiêu
               local Target = nil
               local MaxDist = 500
               for _, v in pairs(workspace:GetChildren()) do
                  if v:FindFirstChild("Humanoid") and v.Name ~= game.Players.LocalPlayer.Name and v.Humanoid.Health > 0 then
                     local Dist = (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                     if Dist < MaxDist then
                        Target = v
                        MaxDist = Dist
                     end
                  end
               end
               
               if Target then
                  -- Hướng nhân vật về phía Boss và kích hoạt chiêu bắn (Phím E / Click chuột)
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, Target.HumanoidRootPart.Position)
                  game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
               end
            end)
            task.wait(0.3) -- Tốc độ bắn
         end
      end)
   end,
})

-- 6. AUTO HỒI MÁU (HEAL)
TabCombat:CreateToggle({
   Name = "Auto Hồi Máu (Auto Heal)",
   CurrentValue = false,
   Callback = function(Value)
      AutoHeal = Value
      task.spawn(function()
         while AutoHeal do
            pcall(function()
               local Humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
               if Humanoid and Humanoid.Health < (Humanoid.MaxHealth * 0.7) then
                  -- Kích hoạt kỹ năng hồi máu bằng phím (Ví dụ: phím X) hoặc dùng Item hồi máu
                  game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.X, false, game)
               end
            end)
            task.wait(2)
         end
      end)
   end,
})

-- Thông báo kích hoạt thành công
Rayfield:Notify({
   Title = "Thành công!",
   Content = "Script Dragon Blox VN đã sẵn sàng sử dụng.",
   Duration = 5,
   Image = 4483362458,
})
