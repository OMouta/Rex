---
title: "Lifecycle Hooks"
description: "Managing component lifecycle events and side effects with Rex hooks."
category: "Core Concepts"
order: 5
version: "0.1.0"
lastUpdated: 2025-06-23
---

Lifecycle hooks in Rex allow you to run logic at specific points in a component's lifecycle. They provide a way to handle side effects, cleanup resources, and respond to component state changes.

## Understanding Component Lifecycle

Rex components go through several phases:

1. **Mount**: Component is created and added to the UI
2. **Update**: Component re-renders due to state or prop changes
3. **Unmount**: Component is removed from the UI

## Core Lifecycle Hooks

### `Rex.onMount`

Runs logic when a component mounts. This is ideal for initialization tasks, setting up subscriptions, or fetching initial data.

```lua
local function DataComponent()
    local data = Rex.useState(nil)
    local loading = Rex.useState(true)
    
    Rex.onMount(function()
        print("Component mounted, fetching data...")
        
        -- Simulate data fetching
        task.spawn(function()
            task.wait(2) -- Simulate network delay
            data:set({ message = "Hello from API!" })
            loading:set(false)
        end)
        
        -- Optional: Return cleanup function
        return function()
            print("Component unmounting, cleaning up...")
        end
    end)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = loading:map(function(isLoading)
                    return isLoading and "Loading..." or data:get().message
                end)
            }
        }
    }
end
```

### `Rex.onUnmount`

Runs cleanup logic when a component unmounts. Use this to disconnect events, cancel ongoing operations, or clean up resources.

```lua
local function TimerComponent()
    local seconds = Rex.useState(0)
    local connection = nil
    
    Rex.onMount(function()
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            seconds:update(function(current) return current + 1 end)
        end)
    end)
    
    Rex.onUnmount(function()
        if connection then
            connection:Disconnect()
            print("Timer disconnected")
        end
    end)
    
    return Rex("TextLabel") {
        Text = seconds:map(function(s) return "Seconds: " .. tostring(s) end)
    }
end
```

## Effect Hook: `Rex.useEffect`

The most powerful lifecycle hook, `useEffect` allows you to run side effects and specify exactly when they should run using dependencies.

### Basic Usage

```lua
local function EffectExample()
    local count = Rex.useState(0)
    local message = Rex.useState("")
    
    -- Effect runs after every render
    Rex.useEffect(function()
        print("Component rendered, count is:", count:get())
    end)
    
    -- Effect with dependencies - only runs when count changes
    Rex.useEffect(function()
        message:set("Count is " .. tostring(count:get()))
    end, {count})
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = message
            },
            Rex("TextButton") {
                Text = "Increment",
                onClick = function()
                    count:update(function(c) return c + 1 end)
                end
            }
        }
    }
end
```

### Effect with Cleanup

```lua
local function WindowResizeListener()
    local windowSize = Rex.useState(workspace.CurrentCamera.ViewportSize)
    
    Rex.useEffect(function()
        local connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            windowSize:set(workspace.CurrentCamera.ViewportSize)
        end)
        
        -- Cleanup function
        return function()
            connection:Disconnect()
        end
    end, {}) -- Empty dependency array means this effect only runs once on mount
    
    return Rex("TextLabel") {
        Text = windowSize:map(function(size)
            return string.format("Window: %.0f x %.0f", size.X, size.Y)
        end)
    }
end
```

### Conditional Effects

```lua
local function ConditionalEffect()
    local userId = Rex.useState(nil)
    local userData = Rex.useState(nil)
    local loading = Rex.useState(false)
    
    -- Effect only runs when userId changes and is not nil
    Rex.useEffect(function()
        local currentUserId = userId:get()
        if not currentUserId then
            userData:set(nil)
            return
        end
        
        loading:set(true)
        
        -- Simulate API call
        task.spawn(function()
            task.wait(1)
            userData:set({
                id = currentUserId,
                name = "User " .. tostring(currentUserId),
                email = "user" .. tostring(currentUserId) .. "@example.com"
            })
            loading:set(false)
        end)
    end, {userId})
    
    return Rex("Frame") {
        children = {
            Rex("TextBox") {
                PlaceholderText = "Enter User ID",
                onTextChanged = function(textBox)
                    local id = tonumber(textBox.Text)
                    userId:set(id)
                end
            },
            Rex("TextLabel") {
                Text = Rex.useComputed(function()
                    if loading:get() then
                        return "Loading user data..."
                    elseif userData:get() then
                        local user = userData:get()
                        return string.format("Name: %s\nEmail: %s", user.name, user.email)
                    else
                        return "No user selected"
                    end
                end, {loading, userData})
            }
        }
    }
end
```

## Advanced Patterns

### Multiple Effects

You can use multiple effects in a single component for different concerns:

```lua
local function MultiEffectComponent()
    local data = Rex.useState(nil)
    local theme = Rex.useState("dark")
    local windowFocused = Rex.useState(true)
    
    -- Effect for data fetching
    Rex.useEffect(function()
        print("Fetching data...")
        -- Data fetching logic
    end, {})
    
    -- Effect for theme changes
    Rex.useEffect(function()
        print("Theme changed to:", theme:get())
        -- Apply theme changes
    end, {theme})
    
    -- Effect for window focus tracking
    Rex.useEffect(function()
        local focusConnection = game:GetService("UserInputService").WindowFocused:Connect(function()
            windowFocused:set(true)
        end)
        
        local blurConnection = game:GetService("UserInputService").WindowFocusReleased:Connect(function()
            windowFocused:set(false)
        end)
        
        return function()
            focusConnection:Disconnect()
            blurConnection:Disconnect()
        end
    end, {})
    
    return Rex("Frame") {
        BackgroundColor3 = Rex.useComputed(function()
            local isDark = theme:get() == "dark"
            local isFocused = windowFocused:get()
            
            if isDark then
                return isFocused and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
            else
                return isFocused and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(200, 200, 200)
            end
        end, {theme, windowFocused})
    }
end
```

