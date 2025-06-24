--!strict
--[[
    Dynamic List Example - Rex Framework
    Demonstrates a reactive list with add/remove functionality
--]]
local Rex = require(game.ReplicatedStorage.Rex)

local function ListItem(props: {
    text: string,
    index: number,
    layoutOrder: number,
    items: Rex.RexState<{string}>,
    onRemove: () -> ()
})
    local items = props.items

    return Rex("Frame") {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        LayoutOrder = props.layoutOrder,

        children = {
            Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
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
            }
        }
    }
end

local function InputRow(props : {
    inputValue: Rex.RexState<string>,
    items: Rex.RexState<{string}>
})
    local inputValue = props.inputValue
    local items = props.items
    
    return Rex("Frame") {
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
                onTextChanged = function(textBox)
                    inputValue:set(textBox.Text)
                end,
            },
            Rex("TextButton") {
                Text = "Add",
                Size = UDim2.new(0.3, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(80, 200, 80),
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                Font = Enum.Font.SourceSansBold,
                onClick = function()
                    local value = inputValue:get():gsub("^%s+", ""):gsub("%s+$", "")
                    if value ~= "" then
                        items:update(function(list)
                            local new = {unpack(list)}
                            table.insert(new, value)
                            return new
                        end)
                        inputValue:set("")
                    end
                end,
            }
        }
    }
end

local function App()

    local items = Rex.useState({"Apple", "Banana", "Cherry"})
    local inputValue = Rex.useState("")

    Rex.useEffect(function()
        print("Text has changed to:", inputValue:get())
    end, {inputValue})

    return Rex("ScreenGui") {
        Name = "DynamicListApp",
        ResetOnSpawn = false,
        children = {
            Rex("Frame") {
                Size = UDim2.fromOffset(400, 350),
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
                    Rex("TextLabel") {
                        Text = "Dynamic List Example",
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansBold,
                        LayoutOrder = 1,
                    },
                    InputRow {
                        inputValue = inputValue,
                        items = items,
                    },
                    Rex("ScrollingFrame") {
                        Size = UDim2.new(1, 0, 1, -100),
                        BackgroundTransparency = 1,
                        LayoutOrder = 3,
                        children = {
                            Rex("UIListLayout") {
                                FillDirection = Enum.FillDirection.Vertical,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                VerticalAlignment = Enum.VerticalAlignment.Top,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },
                            items:map(function(list)
                                local children = {}
                                for i, item in ipairs(list) do
                                    table.insert(children, ListItem {
                                        text = item,
                                        index = i,
                                        layoutOrder = 10 + i,
                                        items = items,
                                        key = item, -- Explicit key for better reconciliation
                                        onRemove = function()
                                            items:update(function(currentList)
                                                local new = {}
                                                for j, listItem in ipairs(currentList) do
                                                    if j ~= i then
                                                        table.insert(new, listItem)
                                                    end
                                                end
                                                return new
                                            end)
                                        end
                                    })
                                end
                                return children
                            end)
                        }
                    }
                }
            }
        }
    }
end

local player = game:GetService("Players").LocalPlayer
local cleanup = Rex.render(App, player.PlayerGui)
