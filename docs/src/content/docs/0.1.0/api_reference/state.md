---
title: "State Management API"
description: "Complete API reference for Rex's state management functions including useState, useComputed, useEffect, and advanced state utilities."
category: "API Reference"
order: 1
version: "0.1.0"
lastUpdated: 2025-06-23
---

Rex provides a comprehensive state management system with multiple primitives for different use cases. All state objects are reactive and automatically update UI elements when changed.

## `Rex.useState<T>(initialValue: T): RexState<T>`

Creates a basic reactive state object.

**Parameters:**

- `initialValue: T` - The initial value of the state

**Returns:** `RexState<T>` with methods:

- `get(): T` - Returns the current value
- `set(value: T): ()` - Sets a new value and triggers updates
- `update(updateFn: (current: T) -> T): ()` - Updates value using function
- `onChange(callback: (newValue: T, oldValue: T) -> ()): () -> ()` - Listens for changes, returns disconnect function
- `map<U>(mapFn: (value: T) -> U): U` - Transforms the value for UI binding

**Example:**

```luau
local count = Rex.useState(0)

-- Get current value
local currentCount = count:get() -- 0

-- Set new value
count:set(10)

-- Update based on current value
count:update(function(current) return current + 1 end)

-- Listen for changes
local disconnect = count:onChange(function(newValue, oldValue)
    print(`Count changed from {oldValue} to {newValue}`)
end)

-- Transform for UI
local element = Rex("TextLabel") {
    Text = count:map(function(c) return `Count: {c}` end)
}

-- Clean up listener
disconnect()
```

## `Rex.useDeepState<T>(initialValue: T): RexState<T>`

Creates a deep reactive state for nested objects. Changes to nested properties trigger reactivity.

**Parameters:**

- `initialValue: T` - The initial nested object/table

**Returns:** `RexState<T>` (same interface as `useState`)

**Example:**

```luau
local user = Rex.useDeepState({
    name = "Player",
    stats = {
        level = 1,
        health = 100,
        mana = 50
    },
    inventory = {
        coins = 100,
        items = {"sword", "potion"}
    }
})

-- Deep updates trigger reactivity
user:update(function(current)
    local newUser = table.clone(current)
    newUser.stats.level = current.stats.level + 1
    newUser.stats.health = 100 -- Reset health on level up
    return newUser
end)

-- Bind to nested properties
local healthBar = Rex("Frame") {
    Size = user:map(function(u) 
        local healthPercent = u.stats.health / 100
        return UDim2.new(healthPercent, 0, 1, 0)
    end)
}
```

## `Rex.useComputed<T>(computeFn: () -> T, dependencies: {RexState<any>}, memoKey: string?): RexState<T>`

Creates a computed state that automatically updates when dependencies change.

**Parameters:**

- `computeFn: () -> T` - Function that computes the derived value
- `dependencies: {RexState<any>}` - Array of state dependencies to watch
- `memoKey: string?` - Optional memoization key for performance

**Returns:** `RexState<T>` (read-only - `set` and `update` will warn)

**Example:**

```luau
local firstName = Rex.useState("John")
local lastName = Rex.useState("Doe")

-- Basic computed state
local fullName = Rex.useComputed(function()
    return firstName:get() .. " " .. lastName:get()
end, {firstName, lastName})

-- Memoized expensive computation
local items = Rex.useState({...}) -- Large array
local sortedItems = Rex.useComputed(function()
    local list = items:get()
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end, {items}, "sortedItemsCache")

print(fullName:get()) -- "John Doe"

firstName:set("Jane")
print(fullName:get()) -- "Jane Doe" (automatically updated)
```

## `Rex.useAutoComputed<T>(computeFn: () -> T): RexState<T>`

Creates a computed state with automatic dependency tracking. Dependencies are detected during the first execution.

**Parameters:**

- `computeFn: () -> T` - Function that computes the value (dependencies auto-detected)

**Returns:** `RexState<T>` (read-only)

**Example:**

