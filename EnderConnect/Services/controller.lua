local version = 0.21
local ec = require("/EnderConnect/ec_lib")
local controller = {}


function controller.run(modem, config, parentChannel, role)
    print("[controller] Starting as " .. role .. " with parent_id " .. config.parent_id)

    local registry = ec.loadJSONFile("EnderConnect/ec_registry.json") or {}
    local nodeCount = 0
    local myChannel = os.getComputerID() + config.channel_offset

    for _ in pairs(registry) do nodeCount = nodeCount + 1 end
    print("[controller] Loaded " .. nodeCount .. " known nodes")

    while true do
        local eventData = {os.pullEvent()}
        local event = eventData[1]

        if event == "modem_message" then
            local side, channel, replyChannel, message = eventData[2], eventData[3], eventData[4], eventData[5]
            
            if channel == parentChannel or channel == myChannel then
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

                    modem.transmit(replyChannel, parentChannel, {
                        type = "register_ack",
                        parentId = config.parent_id,
                        status = "ok"
                    })
                    
                    if channel == myChannel and role == "BASE" then
                        modem.transmit(parentChannel, myChannel, message)
                        print("  -> Forwarded to master")
                    end
                end
            end
        elseif event == "key" then
            local key = eventData[2]
            if key == keys.u then
                local broadcastChannel = (config.channel_offset - 1) % 65536
                modem.transmit(broadcastChannel, myChannel, {type = "update"})
                print("[Controller] Update broadcast sent!")
            end
        end
    end
end

return controller
