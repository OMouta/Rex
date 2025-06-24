---
title: "Key-Based Diffing and Virtual DOM"
description: "Understanding Rex's efficient reconciliation algorithm and how keys optimize UI updates."
category: "Design Choices"
order: 3
version: "0.1.0"
lastUpdated: 2025-06-23
---

Key-based diffing is one of Rex's most important performance optimizations. It enables efficient updates to dynamic lists and helps Rex determine exactly which UI elements need to be created, updated, or removed when your application state changes.

## Understanding the Problem

Without proper reconciliation, dynamic UI updates can be extremely inefficient:

```lua
-- ❌ Without keys: Inefficient reconciliation
local items = Rex.useState({"Apple", "Banana", "Cherry"})

-- When items change to {"Apple", "Cherry", "Date"}:
-- Rex doesn't know that "Banana" was removed and "Date" was added
-- It might recreate ALL list items unnecessarily

items:map(function(itemList)
    local children = {}
    for i, item in ipairs(itemList) do
        table.insert(children, Rex("TextLabel") {
            Text = item
            -- No key! Rex can't track which item is which
        })
    end
    return children
end)
```

## How Keys Solve the Problem

Keys provide a stable identity for each element across renders:

```lua
-- ✅ With keys: Efficient reconciliation
local items = Rex.useState({"Apple", "Banana", "Cherry"})

-- When items change to {"Apple", "Cherry", "Date"}:
// Rex knows:
// - "Apple" (key="Apple") stays in position 1 - no change needed
// - "Banana" (key="Banana") was removed - destroy this element
// - "Cherry" (key="Cherry") moved from position 3 to 2 - just reposition
// - "Date" (key="Date") is new - create new element

items:map(function(itemList)
    local children = {}
    for i, item in ipairs(itemList) do
        table.insert(children, Rex("TextLabel") {
            Text = item,
            key = item  -- Stable, unique identifier
        })
    end
    return children
end)
```

## The Reconciliation Algorithm

Rex uses a sophisticated diffing algorithm similar to React's:

### 1. Collection Phase

Rex builds a map of existing elements by their keys:

```lua
-- Before update: {"Apple", "Banana", "Cherry"}
local existingElements = {
    ["Apple"] = appleElement,
    ["Banana"] = bananaElement,
    ["Cherry"] = cherryElement
}
```

### 2. Comparison Phase

Rex compares the new list with the existing elements:

```lua
-- After update: {"Apple", "Cherry", "Date"}
-- Rex determines:
// - "Apple": exists, same position (index 1) → no change
// - "Cherry": exists, moved from index 3 to index 2 → reposition
// - "Date": new → create
// - "Banana": missing from new list → remove
```

### 3. Update Phase

Rex applies the minimal set of changes:

```lua
-- Only necessary operations:
// 1. Move "Cherry" element to new position
// 2. Create new "Date" element
// 3. Remove "Banana" element
// 4. Leave "Apple" element unchanged
```

## Practical Examples

### Todo List with Efficient Updates

```lua
local function TodoList()
    local todos = Rex.useState({
        { id = 1, text = "Buy groceries", completed = false },
        { id = 2, text = "Walk the dog", completed = true },
        { id = 3, text = "Write documentation", completed = false }
    })
    
    local toggleTodo = function(id)
        todos:update(function(currentTodos)
            local newTodos = {}
            for _, todo in ipairs(currentTodos) do
                if todo.id == id then
                    table.insert(newTodos, {
                        id = todo.id,
                        text = todo.text,
                        completed = not todo.completed
                    })
                else
                    table.insert(newTodos, todo)
                end
            end
            return newTodos
        end)
    end
    
    local removeTodo = function(id)
        todos:update(function(currentTodos)
            local newTodos = {}
            for _, todo in ipairs(currentTodos) do
                if todo.id ~= id then
                    table.insert(newTodos, todo)
                end
            end
            return newTodos
        end)
    end
    
    return Rex("ScrollingFrame") {
        children = {
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 5)
            },
            
            todos:map(function(todoList)
                local children = {}
                for _, todo in ipairs(todoList) do
                    table.insert(children, Rex("Frame") {
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundColor3 = todo.completed and Color3.fromRGB(50, 80, 50) or Color3.fromRGB(50, 50, 80),
                        key = tostring(todo.id), -- Stable key based on ID
                        
                        children = {
                            Rex("TextLabel") {
                                Text = todo.text,
                                Size = UDim2.new(0.7, 0, 1, 0),
                                TextStrikethrough = todo.completed,
                                TextColor3 = todo.completed and Color3.fromRGB(150, 150, 150) or Color3.new(1, 1, 1)
                            },
                            Rex("TextButton") {
                                Text = todo.completed and "✓" or "○",
                                Size = UDim2.fromOffset(30, 30),
                                onClick = function() toggleTodo(todo.id) end
                            },
                            Rex("TextButton") {
                                Text = "🗑",
                                Size = UDim2.fromOffset(30, 30),
                                onClick = function() removeTodo(todo.id) end
                            }
                        }
                    })
                end
                return children
            end)
        }
    }
end
```

