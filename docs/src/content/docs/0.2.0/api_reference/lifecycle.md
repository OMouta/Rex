---
title: "Lifecycle & Effects API"
description: "API reference for Rex's lifecycle hooks and effect system."
category: "API Reference"
order: 3
version: "0.2.0"
lastUpdated: 2025-06-27
---

Rex provides lifecycle hooks and effect utilities for running side effects and managing component mount/unmount logic.

## `Rex.useEffect(effectFn: (...any) -> ...any, dependencies: {RexState<any>}?): () -> ()`

Runs side effects when dependencies change. Supports cleanup functions.

**Parameters:**

- `effectFn: (...any) -> ...any` — Effect function to run. Can return cleanup function
- `dependencies: {RexState<any>}?` — Dependencies to watch. If nil, runs once

**Returns:** `() -> ()` — Cleanup function

**Example:**

```luau
local count = Rex.useState(0)
Rex.useEffect(function()
    print("Count changed to:", count:get())
    return function()
        print("Cleaning up count effect")
    end
end, {count})
```

## `Rex.onMount(callback: () -> (() -> ())?): () -> ()`

Runs a function when component mounts. Shorthand for effect without dependencies.

**Parameters:**

- `callback: () -> (() -> ())?` — Mount callback, can return cleanup function

**Returns:** `() -> ()` — Cleanup function

**Example:**

```luau
Rex.onMount(function()
    print("Component mounted!")
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

- `callback: () -> ()` — Unmount callback

**Returns:** `() -> ()` — The callback function (for consistency)

**Example:**

```luau
Rex.onUnmount(function()
    print("Component will unmount")
end)
```

## `Rex.useWatch(states: {RexState<any>}, callback: () -> (), options: {immediate: boolean?, deep: boolean?}?): () -> ()`

Watches multiple states and runs callback when any of them change.

**Parameters:**

- `states: {RexState<any>}` — Array of states to watch
- `callback: () -> ()` — Callback to run when states change
- `options: {immediate: boolean?, deep: boolean?}?` — Watch options

**Returns:** `() -> ()` — Disconnect function

**Example:**

```luau
local health = Rex.useState(100)
local mana = Rex.useState(50)
local level = Rex.useState(1)
Rex.useWatch({health, mana, level}, function()
    print("Player stats changed!")
end, {immediate = true})
```
