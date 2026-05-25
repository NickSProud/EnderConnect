local version = 1.1
local ec = require("/EnderConnect/ec_lib")

local config = ec.loadJSONFile("EnderConnect/ec_config.json")
if not config then
    print("CRITICAL: ec_config.json missing")
    return
end

if not config.hub_id then
    print("CRITICAL: No 'hub_id' in config!")
    return
end

local modem, side = ec.findAndOpenModem(config.preferredModemSide)
if not modem then
    print("CRITICAL: No wireless modem found!")
    return
end

local bossChannel = config.hub_id + config.channel_offset
modem.open(bossChannel)

print("[Core] Modem ready on channel " .. bossChannel)

local tasks = {}

if type(config.services) == "table" and config.services.base_controller == true then
    print("[Core] Starting base_controller...")
    local bc = require("/EnderConnect/Services/base_controller")
    table.insert(tasks, function() bc.run(modem, config, bossChannel) end)
end

if #tasks == 0 then
    print("[Core] WARNING: No services configured or enabled.")
    return
end

parallel.waitForAll(table.unpack(tasks))