---
title: "Reactivity System Design"
description: "How Rex's reactivity system ensures automatic and efficient UI updates through signals, subscriptions, and smart dependency tracking."
category: "Design Choices"
order: 2
version: "0.1.0"
lastUpdated: 2025-06-23
---

Rex's reactivity system is the foundation that makes declarative UI possible. It automatically tracks dependencies, efficiently updates only what changed, and provides a seamless developer experience where UI stays in sync with application state.

## Core Reactivity Concepts

### Signal-Based Architecture

Rex uses a signal-based reactivity system similar to modern frameworks like Vue 3 and SolidJS:

```luau
-- State objects are reactive signals
local count = Rex.useState(0)

-- UI elements automatically subscribe to signals they use
local label = Rex("TextLabel") {
    Text = count:map(function(value)
        return `Count: {value}`
    end)
}

-- When the signal changes, subscribers are notified
count:set(5) -- label automatically updates to "Count: 5"
```

### Automatic Dependency Tracking

Rex automatically tracks which state objects a computation depends on:

```luau
local firstName = Rex.useState("John")
local lastName = Rex.useState("Doe")

-- Rex automatically tracks that this depends on both firstName and lastName
local fullName = Rex.useAutoComputed(function()
    return firstName:get() .. " " .. lastName:get()
end)

-- Changing either triggers an update
firstName:set("Jane") -- fullName updates to "Jane Doe"
lastName:set("Smith")  -- fullName updates to "Jane Smith"
```

## Reactivity vs Imperative Updates

### The Problem with Imperative UI

Traditional Roblox UI requires manual synchronization:

```luau
-- ❌ Imperative approach: Manual updates required
local playerData = {
    name = "Player1",
    level = 5,
    health = 100,
    maxHealth = 100
}

local nameLabel = Instance.new("TextLabel")
local levelLabel = Instance.new("TextLabel")
local healthBar = Instance.new("Frame")

-- Must manually update every UI element when data changes
local function updateUI()
    nameLabel.Text = playerData.name
    levelLabel.Text = "Level " .. tostring(playerData.level)
    
    local healthPercent = playerData.health / playerData.maxHealth
    healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
    healthBar.BackgroundColor3 = healthPercent > 0.5 and Color3.green or Color3.red
end

-- Must remember to call updateUI() after every change
playerData.health = 80
updateUI() -- Easy to forget!

playerData.level = 6
updateUI() -- Repetitive and error-prone
```

### Rex's Reactive Solution

Rex eliminates manual synchronization:

```luau
-- ✅ Reactive approach: Automatic updates
local playerData = Rex.useDeepState({
    name = "Player1",
    level = 5,
    health = 100,
    maxHealth = 100
})

local ui = Rex("Frame") {
    children = {
        Rex("TextLabel") {
            Text = playerData:map(function(data) return data.name end)
        },
        Rex("TextLabel") {
            Text = playerData:map(function(data) return "Level " .. tostring(data.level) end)
        },
        Rex("Frame") {
            Size = playerData:map(function(data)
                local healthPercent = data.health / data.maxHealth
                return UDim2.new(healthPercent, 0, 1, 0)
            end),
            BackgroundColor3 = playerData:map(function(data)
                local healthPercent = data.health / data.maxHealth
                return healthPercent > 0.5 and Color3.green or Color3.red
            end)
        }
    }
}

-- UI automatically updates when data changes
playerData:update(function(current)
    return {...current, health = 80}
end) -- All UI elements update automatically!

playerData:update(function(current)
    return {...current, level = 6}
end) -- Still automatic!
```

## Dependency Collection and Tracking

### How Rex Tracks Dependencies

Rex uses execution tracking to automatically detect dependencies:

```luau
local a = Rex.useState(1)
local b = Rex.useState(2)
local c = Rex.useState(3)

-- During the first execution, Rex tracks which states are accessed
local computed = Rex.useAutoComputed(function()
    local result = a:get() + b:get() -- a and b are tracked as dependencies
    
    if result > 5 then
        return result + c:get() -- c is conditionally tracked
    else
        return result
    end
end)

-- Rex knows this computed depends on: [a, b, c (conditionally)]
```

### Smart Re-execution

Rex only re-runs computations when their actual dependencies change:

```luau
local condition = Rex.useState(true)
local valueA = Rex.useState(10)
local valueB = Rex.useState(20)

local result = Rex.useAutoComputed(function()
    if condition:get() then
        return valueA:get() * 2  -- Only depends on condition and valueA
    else
        return valueB:get() * 3  -- Only depends on condition and valueB
    end
end)

-- Changing valueB won't trigger re-computation if condition is true
condition:set(true)
valueB:set(100) -- No re-computation! result still depends only on condition and valueA

condition:set(false) -- Now result depends on condition and valueB
valueB:set(200) -- Now this triggers re-computation
```