```luau
local x = Rex.useState(10)
local y = Rex.useState(20)
local z = Rex.useState(30)

-- Dependencies automatically tracked
local sum = Rex.useAutoComputed(function()
    return x:get() + y:get() + z:get() -- x, y, z automatically tracked
end)

print(sum:get()) -- 60

x:set(15)
print(sum:get()) -- 65 (automatically recalculated)
```

## `Rex.useAsyncState<T>(asyncFn: () -> T, dependencies: {RexState<any>}?): AsyncState<T>`

Creates an async state for handling asynchronous operations with loading and error states.

**Parameters:**

- `asyncFn: () -> T` - Async function that returns the data
- `dependencies: {RexState<any>}?` - Optional dependencies that trigger reload

**Returns:** `AsyncState<T>` with properties:

- `data: RexState<T?>` - The loaded data (nil initially)
- `loading: RexState<boolean>` - Loading state
- `error: RexState<string?>` - Error message if operation failed
- `reload: () -> ()` - Function to manually trigger reload

**Example:**

```luau
local userId = Rex.useState(123)

local userData = Rex.useAsyncState(function()
    -- Simulate API call
    wait(1)
    return {
        name = "Player" .. userId:get(),
        level = math.random(1, 50),
        coins = math.random(100, 1000)
    }
end, {userId}) -- Reload when userId changes

-- Use in UI
local userDisplay = Rex("Frame") {
    children = userData.loading:map(function(isLoading)
        if isLoading then
            return { Rex("TextLabel") { Text = "Loading..." } }
        end
        
        local error = userData.error:get()
        if error then
            return { Rex("TextLabel") { 
                Text = `Error: {error}`,
                TextColor3 = Color3.fromRGB(255, 100, 100)
            } }
        end
        
        local data = userData.data:get()
        if data then
            return {
                Rex("TextLabel") { Text = data.name },
                Rex("TextLabel") { Text = `Level {data.level}` },
                Rex("TextLabel") { Text = `{data.coins} coins` }
            }
        end
        
        return {}
    end)
}

-- Manual reload
userData.reload()
```

## `Rex.useEffect(effectFn: (...any) -> ...any, dependencies: {RexState<any>}?): () -> ()`

Runs side effects when dependencies change. Supports cleanup functions.

**Parameters:**

- `effectFn: (...any) -> ...any` - Effect function to run. Can return cleanup function
- `dependencies: {RexState<any>}?` - Dependencies to watch. If nil, runs once

**Returns:** `() -> ()` - Cleanup function

**Example:**

```luau
local count = Rex.useState(0)

-- Effect with dependencies
local cleanupEffect = Rex.useEffect(function()
    print("Count changed to:", count:get())
    
    -- Optional cleanup function
    return function()
        print("Cleaning up count effect")
    end
end, {count})

-- Effect without dependencies (runs once)
local cleanupOnce = Rex.useEffect(function()
    print("Component mounted")
    
    local connection = game:GetService("RunService").Heartbeat:Connect(function()
        -- Do something every frame
    end)
    
    return function()
        connection:Disconnect()
        print("Component unmounted")
    end
end)

-- Clean up manually
cleanupEffect()
cleanupOnce()
```

## `Rex.onMount(callback: () -> (() -> ())?): () -> ()`

Runs a function when component mounts. Shorthand for effect without dependencies.

**Parameters:**

- `callback: () -> (() -> ())?` - Mount callback, can return cleanup function

**Returns:** `() -> ()` - Cleanup function

**Example:**

```luau
local cleanupMount = Rex.onMount(function()
    print("Component mounted!")
    
    -- Setup connections, timers, etc.
    local connection = workspace.ChildAdded:Connect(function(child)
        print("New child added:", child.Name)
    end)
    
    return function()
        connection:Disconnect()
        print("Mount cleanup")
    end
end)
```

## `Rex.onUnmount(callback: () -> ()): () -> ()`

Runs a function when component unmounts.

**Parameters:**

- `callback: () -> ()` - Unmount callback

