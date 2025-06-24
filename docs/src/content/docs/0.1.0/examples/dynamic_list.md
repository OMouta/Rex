---
title: "Dynamic List"
description: "Building reactive lists with add, remove, and update functionality in Rex."
category: "Examples"
order: 2
version: "0.1.0"
lastUpdated: 2025-06-23
---

This example demonstrates how to create a dynamic, reactive list in Rex with full CRUD (Create, Read, Update, Delete) functionality. You'll learn about list rendering, state management, event handling, and the importance of keys for efficient updates.

## What You'll Learn

- Reactive list rendering with state management
- Adding and removing items dynamically
- Input handling and validation
- Using keys for efficient list updates
- Component composition and reusable patterns

## Complete Example

```lua
local Rex = require(game.ReplicatedStorage.Rex)

-- Individual list item component
local function ListItem(props)
    local isEditing = Rex.useState(false)
    local editText = Rex.useState(props.text)
    local isHovered = Rex.useState(false)
    
    -- Reset edit text when item text changes
    Rex.useEffect(function()
        editText:set(props.text)
    end, {props.text})
    
    local handleSave = function()
        local newText = editText:get():gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
        if newText ~= "" and newText ~= props.text then
            props.onUpdate(props.index, newText)
        else
            editText:set(props.text) -- Reset to original if empty or unchanged
        end
        isEditing:set(false)
    end
    
    local handleCancel = function()
        editText:set(props.text) -- Reset to original text
        isEditing:set(false)
    end
    
    local handleKeyPress = function(key)
        if key == Enum.KeyCode.Return then
            handleSave()
        elseif key == Enum.KeyCode.Escape then
            handleCancel()
        end
    end
    
    return Rex("Frame") {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = isHovered:map(function(hovered)
            return hovered and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(40, 40, 60)
        end),
        LayoutOrder = props.layoutOrder,
        
        children = {
            Rex("UICorner") { CornerRadius = UDim.new(0, 6) },
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            },
            Rex("UIPadding") {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 8),
            },
            
            -- Item text or edit input
            isEditing:map(function(editing)
                if editing then
                    return Rex("TextBox") {
                        Text = editText,
                        Size = UDim2.new(0.6, 0, 0.8, 0),
                        BackgroundColor3 = Color3.fromRGB(60, 60, 80),
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSans,
                        BorderSizePixel = 0,
                        ClearTextOnFocus = false,
                        LayoutOrder = 1,
                        
                        children = {
                            Rex("UICorner") { CornerRadius = UDim.new(0, 4) }
                        },
                        
                        onTextChanged = function(textBox)
                            editText:set(textBox.Text)
                        end,
                        
                        onFocusLost = function(textBox, enterPressed)
                            if enterPressed then
                                handleSave()
                            end
                        end,
                        
                        -- Auto-focus when editing starts
                        [Rex.Ref] = function(instance)
                            if instance then
                                instance:CaptureFocus()
                            end
                        end
                    }
                else
                    return Rex("TextLabel") {
                        Text = props.text,
                        Size = UDim2.new(0.6, 0, 1, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSans,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = 1,
                    }
                end
            end),
            
            -- Action buttons
            Rex("Frame") {
                Size = UDim2.new(0.4, 0, 1, 0),
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                
                children = {
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4),
                    },
                    
                    -- Edit/Save button
                    isEditing:map(function(editing)
                        if editing then
                            return Rex("TextButton") {
                                Text = "✓",
                                Size = UDim2.fromOffset(30, 30),
                                BackgroundColor3 = Color3.fromRGB(80, 200, 80),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 1,
                                
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 4) }
                                },
                                
                                onClick = handleSave
                            }
                        else
                            return Rex("TextButton") {
                                Text = "✏",
                                Size = UDim2.fromOffset(30, 30),
                                BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 1,
                                
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 4) }
                                },
                                
                                onClick = function()
                                    isEditing:set(true)
                                end
                            }
                        end
                    end),
                    
                    -- Cancel button (only when editing)
                    isEditing:map(function(editing)
                        if editing then
                            return Rex("TextButton") {
                                Text = "✗",
                                Size = UDim2.fromOffset(30, 30),
                                BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 2,
                                
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 4) }
                                },
                                
                                onClick = handleCancel
                            }
                        else
                            return nil
                        end
                    end),
                    
                    -- Delete button
                    Rex("TextButton") {
                        Text = "🗑",
                        Size = UDim2.fromOffset(30, 30),
                        BackgroundColor3 = Color3.fromRGB(255, 100, 100),
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansBold,
                        LayoutOrder = 3,
                        
                        children = {
                            Rex("UICorner") { CornerRadius = UDim.new(0, 4) }
                        },
                        
                        onClick = function()
                            props.onRemove(props.index)
                        end
                    }
                }
            }
        },
        
        onHover = function() isHovered:set(true) end,
        onLeave = function() isHovered:set(false) end
    }
end

-- Input component for adding new items
local function ItemInput(props)
    local inputValue = Rex.useState("")
    local isFocused = Rex.useState(false)
    
    local handleSubmit = function()
        local value = inputValue:get():gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
        if value ~= "" then
            props.onAdd(value)
            inputValue:set("")
        end
    end
    
    return Rex("Frame") {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        
        children = {
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
            },
            
            Rex("TextBox") {
                Text = inputValue,
                PlaceholderText = "Add new item...",
                Size = UDim2.new(0.7, 0, 0.8, 0),
                BackgroundColor3 = isFocused:map(function(focused)
                    return focused and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(50, 50, 70)
                end),
                BorderColor3 = isFocused:map(function(focused)
                    return focused and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(80, 80, 100)
                end),
                BorderSizePixel = 2,
                TextColor3 = Color3.new(1, 1, 1),
                PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                ClearTextOnFocus = false,
                LayoutOrder = 1,
                
                children = {
                    Rex("UICorner") { CornerRadius = UDim.new(0, 6) },
                    Rex("UIPadding") {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                    }
                },
                
                onTextChanged = function(textBox)
                    inputValue:set(textBox.Text)
                end,
                
                onFocus = function()
                    isFocused:set(true)
                end,
                
                onFocusLost = function(textBox, enterPressed)
                    isFocused:set(false)
                    if enterPressed then
                        handleSubmit()
                    end
                end
            },
            
            Rex("TextButton") {
                Text = "Add Item",
                Size = UDim2.new(0.25, 0, 0.8, 0),
                BackgroundColor3 = inputValue:map(function(value)
                    local trimmed = value:gsub("^%s+", ""):gsub("%s+$", "")
                    return trimmed ~= "" and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(100, 100, 100)
                end),
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                Font = Enum.Font.SourceSansBold,
                LayoutOrder = 2,
                
                children = {
                    Rex("UICorner") { CornerRadius = UDim.new(0, 6) }
                },
                
                onClick = handleSubmit
            }
        }
    }
end

-- Statistics component showing list info
local function ListStats(props)
    local totalItems = Rex.useComputed(function()
        return #props.items:get()
    end, {props.items})
    
    local longestItem = Rex.useComputed(function()
        local items = props.items:get()
        local longest = ""
        for _, item in ipairs(items) do
            if #item > #longest then
                longest = item
            end
        end
        return longest
    end, {props.items})
    
    return Rex("Frame") {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        LayoutOrder = 3,
        
        children = {
            Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
            Rex("UIPadding") {
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
            },
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
            },
            
            Rex("TextLabel") {
                Text = totalItems:map(function(count)
                    return string.format("Total Items: %d", count)
                end),
                Size = UDim2.new(1, 0, 0.5, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
            },
            
            Rex("TextLabel") {
                Text = longestItem:map(function(item)
                    return item ~= "" and string.format("Longest: \"%s\" (%d chars)", item, #item) or "No items"
                end),
                Size = UDim2.new(1, 0, 0.5, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 2,
            }
        }
    }
end

-- Main application component
local function App()
    local items = Rex.useState({"Learn Rex", "Build awesome UIs", "Profit!"})
    
    local addItem = function(text)
        items:update(function(currentItems)
            local newItems = {unpack(currentItems)}
            table.insert(newItems, text)
            return newItems
        end)
    end
    
    local removeItem = function(index)
        items:update(function(currentItems)
            local newItems = {}
            for i, item in ipairs(currentItems) do
                if i ~= index then
                    table.insert(newItems, item)
                end
            end
            return newItems
        end)
    end
    
    local updateItem = function(index, newText)
        items:update(function(currentItems)
            local newItems = {}
            for i, item in ipairs(currentItems) do
                if i == index then
                    table.insert(newItems, newText)
                else
                    table.insert(newItems, item)
                end
            end
            return newItems
        end)
    end
    
    local clearAllItems = function()
        items:set({})
    end
    
    return Rex("ScreenGui") {
        Name = "DynamicListDemo",
        ResetOnSpawn = false,
        
        children = {
            Rex("Frame") {
                Size = UDim2.fromOffset(500, 600),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                
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
                        Padding = UDim.new(0, 15),
                    },
                    
                    -- Header
                    Rex("Frame") {
                        Size = UDim2.new(1, 0, 0, 80),
                        BackgroundTransparency = 1,
                        LayoutOrder = 1,
                        
                        children = {
                            Rex("UIListLayout") {
                                FillDirection = Enum.FillDirection.Vertical,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 8),
                            },
                            
                            Rex("TextLabel") {
                                Text = "Dynamic List Demo",
                                Size = UDim2.new(1, 0, 0.6, 0),
                                BackgroundTransparency = 1,
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 1,
                            },
                            
                            Rex("TextLabel") {
                                Text = "Add, edit, and remove items with full reactivity",
                                Size = UDim2.new(1, 0, 0.4, 0),
                                BackgroundTransparency = 1,
                                TextColor3 = Color3.fromRGB(180, 180, 180),
                                TextScaled = true,
                                Font = Enum.Font.SourceSans,
                                LayoutOrder = 2,
                            }
                        }
                    },
                    
                    -- Input area
                    ItemInput { onAdd = addItem },
                    
                    -- Statistics
                    ListStats { items = items },
                    
                    -- List container
                    Rex("Frame") {
                        Size = UDim2.new(1, 0, 1, -200),
                        BackgroundTransparency = 1,
                        LayoutOrder = 4,
                        
                        children = {
                            Rex("ScrollingFrame") {
                                Size = UDim2.fromScale(1, 1),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                ScrollBarThickness = 6,
                                ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120),
                                CanvasSize = items:map(function(itemList)
                                    return UDim2.fromOffset(0, #itemList * 50)
                                end),
                                
                                children = {
                                    Rex("UIListLayout") {
                                        FillDirection = Enum.FillDirection.Vertical,
                                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                        VerticalAlignment = Enum.VerticalAlignment.Top,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                        Padding = UDim.new(0, 8),
                                    },
                                    
                                    -- Dynamic list items
                                    items:map(function(itemList)
                                        if #itemList == 0 then
                                            return {
                                                Rex("Frame") {
                                                    Size = UDim2.new(1, 0, 0, 100),
                                                    BackgroundColor3 = Color3.fromRGB(40, 40, 55),
                                                    LayoutOrder = 1,
                                                    
                                                    children = {
                                                        Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
                                                        Rex("TextLabel") {
                                                            Text = "No items yet.\nAdd some items to get started!",
                                                            Size = UDim2.fromScale(1, 1),
                                                            BackgroundTransparency = 1,
                                                            TextColor3 = Color3.fromRGB(150, 150, 150),
                                                            TextScaled = true,
                                                            Font = Enum.Font.SourceSansItalic,
                                                        }
                                                    }
                                                }
                                            }
                                        end
                                        
                                        local children = {}
                                        for i, item in ipairs(itemList) do
                                            table.insert(children, ListItem {
                                                text = item,
                                                index = i,
                                                layoutOrder = i,
                                                key = string.format("item_%d_%s", i, item), -- Unique key for efficient updates
                                                onRemove = removeItem,
                                                onUpdate = updateItem
                                            })
                                        end
                                        return children
                                    end)
                                }
                            }
                        }
                    },
                    
                    -- Clear all button
                    items:map(function(itemList)
                        if #itemList > 0 then
                            return Rex("TextButton") {
                                Text = string.format("Clear All (%d items)", #itemList),
                                Size = UDim2.new(1, 0, 0, 40),
                                BackgroundColor3 = Color3.fromRGB(180, 60, 60),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 5,
                                
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 6) }
                                },
                                
                                onClick = clearAllItems
                            }
                        else
                            return nil
                        end
                    end)
                }
            }
        }
    }
end

-- Render the application
local player = game:GetService("Players").LocalPlayer
local cleanup = Rex.render(App, player.PlayerGui)

-- Optional: Cleanup when needed
-- cleanup()
```