## Batching and Performance

### Automatic Update Batching

Rex batches multiple state changes to prevent redundant UI updates:

```luau
local user = Rex.useState({name: "John", age: 25, email: "john@example.com"})

-- Without batching, this would cause 3 separate UI updates
Rex.batch(function()
    user:update(function(current) return {...current, name = "Jane"} end)
    user:update(function(current) return {...current, age = 26} end)
    user:update(function(current) return {...current, email = "jane@example.com"} end)
end)
-- Only 1 UI update happens at the end of the batch!
```

### Synchronous vs Asynchronous Updates

Rex uses synchronous updates for predictable behavior:

```luau
local count = Rex.useState(0)

count:set(5)
print(count:get()) -- Always prints 5 immediately

-- This ensures predictable behavior in event handlers
local button = Rex("TextButton") {
    onClick = function()
        count:set(count:get() + 1)
        print("New count:", count:get()) -- Always prints the updated value
    end
}
```

### Memory Efficiency

Rex automatically cleans up subscriptions to prevent memory leaks:

```luau
local function Component()
    local data = Rex.useState("hello")
    
    -- This subscription is automatically cleaned up when component unmounts
    local derived = Rex.useComputed(function()
        return data:get():upper()
    end, {data})
    
    return Rex("TextLabel") {
        Text = derived
    }
end

-- When Component is unmounted:
// 1. The computed state is destroyed
// 2. Subscriptions are automatically disconnected
// 3. No memory leaks!
```

## Advanced Reactivity Patterns

### Derived State Chains

Create complex data transformations with automatic dependency tracking:

```luau
local function ShoppingCart()
    local items = Rex.useState({
        {id = 1, name = "Apple", price = 1.50, quantity = 3},
        {id = 2, name = "Banana", price = 0.75, quantity = 5}
    })
    
    -- Each computation automatically depends on the previous ones
    local itemTotals = Rex.useComputed(function()
        return table.map(items:get(), function(item)
            return {...item, total = item.price * item.quantity}
        end)
    end, {items})
    
    local subtotal = Rex.useComputed(function()
        local total = 0
        for _, item in ipairs(itemTotals:get()) do
            total = total + item.total
        end
        return total
    end, {itemTotals})
    
    local tax = Rex.useComputed(function()
        return subtotal:get() * 0.08 -- 8% tax
    end, {subtotal})
    
    local grandTotal = Rex.useComputed(function()
        return subtotal:get() + tax:get()
    end, {subtotal, tax})
    
    return Rex("Frame") {
        children = {
            -- All these labels update automatically when items change
            Rex("TextLabel") {
                Text = subtotal:map(function(amount) return `Subtotal: $${amount:.2f}` end)
            },
            Rex("TextLabel") {
                Text = tax:map(function(amount) return `Tax: $${amount:.2f}` end)
            },
            Rex("TextLabel") {
                Text = grandTotal:map(function(amount) return `Total: $${amount:.2f}` end)
            }
        }
    }
end
```

### Cross-Component Reactivity

Share reactive state across components:

```luau
-- Shared reactive state
local AppState = {
    user = Rex.useState(nil),
    theme = Rex.useState("dark"),
    notifications = Rex.useState({})
}

local function Header()
    return Rex("Frame") {
        BackgroundColor3 = AppState.theme:map(function(theme)
            return theme == "dark" and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(240, 240, 240)
        end),
        children = {
            Rex("TextLabel") {
                Text = AppState.user:map(function(user)
                    return user and `Welcome, ${user.name}!` or "Please log in"
                end),
                TextColor3 = AppState.theme:map(function(theme)
                    return theme == "dark" and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
                end)
            }
        }
    }
end

local function ThemeToggle()
    return Rex("TextButton") {
        Text = AppState.theme:map(function(theme)
            return theme == "dark" and "☀️ Light Mode" or "🌙 Dark Mode"
        end),
        onClick = function()
            AppState.theme:update(function(current)
                return current == "dark" and "light" or "dark"
            end)
        end
    }
end
```

### Async Reactivity

Handle asynchronous operations reactively:

```luau
local function UserProfile(props)
    local userId = props.userId
    
    -- Automatically reload when userId changes
    local userData = Rex.useAsyncState(function()
        return HttpService:GetAsync(`/api/users/${userId}`)
    end, {userId})
    
    return Rex("Frame") {
        children = userData.loading:map(function(isLoading)
            if isLoading then
                return {Rex("TextLabel") {Text = "Loading..."}}
            end
            
            local error = userData.error:get()
            if error then
                return {Rex("TextLabel") {
                    Text = `Error: ${error}`,
                    TextColor3 = Color3.fromRGB(255, 100, 100)
                }}
            end
            
            local user = userData.data:get()
            if user then
                return {
                    Rex("TextLabel") {Text = user.name},
                    Rex("TextLabel") {Text = user.email},
                    Rex("ImageLabel") {Image = user.avatar}
                }
            end
            
            return {}
        end)
    }
end
```

