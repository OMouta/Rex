---
title: "States"
description: "Comprehensive guide to Rex's reactive state system, including basic state, deep reactivity, computed values, and state transformations."
category: "Core Concepts"
order: 1

lastUpdated: 2025-06-23
---

States are the foundation of Rex's reactivity system. They represent data that can change over time and automatically trigger UI updates when modified. Rex provides several types of state for different use cases.

## Basic State with `useState`

`Rex.useState` creates a reactive state object that holds a single value.

```luau
local count = Rex.useState(0)
local name = Rex.useState("Player")
local isVisible = Rex.useState(true)
```

### Accessing Values

Use the `get()` method to read the current value:

```luau
local currentCount = count:get()
print("Current count:", currentCount) -- Current count: 0
```

### Setting Values

Use the `set()` method to update the value and trigger UI updates:

```luau
count:set(10)
name:set("NewPlayer")
isVisible:set(false)
```

### Updating Values

Use the `update()` method for immutable updates based on the current value:

```luau
-- Increment counter
count:update(function(current) return current + 1 end)

-- Toggle boolean
isVisible:update(function(current) return not current end)

-- Update string
name:update(function(current) return current .. "_Updated" end)
```

### Listening to Changes

Use `onChange()` to listen for state changes. Returns a disconnect function:

```luau
local disconnect = count:onChange(function(newValue, oldValue)
    print(`Count changed from {oldValue} to {newValue}`)
end)

-- Later, stop listening
disconnect()
```

## Deep Reactive State with `useDeepState`

For complex nested objects, use `Rex.useDeepState` which provides deep reactivity:

```luau
local user = Rex.useDeepState({
    name = "Player",
    stats = {
        level = 1,
        experience = 0,
        inventory = {
            coins = 100,
            items = {"sword", "potion"}
        }
    },
    settings = {
        theme = "dark",
        notifications = true
    }
})
```

### Deep Updates

Changes to nested properties trigger updates:

```luau
-- Update nested values - this triggers reactivity
user:update(function(current)
    local newUser = table.clone(current)
    newUser.stats.level = current.stats.level + 1
    newUser.stats.experience = 0
    return newUser
end)

-- Or replace entire nested objects
user:update(function(current)
    local newUser = table.clone(current)
    newUser.settings = {
        theme = "light",
        notifications = false
    }
    return newUser
end)
```

## Computed State with `useComputed`

Computed states derive their values from other states and automatically update when dependencies change:

```luau
local firstName = Rex.useState("John")
local lastName = Rex.useState("Doe")

-- Computed state with explicit dependencies
local fullName = Rex.useComputed(function()
    return firstName:get() .. " " .. lastName:get()
end, {firstName, lastName})

print(fullName:get()) -- "John Doe"

firstName:set("Jane")
print(fullName:get()) -- "Jane Doe" (automatically updated)
```

### Memoized Computed State

Add an optional memoization key for expensive computations:

```luau
local items = Rex.useState({...}) -- Large array
local sortedItems = Rex.useComputed(function()
    local list = items:get()
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end, {items}, "sortedItems") -- Memoization key
```

## Auto-Tracked Computed with `useAutoComputed`

Automatically detect dependencies without explicit declaration:

```luau
local x = Rex.useState(10)
local y = Rex.useState(20)
local z = Rex.useState(30)

-- Dependencies auto-detected during first execution
local sum = Rex.useAutoComputed(function()
    return x:get() + y:get() + z:get() -- All three states tracked automatically
end)

print(sum:get()) -- 60
x:set(15)
print(sum:get()) -- 65 (automatically updated)
```

## State Transformations with `map`

Transform state values on-the-fly without creating new computed states:

```luau
local count = Rex.useState(0)

-- Use in UI with transformation
Rex("TextLabel") {
    Text = count:map(function(value)
        if value == 0 then
            return "No clicks yet"
        elseif value == 1 then
            return "Clicked once"
        else
            return `Clicked {value} times`
        end
    end),
    Size = UDim2.fromScale(1, 1)
}
```

## Async State with `useAsyncState`

Handle asynchronous operations with built-in loading and error states:

```luau
local userData = Rex.useAsyncState(function()
    -- Simulate API call
    wait(1)
    return {
        name = "Player",
        level = 10,
        coins = 1500
    }
end)

-- Access async state properties
print(userData.loading:get()) -- true initially
print(userData.data:get())    -- nil initially
print(userData.error:get())   -- nil initially

-- After the async operation completes:
-- userData.loading:get() -> false
-- userData.data:get() -> { name = "Player", level = 10, coins = 1500 }

-- Manually reload
userData.reload()
```

## Batching Updates with `useBatch`

Batch multiple state updates for performance:

```luau
local x = Rex.useState(1)
local y = Rex.useState(2)
local z = Rex.useState(3)

-- Without batching: 3 separate UI updates
x:set(10)
y:set(20)
z:set(30)

-- With batching: single UI update
Rex.batch(function()
    x:set(100)
    y:set(200)
    z:set(300)
end)
```

## Watching Multiple States

Watch multiple states simultaneously:

```luau
local health = Rex.useState(100)
local mana = Rex.useState(50)
local level = Rex.useState(1)

local disconnect = Rex.useWatch({health, mana, level}, function()
    print("Player stats changed!")
    print(`Health: {health:get()}, Mana: {mana:get()}, Level: {level:get()}`)
end, {immediate = true}) -- Run immediately on setup

-- Stop watching later
disconnect()
```

## Best Practices

### 1. Use the Right State Type

- `useState` for simple values
- `useDeepState` for complex nested objects (use sparingly)
- `useComputed` for derived values
- `useAutoComputed` for convenience when dependencies are obvious

### 2. Prefer Flat State Structures

```luau
-- Good: Flat structure
local playerName = Rex.useState("Player")
local playerLevel = Rex.useState(1)
local playerCoins = Rex.useState(100)

-- Less ideal: Deep nesting
local player = Rex.useDeepState({
    personal = {
        profile = {
            name = "Player",
            settings = { theme = "dark" }
        }
    }
})
```

### 3. Use Immutable Updates

Always create new objects/arrays when updating deep state:

```luau
-- Good: Immutable update
items:update(function(current)
    local newItems = table.clone(current)
    table.insert(newItems, newItem)
    return newItems
end)

-- Bad: Mutating existing state
items:update(function(current)
    table.insert(current, newItem) -- Mutates existing array!
    return current
end)
```

### 4. Clean Up Listeners

Always clean up onChange listeners to prevent memory leaks:

```luau
local function MyComponent()
    local count = Rex.useState(0)
    
    Rex.useEffect(function()
        local disconnect = count:onChange(function(newValue)
            print("Count:", newValue)
        end)
        
        -- Cleanup function
        return disconnect
    end, {})
    
    -- ... rest of component
end
```
