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
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- Game specific constants
local PlaceId = game.PlaceId 
local Api = "https://games.roblox.com/v1/games/"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Discord Webhook URLs (replace with your actual webhook URLs)
local url = "https://discord.com/api/webhooks/1253107820472172626/q_Uotmsj_J5fZoG-IoKhe-ALliWMF6BU8XcDthTEErI2PJmnE7VmU75cG_AeJPlLxk_O"
local webhook2 = _G.Webhook  -- Assuming _G.Webhook holds the second webhook URL

-- Role IDs for notifications
local roleIDs = {
    normal = "1253237631072866326",
    gifted = "1253392095109054617"
}

local globalRoleIDs = {
    normal = "1253237631072866326",
    gifted = "1253392095109054617"
}

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
    local serversEndpoint = Api .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return game:HttpGet(serversEndpoint)
    end)

    if not success then
        warn("Failed to get servers: " .. response)
        return {}
    end

    local servers = HttpService:JSONDecode(response)
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
        local randomIndex = math.random(1, #filteredServers)
        local server = filteredServers[randomIndex]
        local success, errorMsg = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, server.id, plr)
        end)
        
        if success then
            print("Successfully teleported to a random server!")
        else
            warn("Failed to teleport to server: " .. errorMsg)
        end
    else
        warn("No available servers to teleport to.")
    end
end

