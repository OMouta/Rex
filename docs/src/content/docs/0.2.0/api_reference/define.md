---
title: "Rex.define API"
description: "API reference for wrapping and enhancing existing Roblox UI instances with Rex functionality."
category: "API Reference"
order: 5
version: "0.2.0"
lastUpdated: 2025-06-29
---

The `Rex.define()` function allows you to wrap existing Roblox UI instances with Rex's reactive functionality, enabling incremental migration from traditional UI to Rex-powered reactive UI.

## `Rex.define(instance: Instance | string): (props?: RexProps) -> RexElement`

Wraps an existing Roblox Instance with Rex functionality, allowing you to add reactive properties, event handlers, and children management.

**Parameters:**

- `instance: Instance | string` — The Roblox Instance to wrap, or a string name to find a child by name

**Returns:** Function that accepts props and returns a wrapped RexElement

**Usage:**

```luau
-- Direct instance reference
local enhancedFrame = Rex.define(existingFrame) {
    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
    onClick = function() print("Clicked!") end
}

-- String name reference (finds child in parent context)
Rex.define("ChildButton") {
    Text = "Enhanced Button",
    onClick = handleClick
}
```

## Property Override

Any properties specified in props will override the existing instance properties while preserving unspecified properties:

```luau
Rex.define(studioButton) {
    -- Override Studio-set properties
    BackgroundColor3 = Color3.fromRGB(100, 150, 255),
    Text = "New Text",
    
    -- Add reactive properties
    TextColor3 = isEnabled:map(function(enabled)
        return enabled and Color3.new(1, 1, 1) or Color3.new(0.5, 0.5, 0.5)
    end)
}
```

## Event Attachment

Add Rex event handlers to existing instances using the same event system as regular Rex elements:

```luau
Rex.define(existingButton) {
    onClick = function() playerScore:increment() end,
    onHover = function() setHovered(true) end,
    onLeave = function() setHovered(false) end
}
```

## Children Management

Define children as a mix of existing child references and new Rex components:

```luau
Rex.define(parentFrame) {
    children = {
        -- Reference existing children by name
        Rex.define("ExistingLabel") {
            Text = dynamicText,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        },
        
        -- Add new Rex components
        Rex("TextButton") {
            Text = "New Button",
            Size = UDim2.fromScale(1, 0.2),
            onClick = handleNewAction
        }
    }
}
```

## Instance Resolution

### Direct Instance References

When passing an Instance directly, Rex.define will use it immediately:

```luau
local myFrame = workspace.UI.MainFrame
Rex.define(myFrame) { BackgroundColor3 = Color3.new(1, 0, 0) }
```

### String Name Resolution

When passing a string, Rex.define will find the child within the parent context:

```luau
Rex.define(parentFrame) {
    children = {
        Rex.define("ButtonChild") { -- Looks for parentFrame:FindFirstChild("ButtonChild")
            onClick = handleClick
        }
    }
}
```

## Compatibility

### Preserve Existing Properties

Only specified properties are overridden; all other properties remain unchanged:

```luau
-- If button originally had: Text="Original", Size=UDim2.fromOffset(100,50)
Rex.define(button) {
    BackgroundColor3 = Color3.new(1, 0, 0) -- Only this changes
    -- Text and Size remain "Original" and UDim2.fromOffset(100,50)
}
```

### Reparenting Behavior

Rex.define avoids unnecessary reparenting. If the instance already has the correct parent, it won't be moved:

```luau
-- ✅ Good - no reparenting needed
Rex.define(frameAlreadyInCorrectParent) { ... }

-- ⚠️ Warning - will reparent if necessary but issues warning
Rex("ScreenGui") {
    children = {
        Rex.define(frameFromDifferentParent) { ... }
    }
}
```

## Error Handling

Rex.define provides helpful error messages for common issues:

- **Missing child**: Clear error with available child names
- **Invalid instance type**: Type validation with suggestions
- **No parent context**: Guidance for string name resolution

```luau
-- Error: Child "MissingButton" not found in parent "MainFrame"
-- Available children: Title, Content, Footer
Rex.define("MissingButton") { ... }
```

## Performance Considerations

- **Reconciliation**: Defined elements participate in Rex's efficient diffing system
- **Reactive bindings**: Only reactive properties create subscriptions
- **Memory management**: Automatic cleanup when elements are destroyed

## Examples

### Basic Enhancement

```luau
-- Enhance a Studio-created button with reactive behavior
local enhancedButton = Rex.define(studioButton) {
    Text = buttonText, -- Reactive state
    BackgroundColor3 = isPressed:map(function(pressed)
        return pressed and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(100, 150, 255)
    end),
    onClick = function()
        isPressed:toggle()
        onButtonClick()
    end
}
```

### Complex UI Enhancement

```luau
local function EnhancedDialog()
    local isVisible = Rex.useState(true)
    local message = Rex.useState("Hello!")
    
    return Rex.define(dialogFrame) {
        Visible = isVisible,
        children = {
            Rex.define("TitleLabel") {
                Text = "Enhanced Dialog"
            },
            Rex.define("MessageLabel") {
                Text = message
            },
            Rex.define("CloseButton") {
                onClick = function()
                    isVisible:set(false)
                end
            }
        }
    }
end
```
