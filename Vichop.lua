repeat wait() until game:IsLoaded()
wait(5)

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

-- Game specific constants
local PlaceId = game.PlaceId 
local Api = "https://games.roblox.com/v1/games/"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Discord Webhook URLs (replace with your actual webhook URLs)
local url = "https://discord.com/api/webhooks/1253107820472172626/q_Uotmsj_J5fZoG-IoKhe-ALliWMF6BU8XcDthTEErI2PJmnE7VmU75cG_AeJPlLxk_O"
local webhook2 = _G.Webhook  -- Assuming _G.Webhook holds the second webhook URL
 
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

-- Function to check the whitelist and proceed
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

        game.Players.PlayerRemoving:Connect(function(removedPlayer)
            if removedPlayer == player then
                print("Disconnected from server, attempting to teleport to another random server...")
                TeleportToRandomServer()
            end
        end)

        local function SendMessage(url, message)
            local headers = {
                ["Content-Type"] = "application/json"
            }
            local data = {
                ["content"] = message
            }
            local body = HttpService:JSONEncode(data)
            
            local response1 = request({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body
            })

            local response2 = request({
                Url = webhook2,
                Method = "POST",
                Headers = headers,
                Body = body
            })

            if response1 and response1.Success then
                print("Message sent successfully to URL")
            else
                warn("Failed to send message to URL: " .. tostring(response1))
            end

            if response2 and response2.Success then
                print("Message sent successfully to Webhook2")
            else
                warn("Failed to send message to Webhook2: " .. tostring(response2))
            end
        end

        local function SendMessageEMBED(url, embed)
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
            
            local response1 = request({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body
            })

            local response2 = request({
                Url = webhook2,
                Method = "POST",
                Headers = headers,
                Body = body
            })

            if response1 and response1.Success then
                print("Embed sent successfully to URL")
            else
                warn("Failed to send embed to URL: " .. tostring(response1))
            end

            if response2 and response2.Success then
                print("Embed sent successfully to Webhook2")
            else
                warn("Failed to send embed to Webhook2: " .. tostring(response2))
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

        local workspace = game:GetService("Workspace")

        local fields = {
            {name = "Spider", minX = -115.63, maxX = 24.37, minY = -4.52, maxY = 45.48, minZ = -78.90, maxZ = 61.10},
            {name = "Clover", minX = 100.40, maxX = 210.40, minY = 8.98, maxY = 58.98, minZ = 137.69, maxZ = 247.69},
            {name = "Mountain Top", minX = 7.13, maxX = 147.13, minY = 151.48, maxY = 201.48, minZ = -240.58, maxZ = -100.58},
            {name = "Cactus", minX = -261.56, maxX = -111.56, minY = 43.48, maxY = 93.48, minZ = -176.35, maxZ = -26.35},
            {name = "Rose", minX = -405.28, maxX = -255.28, minY = -4.57, maxY = 45.43, minZ = 49.72, maxZ = 199.72},
            {name = "Pepper", minX = -567.10, maxX = -417.10, minY = 98.68, maxY = 148.68, minZ = 459.48, maxZ = 609.48}
        }

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
                else
                    embed.title = "Vicious bee found!"
                    embed.description = Players.LocalPlayer.DisplayName .. " has found a vicious bee."
                end
                
                local response1, response2 = SendMessageEMBED(url, embed, true)
                local messageId = nil
                if response1 and response1.Success then
                    messageId = response1.message.id
                else
                    warn("Failed to send message to URL: " .. tostring(response1))
                end
                
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
                        wait(1)
                        SendMessageEMBED(url, embedViciousGone, true)
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

-- Only proceed if _G.Key is valid
if _G.Key == "1234abc" then
    game.Players.PlayerAdded:Connect(function(player)
        if player == game.Players.LocalPlayer then
            CheckWhitelistAndProceed(player)
        end
    end)

    if game.Players.LocalPlayer then
        CheckWhitelistAndProceed(game.Players.LocalPlayer)
    end

    -- Teleport after 2 minutes
    delay(120, function()
        TeleportToRandomServer()
    end)
else
    warn("Invalid key! Script will not run.")
end
