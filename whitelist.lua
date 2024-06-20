-- Whitelisted player IDs
local whitelistedPlayerIDs = {
    80299238,  
}

































local Players = game:GetService("Players")

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
local function CheckWhitelistAndProceed(player)
    local playerName = player.Name
    local playerID = player.UserId
    print("Checking whitelist for player: " .. playerName .. " (" .. playerID .. ")")
    
    if IsPlayerWhitelisted(player) then
        print("Player " .. playerName .. " (" .. playerID .. ") is whitelisted. Proceeding with the rest of the script.")
        
        -- Define webhook and role IDs
        local webhook = "https://discord.com/api/webhooks/1253108111351349278/eeYN9I-015aDEo0T9L7ch8aLrZSMCGNKT4M3pRQEn34eLtqM1E9FVN13uIw35dna7S3k"
        local webhookRoleIDs = {
            normal = "Role id here",
            gifted = "Role id here"
        }

        -- Attempt to load and execute external script
        local success, result = pcall(function()
            local externalScript = game:HttpGet("https://raw.githubusercontent.com/surhan1/bss/main/VichopAlt.lua")
            local loadExternalScript = loadstring(externalScript)
            if loadExternalScript then
                loadExternalScript()(webhook, webhookRoleIDs) -- Execute the loaded script passing required arguments
            else
                warn("Failed to load external script.")
            end
        end)

        if not success then
            warn("Failed to load and execute external script:", result)
        end
    else
        player:Kick("Account not whitelisted.")
        print("Kicked player: " .. playerName .. " (" .. playerID .. ") - Account not whitelisted")
    end
end

-- Get the local player
local localPlayer = Players.LocalPlayer 

if localPlayer then
    CheckWhitelistAndProceed(localPlayer)
else
    warn("LocalPlayer is nil. Cannot check whitelist.")
end
