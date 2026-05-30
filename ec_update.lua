local version = 0.2
local args = { ... }
local shouldReboot = true
local targetFile = nil
local ec = require("/EnderConnect/ec_lib")
local onlineManifest = ec.fetchOnlineManifest()
local anyFilesUpdated = false
local config = ec.loadJSONFile("/EnderConnect/ec_config.json") or {}
local activeTags = {["required"] = true}

if type(config.services) == "table" then
    if config.services.master_controller then activeTags["master_controller"] = true end
    if config.services.base_controller then activeTags["base_controller"] = true end
    if config.services.createaddition_electricmotor then activeTags["createaddition_electricmotor"] = true end
end

for i = 1, #args do
    local arg = args[i]
    if arg == "-noreboot" then
        shouldReboot = false
    else
        if targetFile == nil then
            targetFile = arg
        else
            print("Error: You can only specify one file to update.")
            return false
        end
    end
end

if onlineManifest == nil then
    print("No Manifest Available")
    return false
end

local function fileNameFromPath(filePath)
    return string.match(filePath, "([^/]+)%.lua$") or filePath
end

local function shouldDownload(fileData)
    for _, tag in ipairs(fileData.tags) do
        if activeTags[tag] then return true end
    end
    return false
end

local function versionCheck(filePath)
    local localVer = ec.checkLocalVersion(filePath) or 0
    if localVer < onlineManifest[fileNameFromPath(filePath)].version then
        return true
    else
        return false
    end
end

local function doThatUpdate(filePath)
    if versionCheck(filePath) then
        ec.updateFile(onlineManifest,fileNameFromPath(filePath))
        return true
    else
        return false
    end
end

if targetFile == nil then 
    for fileName, fileData in pairs(onlineManifest) do
        print("[Update] File: " .. fileName ..  " Version: " .. fileData.version)
        if not shouldDownload(fileData) then
            print("[Update] Skipping " .. fileName .. " (not required for this role)")
        else
            if doThatUpdate(fileData.path) then
                anyFilesUpdated = true
            end
        end
    end
else
    if onlineManifest[targetFile] then
        print("Checking File: " .. targetFile)
        if doThatUpdate(onlineManifest[targetFile].path) then
            anyFilesUpdated = true
        else
            print(targetFile .. " is already up to date.")
        end
    else
        print("File " .. targetFile .." not in Manifest.")
        return false
    end
end

if anyFilesUpdated then
    if shouldReboot then
        print("\n[+] Updates applied successfully!")
        print("Rebooting system to apply updates...")
        for i = 3, 1, -1 do
            print(i .. "...")
            sleep(1)
        end
        os.reboot()
    else
        print("\n[+] Updates applied successfully! (Reboot bypassed by user)")
    end
else
    print("\n[+] Everything is already up to date. No actions taken.")
end

return true