local function CheckWhitelistAndProceed(player)
    local playerName = player.Name
    local playerID = player.UserId
    print("Checking whitelist for player and HWID: " .. playerName .. " (" .. playerID .. ")")
    
    if IsPlayerWhitelisted(player) then
        print("Player " .. playerName .. " (" .. playerID .. ") is whitelisted. Proceeding with the rest of the script.")

        -- Cap FPS at 5 and disable 3D rendering
        if setfpscap then
            setfpscap(5)
        end
        if setrenderstep then
            setrenderstep(0)
        end

        local function SendMessage(url, message, roleIDs)
            local headers = {
                ["Content-Type"] = "application/json"
            }
            local data = {
                ["content"] = message
            }
            local body = HttpService:JSONEncode(data)
            
            local response = HttpService:RequestAsync({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body
            })

            if response.Success then
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
                local bodyWithPing = HttpService:JSONEncode(dataWithPing)
                
                local response2 = HttpService:RequestAsync({
                    Url = url,
                    Method = "POST",
                    Headers = headers,
                    Body = bodyWithPing
                })

                if response2.Success then
                    print("Roles pinged successfully on URL")
                else
                    warn("Failed to ping roles on URL: " .. tostring(response2))
                end
            end
        end

        local function SendMessageToWebhook2(url, message, roleIDs)
            local headers = {
                ["Content-Type"] = "application/json"
            }
            local data = {
                ["content"] = message
            }
            local body = HttpService:JSONEncode(data)
            
            local response = HttpService:RequestAsync({
                Url = webhook2,
                Method = "POST",
                Headers = headers,
                Body = body
            })

            if response.Success then
                print("Message sent successfully to Webhook2")
            else
                warn("Failed to send message to Webhook2: " .. tostring(response))
            end

            -- Ping roles from globalRoleIDs table
            if globalRoleIDs and next(globalRoleIDs) then
                local roleMentions = {}
                for _, roleId in pairs(globalRoleIDs) do
                    table.insert(roleMentions, "<@&" .. roleId .. ">")
                end
                local pingMessage = table.concat(roleMentions, " ")
                local dataWithPing = {
                    ["content"] = pingMessage .. "\n" .. message
                }
                local bodyWithPing = HttpService:JSONEncode(dataWithPing)
                
                local response2 = HttpService:RequestAsync({
                    Url = webhook2,
                    Method = "POST",
                    Headers = headers,
                    Body = bodyWithPing
                })

                if response2.Success then
                    print("Roles pinged successfully on Webhook2")
                else
                    warn("Failed to ping roles on Webhook2: " .. tostring(response2))
                end
            end
        end

        local currentTime = os.date("%Y-%m-%d %H:%M:%S", os.time())

        local embed = {
            ["title"] = "Vicious bee found!",
            ["description"] = Players.LocalPlayer.DisplayName .. " has found a vicious bee.",
            ["color"] = 65280,
            ["fields"] = {
                {
                    ["name"] = "Profile:",
                    ["value"] = "https://www.roblox.com/users/" .. Players.LocalPlayer.UserId .. "/profile"
                },
                {
                    ["name"] = "Field:",
                    ["value"] = "____ field"
                },
                {
                    ["name"] = "HWID:",
                    ["value"] = HWID
                }
            },
            ["footer"] = {
                ["text"] = currentTime
            }
        }

        local fields = {
            {name = "Spider", minX = -115.63, maxX = 24.37, minY = -4.52, maxY = 45.48, minZ = -78.90, maxZ = 61.10},
            {name = "Clover", minX = 100.40, maxX = 210.40, minY = 8.98, maxY = 58.98, minZ = 137.69, maxZ = 247.69},
            {name = "Mountain Top", minX = 7.13, maxX = 147.13, minY = 151.48, maxY = 201.48, minZ = -240.58, maxZ = -100.58},
            {name = "Cactus", minX = -261.56, maxX = -111.56, minY = 43.48, maxY = 93.48, minZ = -176.35, maxZ = -26.35},
            {name = "Rose", minX = -405.28, maxX = -255.28, minY = -4.57, maxY = 45.43, minZ = 49.72, maxZ = 199.72},
            {name = "Pepper", minX = -567.10, maxX = -417.10, minY = 98.68, maxY = 148.68, minZ = 459.48, maxZ = 609.48}
        }

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

        local function checkField(position)
            for _, field in ipairs(fields) do
                if position.X >= field.minX and position.X <= field.maxX and
                   position.Y >= field.minY and position.Y <= field.maxY and
                   position.Z >= field.minZ and position.Z <= field.maxZ then
                    return field.name
                end
            end
            return "Unknown"
        end

        local function monitorViciousBee()
            local viciousBee, beePosition = findViciousBee()
            if viciousBee then
                local field = checkField(beePosition)
                embed.fields[2].value = field .. " Field"
                
                if viciousBee.Name:match("Gifted") then
                    embed.title = "Gifted vicious bee found!"
                    embed.description = Players.LocalPlayer.DisplayName .. " has found a gifted vicious bee."
                    SendMessage(url, "<@&" .. roleIDs.gifted .. ">")
                    SendMessageToWebhook2(url, "<@&" .. globalRoleIDs.gifted .. ">")
                else
                    SendMessage(url, "<@&" .. roleIDs.normal .. ">")
                    SendMessageToWebhook2(url, "<@&" .. globalRoleIDs.normal .. ">")
                end
                
                local response1 = SendMessage(url, HttpService:JSONEncode(embed), true)
                local messageId = nil
                if response1 and response1.Success then
                    messageId = response1.message.id
                else
                    warn("Failed to send message to URL: " .. tostring(response1))
                end
                
                local response2 = SendMessageToWebhook2(webhook2, HttpService:JSONEncode(embed), true)
                if response2 and response2.Success then
                    messageId = response2.message.id
                else
                    warn("Failed to send message to Webhook2: " .. tostring(response2))
                end

                local sentViciousGoneMessage = false  -- Flag to track if we already sent the "Vicious bee gone!" message

                while true do
                    viciousBee, _ = findViciousBee()
                    if not viciousBee and not sentViciousGoneMessage then
                        local embedViciousGone = {
                            ["title"] = "Vicious bee gone!",
                            ["description"] = Players.LocalPlayer.DisplayName .. " has no vicious bee.",
                            ["color"] = 16711680, -- Red color
                            ["footer"] = {
                                ["text"] = currentTime
                            }
                        }
                        SendMessage(url, HttpService:JSONEncode(embedViciousGone), true)
                        SendMessageToWebhook2(webhook2, HttpService:JSONEncode(embedViciousGone), true)
                        sentViciousGoneMessage = true  -- Update flag to true once we send the message
                    end
                    if not viciousBee then
                        break
                    end
                    wait(10) -- Check every 10 seconds
                end

                TeleportToRandomServer()  -- Teleport to a random server after vicious bee disappears
            else
                wait(5)
                TeleportToRandomServer()  -- Teleport to a random server if no vicious bee is found
            end
        end

        monitorViciousBee()
    else
        print("Unallowed player: " .. playerName .. " (" .. playerID .. ") - Account and HWID not whitelisted")
    end
end

-- Event handler for when a player joins
game.Players.PlayerAdded:Connect(function(player)
    if player == game.Players.LocalPlayer then
        CheckWhitelistAndProceed(player)
    end
end)

-- Check for the local player on script start
if game.Players.LocalPlayer then
    CheckWhitelistAndProceed(game.Players.LocalPlayer)
end

-- Handle script continuation after teleporting to a new server
if RunService:IsStudio() then
    return -- Stop script if running in Roblox Studio
end

game.Players.PlayerRemoving:Connect(function(removedPlayer)
    if removedPlayer == game.Players.LocalPlayer then
        print("Disconnected from server, attempting to teleport to another random server...")
        TeleportToRandomServer()
    end
end)

-- Continuously check and monitor the vicious bee
while true do
    wait(10) -- Check every 10 seconds
    monitorViciousBee()
end