## Reactivity vs Manual Event Handling

### Traditional Event-Driven Updates

```luau
-- ❌ Manual event handling requires coordination
local scoreValue = 0
local scoreLabel = Instance.new("TextLabel")
local levelLabel = Instance.new("TextLabel")
local progressBar = Instance.new("Frame")

local function updateScore(newScore)
    scoreValue = newScore
    scoreLabel.Text = "Score: " .. tostring(scoreValue)
    
    -- Must manually calculate and update level
    local level = math.floor(scoreValue / 1000) + 1
    levelLabel.Text = "Level: " .. tostring(level)
    
    -- Must manually update progress bar
    local progress = (scoreValue % 1000) / 1000
    progressBar.Size = UDim2.new(progress, 0, 1, 0)
end

-- Each system must manually call updateScore
game.Players.PlayerAdded:Connect(function(player)
    updateScore(0) -- Remember to update UI
end)

game.ReplicatedStorage.ScoreChanged:Connect(function(newScore)
    updateScore(newScore) -- Remember to update UI
end)
```

### Rex's Reactive Approach

```luau
-- ✅ Reactive state automatically propagates changes
local score = Rex.useState(0)

-- All computations automatically update when score changes
local level = Rex.useComputed(function()
    return math.floor(score:get() / 1000) + 1
end, {score})

local progress = Rex.useComputed(function()
    return (score:get() % 1000) / 1000
end, {score})

local ui = Rex("Frame") {
    children = {
        Rex("TextLabel") {
            Text = score:map(function(s) return "Score: " .. tostring(s) end)
        },
        Rex("TextLabel") {
            Text = level:map(function(l) return "Level: " .. tostring(l) end)
        },
        Rex("Frame") {
            Size = progress:map(function(p) return UDim2.new(p, 0, 1, 0) end)
        }
    }
}

-- Systems just update the score - UI updates automatically
game.Players.PlayerAdded:Connect(function(player)
    score:set(0) -- All UI updates automatically
end)

game.ReplicatedStorage.ScoreChanged:Connect(function(newScore)
    score:set(newScore) -- All UI updates automatically
end)
```

## Performance Characteristics

### Efficient Change Detection

Rex uses efficient change detection algorithms:

```luau
-- Rex only updates what actually changed
local data = Rex.useState({
    player = {name: "John", level: 5},
    inventory = {coins: 100, items: ["sword", "potion"]},
    settings = {sound: true, graphics: "high"}
})

-- Only the level label updates when level changes
data:update(function(current)
    return {
        ...current,
        player = {...current.player, level = 6}
    }
end)
// Rex detects that only player.level changed
// Only UI elements depending on player.level update
// inventory and settings UI elements are untouched
```

### Subscription Management

Rex efficiently manages subscriptions:

```luau
-- Rex automatically optimizes subscription graphs
local a = Rex.useState(1)
local b = Rex.useComputed(function() return a:get() * 2 end, {a})
local c = Rex.useComputed(function() return b:get() + 1 end, {b})
local d = Rex.useComputed(function() return c:get() * 3 end, {c})

// Subscription chain: a -> b -> c -> d
// When a changes, Rex efficiently propagates through the chain
// No redundant computations or UI updates
```

## Design Trade-offs

### Benefits of Rex's Reactivity

1. **Automatic Synchronization** - UI always reflects application state
2. **Declarative Code** - Describe what UI should look like, not how to update it
3. **Performance** - Only updates what actually changed
4. **Memory Safety** - Automatic cleanup prevents leaks
5. **Developer Experience** - Less boilerplate, fewer bugs

### Considerations

1. **Learning Curve** - Developers must understand reactive patterns
2. **Debugging** - Reactive chains can be harder to debug than imperative code
3. **Overhead** - Small runtime overhead for dependency tracking
4. **Memory Usage** - Additional memory for subscription management

### When to Use Reactive vs Imperative

**Use Rex's Reactivity when:**

- Building complex, interactive UIs
- Working with frequently changing data
- Want automatic UI synchronization
- Building data-driven applications

**Consider imperative approaches when:**

- Building very simple, static UIs
- Performance is extremely critical
- Working with existing imperative codebases
- Need precise control over update timing

Rex's reactivity system provides a powerful foundation for building modern, maintainable UIs while maintaining excellent performance characteristics. By understanding these design principles, developers can leverage Rex's full potential for creating responsive, bug-free user interfaces.
