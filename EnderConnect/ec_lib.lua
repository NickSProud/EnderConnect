local version = 1
local github_location = "https://raw.githubusercontent.com/NickSProud/EnderConnect/main/"
local manifest_location = "manifest.json"
local lib = {}

function lib.fetchOnlineManifest() 
    print ("Fetching Manifest")
    local raw_manifest = http.get(github_location .. manifest_location)

    if raw_manifest then
        if raw_manifest.getResponseCode() == 200 then
            local manifest = textutils.unserializeJSON(raw_manifest.readAll())
            raw_manifest.close()
            print("Fetched Manifest")
            return manifest
        else
            print("Manifest not fetched, Responce Code: " .. raw_manifest.getResponseCode())
            raw_manifest.close()
        end
    else
        print("Failed to reach GitHub.")
    end
    return nil
end

function lib.updateFile(manifest, fileName)
    print("Updating "..fileName)
    local raw_file = http.get(github_location .. manifest[fileName].remote_path)
    if raw_file then
        if raw_file.getResponseCode() == 200 then
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
            print("File not fetched, Responce Code: " .. raw_file.getResponseCode())
            raw_file.close()
            return false
        end
    else
        print("Failed to reach GitHub.")
    end
    return false
end

function lib.checkLocalVersion(filePath)
    if not fs.exsits(filePath) then
        print(filePath .. "doesn't exist")
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
end

return lib