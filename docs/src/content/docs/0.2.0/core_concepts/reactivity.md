---
title: "Reactivity System"
description: "Understand Rex's reactivity system - how state changes automatically trigger UI updates and the principles behind reactive programming."
category: "Core Concepts"
order: 4
version: "0.2.0"
lastUpdated: 2025-06-23
---

Reactivity is the core principle that makes Rex powerful and intuitive. When data changes, the UI automatically updates to reflect those changes without manual intervention. This creates a direct connection between your application's state and its visual representation.

## What is Reactivity?

In traditional imperative UI programming, you manually update UI elements when data changes:

```luau
-- Traditional imperative approach
local count = 0
local label = Instance.new("TextLabel")
label.Text = "Count: " .. count

-- Manual update required
count = count + 1
label.Text = "Count: " .. count -- Must remember to update UI
```

With Rex's reactive approach, the UI automatically updates when state changes:

```luau
-- Rex reactive approach
local count = Rex.useState(0)
local label = Rex("TextLabel") {
    Text = count:map(function(c) return `Count: {c}` end)
}

-- Automatic update
count:set(count:get() + 1) -- UI updates automatically
```

## The Reactive Flow

Rex's reactivity follows a clear flow:

1. **State Creation**: Create reactive state with `useState`, `useComputed`, etc.
2. **UI Binding**: Bind state to UI properties or use in computed values
3. **Change Detection**: When state changes, Rex detects the change
4. **Update Propagation**: Changes propagate to all dependent UI elements
5. **Efficient Rendering**: Only affected elements are updated

```luau
local function ReactiveFlow()
    -- 1. State Creation
    local name = Rex.useState("Player")
    local level = Rex.useState(1)
    
    -- 2. Computed state (automatically updates when dependencies change)
    local displayText = Rex.useComputed(function()
        return `{name:get()} (Level {level:get()})`
    end, {name, level})
    
    -- 3. UI Binding
    return Rex("TextLabel") {
        Text = displayText -- Automatically updates when name or level changes
    }
end
```

## Types of Reactivity

### 1. Direct State Binding

Bind state directly to properties:

```luau
local color = Rex.useState(Color3.fromRGB(255, 0, 0))

Rex("Frame") {
    BackgroundColor3 = color -- Direct binding
}
```

### 2. Transformed Binding

Transform state values using `map`:

```luau
local health = Rex.useState(100)

Rex("TextLabel") {
    Text = health:map(function(h) return `Health: {h}%` end)
}
```

### 3. Computed Reactivity

Derive values from multiple states:

```luau
local width = Rex.useState(100)
local height = Rex.useState(200)

local area = Rex.useComputed(function()
    return width:get() * height:get()
end, {width, height})

Rex("TextLabel") {
    Text = area:map(function(a) return `Area: {a}` end)
}
```

### 4. Effect-Based Reactivity

Run side effects when state changes:

```luau
local playerCount = Rex.useState(0)

Rex.useEffect(function()
    local count = playerCount:get()
    print(`Player count changed to: {count}`)
    
    -- Update game title
    game.Name = `My Game ({count} players)`
end, {playerCount})
```

## Reactive Children

Rex supports reactive children that automatically update when state changes:

```luau
local function DynamicList()
    local items = Rex.useState({"Apple", "Banana", "Cherry"})
    
    return Rex("ScrollingFrame") {
        children = {
            Rex("UIListLayout") {},
            -- Reactive children - automatically updates when items change
            items:map(function(itemList)
                local children = {}
                for i, item in ipairs(itemList) do
                    table.insert(children, Rex("TextLabel") {
                        Text = item,
                        key = item, -- Key for efficient diffing
                        Size = UDim2.new(1, 0, 0, 30)
                    })
                end
                return children
            end)
        }
    }
end
```

## Dependency Tracking

Rex automatically tracks dependencies in computed states and effects:

### Manual Dependency Declaration

```luau
local a = Rex.useState(1)
local b = Rex.useState(2)

-- Explicitly declare dependencies
local sum = Rex.useComputed(function()
    return a:get() + b:get()
end, {a, b}) -- Manual dependency list
```

### Automatic Dependency Tracking

```luau
local a = Rex.useState(1)
local b = Rex.useState(2)

-- Dependencies automatically detected
local sum = Rex.useAutoComputed(function()
    return a:get() + b:get() -- Rex automatically tracks a and b
end)
```

## Reactive Patterns

### 1. Conditional Reactivity

```luau
local function ConditionalUI()
    local isLoggedIn = Rex.useState(false)
    local userName = Rex.useState("")
    
    return Rex("Frame") {
        children = isLoggedIn:map(function(loggedIn)
            if loggedIn then
                return {
                    Rex("TextLabel") {
                        Text = userName:map(function(name) return `Welcome, {name}!` end)
                    },
                    Rex("TextButton") {
                        Text = "Logout",
                        onClick = function() isLoggedIn:set(false) end
                    }
                }
            else
                return {
                    Rex("TextLabel") { Text = "Please log in" },
                    Rex("TextButton") {
                        Text = "Login",
                        onClick = function()
                            userName:set("Player")
                            isLoggedIn:set(true)
                        end
                    }
                }
            end
        end)
    }
end
```

