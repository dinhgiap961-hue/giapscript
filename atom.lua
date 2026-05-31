-- SCRIPT DÒ TÊN REMOTE (DEBUG)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("--- DANH SÁCH REMOTE TÌM THẤY ---")
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        print("Tìm thấy Remote: " .. v.Name .. " tại đường dẫn: " .. v:GetFullName())
    end
end
print("--- KẾT THÚC ---")
