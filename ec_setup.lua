local version = 0.21
local ec = require("/EnderConnect/ec_lib")
local myLabel = os.getComputerLabel()
local config = ec.loadJSONFile("/EnderConnect/ec_config.json") or {}
local drivers = ec.loadJSONFile("EnderConnect/ec_drivers.json")
local default_channel_offset = 1000

while myLabel == nil or myLabel == "" do
    print("[Setup] Please Enter a name for this Computer.")
    write("> ")
    myLabel = read()
    if myLabel ~= "" then
        os.setComputerLabel(myLabel)
    else
        print("[Setup] Name cannot be blank.")
    end
end

if not config.ownerID then
    print("[Setup] Configuration is missing an 'owner' definition.")
    print("Please specify your Minecraft Username:")
    write("> ")
    config.ownerID = string.lower(read())
end

if config.host_id and not config.parent_id then
    config.parent_id = config.host_id
    config.host_id = nil
    ec.saveJSONFile("EnderConnect/ec_config.json", config)
end

if config.parent_id == nil then
    print("[Setup] Is this computer the Server Master? (y/n)")
    write("> ")
    if string.lower(read()) == "y" then
        config.parent_id = os.getComputerID()
        print("[Setup] Set as Host (ID: " .. config.parent_id .. ")")
    else
        print("[Setup] Enter the Host Computer ID:")
        while config.parent_id == nil do
            write("> ")
            config.parent_id = tonumber(read())
            if config.parent_id == nil then 
                print("[Setup] Invalid ID. Numbers only.")
            end
        end
    end
end

if not config.services then
    print("\n[Setup] Select services:")
    print("[1] master controller")
    print("[2] base controller")
    print("[3] Create Additions: Eletric Motor")
    print("Enter numbers, comma-separated (e.g., 1,2):")
    write("> ")
    local choice = read()
    config.services = {}

    for item in choice:gmatch("[^,]+") do
        item = item:gsub("^%s*(.-)%s*$", "%1")  -- trim whitespace
        if item == "1" then
            config.services.master_controller = true
        elseif item == "2" then
            config.services.base_controller = true
        elseif item == "3" then
            config.services.createaddition_electricmotor = true
        elseif item == "all" then
            config.services.base_controller = true
            config.services.master_controller = true
            config.services.createaddition_electricmotor = true
        end
    end
end

if not config.channel_offset then 
    config.channel_offset = default_channel_offset
end

if not config.preferredModemSide then
    config.preferredModemSide = "auto"
end

print("[Setup] Saving settings...")
local success = ec.saveJSONFile("EnderConnect/ec_config.json", config)
if success then
    print("[Setup] Configuration saved successfully!\n")
else
    print("[Setup] ERROR: Failed to write configuration to disk.")
end