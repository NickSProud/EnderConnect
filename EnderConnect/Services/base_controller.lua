local version = 0.2
local controller = require("/EnderConnect/Services/controller")
local baseController = {}

function baseController.run(modem, config, bossChannel)
    return controller.run(modem, config, bossChannel, "BASE")
end

return baseController