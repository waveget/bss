local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local url = "https://discord.com/api/webhooks/1253107820472172626/q_Uotmsj_J5fZoG-IoKhe-ALliWMF6BU8XcDthTEErI2PJmnE7VmU75cG_AeJPlLxk_O"

function SendMessage(url, message)
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
end

function SendMessageEMBED(url, embed)
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
                        ["value"] = "https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile"
                    },
                    {
                        ["name"] = "Field:",
                        ["value"] = "____ field"
                    }
                },
                ["footer"] = {
                    ["text"] = embed.footer.text
                }
            }
        }
    }
    local body = HttpService:JSONEncode(data)
    local response = syn.request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
    print("Sent embed: " .. embed.title)
end

local role_id = "1253237631072866326" 
SendMessage(url, "<@&" .. role_id .. ">")

local currentTime = os.date("%Y-%m-%d %H:%M:%S", os.time())

local embed = {
    ["title"] = "Vicious bee found!",
    ["description"] = LocalPlayer.DisplayName .. " has found a vicious bee.",
    ["color"] = 65280,
    ["footer"] = {
        ["text"] = currentTime
    }
}
SendMessageEMBED(url, embed)
