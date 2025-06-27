---
title: "Memoization and Performance Optimization"
description: "Optimizing Rex applications with computed state, memoization, and efficient update patterns."
category: "Advanced Features"
order: 2
version: "0.2.0"
lastUpdated: 2025-06-23
---

Memoization in Rex ensures that expensive computations are only performed when their dependencies change. This is crucial for building performant applications, especially when dealing with complex derived state, large lists, or expensive calculations.

## Understanding Memoization in Rex

Rex provides several mechanisms for optimization:

1. **Computed State** - Automatically memoized derived values
2. **Auto-tracked Computed** - Dependencies are automatically detected
3. **Efficient List Updates** - Using keys for minimal re-renders
4. **Batch Updates** - Combining multiple state changes

## Computed State Memoization

The most common form of memoization in Rex is `useComputed`, which caches computed values based on dependencies:

```lua
local function ExpensiveCalculationExample()
    local numbers = Rex.useState({1, 2, 3, 4, 5})
    local multiplier = Rex.useState(2)
    
    -- ❌ Without memoization - recalculates on every render
    local function calculateSum()
        print("Calculating sum...") -- This would run every render
        local sum = 0
        for _, num in ipairs(numbers:get()) do
            sum = sum + (num * multiplier:get())
        end
        return sum
    end
    
    -- ✅ With memoization - only recalculates when dependencies change
    local memoizedSum = Rex.useComputed(function()
        print("Calculating memoized sum...") -- Only runs when numbers or multiplier change
        local sum = 0
        for _, num in ipairs(numbers:get()) do
            sum = sum + (num * multiplier:get())
        end
        return sum
    end, {numbers, multiplier})
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = memoizedSum:map(function(sum)
                    return "Sum: " .. tostring(sum)
                end)
            },
            Rex("TextButton") {
                Text = "Add Number",
                onClick = function()
                    numbers:update(function(current)
                        local newNumbers = {unpack(current)}
                        table.insert(newNumbers, #newNumbers + 1)
                        return newNumbers
                    end)
                end
            },
            Rex("TextButton") {
                Text = "Double Multiplier",
                onClick = function()
                    multiplier:update(function(current) return current * 2 end)
                end
            }
        }
    }
end
```

## Auto-tracked Computed State

For even more convenience, use `useAutoComputed` which automatically detects dependencies:

```lua
local function AutoTrackedExample()
    local firstName = Rex.useState("John")
    local lastName = Rex.useState("Doe")
    local age = Rex.useState(30)
    local showAge = Rex.useState(true)
    
    -- Dependencies are automatically tracked
    local displayName = Rex.useAutoComputed(function()
        local name = firstName:get() .. " " .. lastName:get()
        if showAge:get() then
            name = name .. " (" .. tostring(age:get()) .. ")"
        end
        return name
    end)
    
    -- This computed only depends on firstName and lastName (auto-detected)
    local initials = Rex.useAutoComputed(function()
        return string.sub(firstName:get(), 1, 1) .. string.sub(lastName:get(), 1, 1)
    end)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = displayName:map(function(name)
                    return "Name: " .. name
                end)
            },
            Rex("TextLabel") {
                Text = initials:map(function(init)
                    return "Initials: " .. init
                end)
            }
        }
    }
end
```

## Complex Data Memoization

When working with complex data structures, proper memoization becomes critical:

