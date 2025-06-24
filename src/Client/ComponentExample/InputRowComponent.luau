local Rex = require(game.ReplicatedStorage.Rex)

return function(props : {
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