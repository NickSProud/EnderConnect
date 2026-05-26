local version = 1
local GITHUB_URL = "https://raw.githubusercontent.com/NickSProud/EnderConnect/main/EnderConnect/"
local LIB_DEST = "EnderConnect/ec_lib.lua"
local UPDATE_DEST = "EnderConnect/update.lua"

print("--- EnderConnect Installer ---")

if not fs.exists("EnderConnect") then
    fs.makeDir("EnderConnect")
end

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

local libSuccess = downloadFile("ec_lib.lua", LIB_DEST)
local updateSuccess = downloadFile("update.lua", UPDATE_DEST)

if libSuccess and updateSuccess then
    print("\nCore framework installed successfully!")
    print("Handing off to update system to pull remaining files...")
    sleep(1)

    shell.run(UPDATE_DEST)
else
    print("\nInstallation failed. Check your internet connection or GitHub path.")
end