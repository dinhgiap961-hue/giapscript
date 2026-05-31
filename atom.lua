-- Phương pháp: Mô phỏng phím bấm thật (Không cần RemoteEvent)
local VIM = game:GetService("VirtualInputManager")

task.spawn(function()
    while task.wait(0.2) do -- Nhịp độ spam phím
        pcall(function()
            -- Gửi phím 'E' (thường là chiêu cơ bản)
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            
            -- Gửi phím 'R' (thường là chiêu phụ)
            VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end)
    end
end)
