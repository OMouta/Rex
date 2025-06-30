--!strict
--[[
	Test script for Rex.define() functionality
	This tests wrapping existing instances with Rex
--]]

local Players = game:GetService("Players")
local Rex = require(game.ReplicatedStorage.Rex)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a test UI structure in Studio style first
local function createTestUI()
	-- Main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromScale(0.5, 0.5)
	mainFrame.Position = UDim2.fromScale(0.25, 0.25)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	
	-- Label
	local label = Instance.new("TextLabel")
	label.Name = "CounterLabel"
	label.Size = UDim2.new(1, 0, 0.5, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.Text = "Counter: 0"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.Parent = mainFrame
	
	-- Button
	local button = Instance.new("TextButton")
	button.Name = "IncrementButton"
	button.Size = UDim2.new(1, 0, 0.5, 0)
	button.Position = UDim2.new(0, 0, 0.5, 0)
	button.Text = "Click Me!"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
	button.Parent = mainFrame
	
	return mainFrame
end

local testGui = createTestUI()

local function Counter()
	local count = Rex.useState(0)

	return Rex("ScreenGui") {
        Name = "CounterGui",

        children = {
            Rex.define(testGui) {
                -- Override the background color to make it more modern
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                children = {
                    -- Enhance the existing label with reactive text
                    Rex.define("CounterLabel") {
                        Text = count:map(function(value)
                            return `Counter: {value}`
                        end),
                        TextColor3 = count:map(function(value)
                            -- Change color based on count
                            if value > 10 then
                                return Color3.fromRGB(255, 100, 100) -- Red for > 10
                            elseif value > 5 then
                                return Color3.fromRGB(255, 255, 100) -- Yellow for > 5
                            else
                                return Color3.fromRGB(100, 255, 100) -- Green for <= 5
                            end
                        end)
                    },
                    
                    -- Enhance the existing button with click functionality
                    Rex.define("IncrementButton") {
                        -- Override text to be more dynamic
                        Text = count:map(function(value)
                            if value >= 20 then
                                return "Max Reached!"
                            else
                                return `Click me! ({value})`
                            end
                        end),
                        
                        -- Add click functionality
                        onClick = function()
                            if count:get() < 20 then
                                count:increment()
                                print(`Count incremented to: {count:get()}`)
                            else
                                print("Maximum count reached!")
                            end
                        end,
                        
                        -- Dynamic button color based on count
                        BackgroundColor3 = count:map(function(value)
                            if value >= 20 then
                                return Color3.fromRGB(100, 100, 100) -- Gray when maxed
                            else
                                return Color3.fromRGB(70, 130, 255) -- Blue normally
                            end
                        end)
                    }
                }
            }
        }
    }
end

local cleanup = Rex.render(Counter, playerGui)
