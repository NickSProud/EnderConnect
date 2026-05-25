local version = 1
local myLabel = os.getComputerLabel()
local myId = os.getComputerID()
local ec = require("/EnderConnect/ec_lib")

print("EnderConnect Startup Version:" .. version)
print("EnderConnect Library Version:" .. ec.version)

-- ID Management

while myLabel == nil or myLabel == "" do
    print("Please Enter a name for this Computer.")
    write("> ")
    myLabel = read()
    if myLabel ~= "" then
        os.setComputerLabel(myLabel)
    else
        print("Name cannot be blank.")
    end
end

print("Computer: " .. myLabel .. " (ID: " .. myId .. ")")

-- Config Management

local config = ec.loadJSONFile("EnderConnect/ec_config.json")

local saveConfig = false

if not config then
    print("[!] No config file found. Creating default template...")
    config = {}
    saveConfig = true
end

if not config.channel_offset then 
    config.channel_offset = 1000
    saveConfig = true
end

if not config.preferredModemSide then
    config.preferredModemSide = "auto"
    saveConfig = true
end

if not config.services then
    print("[!] This device needs services configured. for now lets just call it a controller")
    config.services = {base_controller = true}
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
    print("Please specify your Base ID: ")
    write("> ")
    config.baseID = string.lower(read())
    saveConfig = true
end

if not config.hub_id then
    config.hub_id = os.getComputerID()
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

-- Driver Management

local drivers = ec.loadJSONFile("EnderConnect/ec_drivers.json")

local saveDrivers = false

if not drivers then
    print("[!] No state file found. Creating default template...")
    drivers = {}
    saveDrivers = true
end

if saveDrivers then
        print("Saving driver change...")
    local success = ec.saveJSONFile("EnderConnect/ec_drivers.json", drivers)
    if success then
        print("State saved successfully!\n")
    else
        print("CRITICAL ERROR: Failed to write state to disk.")
        return -- Stop execution if saving failed
    end
end

print("[Startup] Handing off to core runtime...")
shell.run("EnderConnect/core.lua")