### Animated List Reordering

```lua
local function SortableList()
    local items = Rex.useState({
        { id = 1, name = "First Item", value = 10 },
        { id = 2, name = "Second Item", value = 5 },
        { id = 3, name = "Third Item", value = 15 }
    })
    
    local sortBy = Rex.useState("name") -- "name" or "value"
    
    local sortedItems = Rex.useComputed(function()
        local itemList = items:get()
        local sortField = sortBy:get()
        
        local sorted = {unpack(itemList)} -- Copy array
        table.sort(sorted, function(a, b)
            if sortField == "value" then
                return a.value < b.value
            else
                return a.name < b.name
            end
        end)
        return sorted
    end, {items, sortBy})
    
    return Rex("Frame") {
        children = {
            -- Sort controls
            Rex("Frame") {
                children = {
                    Rex("TextButton") {
                        Text = "Sort by Name",
                        onClick = function() sortBy:set("name") end,
                        BackgroundColor3 = sortBy:map(function(sort)
                            return sort == "name" and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(100, 100, 100)
                        end)
                    },
                    Rex("TextButton") {
                        Text = "Sort by Value", 
                        onClick = function() sortBy:set("value") end,
                        BackgroundColor3 = sortBy:map(function(sort)
                            return sort == "value" and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(100, 100, 100)
                        end)
                    }
                }
            },
            
            -- List items with stable keys
            Rex("Frame") {
                children = {
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 5)
                    },
                    
                    sortedItems:map(function(itemList)
                        local children = {}
                        for i, item in ipairs(itemList) do
                            table.insert(children, Rex("Frame") {
                                Size = UDim2.new(1, 0, 0, 50),
                                BackgroundColor3 = Color3.fromRGB(40, 40, 60),
                                key = tostring(item.id), -- Key doesn't change when sorting!
                                
                                children = {
                                    Rex("TextLabel") {
                                        Text = string.format("%s (Value: %d)", item.name, item.value),
                                        Size = UDim2.fromScale(1, 1),
                                        TextColor3 = Color3.new(1, 1, 1)
                                    }
                                }
                            })
                        end
                        return children
                    end)
                }
            }
        }
    }
end

-- When sorting changes:
// Rex efficiently moves existing elements to new positions
// No elements are recreated - just repositioned
// Smooth animations can be applied to position changes
```

## Key Selection Strategies

### 1. Use Stable, Unique Identifiers

```lua
-- ✅ Good: Stable unique ID
key = tostring(item.id)

-- ✅ Good: Composite key if no single unique field
key = item.category .. "_" .. item.name

-- ✅ Good: Generated stable ID
key = "user_" .. tostring(item.userId) .. "_" .. item.timestamp
```

### 2. Avoid Unstable Keys

```lua
-- ❌ Bad: Array index (changes when items move)
key = tostring(index)

-- ❌ Bad: Random/generated values (different each render)
key = tostring(math.random())

-- ❌ Bad: Non-unique values
key = item.category -- Multiple items might have same category!
```

### 3. Handle Missing Unique Identifiers

