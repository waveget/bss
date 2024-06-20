local Players = game:GetService("Players")

-- Define the whitelisted player IDs
local whitelistedPlayerIDs = {
    80299238,  
}

-- Check if player is whitelisted
local function IsPlayerWhitelisted(player)
    local playerID = player.UserId
    for _, id in ipairs(whitelistedPlayerIDs) do
        if id == playerID then
            return true
        end
    end
    return false
end

-- Proceed if player is whitelisted
local function CheckWhitelistAndProceed(player, webhook, webhookRoleIDs)
    local playerName = player.Name
    local playerID = player.UserId
    print("Checking whitelist for player: " .. playerName .. " (" .. playerID .. ")")
    
    if IsPlayerWhitelisted(player) then
        print("Player " .. playerName .. " (" .. playerID .. ") is whitelisted. Proceeding with the main script.")
        
        -- Load and execute the main script
        local externalScript = game:HttpGet("https://raw.githubusercontent.com/surhan1/bss/main/VichopAlt.lua")
        local loadExternalScript = loadstring(externalScript)

        if loadExternalScript then
            loadExternalScript()(webhook, webhookRoleIDs)
        else
            warn("Failed to load external script.")
        end
    else
        player:Kick("Account not whitelisted.")
        print("Kicked player: " .. playerName .. " (" .. playerID .. ") - Account not whitelisted")
    end
end

-- Get the local player
local localPlayer = Players.LocalPlayer 

if localPlayer then
    CheckWhitelistAndProceed(localPlayer, webhook, webhookRoleIDs)
else
    warn("LocalPlayer is nil. Cannot check whitelist.")
end
