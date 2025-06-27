--!strict
--[[
	Test script for the Universal Reactive System
	Run this to verify the new auto-conversion and reactive binding works
--]]

local Rex = require(game.ReplicatedStorage.Rex)

-- Test the new direct binding capabilities
local function TestUniversalReactivity()
	print("🧪 Testing Universal Reactivity System...")
	
	-- Test 1: Direct number to text binding
	local count = Rex.useState(42)
	local textLabel = Rex("TextLabel") {
		Text = count, -- Should auto-convert number to string!
		Size = UDim2.fromScale(1, 0.1),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.3),
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	}
	
	-- Test 2: Boolean to visibility binding
	local isVisible = Rex.useState(true)
	local frame = Rex("Frame") {
		Visible = isVisible, -- Direct boolean binding!
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.25, 0.25),
		BackgroundColor3 = Color3.new(0.1, 0.4, 0.1),
		
		children = {
			textLabel,
			
			-- Buttons to test reactivity
			Rex("TextButton") {
				Text = "Increment Count",
				Size = UDim2.new(1, 0, 0, 50),
				Position = UDim2.new(0, 0, 0, 60),
				BackgroundColor3 = Color3.new(0.3, 0.5, 0.8),
				TextColor3 = Color3.new(1, 1, 1),
				onClick = function()
					count:set(count:get() + 1)
					print(`Count is now: {count:get()}`)
				end
			},
			
			Rex("TextButton") {
				Text = "Toggle Visibility",
				Size = UDim2.new(1, 0, 0, 50),
				Position = UDim2.new(0, 0, 0, 120),
				BackgroundColor3 = Color3.new(0.8, 0.5, 0.3),
				TextColor3 = Color3.new(1, 1, 1),
				onClick = function()
					isVisible:set(not isVisible:get())
					print(`Visibility is now: {isVisible:get()}`)
				end
			}
		}
	}
	
	-- Test 3: Color state binding
	local bgColor = Rex.useState(Color3.new(1, 0, 0))
	local colorFrame = Rex("Frame") {
		BackgroundColor3 = bgColor, -- Direct Color3 binding!
		Size = UDim2.fromScale(0.2, 0.2),
		Position = UDim2.fromScale(0.05, 0.05),
		
		children = {
			Rex("TextButton") {
				Text = "Change Color",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.5,
				TextColor3 = Color3.new(1, 1, 1),
				onClick = function()
					-- Cycle through colors
					local current = bgColor:get()
					if current.R > 0.5 then
						bgColor:set(Color3.new(0, 1, 0)) -- Green
					elseif current.G > 0.5 then
						bgColor:set(Color3.new(0, 0, 1)) -- Blue
					else
						bgColor:set(Color3.new(1, 0, 0)) -- Red
					end
				end
			}
		}
	}
	
	-- Main container
	local app = Rex("ScreenGui") {
		Name = "UniversalReactivityTest",
		ResetOnSpawn = false,
		
		children = {
			frame,
			colorFrame,
			
			-- Info label
			Rex("TextLabel") {
				Text = "Universal Reactivity Test\nNumber→Text, Boolean→Visible, Color→BackgroundColor3",
				Size = UDim2.new(1, 0, 0, 100),
				Position = UDim2.new(0, 0, 1, -100),
				BackgroundColor3 = Color3.new(0, 0, 0),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextWrapped = true,
			}
		}
	}
	
	return app
end

-- Create and mount the test
local player = game:GetService("Players").LocalPlayer
if player.PlayerGui then
	local testApp = TestUniversalReactivity()
	Rex.render(testApp, player.PlayerGui)
	print("✅ Universal Reactivity Test mounted!")
	print("   - Number state should auto-convert to text")
	print("   - Boolean state should control visibility")
	print("   - Color state should control background color")
	print("   - Click buttons to test reactivity")
else
	print("❌ PlayerGui not available for testing")
end
