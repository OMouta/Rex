---
title: "Context API"
description: "API reference for Rex's context system for state sharing."
category: "API Reference"
order: 2
version: "0.2.0"
lastUpdated: 2025-06-27
---

Rex provides a context system for sharing state across component trees without prop drilling.

## `Rex.createContext<T>(defaultValue: T): RexContext<T>`

Creates a new context for sharing state.

**Parameters:**

- `defaultValue: T` — Default value when no provider is found

**Returns:** `RexContext<T>`

**Example:**

```luau
local ThemeContext = Rex.createContext({
    primary = Color3.fromRGB(70, 130, 255),
    background = Color3.fromRGB(30, 30, 40),
    text = Color3.new(1, 1, 1)
})
```

## `Rex.useContext<T>(context: RexContext<T>): T`

Consumes a context value within a component.

**Parameters:**

- `context: RexContext<T>` — The context to consume

**Returns:** `T` — Current context value

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

## `Rex.withContext<T>(context: RexContext<T>, value: T, fn: () -> any): any`

Provides a context value for a function execution.

**Parameters:**

- `context: RexContext<T>` — The context to provide
- `value: T` — The value to provide
- `fn: () -> any` — Function to execute with context

**Returns:** `any` — Result of the function

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
