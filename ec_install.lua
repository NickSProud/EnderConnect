local version = 0.2
local GITHUB_URL = "https://raw.githubusercontent.com/NickSProud/EnderConnect/main/"
local LIB_REPO = "EnderConnect/ec_lib.lua"
local UPDATE_REPO = "ec_update.lua"
local LIB_DEST = "/EnderConnect/ec_lib.lua"
local UPDATE_DEST = "/ec_update.lua"

print("--- EnderConnect Installer ---")

local function downloadFile(repoPath, localPath)
    print("Downloading: " .. localPath)
    local fullUrl = GITHUB_URL .. repoPath
    local response = http.get(fullUrl)
    
    if response then
        local file = fs.open(localPath, "w")
        file.write(response.readAll())
        file.close()
        response.close()
        return true
    else
        -- THIS WILL SHOW YOU EXACTLY WHAT URL IS FAILING
        print("Error! Failed to download from URL:")
        print(fullUrl) 
        return false
    end
end

local libSuccess = downloadFile(LIB_REPO, LIB_DEST)
local updateSuccess = downloadFile(UPDATE_REPO, UPDATE_DEST)

if libSuccess and updateSuccess then
    print("\nCore framework installed successfully!")
    print("Handing off to update system to pull remaining files...")
    sleep(1)

    shell.run(UPDATE_DEST)
else
    print("\nInstallation failed. Check your internet connection or GitHub path.")
end