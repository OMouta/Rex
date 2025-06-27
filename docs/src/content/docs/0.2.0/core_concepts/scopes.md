---
title: "Component Scopes and Custom Hooks"
description: "Creating reusable logic and isolated state scopes in Rex components."
category: "Core Concepts"
order: 2
version: "0.2.0"
lastUpdated: 2025-06-23
---

Component scopes in Rex allow you to create reusable logic patterns and isolate state within specific parts of your application. This is similar to custom hooks in React.

## Understanding Scopes

In Rex, a scope refers to the context in which state and effects are created and managed. Each component function call creates its own scope, ensuring that:

- State is isolated between component instances
- Effects are properly cleaned up when components unmount
- Logic can be encapsulated and reused

## Custom Hooks Pattern

You can create custom "hooks" (reusable functions) that encapsulate stateful logic:

```lua
-- Custom hook for managing a counter
local function useCounter(initialValue)
    local count = Rex.useState(initialValue or 0)
    
    local increment = function()
        count:update(function(current) return current + 1 end)
    end
    
    local decrement = function()
        count:update(function(current) return current - 1 end)
    end
    
    local reset = function()
        count:set(initialValue or 0)
    end
    
    return {
        count = count,
        increment = increment,
        decrement = decrement,
        reset = reset
    }
end

-- Use the custom hook in a component
local function CounterComponent()
    local counter = useCounter(10)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = counter.count:map(function(value)
                    return "Count: " .. tostring(value)
                end)
            },
            Rex("TextButton") {
                Text = "Increment",
                onClick = counter.increment
            },
            Rex("TextButton") {
                Text = "Decrement", 
                onClick = counter.decrement
            },
            Rex("TextButton") {
                Text = "Reset",
                onClick = counter.reset
            }
        }
    }
end
```

## Scoped State Management

Create scoped state managers for complex data:

```lua
-- Custom hook for managing a todo list
local function useTodoList()
    local todos = Rex.useState({})
    local filter = Rex.useState("all") -- "all", "active", "completed"
    
    local addTodo = function(text)
        todos:update(function(current)
            local newTodos = {unpack(current)}
            table.insert(newTodos, {
                id = #newTodos + 1,
                text = text,
                completed = false,
                createdAt = os.time()
            })
            return newTodos
        end)
    end
    
    local toggleTodo = function(id)
        todos:update(function(current)
            local newTodos = {}
            for _, todo in ipairs(current) do
                if todo.id == id then
                    table.insert(newTodos, {
                        id = todo.id,
                        text = todo.text,
                        completed = not todo.completed,
                        createdAt = todo.createdAt
                    })
                else
                    table.insert(newTodos, todo)
                end
            end
            return newTodos
        end)
    end
    
    local removeTodo = function(id)
        todos:update(function(current)
            local newTodos = {}
            for _, todo in ipairs(current) do
                if todo.id ~= id then
                    table.insert(newTodos, todo)
                end
            end
            return newTodos
        end)
    end
    
    -- Computed filtered todos
    local filteredTodos = Rex.useComputed(function()
        local allTodos = todos:get()
        local currentFilter = filter:get()
        
        if currentFilter == "active" then
            local activeTodos = {}
            for _, todo in ipairs(allTodos) do
                if not todo.completed then
                    table.insert(activeTodos, todo)
                end
            end
            return activeTodos
        elseif currentFilter == "completed" then
            local completedTodos = {}
            for _, todo in ipairs(allTodos) do
                if todo.completed then
                    table.insert(completedTodos, todo)
                end
            end
            return completedTodos
        else
            return allTodos
        end
    end, {todos, filter})
    
    return {
        todos = todos,
        filteredTodos = filteredTodos,
        filter = filter,
        addTodo = addTodo,
        toggleTodo = toggleTodo,
        removeTodo = removeTodo,
        setFilter = function(newFilter) filter:set(newFilter) end
    }
end
```

## Scoped Effects and Cleanup

Custom hooks can also manage effects and their cleanup:

