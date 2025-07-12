---
title: "Rendering & Children API"
description: "API reference for Rex's rendering, children, fragments, and refs."
category: "API Reference"
order: 4

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

Children define the nested elements within a Rex component. They can be static, reactive, or mixed:

### Static Children

```luau
children = {
    Rex("TextLabel") { Text = "Header" },
    Rex("Frame") { Size = UDim2.fromScale(1, 0.5) },
    Rex("TextButton") { Text = "Click Me" }
}
```

### Reactive Children with `:each()`

The `:each()` method provides a clean syntax for rendering lists from array state:

```luau
local items = Rex.useState({"Apple", "Banana", "Cherry"})

children = {
    Rex("UIListLayout") {},
    items:each(function(item, index)
        return Rex("TextLabel") {
            Text = `{index}: {item}`,
            key = item, -- Important for efficient updates
            LayoutOrder = index
        }
    end)
}
```

### Mixed Static and Reactive Children

```luau
children = {
    Rex("TextLabel") { Text = "Shopping List" }, -- Static header
    items:each(function(item, index)             -- Dynamic list items
        return ItemComponent { item = item, key = item.id }
    end),
    Rex("TextButton") { Text = "Add Item" }      -- Static footer
}
```

### Advanced List Rendering

For complex interactive lists with state management:

```luau
local todos = Rex.useState({
    {id = 1, text = "Learn Rex", done = false},
    {id = 2, text = "Build App", done = true}
})

children = {
    Rex("UIListLayout") { Padding = UDim.new(0, 5) },
    todos:each(function(todo, index)
        return Rex("Frame") {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = todo.done 
                and Color3.fromRGB(100, 255, 100)
                or Color3.fromRGB(255, 255, 255),
            key = tostring(todo.id), -- Use stable IDs as keys
            
            children = {
                Rex("TextLabel") {
                    Text = todo.text,
                    Size = UDim2.new(0.8, 0, 1, 0),
                    TextStrikethrough = todo.done
                },
                Rex("TextButton") {
                    Text = todo.done and "↶" or "✓",
                    Size = UDim2.new(0..3, 0, 1, 0),
                    onClick = function()
                        todos:update(function(currentTodos)
                            local newTodos = table.clone(currentTodos)
                            newTodos[index].done = not newTodos[index].done
                            return newTodos
                        end)
                    end
                }
            }
        }
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

Keys are essential for efficient list updates and animations. Rex uses keys to determine which elements to create, update, or remove when lists change.

### Why Keys Matter

```luau
-- ❌ Without keys - inefficient, may cause issues
items:each(function(item, index)
    return ItemComponent { item = item }
end)

-- ✅ With keys - efficient reconciliation
items:each(function(item, index)
    return ItemComponent { 
        item = item, 
        key = item.id -- Use stable, unique identifier
    }
end)
```

### Key Selection Best Practices

```luau
-- ✅ Good - stable unique IDs
todos:each(function(todo, index)
    return TodoItem { 
        todo = todo, 
        key = tostring(todo.id) -- Database ID, UUID, etc.
    }
end)

-- ✅ Acceptable - content-based keys for simple data
fruits:each(function(fruit, index)
    return FruitItem { 
        fruit = fruit, 
        key = fruit -- If fruit names are unique
    }
end)

-- ❌ Avoid - index as key (breaks on reordering)
items:each(function(item, index)
    return ItemComponent { 
        item = item, 
        key = tostring(index) -- Don't use index!
    }
end)
```

### Performance Benefits

With proper keys, Rex can:

- Reuse existing elements when items move
- Preserve component state during reordering
- Optimize animations and transitions
- Minimize unnecessary re-renders
