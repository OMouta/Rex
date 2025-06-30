---
title: "List Rendering & Children"
description: "Learn how to efficiently render dynamic lists and manage children in Rex using the :each() method and keys."
category: "Core Concepts"
order: 6
version: "0.2.0"
lastUpdated: 2025-06-29
---

Dynamic list rendering is one of the most common patterns in UI development. Rex provides powerful tools for rendering lists efficiently with the `:each()` method, intelligent reconciliation, and proper key management.

## The `:each()` Method

Rex's `:each()` method provides a clean, reactive way to render lists from array state:

```luau
local items = Rex.useState({"Apple", "Banana", "Cherry"})

Rex("ScrollingFrame") {
    children = {
        Rex("UIListLayout") {},
        items:each(function(item, index)
            return Rex("TextLabel") {
                Text = `{index}: {item}`,
                key = item -- Important for efficient updates
            }
        end)
    }
}
```

### Automatic Reactivity

When the array state changes, the UI automatically updates:

```luau
local function TodoApp()
    local todos = Rex.useState({
        "Learn Rex",
        "Build amazing UI",
        "Ship the project"
    })
    
    return Rex("Frame") {
        children = {
            Rex("UIListLayout") {},
            
            -- Header
            Rex("TextLabel") {
                Text = todos:map(function(list)
                    return `Tasks: {#list}`
                end),
                LayoutOrder = 1
            },
            
            -- Dynamic todo list
            todos:each(function(todo, index)
                return Rex("TextLabel") {
                    Text = `{index}. {todo}`,
                    key = todo,
                    LayoutOrder = index + 1
                }
            end),
            
            -- Add button
            Rex("TextButton") {
                Text = "Add Random Task",
                LayoutOrder = 1000,
                onClick = function()
                    local tasks = {"Review code", "Write tests", "Update docs", "Fix bugs"}
                    local randomTask = tasks[math.random(1, #tasks)]
                    todos:push(randomTask)
                end
            }
        }
    }
end
```

## Interactive Lists

Create interactive lists with buttons, inputs, and state management:

```luau
local function ShoppingList()
    local items = Rex.useState({
        {id = 1, name = "Milk", bought = false},
        {id = 2, name = "Bread", bought = true},
        {id = 3, name = "Eggs", bought = false}
    })
    
    local function toggleItem(itemId)
        items:update(function(currentItems)
            local newItems = table.clone(currentItems)
            for i, item in ipairs(newItems) do
                if item.id == itemId then
                    newItems[i] = {
                        id = item.id,
                        name = item.name,
                        bought = not item.bought
                    }
                    break
                end
            end
            return newItems
        end)
    end
    
    local function removeItem(itemId)
        items:update(function(currentItems)
            local newItems = {}
            for _, item in ipairs(currentItems) do
                if item.id ~= itemId then
                    table.insert(newItems, item)
                end
            end
            return newItems
        end)
    end
    
    return Rex("ScrollingFrame") {
        Size = UDim2.fromScale(1, 1),
        children = {
            Rex("UIListLayout") { Padding = UDim.new(0, 5) },
            
            items:each(function(item, index)
                return Rex("Frame") {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = item.bought 
                        and Color3.fromRGB(100, 255, 100)  -- Green when bought
                        or Color3.fromRGB(255, 255, 255),  -- White when pending
                    key = tostring(item.id), -- Use stable ID
                    
                    children = {
                        Rex("UIListLayout") {
                            FillDirection = Enum.FillDirection.Horizontal,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0, 10)
                        },
                        
                        -- Item name
                        Rex("TextLabel") {
                            Text = item.name,
                            Size = UDim2.new(0.6, 0, 1, 0),
                            TextStrikethrough = item.bought,
                            TextColor3 = item.bought 
                                and Color3.fromRGB(100, 100, 100)
                                or Color3.fromRGB(0, 0, 0),
                            LayoutOrder = 1
                        },
                        
                        -- Toggle button
                        Rex("TextButton") {
                            Text = item.bought and "↶ Undo" or "✓ Buy",
                            Size = UDim2.new(0.25, 0, 0.8, 0),
                            BackgroundColor3 = item.bought
                                and Color3.fromRGB(255, 200, 100)
                                or Color3.fromRGB(100, 200, 255),
                            onClick = function()
                                toggleItem(item.id)
                            end,
                            LayoutOrder = 2
                        },
                        
                        -- Remove button
                        Rex("TextButton") {
                            Text = "✕",
                            Size = UDim2.new(0.15, 0, 0.8, 0),
                            BackgroundColor3 = Color3.fromRGB(255, 100, 100),
                            TextColor3 = Color3.new(1, 1, 1),
                            onClick = function()
                                removeItem(item.id)
                            end,
                            LayoutOrder = 3
                        }
                    }
                }
            end)
        }
    }
end
```

## Key Management

Keys are critical for efficient list updates. Rex uses keys to identify which elements have changed, been added, or removed.

### Why Keys Matter

Without keys, Rex must guess which elements correspond to which data:

```luau
-- ❌ Without keys - inefficient
items:each(function(item, index)
    return ItemComponent { item = item }
    -- Rex can't track which element is which
end)

