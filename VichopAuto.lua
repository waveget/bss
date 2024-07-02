        repeat
            task.wait()
        until game:IsLoaded() 
        wait(5) 
        
            
        -- List of whitelisted player IDs
        _G.whitelistedPlayerIDs = {
            6190530680, 6190533869, 6190538759, 6190541922, 80299238, -- Me
            6194478155, 6194479885, 6194483501, 6195983246, 6196146993, 2329338095, -- 1204635486266724383
            495592364, -- Fred
            6199374954, -- Bacon
            6200961988, -- Nihal
        }	
        
        local EasyPath = loadstring(game:HttpGet("https://raw.githubusercontent.com/surhan1/bss/main/pathfinding"))()
        local PathfindingService = game:GetService('PathfindingService')
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local ActivatablesToys = require(ReplicatedStorage.Activatables.Toys)
        local plr = game:GetService("Players").LocalPlayer
        local character = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local tweenSpeed = 21
        local tweenSpeedClaimHive = 13  -- New tween speed for claiming hives
        local foundInPepper = false
        
        _G.HttpService = game:GetService("HttpService")
        _G.Players = game:GetService("Players") 
        _G.TeleportService = game:GetService("TeleportService")
        _G.PlaceId = game.PlaceId
        _G.Api = "https://games.roblox.com/v1/games/"
        _G.HWID = game:GetService("RbxAnalyticsService"):GetClientId()
        _G.url = "https://discord.com/api/webhooks/1253107820472172626/q_Uotmsj_J5fZoG-IoKhe-ALliWMF6BU8XcDthTEErI2PJmnE7VmU75cG_AeJPlLxk_O"
        
        local TweenService = game:GetService("TweenService")  -- Added TweenService
        
        local function deleteRetroChallengePortal()
            game:GetService("Workspace").RetroEvent:Destroy()
        end
        
        
        local function tp(targetPos, onComplete, speed)
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                local currentPosition = humanoidRootPart.Position
                local distance = (targetPos - currentPosition).magnitude
                local timeRequired = distance / (speed or tweenSpeed)  -- Use default tweenSpeed if speed is nil
        
                local tweenInfo = TweenInfo.new(timeRequired, Enum.EasingStyle.Quad)
                local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
                tween:Play()
                tween.Completed:Connect(function()
                    if onComplete then
                        onComplete()

                    end
                end)
            else
                return "Character not found!"
            end
        end
        
        
        local function moveInSquare()
            local startPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local squareSize = 15  -- Size of the square in studs
            local waypoints = {
                startPos + Vector3.new(squareSize, 0, 0),
                startPos + Vector3.new(squareSize, 0, squareSize),
                startPos + Vector3.new(0, 0, squareSize),
                startPos
            }
        
            for _, waypoint in ipairs(waypoints) do
                EasyPath:WalkToPath({
                    Destination = waypoint,
                    PathOffset = Vector3.new(0, 0, 0),
                    DebugMode = false,
                    StrongAnticheat = true,
                    VisualPath = false,
                    VisualPathSize = Vector3.new(1, 1, 1),
                    VisualPathColor = Color3.fromRGB(255, 0, 0),
                    VisualPathOffset = Vector3.new(0, 0, 0),
                    DeletePathWhenDone = true
                })
        
                repeat
                    wait()
                until EasyPath:FinishedPathfinding()
            end
        end
        
        local function moveInSquareLoop()
            for i = 1, 5 do
                moveInSquare()  -- Call the function to move in a square
                wait(1)  -- Adjust delay as needed to control the pace of movement
            end
        end
        
        
        local function firecannon()
            local args = {
            [1] = "Red Cannon"
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToyEvent"):FireServer(unpack(args))
        end
        
        local function claimHive6()
            local args = { [1] = 6 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
        end
        
        local function claimHive5()
            local args = { [1] = 5 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
        end
        
        local function claimHive4()
            local args = { [1] = 4 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
        end
        
        local function claimHive3()
            local args = { [1] = 3 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
        end
        
        local function claimHive2()
            local args = { [1] = 2 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
        end
        
        local function claimHive1()
            local args = { [1] = 1 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
        end
        
        -- Function to claim the hive based on its number
        local function claimHive(hiveNumber)
            if hiveNumber == 6 then
                claimHive6()
            elseif hiveNumber == 5 then
                claimHive5()
            elseif hiveNumber == 4 then
                claimHive4()
            elseif hiveNumber == 3 then
                claimHive3()
            elseif hiveNumber == 2 then
                claimHive2()
            elseif hiveNumber == 1 then
                claimHive1()
            end
        end
        
        
        local function moveTo(destination)
            EasyPath:WalkToPath({
                Destination = destination,
                PathOffset = Vector3.new(0, 0, 0),
                DebugMode = true,
                StrongAnticheat = false,
                VisualPath = true,
                VisualPathSize = Vector3.new(1, 1, 1),
                VisualPathColor = Color3.fromRGB(255, 0, 0),
                VisualPathOffset = Vector3.new(0, 0, 0),
                DeletePathWhenDone = true
            })
        
            repeat
                wait()
            until EasyPath:FinishedPathfinding()
        end
  
  local function createClaimHoneycomb()
    local claimed = false  -- Flag to track if honeycomb has been claimed

    return function()
        if claimed then
            print("Honeycomb has already been claimed.")
            return nil
        end

        claimed = true  -- Set claimed to true to prevent further claims

        for i = 6, 1, -1 do
            local hive = Workspace.Honeycombs:FindFirstChild("Hive" .. i)
            if hive and not hive.Owner.Value then
                repeat
                    if hive.SpawnPos and hive.SpawnPos.Value then
                        local targetPos = hive.SpawnPos.Value.p - Vector3.new(0, 2, 0)

                        local tweenCompleted = false

                        local tweenInfo = TweenInfo.new((targetPos - player.Character.HumanoidRootPart.Position).magnitude / tweenSpeedClaimHive, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(player.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
                        tween:Play()

                        tween.Completed:Connect(function()
                            tweenCompleted = true
                        end)

                        while not tweenCompleted do
                            task.wait()
                        end

                        if not hive.Owner.Value then
                            claimHive(i)
                            task.wait(0.75)
                        end
                    end

                    task.wait()
                until hive.Owner.Value or player:FindFirstChild("Honeycomb")

                if player:FindFirstChild("Honeycomb") then
                    return player.Honeycomb.Value  -- Return the player's honeycomb if found
                end
            end
        end

        return nil  -- Return nil if no honeycomb is found
    end
end

-- Create a single instance of claimHoneycomb
local claimHoneycomb = createClaimHoneycomb()



        
        
        
        
        
        -- Function to check if a player is whitelisted
        _G.IsPlayerWhitelisted = function(player)
            local playerID = player.UserId
            for _, id in ipairs(_G.whitelistedPlayerIDs) do
                if id == playerID then
                    return true
                end
            end
            return false
        end
        
        -- Function to list and filter servers
        _G.ListAndFilterServers = function()
            local serversEndpoint = _G.Api .. _G.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local success, response = pcall(function()
                return game:HttpGet(serversEndpoint)
            end)
        
            if not success then
                warn("Failed to get servers: " .. response)
                return {}
            end
            
            local servers = _G.HttpService:JSONDecode(response)
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
        _G.TeleportToRandomServer = function()
            local plr = _G.Players.LocalPlayer
            local filteredServers = _G.ListAndFilterServers()
        
            if #filteredServers > 0 then
                local retries = 5
                while retries > 0 do
                    local randomIndex = math.random(1, #filteredServers)
                    local server = filteredServers[randomIndex]
                    local success, errorMsg = pcall(function()
                        _G.TeleportService:TeleportToPlaceInstance(_G.PlaceId, server.id, plr)
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
        _G.CheckWhitelistAndProceed = function(player)
            local playerName = player.Name
            local playerID = player.UserId
            print("Checking whitelist for player and HWID: " .. playerName .. " (" .. playerID .. ")")
        
            if _G.IsPlayerWhitelisted(player) then
                print("Player " .. playerName .. " (" .. playerID .. ") is whitelisted. Proceeding with the rest of the script.")
                game.Players.PlayerRemoving:Connect(function(removedPlayer)
                    if removedPlayer == player then
                        print("Disconnected from server, attempting to teleport to another random server...")
                        _G.TeleportToRandomServer()
                    end
                end)
        
                local function SendMessageEMBED(embed)
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
            local body = _G.HttpService:JSONEncode(data)
            
            local response1 = request({
                Url = _G.url,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        
            if response1 and response1.Success then
               print("U")
            else
               print("C")
            end
        end
        
        local currentTime = os.date("%Y-%m-%d %H:%M:%S", os.time())
        
        local embed = {
    ["title"] = "Vicious bee found!",
    ["description"] = _G.Players.LocalPlayer.UserId .. " has found a vicious bee.",
    ["color"] = 65280,
    ["fields"] = {
        {
            ["name"] = "Profile:",
            ["value"] = "https://www.roblox.com/users/" .. _G.Players.LocalPlayer.UserId .. "/profile"
        },
        {
            ["name"] = "Field:",
            ["value"] = "____ field"
        },
        {
            ["name"] = "HWID:",
            ["value"] = _G.HWID
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
        
        local function findViciousBee()
            local monsters = workspace:FindFirstChild("Monsters")
            if monsters then
                for _, monster in ipairs(monsters:GetChildren()) do
                    if monster:IsA("Model") and monster.Name:match("^Vicious Bee") and monster.PrimaryPart then
                        return monster, monster.PrimaryPart.Position
                    end
                end
            end
            return nil, nil
        end
        
        local function monitorViciousBee()
            local viciousBee, beePosition = findViciousBee()
            if viciousBee then
                if beePosition == nil then
                    _G.TeleportToRandomServer() -- Teleport to a random server if beePosition is nil
                    return
                end        
                
                claimHoneycomb()
                
                local field = checkField(beePosition)
                embed.fields[2].value = field .. " Field"
        
                if viciousBee.Name:match("Gifted") then
                    embed.title = "Gifted vicious bee found!"
                    embed.description = _G.Players.LocalPlayer.DisplayName .. " has found a gifted vicious bee."
                else
                    embed.title = "Vicious bee found!"
                    embed.description = _G.Players.LocalPlayer.DisplayName .. " has found a vicious bee."
                end
        
        
                -- Perform actions based on the detected field
                if field == "Spider" then
                    deleteRetroChallengePortal()
                    tp(Vector3.new(-0.7347967028617859, 20.475887298583984, 39.055145263671875), function()
                        wait(5)  -- Wait for 5 seconds after the tween completes
                        moveTo(beePosition)
                        repeat wait() until EasyPath:FinishedPathfinding()
                        wait(1)
                        moveInSquareLoop()
                    end)
                elseif field == "Clover" then
                    deleteRetroChallengePortal()
                    tp(Vector3.new(106.1234359741211, 33.97587585449219, 195.09564208984375), function()
                        wait(5)  -- Wait for 5 seconds after the tween completes
                        moveTo(beePosition)
                        repeat wait() until EasyPath:FinishedPathfinding()
                        wait(1)
                        moveInSquareLoop()
                    end)
                elseif field == "Mountain Top" then
                    tp(Vector3.new(95.09291076660156, 176.47589111328125, -104.65147399902344), function()
                        wait(5)  -- Wait for 5 seconds after the tween completes
                        moveTo(beePosition)
                        repeat wait() until EasyPath:FinishedPathfinding()
                        wait(1)
                        moveInSquareLoop()
                    end)
                elseif field == "Cactus" then
                    tp(Vector3.new(-158.81430053710938, 68.47586822509766, -65.26766967773438), function()
                        wait(5)  -- Wait for 5 seconds after the tween completes
                        moveTo(beePosition)
                        repeat wait() until EasyPath:FinishedPathfinding()
                        wait(1)
                        moveInSquareLoop()
                    end)
                elseif field == "Rose" then
                    tp(Vector3.new(-261.6981506347656, 20.367794036865234, 169.49461364746094), function()
                        wait(5)  -- Wait for 5 seconds after the tween completes
                        moveTo(beePosition)
                        repeat wait() until EasyPath:FinishedPathfinding()
                        wait(1)
                        moveInSquareLoop()
                    end)
                elseif field == "Pepper" then
                    SendMessageEMBED(embed)
                    local sentViciousGoneMessage = false
                    foundInPepper = true
                    tp(Vector3.new(-443.9128723144531, 123.67738342285156, 532.28271484375 + 5), function()
                wait(5)  -- Wait for 5 seconds after the tween completes
                moveTo(beePosition + Vector3.new(0, 5, 0))
                repeat wait() until EasyPath:FinishedPathfinding()
                wait(1)
                moveInSquareLoop()
                    end)
                else
                    _G.TeleportToRandomServer() -- Teleport to a random server if beePosition is nil
                    return
                end
        
                -- Continuously check for the presence of the vicious bee
                while true do
                    viciousBee, _ = findViciousBee()
                    if not viciousBee and not sentViciousGoneMessage then
                        if foundInPepper then
                        local embedViciousGone = {
                            ["title"] = "Vicious bee gone!",
                            ["description"] = _G.Players.LocalPlayer.DisplayName .. " has no vicious bee.",
                            ["color"] = 16711680, -- Red color
                            ["footer"] = {
                                ["text"] = os.date("%Y-%m-%d %H:%M:%S", os.time())
                            }
                        }
                        sentViciousGoneMessage = true
                        wait(1)
                        SendMessageEMBED(embedViciousGone)
                        end
                end
                    if not viciousBee then
                        break
                    end
                    wait(5) -- Check every 5 seconds
                end
                _G.TeleportToRandomServer() -- Teleport to a random server after vicious bee disappears
            else
                wait(3)
                _G.TeleportToRandomServer() -- Teleport to a random server if no vicious bee is found
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
                    _G.CheckWhitelistAndProceed(player)
                end
            end)
        
            if game.Players.LocalPlayer then
                _G.CheckWhitelistAndProceed(game.Players.LocalPlayer)
            end
        
            delay(120, function()
                local viciousBee, beePosition = findViciousBee()
                if beePosition == nil then
                    _G.TeleportToRandomServer()
                end
            end)
        else
            warn("Invalid key! Script will not run.")
        end
