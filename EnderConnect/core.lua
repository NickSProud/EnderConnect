local version = 0.21
local ec = require("/EnderConnect/ec_lib")
local config = ec.loadJSONFile("/EnderConnect/ec_config.json")

if not config then
    print("CRITICAL: ec_config.json missing")
    return
end

if not config.parent_id then
    print("CRITICAL: No 'parent_id' in config!")
    return
end

local myChannel = os.getComputerID() + config.channel_offset
local parentChannel = config.parent_id + config.channel_offset
local broadcastChannel = (config.channel_offset - 1) % 65536

local modem, side = ec.findAndOpenModem(config.preferredModemSide)
if not modem then
    print("CRITICAL: No wireless modem found!")
    return
end

modem.open(myChannel)
modem.open(parentChannel)
modem.open(broadcastChannel)
print("[Core] Modem ready on channel " .. parentChannel)

local tasks = {}

table.insert(tasks, function()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == broadcastChannel and type(message) == "table" and message.type == "update" then
            print("[Core] Update broadcast received. Running ec_update...")
            shell.run("ec_update")
        end
    end
end)

if type(config.services) == "table" and config.services.base_controller == true then
    print("[Core] Starting base_controller...")
    local baseController = require("/EnderConnect/Services/base_controller")
    table.insert(tasks, function() baseController.run(modem, config, parentChannel) end)
end

if type(config.services) == "table" and config.services.master_controller == true then
    print("[Core] Starting master_controller...")
    local masterController = require("/EnderConnect/Services/master_controller")
    table.insert(tasks, function() masterController.run(modem, config, parentChannel) end)
end

if type(config.services) == "table" and config.services.createaddition_electricmotor == true then
    print("[Core] Starting createaddition_electricmotor...")
    local electricMotor = require("/EnderConnect/Services/createaddition_electricmotor")
    table.insert(tasks, function() electricMotor.run(modem, config, parentChannel) end)
end

if #tasks == 0 then
    print("[Core] WARNING: No services configured or enabled.")
    return
end

parallel.waitForAll(table.unpack(tasks))