local version = 1
local computer_label = os.getComputerLabel()
local computer_id = os.getComputerID()

print("EnderConnect Version:" .. version)

if computer_label ~= nil then 
    print("Computer Label: " .. computer_label)
else
    print("Computer Label: nil.")
end

if computer_id ~= nil then 
    print("Computer ID: " .. computer_id)
else
    print("Computer ID Not Set")
end