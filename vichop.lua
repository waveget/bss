print("executed")
task.wait(15)

local hive1 = Vector3.new(-186.4783477783203, 6.410924911499023, 330.5643615722656)
local hive2 = Vector3.new(-150.09255981445312, 6.410924434661865, 330.5643615722656)
local hive3 = Vector3.new(-113.14099884033203, 6.410924434661865, 330.5643615722656)
local hive4 = Vector3.new(-77.5650405883789, 6.410924434661865, 330.5643615722656)
local hive5 = Vector3.new(-41.32465362548828, 6.410924434661865, 330.5643615722656)
local hive6 = Vector3.new(-3.8163251876831055, 6.410924911499023, 330.5643615722656)

local tweenSpeed = 25
local squareSize = 10
local walkSpeed = 8       
local plr = game:GetService("Players").LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local totalTime = 45 

local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local Api = "https://games.roblox.com/v1/games/"
local PlaceId = game.PlaceId

local function ListAndFilterServers()
    local serversEndpoint = Api .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local response = game:HttpGet(serversEndpoint)
    local servers = Http:JSONDecode(response)

    local filteredServers = {}
    for _, server in ipairs(servers.data) do
        if server.playing < server.maxPlayers then
            table.insert(filteredServers, server)
        end
    end

    return filteredServers
end

local function TeleportToRandomServer()
    local plr = game.Players.LocalPlayer
    local filteredServers = ListAndFilterServers()
    if #filteredServers > 0 then
        local randomIndex = math.random(1, #filteredServers)
        local server = filteredServers[randomIndex]
        local success, errorMsg = pcall(function()
            TPS:TeleportToPlaceInstance(PlaceId, server.id, plr)
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

game.Players.PlayerRemoving:Connect(function(player)
    if player == game.Players.LocalPlayer then
        print("Disconnected from server, attempting to teleport to another random server...")
        TeleportToRandomServer()
    end
end)

function Time(targetPos)
    local distance = (targetPos - plr.Character.HumanoidRootPart.Position).Magnitude
    local timeRequired = distance / tweenSpeed
    return timeRequired
end

local tweenService = game:GetService("TweenService")

function tp(targetPos, onComplete)
    local timeRequired = Time(targetPos)
    local tweenInfo = TweenInfo.new(timeRequired, Enum.EasingStyle.Quad)
    local cframe = CFrame.new(targetPos)
    local success, err = pcall(function()
        local tween = tweenService:Create(plr.Character.HumanoidRootPart, tweenInfo, {CFrame = cframe})
        tween.Completed:Connect(function()
            if onComplete then
                onComplete()
            end
        end)
        tween:Play()
    end)
    if not success then
        return err
    end
end

function claimHive1()
    local args = {
        [1] = 6
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
end

function claimHive2()
    local args = {
        [1] = 5
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
end

function claimHive3()
    local args = {
        [1] = 4
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
end

function claimHive4()
    local args = {
        [1] = 3
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
end

function claimHive5()
    local args = {
        [1] = 2
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
end

function claimHive6()
    local args = {
        [1] = 1
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
end

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

-- Example usage:
local viciousBee, beePosition = findViciousBee()
if viciousBee then
    print("Found Vicious Bee at:", beePosition)
    tp(hive1, claimHive1)
    wait(4)
    tp(hive2, claimHive2)
    wait(2)
    tp(hive3, claimHive3)
    wait(2)
    tp(hive4, claimHive4)
    wait(2)
    tp(hive5, claimHive5)
    wait(2)
    tp(hive6, claimHive6)
    wait(2)
    tp(beePosition)
    wait(50)
    TeleportToRandomServer()
else
   wait(5)
   TeleportToRandomServer()
end
