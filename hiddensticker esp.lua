-- Define the workspace and folder
local workspace = game:GetService("Workspace")
local hiddenStickersFolder = workspace:FindFirstChild("HiddenStickers")

-- Function to update hidden stickers
local function updateHiddenStickers()
    -- Clear previous BillboardGui instances
    for _, child in ipairs(hiddenStickersFolder:GetChildren()) do
        for _, descendant in ipairs(child:GetDescendants()) do
            if descendant:IsA("BillboardGui") then
                descendant:Destroy()
            end
        end
    end

    -- Iterate through all the stickers in the folder
    for _, sticker in ipairs(hiddenStickersFolder:GetChildren()) do
        if sticker:IsA("BasePart") then
            -- Set the sticker to neon
            sticker.Material = Enum.Material.Neon
            
            -- Optional: Change the color to make it more visible
            sticker.Color = Color3.fromRGB(0, 255, 0) -- Green color, you can change it to any color you like

            -- Create a BillboardGui to make it visible from anywhere
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Adornee = sticker
            billboardGui.Size = UDim2.new(0, 200, 0, 50) -- Adjust size to fit text
            billboardGui.AlwaysOnTop = true
            billboardGui.LightInfluence = 0 -- Ensure it is not affected by lighting
            
            -- Create a TextLabel to display the text "Hidden Sticker"
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "Hidden Sticker"
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.SourceSansBold -- You can change the font if you like
            textLabel.Parent = billboardGui
            
            billboardGui.Parent = sticker
        end
    end
end

-- Continuously check for hidden stickers
while true do
    if hiddenStickersFolder then
        updateHiddenStickers()
    else
        warn("Folder 'HiddenStickers' not found in Workspace.")
    end
    wait(5) -- Check every 5 seconds, you can adjust this interval
end