```lua
local function DataProcessingExample()
    local rawData = Rex.useState({
        { name = "Alice", score = 85, category = "A" },
        { name = "Bob", score = 92, category = "B" },
        { name = "Charlie", score = 78, category = "A" },
        { name = "Diana", score = 96, category = "B" }
    })
    local selectedCategory = Rex.useState("all")
    local sortBy = Rex.useState("name") -- "name", "score"
    
    -- Filter data by category (memoized)
    local filteredData = Rex.useComputed(function()
        local data = rawData:get()
        local category = selectedCategory:get()
        
        if category == "all" then
            return data
        end
        
        local filtered = {}
        for _, item in ipairs(data) do
            if item.category == category then
                table.insert(filtered, item)
            end
        end
        return filtered
    end, {rawData, selectedCategory})
    
    -- Sort filtered data (memoized)
    local sortedData = Rex.useComputed(function()
        local data = filteredData:get()
        local sortField = sortBy:get()
        
        local sorted = {unpack(data)} -- Copy array
        table.sort(sorted, function(a, b)
            if sortField == "score" then
                return a.score > b.score
            else
                return a.name < b.name
            end
        end)
        return sorted
    end, {filteredData, sortBy})
    
    -- Calculate statistics (memoized)
    local statistics = Rex.useComputed(function()
        local data = sortedData:get()
        if #data == 0 then
            return { count = 0, average = 0, highest = 0, lowest = 0 }
        end
        
        local total = 0
        local highest = data[1].score
        local lowest = data[1].score
        
        for _, item in ipairs(data) do
            total = total + item.score
            highest = math.max(highest, item.score)
            lowest = math.min(lowest, item.score)
        end
        
        return {
            count = #data,
            average = total / #data,
            highest = highest,
            lowest = lowest
        }
    end, {sortedData})
    
    return Rex("Frame") {
        children = {
            -- Controls
            Rex("Frame") {
                children = {
                    Rex("TextButton") {
                        Text = "All Categories",
                        onClick = function() selectedCategory:set("all") end
                    },
                    Rex("TextButton") {
                        Text = "Category A",
                        onClick = function() selectedCategory:set("A") end
                    },
                    Rex("TextButton") {
                        Text = "Category B",
                        onClick = function() selectedCategory:set("B") end
                    },
                    Rex("TextButton") {
                        Text = sortBy:map(function(sort)
                            return sort == "name" and "Sort by Score" or "Sort by Name"
                        end),
                        onClick = function()
                            sortBy:update(function(current)
                                return current == "name" and "score" or "name"
                            end)
                        end
                    }
                }
            },
            
            -- Statistics (automatically updates when data changes)
            Rex("TextLabel") {
                Text = statistics:map(function(stats)
                    return string.format(
                        "Count: %d | Avg: %.1f | High: %d | Low: %d",
                        stats.count, stats.average, stats.highest, stats.lowest
                    )
                end)
            },
            
            -- Data list (only re-renders when sorted data actually changes)
            sortedData:map(function(data)
                local children = {}
                for i, item in ipairs(data) do
                    table.insert(children, Rex("TextLabel") {
                        Text = string.format("%s: %d (%s)", item.name, item.score, item.category),
                        key = item.name -- Important for efficient updates
                    })
                end
                return children
            end)
        }
    }
end
```

## List Optimization with Keys

Proper use of keys is crucial for list performance:

```lua
local function OptimizedListExample()
    local items = Rex.useState({
        { id = 1, name = "Item 1", value = 10 },
        { id = 2, name = "Item 2", value = 20 },
        { id = 3, name = "Item 3", value = 30 }
    })
    
    local shuffleItems = function()
        items:update(function(current)
            local shuffled = {unpack(current)}
            for i = #shuffled, 2, -1 do
                local j = math.random(i)
                shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
            end
            return shuffled
        end)
    end
    
    return Rex("Frame") {
        children = {
            Rex("TextButton") {
                Text = "Shuffle Items",
                onClick = shuffleItems
            },
            
            -- ✅ Good: Using stable keys
            items:map(function(itemList)
                local children = {}
                for _, item in ipairs(itemList) do
                    table.insert(children, Rex("TextLabel") {
                        Text = string.format("%s: %d", item.name, item.value),
                        key = tostring(item.id), -- Stable, unique key
                        BackgroundColor3 = Color3.fromHSV(item.id * 0.1, 0.5, 0.8)
                    })
                end
                return children
            end),
            
            -- ❌ Bad: Using array indices as keys (don't do this for dynamic lists)
            -- items:map(function(itemList)
            --     local children = {}
            --     for i, item in ipairs(itemList) do
            --         table.insert(children, Rex("TextLabel") {
            --             Text = string.format("%s: %d", item.name, item.value),
            --             key = tostring(i), -- Bad: index changes when items move
            --         })
            --     end
            --     return children
            -- end)
        }
    }
end
```

## Batch Updates for Performance

When making multiple state updates, batch them to avoid unnecessary re-renders:

```lua
local function BatchUpdateExample()
    local firstName = Rex.useState("John")
    local lastName = Rex.useState("Doe")
    local age = Rex.useState(30)
    local email = Rex.useState("john.doe@example.com")
    
    -- This will cause 4 separate re-renders
    local updateProfileSeparately = function()
        firstName:set("Jane")
        lastName:set("Smith")
        age:set(25)
        email:set("jane.smith@example.com")
    end
    
    -- This will cause only 1 re-render
    local updateProfileBatched = function()
        Rex.batch(function()
            firstName:set("Jane")
            lastName:set("Smith")
            age:set(25)
            email:set("jane.smith@example.com")
        end)
    end
    
    return Rex("Frame") {
        children = {
            Rex("TextButton") {
                Text = "Update Profile (Batched)",
                onClick = updateProfileBatched
            }
        }
    }
end
```

## Memoization with External Dependencies

Sometimes you need to memoize based on external factors:

