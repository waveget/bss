-- Define global role IDs (if not already defined)
local globalRoleIDs = _G.WebhookRoleIds or {
    vicious = "1253237631072866326",
    giftedvicious = "1253392095109054617"
}

-- Define local webhook URL
local localWebhook = "https://discord.com/api/webhooks/1253107820472172626/q_Uotmsj_J5fZoG-IoKhe-ALliWMF6BU8XcDthTEErI2PJmnE7VmU75cG_AeJPlLxk_O"

-- Function to check if a player is whitelisted
local function IsPlayerWhitelisted(player)
    local whitelistedPlayerIDs = {
        6190530680,
        6190533869,
        6190538759,
        6190541922,
        80299238,
    }
    local playerID = player.UserId
    for _, id in ipairs(whitelistedPlayerIDs) do
        if id == playerID then
            return true
        end
    end
    return false
end

-- Function to list and filter available servers
local function ListAndFilterServers()
    local HttpService = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/"
    local PlaceId = game.PlaceId 
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
    local TPS = game:GetService("TeleportService")
    local plr = game.Players.LocalPlayer
    local filteredServers = ListAndFilterServers()
    
    if #filteredServers > 0 then
        local retries = 5
        while retries > 0 do
            local randomIndex = math.random(1, #filteredServers)
            local server = filteredServers[randomIndex]
            local success, errorMsg = pcall(function()
                TPS:TeleportToPlaceInstance(game.PlaceId, server.id, plr)
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

-- Function to send a message to a Discord webhook
local function SendMessage(url, message)
    local HttpService = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = message
    }
    local body = HttpService:JSONEncode(data)
    local response = syn.request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
    print("Sent message: " .. message)
    return response
end

-- Function to send an embed message to a Discord webhook
local function SendMessageEMBED(url, embed, useWebhook)
    local HttpService = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = {
                    ["text"] = embed.footer.text
                }
            }
        }
    }

    local body = HttpService:JSONEncode(data)
    local response = syn.request({
        Url = useWebhook and url or "",
        Method = "POST",
        Headers = headers,
        Body = body
    })

    print("Sent embed: " .. embed.title)
    return response
end

-- Function to find the vicious bee and determine its location
local function monitorViciousBee()
    local Players = game:GetService("Players")
    local workspace = game:GetService("Workspace")

    local function findViciousBee()
        local monsters = workspace:FindFirstChild("Monsters")
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

    local function generateViciousBeeEmbed(title, description, color)
        local currentTime = os.date("%Y-%m-%d %H:%M:%S", os.time())
        local embed = {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["fields"] = {
                {
                    ["name"] = "Profile:",
                    ["value"] = "https://www.roblox.com/users/" .. Players.LocalPlayer.UserId .. "/profile"
                },
                {
                    ["name"] = "HWID:",
                    ["value"] = HWID
                },
                {
                    ["name"] = "Location:",
                    ["value"] = "",
                    ["inline"] = true
                },
                {
                    ["name"] = "Server:",
                    ["value"] = game.JobId,
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = currentTime
            }
        }
        return embed
    end

    local viciousBee, beePosition = findViciousBee()
    if viciousBee then
        local field = checkField(beePosition)
        local embed = generateViciousBeeEmbed("Vicious bee found!", Players.LocalPlayer.DisplayName .. " has found a vicious bee.", 65280)
        embed.fields[3].value = field .. " field alive"
        
        if viciousBee.Name:match("Gifted") then
            embed.title = "Gifted vicious bee found!"
            embed.description = Players.LocalPlayer.DisplayName .. " has found a gifted vicious bee."
            SendMessage(localWebhook, "<@&" .. globalRoleIDs.giftedvicious .. ">")
        else
            SendMessage(localWebhook, "<@&" .. globalRoleIDs.vicious .. ">")
        end
        
        SendMessageEMBED(localWebhook, embed, true)

        while true do
            viciousBee, _ = findViciousBee()
            if not viciousBee then
                local embedViciousGone = {
                    ["title"] = "Vicious bee gone!",
                    ["description"] = Players.LocalPlayer.DisplayName .. " has found that the vicious bee disappeared.",
                    ["color"] = 16711680,
                    ["fields"] = {
                        {
                            ["name"] = "Profile:",
                            ["value"] = "https://www.roblox.com/users/" .. Players.LocalPlayer.UserId .. "/profile"
                        },
                        {
                            ["name"] = "HWID:",
                            ["value"] = HWID
                        },
                        {
                            ["name"] = "Server:",
                            ["value"] = game.JobId,
                            ["inline"] = true
                        }
                    },
                    ["footer"] = {
                        ["text"] = currentTime
                    }
                }
                SendMessageEMBED(localWebhook, embedViciousGone, true)
                break
            end
            wait(10)
        end
        TeleportToRandomServer()
    else
        wait(5)
        TeleportToRandomServer()
    end
end

-- Main loop
while true do
    if IsPlayerWhitelisted(game.Players.LocalPlayer) then
        monitorViciousBee()
    end
    wait(1)
end
