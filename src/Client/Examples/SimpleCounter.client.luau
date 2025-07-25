local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Rex = require(game.ReplicatedStorage.Rex)

-- Theme colors
local COLORS = {
	background = Color3.fromRGB(30, 30, 40),
	button = Color3.fromRGB(70, 130, 255),
	buttonHover = Color3.fromRGB(90, 150, 255),
	text = Color3.new(1, 1, 1),
	accent = Color3.fromRGB(100, 255, 150),
}

local function App()
	local count = Rex.useState(0)

	local displayText = Rex.useAutoComputed(function()
		local currentCount = count:get()
		if currentCount == 0 then
			return "Click to start counting!"
		elseif currentCount == 1 then
			return "You clicked once!"
		else
			return `You clicked {currentCount} times!`
		end
	end)
	
	-- Effect to log count changes
	Rex.useEffect(function()
		local currentCount = count:get()
		print(`Count changed to: {currentCount}`)
	end, {count})
	
	return Rex("ScreenGui") {
		Name = "SimpleCounterApp",
		ResetOnSpawn = false,

		Rex("Frame") {
			Name = "MainContainer",
			Size = UDim2.fromScale(0.4, 0.6),
			Position = UDim2.fromScale(0.3, 0.2),
			BackgroundColor3 = COLORS.background,
			BorderSizePixel = 0,

			Rex("UICorner") { CornerRadius = UDim.new(0, 16) },

			Rex("UIPadding") { 
				PaddingTop = UDim.new(0, 30),
				PaddingBottom = UDim.new(0, 30),
				PaddingLeft = UDim.new(0, 30),
				PaddingRight = UDim.new(0, 30),
			},

			Rex("UIListLayout") {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 20),
			},

			Rex("TextLabel") {
				Name = "Title",
				Text = "Simple Counter",
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				TextColor3 = COLORS.text,
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				LayoutOrder = 1,
			},

			Rex("Frame") {
				Name = "CounterDisplay",
				Size = UDim2.new(1, 0, 0, 120),
				BackgroundColor3 = Color3.fromRGB(20, 20, 30),
				BorderSizePixel = 0,
				LayoutOrder = 2,

				Rex("UICorner") { CornerRadius = UDim.new(0, 12) },

				Rex("TextLabel") {
					Name = "CountNumber",
					Text = count,
					Size = UDim2.new(1, 0, 0.6, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = COLORS.accent,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
				},

				Rex("TextLabel") {
					Name = "DisplayText",
					Text = displayText,
					Size = UDim2.new(1, 0, 0.4, 0),
					Position = UDim2.new(0, 0, 0.6, 0),
					BackgroundTransparency = 1,
					TextColor3 = COLORS.text,
					TextScaled = true,
					Font = Enum.Font.SourceSans,
				}
			},

			Rex("Frame") {
				Name = "ButtonContainer",
				Size = UDim2.new(1, 0, 0, 60),
				BackgroundTransparency = 1,
				LayoutOrder = 3,

				Rex("UIListLayout") {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 15),
				},

				Rex("TextButton") {
					Name = "DecrementButton",
					Text = "-",
					Size = UDim2.new(0, 80, 1, 0),
					BackgroundColor3 = COLORS.button,
					BorderSizePixel = 0,
					TextColor3 = COLORS.text,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					LayoutOrder = 1,

					onClick = function()
						local newValue = math.max(0, count:get() - 1)
						count:set(newValue)
					end,

					Rex("UICorner") { CornerRadius = UDim.new(0, 8) }
				},

				Rex("TextButton") {
					Name = "IncrementButton",
					Text = "+",
					Size = UDim2.new(0, 80, 1, 0),
					BackgroundColor3 = COLORS.button,
					BorderSizePixel = 0,
					TextColor3 = COLORS.text,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					LayoutOrder = 2,
					
					onClick = function()
						count:set(count:get() + 1)
					end,
					
					Rex("UICorner") { CornerRadius = UDim.new(0, 8) }
				},

				Rex("TextButton") {
					Name = "ResetButton",
					Text = "Reset",
					Size = UDim2.new(0, 100, 1, 0),
					BackgroundColor3 = Color3.fromRGB(255, 100, 100),
					BorderSizePixel = 0,
					TextColor3 = COLORS.text,
					TextScaled = true,
					Font = Enum.Font.SourceSans,
					LayoutOrder = 3,
					
					onClick = function()
						count:set(0)
					end,
					
					Rex("UICorner") { CornerRadius = UDim.new(0, 8) }
				}
			},

			Rex("TextLabel") {
				Name = "InfoText",
				Text = "Built with Rex Framework",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextScaled = true,
				Font = Enum.Font.SourceSans,
				LayoutOrder = 4,
			}
		}
	}
end

-- Render the app
local cleanup = Rex.render(App, player.PlayerGui)