```lua
-- Custom hook for managing a timer
local function useTimer(interval, callback)
    local isRunning = Rex.useState(false)
    local timeRemaining = Rex.useState(0)
    
    Rex.useEffect(function()
        if not isRunning:get() then return end
        
        local connection
        local startTime = tick()
        local duration = timeRemaining:get()
        
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            local remaining = math.max(0, duration - elapsed)
            
            timeRemaining:set(remaining)
            
            if remaining <= 0 then
                isRunning:set(false)
                if callback then callback() end
            end
        end)
        
        -- Cleanup function
        return function()
            if connection then
                connection:Disconnect()
            end
        end
    end, {isRunning})
    
    local start = function(duration)
        timeRemaining:set(duration)
        isRunning:set(true)
    end
    
    local stop = function()
        isRunning:set(false)
    end
    
    local reset = function()
        isRunning:set(false)
        timeRemaining:set(0)
    end
    
    return {
        timeRemaining = timeRemaining,
        isRunning = isRunning,
        start = start,
        stop = stop,
        reset = reset
    }
end

-- Using the timer hook
local function TimerComponent()
    local timer = useTimer(5, function()
        print("Timer finished!")
    end)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = timer.timeRemaining:map(function(time)
                    return string.format("Time: %.1fs", time)
                end)
            },
            Rex("TextButton") {
                Text = "Start 5s Timer",
                onClick = function() timer.start(5) end
            },
            Rex("TextButton") {
                Text = "Stop",
                onClick = timer.stop
            }
        }
    }
end
```

## Component Instance Isolation

Each component instance has its own scope, so state doesn't leak between instances:

```lua
local function IndependentCounter()
    local count = Rex.useState(0)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = count:map(function(value)
                    return "Count: " .. tostring(value)
                end)
            },
            Rex("TextButton") {
                Text = "Increment",
                onClick = function()
                    count:update(function(current) return current + 1 end)
                end
            }
        }
    }
end

-- Multiple instances work independently
local function App()
    return Rex("Frame") {
        children = {
            IndependentCounter(), -- Has its own count state
            IndependentCounter(), -- Has its own separate count state
            IndependentCounter()  -- Has its own separate count state
        }
    }
end
```

## Best Practices

### 1. Keep Custom Hooks Focused

Create hooks that handle a single concern or closely related functionality.

### 2. Use Descriptive Names

Prefix custom hooks with "use" to follow convention: `useCounter`, `useApi`, `useLocalStorage`.

### 3. Return Consistent Interfaces

Structure return values consistently across similar hooks.

### 4. Handle Cleanup

Always clean up effects, connections, and resources in custom hooks.

### 5. Consider Dependencies

Be explicit about dependencies in computed states and effects within custom hooks.

## Advanced Patterns

### Provider Pattern with Custom Hooks

```lua
-- Create a context and custom hook for managing global app state
local AppStateContext = Rex.createContext(nil)

local function useAppState()
    local context = Rex.useContext(AppStateContext)
    if not context then
        error("useAppState must be used within AppStateProvider")
    end
    return context
end

local function AppStateProvider(props)
    local user = Rex.useState(nil)
    local theme = Rex.useState("dark")
    local notifications = Rex.useState({})
    
    local addNotification = function(message, type)
        notifications:update(function(current)
            local newNotifications = {unpack(current)}
            table.insert(newNotifications, {
                id = #newNotifications + 1,
                message = message,
                type = type or "info",
                timestamp = os.time()
            })
            return newNotifications
        end)
    end
    
    local removeNotification = function(id)
        notifications:update(function(current)
            local newNotifications = {}
            for _, notification in ipairs(current) do
                if notification.id ~= id then
                    table.insert(newNotifications, notification)
                end
            end
            return newNotifications
        end)
    end
    
    local appState = {
        user = user,
        theme = theme,
        notifications = notifications,
        addNotification = addNotification,
        removeNotification = removeNotification,
        setUser = function(userData) user:set(userData) end,
        setTheme = function(newTheme) theme:set(newTheme) end
    }
    
    return Rex.Provider {
        context = AppStateContext,
        value = appState,
        children = props.children
    }
end
```

This scoping system allows you to build complex, maintainable applications with reusable logic and proper separation of concerns.
