
local whitelistedPlayerIDs = {
    80299238,  
    987654321,  
}





























































































local Players = game:GetService("Players")

local function IsPlayerWhitelisted(player)
    local playerID = player.UserId
    for _, id in ipairs(whitelistedPlayerIDs) do
        if id == playerID then
            return true
        end
    end
    return false
end

local function CheckWhitelistAndProceed(player)
    local playerName = player.Name
    local playerID = player.UserId
    print("Checking whitelist for player: " .. playerName .. " (" .. playerID .. ")")
    
    if IsPlayerWhitelisted(player) then
        print("Player " .. playerName .. " (" .. playerID .. ") is whitelisted. Proceeding with the rest of the script.")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/surhan1/bss/main/VichopAlt.lua"))()
    else
        player:Kick("Account not whitelisted.")
        print("Kicked player: " .. playerName .. " (" .. playerID .. ") - Account not whitelisted")
    end
end


local localPlayer = Players.LocalPlayer 

if localPlayer then
    CheckWhitelistAndProceed(localPlayer)
else
    warn("LocalPlayer is nil. Cannot check whitelist.")
end
