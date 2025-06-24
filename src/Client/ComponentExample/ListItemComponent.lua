local Rex = require(game.ReplicatedStorage.Rex)

return function(props: {
    text: string,
    index: number,
    layoutOrder: number,
    items: Rex.RexState<{string}>
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
                onClick = function()
                    items:update(function(list)
                        local new = {unpack(list)}
                        table.remove(new, props.index)
                        return new
                    end)
                end,
            }
        }
    }
end