local version = 2
local myLabel = os.getComputerLabel()
local myId = os.getComputerID()
local ec = require("/EnderConnect/ec_lib")

print("EnderConnect Startup Version:" .. version)
print("EnderConnect Library Version:" .. ec.version)

while myLabel == nil or myLabel == "" do
    print("Please Enter a name for this Computer.")
    write("> ")
    myLabel = read()
    if myLabel ~= "" then
        os.setComputerLabel(myLabel)
    else
        print("Name cannot be blank!")
    end
end

print("Computer: " .. myLabel .. " (ID: " .. myId .. ")")

local myPeripherals = ec.scanForPeripherals()

--- I need to hande if there isn't a config script, possibly run an install process where it prompts the user locally if this is the first time this program is run.
local config = ec.loadJSONFile("EnderConnect/ec_config.json")

local saveConfig = false

if not config then
    print("[!] No config file found. Creating default template...")
    config = {
        network_id = "EnderConnect",
        saved_hub_id = ""
    }
    saveConfig = true
end

if not config.role then
    print("[!] Configuration is missing a 'role' definition.")
    print("Please specify a role for this device (hub, node):")
    write("> ")
    config.role = string.lower(read())
    saveConfig = true
end

if not config.ownerID then
    print("[!] Configuration is missing an 'owner' definition.")
    print("Please specify your Minecraft Username:")
    write("> ")
    config.ownerID = string.lower(read())
    saveConfig = true
end

if not config.baseID then
    print("[!] Configuration is missing a 'Base' definition.")
    print("Please specify your Base ID:")
    write("> ")
    config.baseID = string.lower(read())
    saveConfig = true
end

if saveConfig then
        print("Saving settings...")
    local success = ec.saveJSONFile("EnderConnect/ec_config.json", config)
    if success then
        print("Configuration saved successfully!\n")
    else
        print("CRITICAL ERROR: Failed to write configuration to disk.")
        return -- Stop execution if saving failed
    end
end

print("Role: " .. config.role)

if config.role == "hub" then
    print("Launching Hub Controller...")
    -- shell.run("EnderConnect/programs/hub.lua", textutils.serialize(myPeripherals))
elseif config.role == "node" then
    print("Launching Node Worker...")
    -- shell.run("EnderConnect/programs/node.lua", textutils.serialize(myPeripherals))
else
    print("Error: Unknown role '" .. tostring(config.role) .. "' in config.")
end