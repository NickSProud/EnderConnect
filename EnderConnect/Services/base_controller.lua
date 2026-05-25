local version = 1
local ec = require("/EnderConnect/ec_lib")
local baseController = {}

function baseController.run(modem, config, bossChannel)
    print("[BaseController] Starting with hub_id " .. config.hub_id)

    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

        if channel == bossChannel then
            print("[BaseController] Got message on channel " .. channel)

            if type(message) == "table" and message.type == "register" then
                print("  -> Register: " .. message.senderLabel .. " (ID: " .. message.senderId .. ")")

                -- We can reply using the modem that was passed to us
                local reply = {
                    type = "register_ack",
                    hubId = config.hub_id,
                    status = "ok"
                }
                modem.transmit(replyChannel, bossChannel, reply)
            end
        end
    end
end

return baseController