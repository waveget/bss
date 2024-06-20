-- Define function to check if player is whitelisted
local function IsPlayerWhitelisted(player)
    local whitelistedPlayerIDs = {
        80299238,  -- Example whitelisted player IDs
    }
    
    local playerID = player.UserId
    for _, id in ipairs(whitelistedPlayerIDs) do
        if id == playerID then
            return true
        end
    end
    return false
end

-- Main function to check whitelist and proceed
return function(webhook, webhookRoleIDs)
    local Players = game:GetService("Players")
    local playerName = Players.LocalPlayer.Name
    local playerID = Players.LocalPlayer.UserId
    print("Checking whitelist for player: " .. playerName .. " (" .. playerID .. ")")
    
    if IsPlayerWhitelisted(Players.LocalPlayer) then
        print("Player " .. playerName .. " (" .. playerID .. ") is whitelisted. Proceeding with the main script.")
        
        -- Load and execute the main script
        local success, externalScript = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/surhan1/bss/main/VichopAlt.lua")
        if success then
            local loadExternalScript = loadstring(externalScript)

            if loadExternalScript then
                local successMain, errorMain = pcall(loadExternalScript, webhook, webhookRoleIDs)
                if not successMain then
                    warn("Failed to execute main script:", errorMain)
                end
            else
                warn("Failed to load external script: Script compilation failed.")
            end
        else
            warn("Failed to load external script: " .. externalScript)
        end
    else
        Players.LocalPlayer:Kick("Account not whitelisted.")
        print("Kicked player: " .. playerName .. " (" .. playerID .. ") - Account not whitelisted")
    end
end