### 2. Cascading Updates

```luau
local function CascadingExample()
    local baseValue = Rex.useState(10)
    
    -- Each computed state depends on the previous one
    local doubled = Rex.useComputed(function()
        return baseValue:get() * 2
    end, {baseValue})
    
    local formatted = Rex.useComputed(function()
        return `Value: {doubled:get()}`
    end, {doubled})
    
    local styled = Rex.useComputed(function()
        local value = doubled:get()
        return {
            text = formatted:get(),
            color = value > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        }
    end, {doubled, formatted})
    
    return Rex("TextLabel") {
        Text = styled:map(function(s) return s.text end),
        TextColor3 = styled:map(function(s) return s.color end)
    }
end
```

### 3. Cross-Component Reactivity with Context

```luau
-- Global theme context
local ThemeContext = Rex.createContext({
    primary = Color3.fromRGB(70, 130, 255),
    background = Color3.fromRGB(30, 30, 40)
})

local function App()
    local currentTheme = Rex.useState({
        primary = Color3.fromRGB(70, 130, 255),
        background = Color3.fromRGB(30, 30, 40)
    })
    
    return Rex.Provider {
        context = ThemeContext,
        value = currentTheme,
        children = {
            ThemedComponent(),
            ThemeToggleButton { theme = currentTheme }
        }
    }
end

local function ThemedComponent()
    local theme = Rex.useContext(ThemeContext)
    
    return Rex("Frame") {
        BackgroundColor3 = theme:map(function(t) return t.background end),
        children = {
            Rex("TextLabel") {
                Text = "Themed Component",
                TextColor3 = theme:map(function(t) return t.primary end)
            }
        }
    }
end
```

## Performance and Reactivity

### Batching Updates

Rex automatically batches updates for better performance:

```luau
local function BatchedUpdates()
    local x = Rex.useState(0)
    local y = Rex.useState(0)
    local z = Rex.useState(0)
    
    -- Multiple updates in one action
    local function updateAll()
        Rex.batch(function()
            x:set(10)
            y:set(20)
            z:set(30)
        end) -- Single UI update instead of three
    end
    
    return Rex("TextButton") {
        Text = "Update All",
        onClick = updateAll
    }
end
```

### Memoization

Use memoization for expensive computations:

```luau
local function ExpensiveComputation()
    local data = Rex.useState(largeDataSet)
    
    -- Memoized expensive calculation
    local processedData = Rex.useComputed(function()
        return performExpensiveProcessing(data:get())
    end, {data}, "expensiveProcess") -- Memoization key
    
    return Rex("TextLabel") {
        Text = processedData:map(function(result) return `Processed: {#result} items` end)
    }
end
```

## Debugging Reactivity

### 1. Use Effects to Debug State Changes

```luau
local count = Rex.useState(0)

-- Debug effect
Rex.useEffect(function()
    print(`Count changed to: {count:get()}`)
    print(`Call stack:`, debug.traceback())
end, {count})
```

### 2. Name Your States

```luau
-- Add meaningful names for debugging
local playerHealth = Rex.useState(100, "playerHealth")
local playerMana = Rex.useState(50, "playerMana")
```

### 3. Monitor Dependency Chains

```luau
local function DebugDependencies()
    local a = Rex.useState(1)
    local b = Rex.useComputed(function() return a:get() * 2 end, {a})
    local c = Rex.useComputed(function() return b:get() + 10 end, {b})
    
    -- Debug each level
    Rex.useEffect(function() print("a changed:", a:get()) end, {a})
    Rex.useEffect(function() print("b changed:", b:get()) end, {b})
    Rex.useEffect(function() print("c changed:", c:get()) end, {c})
end
```

## Best Practices for Reactivity

### 1. Keep State Close to Where It's Used

```luau
-- Good: Local state
local function Counter()
    local count = Rex.useState(0) -- Used only in this component
    
    return Rex("TextLabel") {
        Text = count:map(function(c) return `Count: {c}` end)
    }
end

-- Less ideal: Global state for local concerns
local globalCount = Rex.useState(0) -- Used everywhere, harder to track
```

### 2. Use Computed States for Derived Data

```luau
-- Good: Computed state for derived data
local items = Rex.useState({...})
local itemCount = Rex.useComputed(function()
    return #items:get()
end, {items})

-- Less ideal: Manual synchronization
local items = Rex.useState({...})
local itemCount = Rex.useState(0) -- Must manually keep in sync
```

### 3. Minimize Deep State

```luau
-- Good: Flat state structure
local playerName = Rex.useState("Player")
local playerLevel = Rex.useState(1)
local playerHealth = Rex.useState(100)

-- Less ideal: Deep nested state
local player = Rex.useDeepState({
    personal = {
        profile = { name = "Player" },
        stats = { level = 1, health = 100 }
    }
})
```

Reactivity is what makes Rex feel magical - your UI stays perfectly in sync with your data automatically. Understanding these patterns will help you build more efficient and maintainable applications.