**Returns:** `() -> ()` - The callback function (for consistency)

**Example:**

```luau
Rex.onUnmount(function()
    print("Component will unmount")
    -- Cleanup resources
end)
```

## `Rex.batch(updateFn: () -> ()): ()`

Batches multiple state updates into a single UI update for performance.

**Parameters:**

- `updateFn: () -> ()` - Function containing multiple state updates

**Example:**

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

## `Rex.useWatch(states: {RexState<any>}, callback: () -> (), options: {immediate: boolean?, deep: boolean?}?): () -> ()`

Watches multiple states and runs callback when any of them change.

**Parameters:**

- `states: {RexState<any>}` - Array of states to watch
- `callback: () -> ()` - Callback to run when states change
- `options: {immediate: boolean?, deep: boolean?}?` - Watch options

**Returns:** `() -> ()` - Disconnect function

**Example:**

```luau
local health = Rex.useState(100)
local mana = Rex.useState(50)
local level = Rex.useState(1)

local disconnect = Rex.useWatch({health, mana, level}, function()
    print("Player stats changed!")
    print(`Health: {health:get()}, Mana: {mana:get()}, Level: {level:get()}`)
    
    -- Update UI, save to server, etc.
end, {immediate = true}) -- Run immediately

-- Stop watching
disconnect()
```

## Context API

### `Rex.createContext<T>(defaultValue: T): RexContext<T>`

Creates a new context for sharing state across components.

**Parameters:**

- `defaultValue: T` - Default value when no provider is found

**Returns:** `RexContext<T>` object

**Example:**

```luau
local ThemeContext = Rex.createContext({
    primary = Color3.fromRGB(70, 130, 255),
    background = Color3.fromRGB(30, 30, 40),
    text = Color3.new(1, 1, 1)
})
```

### `Rex.useContext<T>(context: RexContext<T>): T`

Consumes a context value within a component.

**Parameters:**

- `context: RexContext<T>` - The context to consume

**Returns:** `T` - Current context value

**Example:**

```luau
local function ThemedButton()
    local theme = Rex.useContext(ThemeContext)
    
    return Rex("TextButton") {
        BackgroundColor3 = theme.primary,
        TextColor3 = theme.text
    }
end
```

### `Rex.withContext<T>(context: RexContext<T>, value: T, fn: () -> any): any`

Provides a context value for a function execution.

**Parameters:**

- `context: RexContext<T>` - The context to provide
- `value: T` - The value to provide
- `fn: () -> any` - Function to execute with context

**Returns:** `any` - Result of the function

**Example:**

```luau
local function App()
    local theme = Rex.useState({
        primary = Color3.fromRGB(70, 130, 255),
        background = Color3.fromRGB(30, 30, 40)
    })
    
    return Rex.withContext(ThemeContext, theme:get(), function()
        return MainUI()
    end)
end
```

## Utility Functions

### `Rex.isState(value: any): boolean`

Checks if a value is a valid RexState object.

**Parameters:**

- `value: any` - Value to check

**Returns:** `boolean` - True if value is a state object

**Example:**

```luau
local count = Rex.useState(0)
local number = 42

print(Rex.isState(count))  -- true
print(Rex.isState(number)) -- false
```

## Type Definitions

```luau
export type RexState<T> = {
    get: (self: RexState<T>) -> T,
    set: (self: RexState<T>, value: T) -> (),
    onChange: (self: RexState<T>, callback: (newValue: T, oldValue: T) -> ()) -> () -> (),
    map: (self: RexState<T>, mapFn: (value: T) -> any) -> any,
    update: (self: RexState<T>, updateFn: (current: T) -> T) -> (),
    destroy: ((self: RexState<T>) -> ())?, -- For computed states
}

export type AsyncState<T> = {
    data: RexState<T?>,
    loading: RexState<boolean>,
    error: RexState<string?>,
    reload: () -> (),
}

export type RexContext<T> = {
    defaultValue: T,
    _contextId: string,
}
```
