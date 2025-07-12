---
title: "Type Definitions"
description: "Type definitions and utility functions for Rex."
category: "API Reference"
order: 5

lastUpdated: 2025-06-27
---

## Type Definitions

```luau
export type RexState<T> = {
    get: (self: RexState<T>) -> T,
    set: (self: RexState<T>, value: T) -> (),
    onChange: (self: RexState<T>, callback: (newValue: T, oldValue: T) -> ()) -> () -> (),
    map: (self: RexState<T>, mapFn: (value: T) -> any) -> any,
    update: (self: RexState<T>, updateFn: (current: T) -> T) -> (),
    destroy: ((self: RexState<T>) -> ())?,
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

## Utility Functions

### `Rex.isState(value: any): boolean`

Checks if a value is a valid RexState object.

**Parameters:**

- `value: any` — Value to check

**Returns:** `boolean` — True if value is a state object

**Example:**

```luau
local count = Rex.useState(0)
print(Rex.isState(count))  -- true
```
