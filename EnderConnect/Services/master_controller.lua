local version = 0.2
local controller = require("/EnderConnect/Services/controller")
local masterController = {}

function masterController.run(modem, config, bossChannel)
    return controller.run(modem, config, bossChannel, "MASTER")
end

return masterController