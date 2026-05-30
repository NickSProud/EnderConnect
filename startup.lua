local version = 0.2
local ec = require("/EnderConnect/ec_lib")
local config = ec.loadJSONFile("EnderConnect/ec_config.json")
local drivers = ec.loadJSONFile("EnderConnect/ec_drivers.json")
local saveDrivers = false

-- ID Management

print("[Startup] Computer: " .. (os.getComputerLabel() or "unnamed") .. " (ID: " .. os.getComputerID() .. ")")

-- Config Management

if not config or not config.host_id then
    print("[Startup] First-time setup required.")
    shell.run("ec_setup.lua")
    config = ec.loadJSONFile("EnderConnect/ec_config.json")
end

if not config or not config.host_id then
    print("CRITICAL: Setup failed. Please check for errors above.")
    return
end

-- Driver Management

if not drivers then
    print("[Startup] No state file found. Creating default template...")
    drivers = {}
    saveDrivers = true
end

if saveDrivers then
        print("[Startup] Saving driver change...")
    local success = ec.saveJSONFile("EnderConnect/ec_drivers.json", drivers)
    if success then
        print("[Startup] State saved successfully!\n")
    else
        print("CRITICAL ERROR: Failed to write state to disk.")
        return -- Stop execution if saving failed
    end
end

print("[Startup] Handing off to core runtime...")
shell.run("EnderConnect/core.lua")