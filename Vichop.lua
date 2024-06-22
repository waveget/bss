task.wait(15)

local whitelistedPlayerIDs = {
    6190530680,
    6190533869,
    6190538759,
    6190541922,
    80299238,
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TPS = game:GetService("TeleportService")
local PlaceId = game.PlaceId 
local Api = "https://games.roblox.com/v1/games/"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Define the first webhook URL and role IDs
local url = "https://discord.com/api/webhooks/1253107820472172626/q_Uotmsj_J5fZoG-IoKhe-ALliWMF6BU8XcDthTEErI2PJmnE7VmU75cG_AeJPlLxk_O"
local roleIDs = {
    normal = "1253237631072866326",
    gifted = "1253392095109054617"
}

-- Define the second webhook URL and role IDs using _G variables (to be defined in a loader script)
local secondUrl = _G.Webhook or ""
local secondRoleIDs = _G.WebhookRoleIds or {
    vicious = "roleid here",
    giftedvicious = "roleid here"
}

local function IsPlayerWhitelisted(player)
    local playerID = player.UserId
    for _, id in ipairs(whitelistedPlayerIDs) do
        if id == playerID then
            return true
        end
    end
    return false
end

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

local function TeleportToRandomServer()
    local plr = game.Players.LocalPlayer
    local filteredServers = ListAndFilterServers()
    
    if #filteredServers > 0 then
        local retries = 5
        while retries > 0 do
            local randomIndex = math.random(1, #filteredServers)
            local server = filteredServers[randomIndex]
            local success, errorMsg = pcall(function()
                TPS:TeleportToPlaceInstance(PlaceId, server.id, plr)
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

local function CheckWhitelistAndProceed(player)
    local playerName = player.Name
    local playerID = player.UserId
    print("Checking whitelist for player: " .. playerName .. " (" .. playerID .. ")")
    
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
            local response = syn.request({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body
            })
            print("Sent message: " .. message)
            return response
        end

        local function SendMessageEMBED(url, embed, useWebhook)
            local headers = {
                ["Content-Type"] = "application/json"
            }
            local data = {
                ["embeds"] = {
                    {
                        ["title"] = embed.title,
                        ["description"] = embed.description,
                        ["color"] = embed.color,
                        ["fields"] = {
                            {
                                ["name"] = "Profile:",
                                ["value"] = "https://www.roblox.com/users/" .. Players.LocalPlayer.UserId .. "/profile"
                            },
                            {
                                ["name"] = "HWID:",
                                ["value"] = HWID
                            }
                        },
                        ["footer"] = {
                            ["text"] = embed.footer.text
                        }
                    }
                }
            }

            -- Only add the "Field" field for the first webhook
            if not useWebhook then
                table.insert(data.embeds[1].fields, 2, {
                    ["name"] = "Field:",
                    ["value"] = embed.fields[2].value
                })
            end

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

        local function EditMessage(url, messageId, embed)
            local headers = {
                ["Content-Type"] = "application/json"
            }
            local data = {
                ["embeds"] = {
                    {
                        ["title"] = embed.title,
                        ["description"] = embed.description,
                        ["color"] = embed.color,
                        ["fields"] = {
                            {
                                ["name"] = "Profile:",
                                ["value"] = "https://www.roblox.com/users/" .. Players.LocalPlayer.UserId .. "/profile"
                            },
                            {
                                ["name"] = "HWID:",
                                ["value"] = HWID
                            }
                        },
                        ["footer"] = {
                            ["text"] = embed.footer.text
                        }
                    }
                }
            }

            -- Only add the "Field" field for the first webhook
            if not useWebhook then
                table.insert(data.embeds[1].fields, 2, {
                    ["name"] = "Field:",
                    ["value"] = embed.fields[2].value
                })
            end

            -- Modify the specified embed field
            data.embeds[1].fields[2].value = embed.fields[2].value

            local body = HttpService:JSONEncode(data)
            local response = syn.request({
                Url = url .. "/messages/" .. messageId,
                Method = "PATCH",
                Headers = headers,
                Body = body
            })

            print("Edited message: " .. embed.title)
            return response
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
                embed.fields[2].value = field .. " field alive"
                
                if viciousBee.Name:match("Gifted") then
                    embed.title = "Gifted vicious bee found!"
                    embed.description = Players.LocalPlayer.DisplayName .. " has found a gifted vicious bee."
                    SendMessage(url, "<@&" .. roleIDs.gifted .. ">")
                    SendMessage(secondUrl, "<@&" .. secondRoleIDs.giftedvicious .. ">")
                else
                    SendMessage(url, "<@&" .. roleIDs.normal .. ">")
                    SendMessage(secondUrl, "<@&" .. secondRoleIDs.vicious .. ">")
                end
                
                local response = SendMessageEMBED(url, embed, true)
                local secondResponse = SendMessageEMBED(secondUrl, embed, true)
                
                local messageId = nil
                if response and response.Success then
                    messageId = response.Body.message.id
                else
                    warn("Failed to send message: " .. tostring(response))
                end
                
                local secondMessageId = nil
                if secondResponse and secondResponse.Success then
                    secondMessageId = secondResponse.Body.message.id
                else
                    warn("Failed to send message to second webhook: " .. tostring(secondResponse))
                end

                while true do
                    viciousBee, _ = findViciousBee()
                    if not viciousBee then
                        local embedViciousGone = {
                            ["title"] = "Vicious bee gone!",
                            ["description"] = Players.LocalPlayer.DisplayName .. " has found that the vicious bee disappeared.",
                            ["color"] = 16711680, -- Red color
                            ["fields"] = {},
                            ["footer"] = {
                                ["text"] = currentTime
                            }
                        }
                        SendMessageEMBED(url, embedViciousGone, true)
                        SendMessageEMBED(secondUrl, embedViciousGone, true)
                        break
                    end
                    wait(10) -- Check every 10 seconds
                end

                TeleportToRandomServer()
            else
                wait(5)
                TeleportToRandomServer()
            end
        end

        monitorViciousBee()
    else
        print("Unallowed player: " .. playerName .. " (" .. playerID .. ") - Account not whitelisted")
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if player == game.Players.LocalPlayer then
        CheckWhitelistAndProceed(player)
    end
end)

if game.Players.LocalPlayer then
    CheckWhitelistAndProceed(game.Players.LocalPlayer)
end