```lua
-- If your data doesn't have stable IDs, create them:
local function addStableIds(items)
    local itemsWithIds = {}
    for i, item in ipairs(items) do
        table.insert(itemsWithIds, {
            _id = "item_" .. tostring(i) .. "_" .. item.name,
            ...item
        })
    end
    return itemsWithIds
end

local itemsWithIds = Rex.useComputed(function()
    return addStableIds(rawItems:get())
end, {rawItems})

-- Now use _id as the key
itemsWithIds:map(function(items)
    local children = {}
    for _, item in ipairs(items) do
        table.insert(children, ItemComponent {
            item = item,
            key = item._id
        })
    end
    return children
end)
```

## Performance Impact

### Without Keys: O(n) Operations

```lua
-- When one item is removed from the middle of a large list:
-- ❌ Without keys: All subsequent items are recreated
// Item 0: unchanged
// Item 1: unchanged  
// Item 2: REMOVED
// Item 3: recreated (was Item 4)
// Item 4: recreated (was Item 5)
// Item 5: recreated (was Item 6)
// ... all remaining items recreated!
```

### With Keys: O(1) Operations

```lua
-- With proper keys: Only the removed item is destroyed
// Item 0 (key="item_0"): unchanged
// Item 1 (key="item_1"): unchanged
// Item 2 (key="item_2"): REMOVED
// Item 3 (key="item_3"): unchanged (just repositioned)
// Item 4 (key="item_4"): unchanged (just repositioned)
// ... only position updates, no recreation!
```

### Benchmarking Performance

```lua
local function PerformanceComparison()
    local itemCount = Rex.useState(100)
    local items = Rex.useComputed(function()
        local count = itemCount:get()
        local itemList = {}
        for i = 1, count do
            table.insert(itemList, {
                id = i,
                name = "Item " .. tostring(i),
                value = math.random(100)
            })
        end
        return itemList
    end, {itemCount})
    
    local removeRandomItem = function()
        items:update(function(currentItems)
            if #currentItems == 0 then return currentItems end
            
            local newItems = {unpack(currentItems)}
            local indexToRemove = math.random(#newItems)
            table.remove(newItems, indexToRemove)
            return newItems
        end)
    end
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = items:map(function(itemList)
                    return string.format("Items: %d", #itemList)
                end)
            },
            
            Rex("TextButton") {
                Text = "Remove Random Item",
                onClick = removeRandomItem
            },
            
            -- With keys (efficient)
            Rex("TextLabel") { Text = "With Keys (Fast):" },
            Rex("ScrollingFrame") {
                Size = UDim2.new(0.5, 0, 1, -100),
                children = {
                    items:map(function(itemList)
                        local startTime = tick()
                        local children = {}
                        
                        for _, item in ipairs(itemList) do
                            table.insert(children, Rex("TextLabel") {
                                Text = item.name,
                                key = tostring(item.id) -- Efficient with keys
                            })
                        end
                        
                        print("With keys render time:", (tick() - startTime) * 1000, "ms")
                        return children
                    end)
                }
            },
            
            -- Without keys (inefficient - don't do this!)
            Rex("TextLabel") { Text = "Without Keys (Slow):" },
            Rex("ScrollingFrame") {
                Size = UDim2.new(0.5, 0, 1, -100),
                Position = UDim2.new(0.5, 0, 0, 100),
                children = {
                    items:map(function(itemList)
                        local startTime = tick()
                        local children = {}
                        
                        for i, item in ipairs(itemList) do
                            table.insert(children, Rex("TextLabel") {
                                Text = item.name
                                -- No key - inefficient!
                            })
                        end
                        
                        print("Without keys render time:", (tick() - startTime) * 1000, "ms")
                        return children
                    end)
                }
            }
        }
    }
end
```

## Advanced Reconciliation Patterns

### Nested Lists with Compound Keys

```lua
local function NestedListExample()
    local categories = Rex.useState({
        {
            id = "fruits",
            name = "Fruits",
            items = {
                { id = 1, name = "Apple" },
                { id = 2, name = "Banana" }
            }
        },
        {
            id = "vegetables", 
            name = "Vegetables",
            items = {
                { id = 3, name = "Carrot" },
                { id = 4, name = "Broccoli" }
            }
        }
    })
    
    return Rex("ScrollingFrame") {
        children = {
            categories:map(function(categoryList)
                local children = {}
                
                for _, category in ipairs(categoryList) do
                    -- Category header
                    table.insert(children, Rex("TextLabel") {
                        Text = category.name,
                        key = "category_" .. category.id
                    })
                    
                    -- Category items
                    for _, item in ipairs(category.items) do
                        table.insert(children, Rex("TextLabel") {
                            Text = "  • " .. item.name,
                            key = "item_" .. tostring(item.id) -- Global item key
                        })
                    end
                end
                
                return children
            end)
        }
    }
end
```