-- When items reorder: [A, B, C] → [B, A, C]
-- Rex might recreate all elements instead of just moving them
```

With keys, Rex knows exactly which elements to reuse:

```luau
-- ✅ With keys - efficient
items:each(function(item, index)
    return ItemComponent { 
        item = item, 
        key = item.id -- Stable identifier
    }
end)

-- When items reorder: Rex moves existing elements efficiently
```

### Key Selection Strategies

**Best: Stable Unique IDs**

```luau
todos:each(function(todo, index)
    return TodoItem { 
        todo = todo, 
        key = tostring(todo.id) -- Database ID, UUID, etc.
    }
end)
```

**Good: Content-Based Keys (for simple, unique data)**

```luau
colors:each(function(color, index)
    return ColorSwatch { 
        color = color, 
        key = color -- "red", "blue", etc. if unique
    }
end)
```

**Avoid: Index-Based Keys**

```luau
-- ❌ Don't use index as key
items:each(function(item, index)
    return ItemComponent { 
        item = item, 
        key = tostring(index) -- Breaks on reordering!
    }
end)
```

## Performance Patterns

### Filtering and Searching

Combine reactive state with `:each()` for dynamic filtering:

```luau
local function FilteredList()
    local allItems = Rex.useState({"Apple", "Banana", "Cherry", "Date"})
    local searchText = Rex.useState("")
    
    local filteredItems = Rex.useComputed(function()
        local search = searchText:get():lower()
        if search == "" then
            return allItems:get()
        end
        
        local filtered = {}
        for _, item in ipairs(allItems:get()) do
            if item:lower():find(search) then
                table.insert(filtered, item)
            end
        end
        return filtered
    end, {allItems, searchText})
    
    return Rex("Frame") {
        children = {
            -- Search box
            Rex("TextBox") {
                PlaceholderText = "Search items...",
                Text = searchText,
                onTextChanged = function(textBox)
                    searchText:set(textBox.Text)
                end
            },
            
            -- Filtered results
            Rex("ScrollingFrame") {
                children = {
                    Rex("UIListLayout") {},
                    filteredItems:each(function(item, index)
                        return Rex("TextLabel") {
                            Text = item,
                            key = item
                        }
                    end)
                }
            }
        }
    }
end
```

### Virtualization for Large Lists

For very large lists (1000+ items), consider virtualization:

```luau
local function VirtualizedList()
    local allItems = Rex.useState(generateLargeDataset()) -- 10,000 items
    local scrollPosition = Rex.useState(0)
    local itemHeight = 50
    local visibleCount = 20
    
    local visibleItems = Rex.useComputed(function()
        local startIndex = math.floor(scrollPosition:get() / itemHeight) + 1
        local endIndex = math.min(startIndex + visibleCount - 1, #allItems:get())
        
        local visible = {}
        for i = startIndex, endIndex do
            table.insert(visible, {
                data = allItems:get()[i],
                originalIndex = i
            })
        end
        return visible
    end, {allItems, scrollPosition})
    
    return Rex("ScrollingFrame") {
        CanvasSize = UDim2.new(0, 0, 0, #allItems:get() * itemHeight),
        onCanvasPositionChanged = function(scrollFrame)
            scrollPosition:set(scrollFrame.CanvasPosition.Y)
        end,
        
        children = {
            visibleItems:each(function(item, index)
                return Rex("TextLabel") {
                    Text = `{item.originalIndex}: {item.data}`,
                    Size = UDim2.new(1, 0, 0, itemHeight),
                    Position = UDim2.new(0, 0, 0, (item.originalIndex - 1) * itemHeight),
                    key = tostring(item.originalIndex)
                }
            end)
        }
    }
end
```

## Best Practices

### 1. Always Use Keys

```luau
-- ✅ Good
items:each(function(item, index)
    return Component { data = item, key = item.id }
end)
```

### 2. Keep List Functions Pure

```luau
-- ✅ Good - pure function
items:each(function(item, index)
    return createListItem(item, index)
end)

-- ❌ Avoid - side effects in render function
items:each(function(item, index)
    if item.special then
        someGlobalState:set(true) -- Side effect!
    end
    return createListItem(item, index)
end)
```

### 3. Use LayoutOrder for Ordered Lists

```luau
items:each(function(item, index)
    return Rex("Frame") {
        LayoutOrder = index, -- Preserve order
        key = item.id
    }
end)
```

### 4. Memoize Expensive Operations

```luau
local processedItems = Rex.useComputed(function()
    return allItems:get():map(function(item)
        return expensiveProcessing(item) -- Only runs when allItems changes
    end)
end, {allItems})

return processedItems:each(function(item, index)
    return ItemComponent { item = item, key = item.id }
end)
```

Rex's `:each()` method and intelligent reconciliation make it easy to build performant, interactive lists that scale from simple todo apps to complex data-driven interfaces.
