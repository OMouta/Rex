--!strict
--[[
    Dynamic List Example - Rex Framework
    Demonstrates a reactive list with add/remove functionality
--]]
local Rex = require(game.ReplicatedStorage.Rex)

local function App()
    local ListItem = require("./ListItemComponent")
    local InputRow = require("./InputRowComponent")

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
                                        items = items
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
