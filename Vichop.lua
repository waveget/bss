repeat wait() until game:IsLoaded()

local whitelistedPlayerIDs = {
    6190530680, -- me
    6190533869, --
    6190538759, --
    6190541922, --
    80299238, --
    6194478155, -- 1204635486266724383
    6194479885, --
    6194483501, --
    6195983246, --
    6196146993, --
    495592364, -- fred
}



-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Game specific constants
local PlaceId = game.PlaceId 
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Discord Webhook URLs (replace with your actual webhook URLs)
local url = "https://discord.com/api/webhooks/1253107820472172626/q_Uotmsj_J5fZoG-IoKhe-ALliWMF6BU8XcDthTEErI2PJmnE7VmU75cG_AeJPlLxk_O"
local webhook2 = _G.Webhook  -- Assuming _G.Webhook holds the second webhook URL

-- Role IDs for notifications
local roleIDs = {
    normal = "1253237631072866326",
    gifted = "1253392095109054617"
}

local globalRoleIDs = _G.WebhookRoleIds or {}  -- Assuming _G.WebhookRoleIds holds the second set of role IDs

-- Function to check if a player is whitelisted
local function IsPlayerWhitelisted(player)
    local playerID = player.UserId
    for _, id in ipairs(whitelistedPlayerIDs) do
        if id == playerID then
            return true
        end
    end
    return false
end

-- Function to list and filter servers
local function ListAndFilterServers()
    local serversEndpoint = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return game:HttpGet(serversEndpoint)
    end)

    if not success then
        warn("Failed to get servers: " .. response)
        return {}
    end

    local servers = game.HttpService:JSONDecode(response)
    local filteredServers = {}
    
    if servers and servers.data then
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers then
                table.insert(filteredServers, server)
            end
        end
    end

    return filteredServers
end

-- Function to teleport to a random server
local function TeleportToRandomServer()
    local plr = game.Players.LocalPlayer
    local filteredServers = ListAndFilterServers()
    
    if #filteredServers > 0 then
        local retries = 5
        while retries > 0 do
            local randomIndex = math.random(1, #filteredServers)
            local server = filteredServers[randomIndex]
            local success, errorMsg = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, plr)
            end)
            
            if success then
                print("Successfully teleported to a random server!")
                return
            else
                warn("Failed to teleport to server: " .. errorMsg)
                if errorMsg:find("Unauthorized") then
                    retries = retries - 1
                    wait(10) -- Wait before retrying
                else
                    return -- Exit if the error is not related to authorization
                end
            end
        end
        warn("Failed to teleport after multiple retries.")
    else
        warn("No available servers to teleport to.")
    end
end

-- Function to send messages and ping roles
local function SendMessage(url, message, roleIDs)
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = message
    }
    local body = game.HttpService:JSONEncode(data)
    
    local response = game:HttpPostAsync(url, body)
    
    if response and response == "200 OK" then
        print("Message sent successfully to URL")
    else
        warn("Failed to send message to URL: " .. tostring(response))
    end

    -- Ping roles from roleIDs table
    if roleIDs and next(roleIDs) then
        local roleMentions = {}
        for _, roleId in pairs(roleIDs) do
            table.insert(roleMentions, "<@&" .. roleId .. ">")
        end
        local pingMessage = table.concat(roleMentions, " ")
        local dataWithPing = {
            ["content"] = pingMessage .. "\n" .. message
        }
        local bodyWithPing = game.HttpService:JSONEncode(dataWithPing)
        
        local response = game:HttpPostAsync(url, bodyWithPing)
        
        if response and response == "200 OK" then
            print("Roles pinged successfully on URL")
        else
            warn("Failed to ping roles on URL: " .. tostring(response))
        end
    end
end