```lua
local function ExternalDependencyExample()
    local playerCount = Rex.useState(1)
    
    -- Memoize expensive calculation that depends on external game state
    local gameSettings = Rex.useComputed(function()
        local players = playerCount:get()
        local currentTime = workspace:GetServerTimeNow()
        
        -- Expensive calculation based on player count and time
        local difficulty = math.floor(players / 2) + math.floor(currentTime / 60)
        local maxEnemies = players * 5 + difficulty
        local spawnRate = math.max(1, 10 - difficulty)
        
        return {
            difficulty = difficulty,
            maxEnemies = maxEnemies,
            spawnRate = spawnRate,
            calculatedAt = currentTime
        }
    end, {playerCount})
    
    -- Update player count when players join/leave
    Rex.useEffect(function()
        local players = game:GetService("Players")
        
        local function updateCount()
            playerCount:set(#players:GetPlayers())
        end
        
        local addedConnection = players.PlayerAdded:Connect(updateCount)
        local removedConnection = players.PlayerRemoving:Connect(updateCount)
        
        return function()
            addedConnection:Disconnect()
            removedConnection:Disconnect()
        end
    end, {})
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = gameSettings:map(function(settings)
                    return string.format(
                        "Players: %d | Difficulty: %d | Max Enemies: %d | Spawn Rate: %ds",
                        playerCount:get(),
                        settings.difficulty,
                        settings.maxEnemies,
                        settings.spawnRate
                    )
                end)
            }
        }
    }
end
```

## Performance Monitoring

You can monitor when computations are running:

```lua
local function PerformanceMonitoringExample()
    local counter = Rex.useState(0)
    local multiplier = Rex.useState(1)
    
    local expensiveComputation = Rex.useComputed(function()
        local start = tick()
        
        -- Simulate expensive work
        local result = 0
        for i = 1, 1000000 do
            result = result + (counter:get() * multiplier:get() * i)
        end
        
        local duration = tick() - start
        print(string.format("Computation took %.2fms", duration * 1000))
        
        return {
            result = result,
            duration = duration
        }
    end, {counter, multiplier})
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = expensiveComputation:map(function(comp)
                    return string.format("Result: %d (%.2fms)", comp.result, comp.duration * 1000)
                end)
            },
            Rex("TextButton") {
                Text = "Increment Counter",
                onClick = function()
                    counter:update(function(c) return c + 1 end)
                end
            },
            Rex("TextButton") {
                Text = "Double Multiplier", 
                onClick = function()
                    multiplier:update(function(m) return m * 2 end)
                end
            }
        }
    }
end
```

## Best Practices for Memoization

### 1. Use Computed State for Derived Values

Always use `useComputed` or `useAutoComputed` for values derived from state:

```lua
-- ✅ Good
local fullName = Rex.useComputed(function()
    return firstName:get() .. " " .. lastName:get()
end, {firstName, lastName})

-- ❌ Bad: Recalculates every render
local fullName = firstName:get() .. " " .. lastName:get()
```

### 2. Be Specific with Dependencies

Include all dependencies and only the necessary ones:

```lua
-- ✅ Good: Exact dependencies
local computed = Rex.useComputed(function()
    return a:get() + b:get()
end, {a, b})

-- ❌ Bad: Missing dependency
local computed = Rex.useComputed(function()
    return a:get() + b:get() + c:get() -- c is missing from dependencies!
end, {a, b})

-- ❌ Bad: Unnecessary dependency
local computed = Rex.useComputed(function()
    return a:get() + b:get()
end, {a, b, c}) -- c is not used in the computation
```

### 3. Use Stable Keys for Lists

Ensure list keys are stable and unique:

```lua
-- ✅ Good: Stable unique keys
key = item.id

-- ✅ Good: Composite key if no single unique field
key = item.category .. "_" .. item.name

-- ❌ Bad: Array index (unstable when items move)
key = tostring(index)

-- ❌ Bad: Non-unique key
key = item.category
```

### 4. Batch Related Updates

Group related state updates to minimize re-renders:

```lua
-- ✅ Good: Batched updates
Rex.batch(function()
    setX(newX)
    setY(newY)
    setZ(newZ)
end)

-- ❌ Bad: Separate updates causing multiple re-renders
setX(newX)
setY(newY)
setZ(newZ)
```

### 5. Profile Performance-Critical Paths

For computationally expensive operations, measure performance:

```lua
local expensiveComputed = Rex.useComputed(function()
    local start = tick()
    local result = expensiveCalculation()
    print("Expensive calculation took:", (tick() - start) * 1000, "ms")
    return result
end, dependencies)
```

Proper memoization is key to building smooth, responsive Rex applications. By leveraging computed state, using appropriate keys, and batching updates, you can ensure your app performs well even with complex data flows and frequent updates.
