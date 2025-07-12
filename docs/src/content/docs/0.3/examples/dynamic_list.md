---
title: "Dynamic List"
description: "Building reactive lists with add, remove, and update functionality in Rex."
category: "Examples"
order: 2

lastUpdated: 2025-07-13
---

This example demonstrates how to create a dynamic, reactive list in Rex with full CRUD (Create, Read, Update, Delete) functionality using Rex's new universal reactivity system and simplified list rendering. You'll learn about the `each` method for lists, automatic type conversion, and enhanced state helpers.

## What You'll Learn

- Simplified list rendering with the `each` method
- Universal reactivity with direct state binding
- Enhanced state helpers (`push`, `remove`, `clear`)
- Automatic type conversion for properties
- Component composition and reusable patterns

## Complete Example

```lua
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
                Size = UDim2.new(0.2, 0, 1, 0),
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
                -- Direct state binding - automatically reactive!
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
                Size = UDim2.new(0.2, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(80, 200, 80),
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                Font = Enum.Font.SourceSansBold,
                onClick = function()
                    local value = inputValue:get():gsub("^%s+", ""):gsub("%s+$", "")
                    if value ~= "" then
                        -- Use push helper instead of update
                        items:push(value)
                        -- Use clear helper instead of set("")
                        inputValue:clear()
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
                            -- Simple list rendering with each method
                            items:each(function(item, index)
                                return ListItem {
                                    text = item,
                                    index = index,
                                    layoutOrder = 10 + index,
                                    items = items,
                                    key = item, -- Key for efficient reconciliation
                                    onRemove = function()
                                        -- Use removeAt helper
                                        items:removeAt(index)
                                    end
                                }
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
```

## Key Concepts Demonstrated

### 1. State Management

The example uses `Rex.useState` to manage the list of items:

```lua
local items = Rex.useState({"Apple", "Banana", "Cherry"})
```

### 2. List Updates with Helper Methods

Items are updated using convenient helper methods:

```lua
onClick = function()
    local value = inputValue:get():gsub("^%s+", ""):gsub("%s+$", "")
    if value ~= "" then
        -- Use push helper to add items
        items:push(value)
        -- Use clear helper to empty input
        inputValue:clear()
    end
end,
```

**Available helper methods:**

- `items:push(value)` - Add item to end
- `items:removeAt(index)` - Remove item by index
- `items:remove(predicate)` - Remove items matching condition
- `items:clear()` - Empty the list
- `inputValue:clear()` - Clear string values

### 3. Simplified List Rendering with `each`

The list automatically updates when items change using the `each` method:

```lua
-- Before: Complex mapping with manual loop
items:map(function(list)
    local children = {}
    for i, item in ipairs(list) do
        table.insert(children, ListItem { ... })
    end
    return children
end)

-- After: Simple each method
items:each(function(item, index)
    return ListItem {
        text = item,
        index = index,
        layoutOrder = 10 + index,
        key = item, -- Key for efficient reconciliation
        onRemove = function()
            items:removeAt(index)
        end
    }
end)
```

The `each` method automatically:

- Handles the loop internally
- Provides both item and index
- Maintains keys for efficient updates
- Simplifies the code significantly

### 4. Component Composition

The example breaks down into focused, reusable components:

- `ListItem`: Individual item with edit/delete functionality
- `InputRow`: Input form for adding new items
- `App`: Main application container

### 5. Event Handling

Various events are handled reactively:

```lua
onClick = function()
    props.onRemove(props.index)
end,

onTextChanged = function(textBox)
    inputValue:set(textBox.Text)
end,
```

## Important Notes

### Keys for Performance

Notice the `key` property on list items:

```lua
key = item, -- Explicit key for better reconciliation
```

Keys help Rex efficiently update the UI when items are added, removed, or reordered. Without keys, Rex would have to recreate all items when the list changes.

### State Immutability

Always create new arrays/objects when updating state:

```lua
-- ✅ Correct: Create new array
items:update(function(current)
    local newItems = {unpack(current)}
    table.insert(newItems, newItem)
    return newItems
end)

-- ❌ Wrong: Modify existing array
items:update(function(current)
    table.insert(current, newItem) -- Mutates existing state!
    return current
end)
```

## Variations and Extensions

You can extend this example with:

- **Filtering**: Add a search box to filter items
- **Sorting**: Allow sorting by text, date created, etc.
- **Drag and Drop**: Reorder items by dragging
- **Categories**: Group items into categories
- **Persistence**: Save/load items from DataStore
- **Validation**: Add more complex validation rules
- **Animations**: Animate item additions/removals

The reactive nature of Rex makes all these extensions straightforward to implement!
