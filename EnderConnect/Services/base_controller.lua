local version = 1
local ec = require("/EnderConnect/ec_lib")
local baseController = {}


function baseController.run(modem, config, bossChannel)
    print("[BaseController] Starting with hub_id " .. config.hub_id)

    local registry = ec.loadJSONFile("EnderConnect/ec_registry.json") or {}
    local nodeCount = 0
    for _ in pairs(registry) do nodeCount = nodeCount + 1 end
    print("[BaseController] Loaded " .. nodeCount .. " known nodes")

    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

        if channel == bossChannel then
            print("[BaseController] Got message on channel " .. channel)

            if type(message) == "table" and message.type == "register" then
                local id = message.senderId
                
                if registry[id] then
                    registry[id].label = message.senderLabel
                    registry[id].lastSeen = os.time()
                    registry[id].status = "online"
                    registry[id].replyChannel = replyChannel
                    print("  -> Updated: " .. message.senderLabel .. " (ID: " .. id .. ")")
                else
                    registry[id] = {
                        label = message.senderLabel,
                        role = message.role or "unknown",
                        replyChannel = replyChannel,
                        firstSeen = os.time(),
                        lastSeen = os.time(),
                        status = "online"
                    }
                    print("  -> Registered: " .. message.senderLabel .. " (ID: " .. id .. ")")
                end

                ec.saveJSONFile("EnderConnect/ec_registry.json", registry)

                modem.transmit(replyChannel, bossChannel, {
                    type = "register_ack",
                    hubId = config.hub_id,
                    status = "ok"
                })
            end
        end
    end
end

return baseController