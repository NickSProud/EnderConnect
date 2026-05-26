local version = 1
local args = { ... }
local shouldReboot = true
local targetFile = nil

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

local ec = require("/EnderConnect/ec_lib")
local onlineManifest = ec.fetchOnlineManifest()

if onlineManifest == nil then
    print("No Manifest Avaialbe")
    return false
end

local function fileNameFromPath(filePath)
    return string.match(filePath, "([^/]+)%.lua$") or filePath
end

local function toUpdate(filePath)
    if ec.checkLocalVersion(filePath) < onlineManifest[fileNameFromPath(filePath)].version then
        return true
    else
        return false
    end
end

local function doThatUpdate(filePath)
    if toUpdate(filePath) then
        ec.updateFile(onlineManifest,fileNameFromPath(filePath))
        return true
    else
        return false
    end
end

local anyFilesUpdated = false

if targetFile == nil then 
    for fileName, fileData in pairs(onlineManifest) do
        print("File: " .. fileName ..  " Version: " .. fileData.version)
         if doThatUpdate(fileData.path) then
            anyFilesUpdated = true
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