### Conditional Rendering with Keys

```lua
local function ConditionalExample()
    local showAdvanced = Rex.useState(false)
    local items = Rex.useState({"Basic Item 1", "Basic Item 2"})
    
    return Rex("Frame") {
        children = {
            -- Always visible items
            Rex("TextLabel") {
                Text = "Basic Settings",
                key = "basic_header"
            },
            
            items:map(function(itemList)
                local children = {}
                for i, item in ipairs(itemList) do
                    table.insert(children, Rex("TextLabel") {
                        Text = item,
                        key = "basic_item_" .. tostring(i)
                    })
                end
                return children
            end),
            
            -- Conditionally visible items
            showAdvanced:map(function(show)
                if not show then return nil end
                
                return {
                    Rex("TextLabel") {
                        Text = "Advanced Settings",
                        key = "advanced_header" -- Stable key for advanced section
                    },
                    Rex("TextLabel") {
                        Text = "Advanced Option 1",
                        key = "advanced_option_1"
                    },
                    Rex("TextLabel") {
                        Text = "Advanced Option 2", 
                        key = "advanced_option_2"
                    }
                }
            end),
            
            Rex("TextButton") {
                Text = showAdvanced:map(function(show)
                    return show and "Hide Advanced" or "Show Advanced"
                end),
                onClick = function()
                    showAdvanced:update(function(current) return not current end)
                end,
                key = "toggle_button" -- Stable key
            }
        }
    }
end
```

## Debugging Key Issues

### Common Problems and Solutions

```lua
-- ❌ Problem: Duplicate keys
items:map(function(itemList)
    local children = {}
    for i, item in ipairs(itemList) do
        table.insert(children, Rex("TextLabel") {
            Text = item.name,
            key = item.category -- Multiple items might have same category!
        })
    end
    return children
end)

-- ✅ Solution: Ensure unique keys
items:map(function(itemList)
    local children = {}
    for i, item in ipairs(itemList) do
        table.insert(children, Rex("TextLabel") {
            Text = item.name,
            key = item.category .. "_" .. tostring(item.id) -- Unique combination
        })
    end
    return children
end)
```

### Key Validation

```lua
-- Add development-time key validation
local function validateKeys(children)
    if not _G.DEV_MODE then return children end
    
    local seenKeys = {}
    local function checkElement(element)
        if element.key then
            if seenKeys[element.key] then
                warn("Duplicate key detected: " .. tostring(element.key))
            end
            seenKeys[element.key] = true
        end
    end
    
    for _, child in ipairs(children) do
        checkElement(child)
    end
    
    return children
end

-- Use in development
items:map(function(itemList)
    local children = {}
    -- ... build children array ...
    return validateKeys(children)
end)
```

## Best Practices Summary

### 1. Always Use Keys for Dynamic Lists

```lua
-- ✅ Always provide keys for list items
children:map(function(items)
    local elements = {}
    for _, item in ipairs(items) do
        table.insert(elements, Component {
            key = tostring(item.id),
            data = item
        })
    end
    return elements
end)
```

### 2. Use Stable, Meaningful Keys

```lua
-- ✅ Good key choices
key = tostring(item.id)                    -- Database ID
key = item.type .. "_" .. item.name        -- Composite natural key
key = "user_" .. tostring(item.userId)     -- Prefixed ID
```

### 3. Avoid Index-Based Keys for Dynamic Lists

```lua
-- ❌ Bad for dynamic lists
key = tostring(index)

-- ✅ Good for static lists only
key = "static_item_" .. tostring(index)
```

### 4. Consider Performance Implications

```lua
-- For large lists, keys are essential for performance
// 1000+ items: Keys prevent massive recreation
// Frequent updates: Keys enable efficient diffing
// Animations: Keys enable smooth transitions
```

Key-based diffing is fundamental to Rex's performance and correctness. By understanding and properly implementing keys, you ensure that your Rex applications update efficiently and provide smooth user experiences.
