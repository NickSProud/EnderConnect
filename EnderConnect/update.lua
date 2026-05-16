local version = 1
local args = { ... }

if #args == 0 then 
    print("Updating all")
elseif #args == 1 then
    print("Updating ".. args[1])
else
    print("Only use one argument for the file you want updated or no arguments for update all")
    return false
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

if #args == 0 then 
    for fileName, fileData in pairs(onlineManifest) do
        print("File: " .. fileName ..  " Version: " .. fileData.version)
        doThatUpdate(fileData.path)
    end
    return true
elseif #args == 1 then
    local targetFile = args[1]
    if onlineManifest[targetFile] then
        doThatUpdate(onlineManifest[targetFile].path)
    else
        print("File " .. targetFile .." not in Manifest.")
        return false
    end
else
    print("If you can see this message something has gone very wrong.")
    return false
end