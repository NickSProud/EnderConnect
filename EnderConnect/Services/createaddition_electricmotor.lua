local version = 0.2
local ec = require("/EnderConnect/ec_lib")
local motorService = {}

function motorService.run(modem, config, bossChannel)
    -- Load driver config from ec_drivers.json
    local drivers = ec.loadJSONFile("EnderConnect/ec_drivers.json")
    local motorDrivers = drivers and drivers.createaddition_electric_motors or {}

    -- Wrap all motors from driver config
    local motors = {}
    for name, driver in pairs(motorDrivers) do
        if peripheral.getType(driver.side) == "electric_motor" then
            motors[name] = {
                handle = peripheral.wrap(driver.side),
                config = driver
            }
            print("[MotorService] Loaded motor '" .. name .. "' on " .. driver.side)
        else
            print("[MotorService] WARNING: Motor '" .. name .. "' not found on " .. driver.side)
        end
    end

    -- Fall back to auto-detect if no drivers configured
    if next(motors) == nil then
        print("[MotorService] No driver config found. Auto-detecting...")
        local side = ec.findPeripheral("electric_motor")
        if side then
            motors["default"] = {
                handle = peripheral.wrap(side),
                config = { side = side, maxSpeed = 256 }
            }
            print("[MotorService] Auto-detected motor on " .. side)
        end
    end

    if next(motors) == nil then
        print("[MotorService] ERROR: No motors found!")
        return
    end

    -- Register with hub
    local myId = tostring(os.getComputerID())
    local myLabel = os.getComputerLabel() or "motor_controller_" .. myId
    local myChannel = os.getComputerID()
    modem.open(myChannel)

    modem.transmit(bossChannel, myChannel, {
        type = "register",
        senderId = myId,
        senderLabel = myLabel,
        role = "motor_controller",
        motorCount = ec.tableCount(motors)
    })
    print("[MotorService] Registered with hub as " .. myLabel .. " (" .. ec.tableCount(motors) .. " motors)")

    -- Command loop
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

        if channel == myChannel and type(message) == "table" then
            if message.type == "register_ack" then
                print("[MotorService] Hub acknowledged registration")

            elseif message.type == "command" then
                local targetMotor = message.target
                local motor = motors[targetMotor]
                local response = { type = "motor_response", target = targetMotor, command = message.action }

                if not motor then
                    response.success = false
                    response.error = "Motor not found: " .. tostring(targetMotor)
                else
                    if message.action == "setSpeed" then
                        local rpm = tonumber(message.value) or 0
                        local max = motor.config.maxSpeed or 256
                        if math.abs(rpm) > max then
                            rpm = (rpm > 0) and max or -max
                        end
                        motor.handle.setSpeed(rpm)
                        response.success = true
                        response.speed = motor.handle.getSpeed()

                    elseif message.action == "stop" then
                        motor.handle.stop()
                        response.success = true
                        response.speed = 0

                    elseif message.action == "status" then
                        response.success = true
                        response.speed = motor.handle.getSpeed()
                        response.energy = motor.handle.getEnergyConsumption()
                        response.stress = motor.handle.getStressCapacity()

                    else
                        response.success = false
                        response.error = "Unknown command: " .. message.action
                    end
                end

                modem.transmit(bossChannel, myChannel, response)
            end
        end
    end
end

return motorService
