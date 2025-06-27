---
title: "Rendering & Children API"
description: "API reference for Rex's rendering, children, fragments, and refs."
category: "API Reference"
order: 4
version: "0.2.0"
lastUpdated: 2025-06-27
---

Rex provides a declarative rendering system with support for children, fragments, and refs.

## Rendering Elements

Elements are created using `Rex(className)` syntax:

```luau
local element = Rex("Frame") {
    Size = UDim2.fromScale(1, 1),
    children = {
        Rex("TextLabel") {
            Text = "Hello World"
        }
    }
}
```

## Children

Children can be static, reactive, or mixed:

```luau
children = {
    Rex("TextLabel") { Text = "Header" },
    items:each(function(item, i)
        return ItemComponent { item = item, key = tostring(i) }
    end)
}
```

## Fragments

Group elements without wrapper instances:

```luau
Rex.Fragment {
    children = {
        Rex("Frame") {},
        Rex("TextLabel") {}
    }
}
```

## Refs

Access instances directly:

```luau
local frameRef = Rex.useRef()
Rex("Frame") {
    [Rex.Ref] = frameRef,
    Size = UDim2.fromScale(1, 1)
}
```

## Keyed List Rendering

Use `key` for efficient updates:

```luau
children = items:each(function(item)
    return ItemComponent { item = item, key = item.id }
end)
```