### Effect Dependencies Best Practices

```lua
local function DependencyExample()
    local count = Rex.useState(0)
    local multiplier = Rex.useState(1)
    local result = Rex.useState(0)
    
    -- ❌ Bad: Missing dependencies
    Rex.useEffect(function()
        result:set(count:get() * multiplier:get()) -- Uses both count and multiplier
    end, {count}) -- Missing multiplier dependency!
    
    -- ✅ Good: All dependencies included
    Rex.useEffect(function()
        result:set(count:get() * multiplier:get())
    end, {count, multiplier})
    
    -- ✅ Alternative: Use computed state for derived values
    local computedResult = Rex.useComputed(function()
        return count:get() * multiplier:get()
    end, {count, multiplier})
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = result:map(function(r) return "Result: " .. tostring(r) end)
            }
        }
    }
end
```

## Common Use Cases

### 1. API Data Fetching

```lua
local function UserProfile(props)
    local user = Rex.useState(nil)
    local loading = Rex.useState(true)
    local error = Rex.useState(nil)
    
    Rex.useEffect(function()
        loading:set(true)
        error:set(nil)
        
        -- Simulate API call
        task.spawn(function()
            local success, result = pcall(function()
                -- Your API call here
                task.wait(1) -- Simulate network delay
                return {
                    id = props.userId,
                    name = "John Doe",
                    avatar = "rbxasset://textures/face.png"
                }
            end)
            
            if success then
                user:set(result)
            else
                error:set("Failed to load user")
            end
            loading:set(false)
        end)
    end, {props.userId}) -- Re-fetch when userId changes
    
    return Rex("Frame") {
        children = {
            loading:map(function(isLoading)
                if isLoading then
                    return Rex("TextLabel") { Text = "Loading..." }
                elseif error:get() then
                    return Rex("TextLabel") { 
                        Text = error:get(),
                        TextColor3 = Color3.fromRGB(255, 100, 100)
                    }
                else
                    local userData = user:get()
                    return Rex("TextLabel") { 
                        Text = "Hello, " .. userData.name 
                    }
                end
            end)
        }
    }
end
```

### 2. Event Subscriptions

```lua
local function PlayerJoinTracker()
    local playersOnline = Rex.useState({})
    
    Rex.useEffect(function()
        local players = game:GetService("Players")
        
        local function updatePlayerList()
            local playerList = {}
            for _, player in ipairs(players:GetPlayers()) do
                table.insert(playerList, player.Name)
            end
            playersOnline:set(playerList)
        end
        
        -- Initial update
        updatePlayerList()
        
        -- Set up event listeners
        local joinConnection = players.PlayerAdded:Connect(updatePlayerList)
        local leaveConnection = players.PlayerRemoving:Connect(updatePlayerList)
        
        -- Cleanup
        return function()
            joinConnection:Disconnect()
            leaveConnection:Disconnect()
        end
    end, {}) -- No dependencies - only run once
    
    return Rex("ScrollingFrame") {
        children = {
            playersOnline:map(function(players)
                local children = {}
                for i, playerName in ipairs(players) do
                    table.insert(children, Rex("TextLabel") {
                        Text = playerName,
                        key = playerName
                    })
                end
                return children
            end)
        }
    }
end
```

### 3. Timer and Intervals

```lua
local function CountdownTimer(props)
    local timeLeft = Rex.useState(props.duration or 60)
    local isActive = Rex.useState(false)
    
    Rex.useEffect(function()
        if not isActive:get() or timeLeft:get() <= 0 then
            return
        end
        
        local connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            timeLeft:update(function(current)
                local newTime = math.max(0, current - deltaTime)
                if newTime <= 0 and props.onComplete then
                    props.onComplete()
                end
                return newTime
            end)
        end)
        
        return function()
            connection:Disconnect()
        end
    end, {isActive, timeLeft})
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = timeLeft:map(function(time)
                    return string.format("Time: %.1fs", time)
                end)
            },
            Rex("TextButton") {
                Text = isActive:map(function(active)
                    return active and "Pause" or "Start"
                end),
                onClick = function()
                    isActive:update(function(current) return not current end)
                end
            }
        }
    }
end
```

## Best Practices

### 1. Keep Effects Focused

Each effect should handle a single concern. Split complex logic into multiple effects.

### 2. Always Clean Up

If an effect creates connections, subscriptions, or timers, always clean them up in the return function.

### 3. Be Careful with Dependencies

Include all variables from component scope that are used inside the effect in the dependency array.

### 4. Use Empty Dependencies Sparingly

Effects with empty dependency arrays (`{}`) only run once on mount. Use them for initialization that should happen only once.

### 5. Prefer Computed State for Derived Values

If you're just calculating a new value based on existing state, consider using `Rex.useComputed` instead of `useEffect`.

```lua
-- ❌ Avoid: Using effect for simple derived state
Rex.useEffect(function()
    fullName:set(firstName:get() .. " " .. lastName:get())
end, {firstName, lastName})

-- ✅ Prefer: Using computed state
local fullName = Rex.useComputed(function()
    return firstName:get() .. " " .. lastName:get()
end, {firstName, lastName})
```

Lifecycle hooks are essential for building interactive, responsive applications with Rex. They provide the foundation for handling side effects while maintaining the declarative nature of your components.
