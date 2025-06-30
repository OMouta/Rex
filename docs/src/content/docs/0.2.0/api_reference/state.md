---
title: "State API"
description: "API reference for Rex's state management system with universal reactivity and helpers."
category: "API Reference"
order: 1
version: "0.2.0"
lastUpdated: 2025-06-27
---

Rex provides a comprehensive state management system with universal reactivity. All state objects automatically update UI elements with intelligent type conversion.

## `Rex.useState<T>(initialValue: T): RexState<T>`

Creates a basic reactive state object with helper methods.

**Parameters:**

- `initialValue: T` — The initial value of the state

**Returns:** `RexState<T>` with methods:

### Core Methods

- `get(): T` — Returns the current value
- `set(value: T): ()` — Sets a new value and triggers updates
- `update(updateFn: (current: T) -> T): ()` — Updates value using function
- `onChange(callback: (newValue: T, oldValue: T) -> ()): () -> ()` — Listens for changes, returns disconnect function
- `map<U>(mapFn: (value: T) -> U): U` — Transforms the value for UI binding
- `each(mapFn: (item: any, index: number) -> any): any` — Maps over array items for list rendering

### Numeric State Helpers

- `increment(amount?: number): ()` — Adds 1 or specified amount to numeric state
- `decrement(amount?: number): ()` — Subtracts 1 or specified amount from numeric state

### Boolean State Helpers  

- `toggle(): ()` — Flips boolean state value

### Array State Helpers

- `push(...items: any[]): ()` — Adds one or more items to the end of array
- `pop(): any` — Removes and returns the last item from array
- `removeAt(index: number): ()` — Removes item at specified index
- `remove(value: any): ()` — Removes first occurrence of value
- `clear(): ()` — Removes all items from array
- `each(mapFn: (item: any, index: number) -> any): any` — Maps over array items for reactive list rendering

### Object State Helpers

- `setPath(path: string, value: any): ()` — Sets nested property using dot notation
- `getPath(path: string): any` — Gets nested property using dot notation

**Array Example:**

```luau
local items = Rex.useState({"apple", "banana"})

-- Enhanced array helpers
items:push("cherry")           -- ["apple", "banana", "cherry"]
items:push("date", "elderberry") -- Add multiple
local last = items:pop()       -- Returns "elderberry", array: ["apple", "banana", "cherry", "date"]
items:removeAt(2)             -- Remove index 2: ["apple", "cherry", "date"] 
items:remove("cherry")        -- Remove by value: ["apple", "date"]
items:clear()                 -- []

-- Enhanced list rendering with :each()
local listUI = Rex("ScrollingFrame") {
    children = {
        Rex("UIListLayout") {},
        items:each(function(item, index)  -- Simplified syntax for reactive lists!
            return Rex("TextLabel") {
                Text = `{index}: {item}`,
                key = item -- Important: Use keys for efficient reconciliation
            }
        end)
    }
}
```

**Advanced List Rendering with :each():**

```luau
local todos = Rex.useState({
    {id = 1, text = "Learn Rex", completed = false},
    {id = 2, text = "Build UI", completed = true}
})

-- Complex list rendering with reactive properties
Rex("ScrollingFrame") {
    children = {
        Rex("UIListLayout") {},
        todos:each(function(todo, index)
            return Rex("Frame") {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = todo.completed 
                    and Color3.fromRGB(100, 255, 100)  -- Green for completed
                    or Color3.fromRGB(255, 255, 255),  -- White for pending
                key = tostring(todo.id), -- Use stable ID as key
                
                children = {
                    Rex("TextLabel") {
                        Text = todo.text,
                        TextStrikethrough = todo.completed
                    },
                    Rex("TextButton") {
                        Text = "✓",
                        onClick = function()
                            todos:update(function(currentTodos)
                                local newTodos = table.clone(currentTodos)
                                newTodos[index].completed = not newTodos[index].completed
                                return newTodos
                            end)
                        end
                    }
                }
            }
        end)
    }
}
```

- `getPath(path: string): any` — Gets nested property using dot notation

**Example:**

```luau
local count = Rex.useState(0)

-- Get current value
local currentCount = count:get() -- 0

-- Enhanced helpers
count:increment()        -- count is now 1
count:increment(5)       -- count is now 6  
count:decrement()        -- count is now 5

-- Set new value
count:set(10)

-- Update based on current value
count:update(function(current) return current + 1 end)

-- Universal reactive binding
local element = Rex("TextLabel") {
    Text = count -- Automatically converts number to string!
}
```

**Array State Example:**

```luau
local items = Rex.useState({"apple", "banana"})

-- Enhanced array helpers
items:push("cherry")           -- ["apple", "banana", "cherry"]
items:push("date", "elderberry") -- Add multiple
local last = items:pop()       -- Returns "elderberry", array: ["apple", "banana", "cherry", "date"]
items:removeAt(2)             -- Remove index 2: ["apple", "cherry", "date"] 
items:remove("cherry")        -- Remove by value: ["apple", "date"]
items:clear()                 -- []

-- Enhanced list rendering
local listUI = Rex("ScrollingFrame") {
    children = {
        Rex("UIListLayout") {},
        items:each(function(item, index)  -- Simplified syntax!
            return Rex("TextLabel") {
                Text = item,
                key = item -- Automatic reconciliation
            }
        end)
    }
}
```

**Object Path Example:**

```luau
local user = Rex.useState({
    name = "Player",
    settings = { theme = "dark", volume = 0.8 }
})

-- Enhanced path operations
user:setPath("settings.theme", "light")     -- Deep property setting
user:setPath("settings.volume", 0.5)

local theme = user:getPath("settings.theme")   -- Returns "light"
local volume = user:getPath("settings.volume") -- Returns 0.5
```

## `Rex.useDeepState<T>(initialValue: T): RexState<T>`

Creates a deep reactive state for nested objects. Changes to nested properties trigger reactivity.

**Parameters:**

- `initialValue: T` — The initial nested object/table

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

- `computeFn: () -> T` — Function that computes the derived value
- `dependencies: {RexState<any>}` — Array of state dependencies to watch
- `memoKey: string?` — Optional memoization key

**Returns:** `RexState<T>` (read-only)

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

Creates a computed state with automatic dependency tracking.

**Parameters:**

- `computeFn: () -> T` — Function that computes the value

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

- `asyncFn: () -> T` — Async function that returns the data
- `dependencies: {RexState<any>}?` — Optional dependencies that trigger reload

**Returns:** `AsyncState<T>`

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

## `Rex.batch(updateFn: () -> ()): ()`

Batches multiple state updates into a single UI update for performance.

**Parameters:**

- `updateFn: () -> ()` — Function containing multiple state updates

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