## Key Concepts Demonstrated

### 1. State Management

The example uses `Rex.useState` to manage the list of items:

```lua
local items = Rex.useState({"Learn Rex", "Build awesome UIs", "Profit!"})
```

### 2. List Updates

Items are updated immutably using the `:update()` method:

```lua
local addItem = function(text)
    items:update(function(currentItems)
        local newItems = {unpack(currentItems)} -- Create a new array
        table.insert(newItems, text)
        return newItems
    end)
end
```

### 3. Reactive List Rendering

The list automatically updates when items change using `:map()`:

```lua
items:map(function(itemList)
    local children = {}
    for i, item in ipairs(itemList) do
        table.insert(children, ListItem {
            text = item,
            index = i,
            key = string.format("item_%d_%s", i, item), -- Important for performance!
            -- ... other props
        })
    end
    return children
end)
```

### 4. Component Composition

The example breaks down into focused, reusable components:

- `ListItem`: Individual item with edit/delete functionality
- `ItemInput`: Input form for adding new items  
- `ListStats`: Statistics display
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

onFocusLost = function(textBox, enterPressed)
    if enterPressed then
        handleSubmit()
    end
end
```

### 6. Computed Values

Derived state is calculated automatically:

```lua
local totalItems = Rex.useComputed(function()
    return #props.items:get()
end, {props.items})
```

## Important Notes

### Keys for Performance

Notice the `key` property on list items:

```lua
key = string.format("item_%d_%s", i, item)
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

### Component Responsibility

Each component has a clear responsibility:

- **ListItem**: Display and manage individual item interactions
- **ItemInput**: Handle new item creation with validation
- **ListStats**: Display computed information about the list
- **App**: Coordinate overall state and layout

This separation makes the code easier to understand, test, and maintain.

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
