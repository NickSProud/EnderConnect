local version = 2.1
local github_location = "https://raw.githubusercontent.com/NickSProud/EnderConnect/main/"
local manifest_location = "manifest.json"
local lib = {}
lib.version = version

-- Updating

function lib.fetchOnlineManifest() 
    print ("Fetching Manifest")
    local raw_manifest = http.get(github_location .. manifest_location)

    if raw_manifest then
        local manifest = textutils.unserializeJSON(raw_manifest.readAll())
        raw_manifest.close()
        print("Fetched Manifest")
        return manifest
    else
        print("Failed to reach GitHub.")
    end
    return nil
end

function lib.updateFile(manifest, fileName)
    print("Updating ".. fileName)
    local raw_file = http.get( github_location .. manifest[fileName].path)
    if raw_file then
        local directory = string.match(manifest[fileName].path, "(.+)/[^/]+")
        if directory then
            fs.makeDir(directory)
        end
        local file = fs.open(manifest[fileName].path..".tmp","w")
        file.write(raw_file.readAll())
        file.close()
        raw_file.close()
        if fs.exists(manifest[fileName].path) then
           fs.delete(manifest[fileName].path)
        end
        fs.move(manifest[fileName].path ..".tmp", manifest[fileName].path)
        return true
    else
        print("Failed to reach GitHub.")
    end
    return false
end

function lib.checkLocalVersion(filePath)
    if not fs.exists(filePath) then
        print(filePath .. " doesn't exist")
        return 0
    end
    
    local file = fs.open(filePath, "r")
    local firstLine = file.readLine()
    file.close()

    if firstLine then
        local versionString = string.match(firstLine, "local%s+version%s*=%s*(%d+)")
        if versionString then
            return tonumber(versionString)
        end
    end
    print("Could not parse version string. Defaulting to 0.")
    return 0
end

-- Other?

function lib.scanForPeripherals()
    local foundPeripherals = {}
    print("--- Scanning for Peripherals ---")
    for _, side in ipairs(peripheral.getNames()) do
        foundPeripherals[side] = peripheral.getType(side)
        print("Peripheral: " .. foundPeripherals[side])
        print("Attached: " .. side)
        print("---")
    end
    return foundPeripherals
end

--JSON File Management

function lib.loadJSONFile(filePath)
    if not fs.exists(filePath) then
        print(filePath .. " doesn't exist")
        return nil
    else
        local file = fs.open(filePath, "r")
        local fileContents = file.readAll()
        file.close()
        local jsonObject = textutils.unserializeJSON(fileContents)
        return jsonObject
    end
end

function lib.saveJSONFile(filePath, data)
    local file = fs.open(filePath, "w")
    if not file then
        print("Error: Could not open " .. filePath .. " for writing.")
        return false
    end
    local jsonData = textutils.serializeJSON(data)
    file.writeLine(jsonData)
    file.close()
    return true
end

-- Networking

function lib.findAndOpenModem(preferredSide)
    if preferredSide and preferredSide ~= "auto" then
        if peripheral.getType(preferredSide) == "modem" then
            local modem = peripheral.wrap(preferredSide)
            if modem.isWireless() then
                return modem, preferredSide
            else
                print("Warning: Preferred side '" .. preferredSide .. "' is not a wireless modem.")
            end
        else
            print("Warning: Preferred side '" .. preferredSide .. "' has no modem.")
        end
    end

    -- Fall back to auto-detect
    for _, side in ipairs(peripheral.getNames()) do
        if peripheral.getType(side) == "modem" then
            local modem = peripheral.wrap(side)
            if modem.isWireless() then
                return modem, side
            end
        end
    end
    return nil, nil
end

return lib