-- Function to monitor the vicious bee
local function monitorViciousBee()
    local workspace = game:GetService("Workspace")
    local embedSent = false

    while true do
        local viciousBee, beePosition = findViciousBee()
        if viciousBee then
            local field = checkField(beePosition)
            local embed = {
                ["title"] = viciousBee.Name:match("Gifted") and "Gifted vicious bee found!" or "Vicious bee found!",
                ["description"] = Players.LocalPlayer.DisplayName .. " has found a vicious bee.",
                ["color"] = viciousBee.Name:match("Gifted") and 65280 or 16711680, -- Green for Gifted, Red for normal
                ["fields"] = {
                    {
                        ["name"] = "Profile:",
                        ["value"] = "https://www.roblox.com/users/" .. Players.LocalPlayer.UserId .. "/profile"
                    },
                    {
                        ["name"] = "Field:",
                        ["value"] = field .. " Field"
                    },
                    {
                        ["name"] = "HWID:",
                        ["value"] = HWID
                    }
                },
                ["footer"] = {
                    ["text"] = os.date("%Y-%m-%d %H:%M:%S", os.time())
                }
            }
            
            if not embedSent then
                SendMessage(url, game.HttpService:JSONEncode(embed), roleIDs)
                SendMessage(webhook2, game.HttpService:JSONEncode(embed), globalRoleIDs)
                embedSent = true
            end
        else
            if embedSent then
                local embedViciousGone = {
                    ["title"] = "Vicious bee gone!",
                    ["description"] = Players.LocalPlayer.DisplayName .. " has no vicious bee.",
                    ["color"] = 16711680, -- Red color
                    ["footer"] = {
                        ["text"] = os.date("%Y-%m-%d %H:%M:%S", os.time())
                    }
                }
                SendMessage(url, game.HttpService:JSONEncode(embedViciousGone), roleIDs)
                SendMessage(webhook2, game.HttpService:JSONEncode(embedViciousGone), globalRoleIDs)
                embedSent = false
            end
        end
        wait(10) -- Check every 10 seconds
    end
end

-- Function to find the vicious bee
local function findViciousBee()
    local monsters = game.Workspace:FindFirstChild("Monsters")
    if monsters then
        for _, monster in ipairs(monsters:GetChildren()) do
            if monster:IsA("Model") and monster.Name:match("^Vicious Bee") then
                return monster, monster.PrimaryPart.Position
            end
        end
    end
    return nil, nil 
end

-- Function to check which field the bee is in
local function checkField(position)
    local fields = {
        {name = "Spider", minX = -115.63, maxX = 24.37, minY = -4.52, maxY = 45.48, minZ = -78.90, maxZ = 61.10},
        {name = "Clover", minX = 100.40, maxX = 210.40, minY = 8.98, maxY = 58.98, minZ = 137.69, maxZ = 247.69},
        {name = "Mountain Top", minX = 7.13, maxX = 147.13, minY = 151.48, maxY = 201.48, minZ = -240.58, maxZ = -100.58},
        {name = "Cactus", minX = -261.56, maxX = -111.56, minY = 43.48, maxY = 93.48, minZ = -176.35, maxZ = -26.35},
        {name = "Rose", minX = -405.28, maxX = -255.28, minY = -4.57, maxY = 45.43, minZ = 49.72, maxZ = 199.72},
        {name = "Pepper", minX = -567.10, maxX = -417.10, minY = 98.68, maxY = 148.68, minZ = 459.48, maxZ = 609.48}
    }

    for _, field in ipairs(fields) do
        if position.X >= field.minX and position.X <= field.maxX and
           position.Y >= field.minY and position.Y <= field.maxY and
           position.Z >= field.minZ and position.Z <= field.maxZ then
            return field.name
        end
    end
    return "Unknown"
end

-- Start monitoring when the player joins
game.Players.PlayerAdded:Connect(function(player)
    if player == game.Players.LocalPlayer and IsPlayerWhitelisted(player) then
        monitorViciousBee()
    end
end)

-- Check immediately for the local player
if game.Players.LocalPlayer and IsPlayerWhitelisted(game.Players.LocalPlayer) then
    monitorViciousBee()
end


