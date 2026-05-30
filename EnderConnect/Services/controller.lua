local version = 0.2
local ec = require("/EnderConnect/ec_lib")
local controller = {}


function controller.run(modem, config, bossChannel, role)
    print("[controller] Starting as " .. role .. " with host_id " .. config.host_id)

    local registry = ec.loadJSONFile("EnderConnect/ec_registry.json") or {}
    local nodeCount = 0
    for _ in pairs(registry) do nodeCount = nodeCount + 1 end
    print("[controller] Loaded " .. nodeCount .. " known nodes")

    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

        if channel == bossChannel then
            print("[Controller] Got message on channel " .. channel)

            if type(message) == "table" and message.type == "register" then
                local id = tostring(message.senderId)
                
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
                    hostId = config.host_id,
                    status = "ok"
                })
            end
        end
    end
end

return controller