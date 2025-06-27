--!strict

local Rex = require(game.ReplicatedStorage.Rex)

-- Simple list item component
local function ListItem(props: {text: string, index: number, key: string?, onRemove: () -> ()})
	return Rex("Frame") {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(40, 40, 60),
		LayoutOrder = props.index,
		key = props.key,
		
		children = {
			Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
			
			Rex("UIListLayout") {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			},
			
			Rex("UIPadding") {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			},
			
			Rex("TextLabel") {
				Text = props.text,
				Size = UDim2.new(0.7, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSans,
				LayoutOrder = 1,
			},
			
			Rex("TextButton") {
				Text = "Remove",
				Size = UDim2.new(0.3, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(255, 100, 100),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSans,
				LayoutOrder = 2,
				onClick = props.onRemove,
				
				children = {
					Rex("UICorner") { CornerRadius = UDim.new(0, 4) }
				}
			}
		}
	}
end

local function App()
	-- Test data
	local items = Rex.useState({"Apple", "Banana", "Cherry", "Date"})
	local inputValue = Rex.useState("")
	
	local function addItem()
		local value = inputValue:get():gsub("^%s+", ""):gsub("%s+$", "")
		if value ~= "" then
			items:set(table.move({value}, 1, 1, #items:get() + 1, table.clone(items:get())))
			inputValue:set("")
		end
	end
	
	local function removeItem(index: number)
		local currentItems = items:get()
		local newItems = {}
		for i, item in ipairs(currentItems) do
			if i ~= index then
				table.insert(newItems, item)
			end
		end
		items:set(newItems)
	end
	
	-- Main app using the new `each` method
	local app = Rex("ScreenGui") {
		Name = "EnhancedChildrenTest",
		ResetOnSpawn = false,
		
		children = {
			Rex("Frame") {
				Size = UDim2.fromOffset(400, 500),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(30, 30, 40),
				
				children = {
					Rex("UICorner") { CornerRadius = UDim.new(0, 12) },
					
					Rex("UIPadding") {
						PaddingTop = UDim.new(0, 20),
						PaddingBottom = UDim.new(0, 20),
						PaddingLeft = UDim.new(0, 20),
						PaddingRight = UDim.new(0, 20),
					},
					
					Rex("UIListLayout") {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 10),
					},
					
					-- Title
					Rex("TextLabel") {
						Text = "Enhanced Children Test\nUsing items:each()",
						Size = UDim2.new(1, 0, 0, 60),
						BackgroundTransparency = 1,
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						LayoutOrder = 1,
					},
					
					-- Input section
					Rex("Frame") {
						Size = UDim2.new(1, 0, 0, 40),
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						
						children = {
							Rex("UIListLayout") {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 8),
							},
							
							Rex("TextBox") {
								Text = inputValue,
								PlaceholderText = "Add new item...",
								Size = UDim2.new(0.7, 0, 1, 0),
								BackgroundColor3 = Color3.fromRGB(50, 50, 70),
								TextColor3 = Color3.new(1, 1, 1),
								TextScaled = true,
								Font = Enum.Font.SourceSans,
								LayoutOrder = 1,
								onTextChanged = function(textBox)
									inputValue:set(textBox.Text)
								end,
								
								children = {
									Rex("UICorner") { CornerRadius = UDim.new(0, 6) }
								}
							},
							
							Rex("TextButton") {
								Text = "Add",
								Size = UDim2.new(0.3, 0, 1, 0),
								BackgroundColor3 = Color3.fromRGB(80, 200, 80),
								TextColor3 = Color3.new(1, 1, 1),
								TextScaled = true,
								Font = Enum.Font.SourceSansBold,
								LayoutOrder = 2,
								onClick = addItem,
								
								children = {
									Rex("UICorner") { CornerRadius = UDim.new(0, 6) }
								}
							}
						}
					},
					
					-- Items list using the new `each` method!
					Rex("ScrollingFrame") {
						Size = UDim2.new(1, 0, 1, -120),
						BackgroundTransparency = 1,
						LayoutOrder = 3,
						CanvasSize = UDim2.new(0, 0, 0, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						
						children = {
							Rex("UIListLayout") {
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 5),
							},
							
							items:each(function(item, index)
								return ListItem {
									text = item,
									index = index,
									key = item,
									onRemove = function()
										removeItem(index)
									end
								}
							end)
						}
					}
				}
			}
		}
	}
	
	return app
end

-- Create and mount the test
local player = game:GetService("Players").LocalPlayer
Rex.render(App, player.PlayerGui)