local version = 0.2
local ec = require("/EnderConnect/ec_lib")
local config = ec.loadJSONFile("/EnderConnect/ec_config.json")

if not config then
    print("CRITICAL: ec_config.json missing")
    return
end

if not config.host_id then
    print("CRITICAL: No 'host_id' in config!")
    return
end

local hostChannel = config.host_id + config.channel_offset

local modem, side = ec.findAndOpenModem(config.preferredModemSide)
if not modem then
    print("CRITICAL: No wireless modem found!")
    return
end

modem.open(hostChannel)

print("[Core] Modem ready on channel " .. hostChannel)

local tasks = {}

if type(config.services) == "table" and config.services.base_controller == true then
    print("[Core] Starting base_controller...")
    local baseController = require("/EnderConnect/Services/base_controller")
    table.insert(tasks, function() baseController.run(modem, config, hostChannel) end)
end

if type(config.services) == "table" and config.services.createaddition_electricmotor == true then
    print("[Core] Starting createaddition_electricmotor...")
    local electricMotor = require("/EnderConnect/Services/createaddition_electricmotor")
    table.insert(tasks, function() electricMotor.run(modem, config, hostChannel) end)
end

if #tasks == 0 then
    print("[Core] WARNING: No services configured or enabled.")
    return
end

parallel.waitForAll(table.unpack(tasks))