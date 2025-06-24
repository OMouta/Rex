---
title: "Unified API Design"
description: "Understanding Rex's consistent, declarative approach to UI creation and the principles behind its design."
category: "Design Choices"
order: 1
version: "0.1.0"
lastUpdated: 2025-06-23
---

Rex's unified API design is one of its core strengths, providing a consistent, predictable way to create and manage UI components. This design philosophy draws inspiration from modern web frameworks while adapting to Roblox's unique environment.

## Design Philosophy

### 1. Declarative Over Imperative

Rex encourages describing *what* the UI should look like rather than *how* to create it:

```lua
-- ❌ Imperative approach (traditional Roblox)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = parent

local label = Instance.new("TextLabel")
label.Text = "Hello World"
label.Size = UDim2.new(1, 0, 0, 50)
label.Parent = frame

local button = Instance.new("TextButton")
button.Text = "Click Me"
button.Size = UDim2.new(1, 0, 0, 40)
button.Position = UDim2.new(0, 0, 0, 50)
button.Parent = frame

local connection = button.MouseButton1Click:Connect(function()
    print("Button clicked!")
end)

-- ✅ Declarative approach (Rex)
local ui = Rex("Frame") {
    Size = UDim2.fromOffset(300, 200),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    children = {
        Rex("TextLabel") {
            Text = "Hello World",
            Size = UDim2.new(1, 0, 0, 50)
        },
        Rex("TextButton") {
            Text = "Click Me",
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 50),
            onClick = function()
                print("Button clicked!")
            end
        }
    }
}
```

### 2. Consistency Across All Elements

Every UI element follows the same creation pattern:

```lua
-- All elements use the same syntax
Rex("Frame") { /* properties */ }
Rex("TextLabel") { /* properties */ }
Rex("TextButton") { /* properties */ }
Rex("ScrollingFrame") { /* properties */ }
Rex("ImageLabel") { /* properties */ }

-- This consistency makes the API easy to learn and remember
```

### 3. Property-Driven Configuration

All element configuration happens through a single properties table:

```lua
Rex("TextButton") {
    -- Visual properties
    Text = "Submit",
    Size = UDim2.fromOffset(120, 40),
    BackgroundColor3 = Color3.fromRGB(70, 130, 255),
    TextColor3 = Color3.new(1, 1, 1),
    
    -- Behavior properties
    onClick = handleSubmit,
    onHover = handleHover,
    
    -- Layout properties
    LayoutOrder = 1,
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    
    -- Child elements
    children = {
        Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
        Rex("UIPadding") { PaddingLeft = UDim.new(0, 10) }
    }
}
```

## Event Handling Unification

### Consistent Event Naming

Rex normalizes Roblox's inconsistent event names into a predictable pattern:

```lua
-- Rex unifies event naming with camelCase "on" prefix
Rex("TextButton") {
    onClick = function() end,        -- MouseButton1Click
    onRightClick = function() end,   -- MouseButton2Click
    onHover = function() end,        -- MouseEnter
    onLeave = function() end,        -- MouseLeave
    onActivated = function() end     -- Activated
}

Rex("TextBox") {
    onTextChanged = function() end,  -- Changed (for text)
    onFocus = function() end,        -- Focused
    onFocusLost = function() end     -- FocusLost
}

Rex("ScrollingFrame") {
    onScrolled = function() end      -- Changed (for CanvasPosition)
}
```

### Event Handler Patterns

All event handlers follow consistent patterns:

```lua
-- Simple handlers
onClick = function()
    print("Clicked!")
end

-- Handlers with instance parameter
onTextChanged = function(instance)
    print("Text changed to:", instance.Text)
end

-- Handlers with multiple parameters
onFocusLost = function(instance, enterPressed, inputObject)
    if enterPressed then
        print("User pressed Enter")
    end
end

-- Conditional handlers (reactive)
onClick = isEnabled:map(function(enabled)
    return enabled and function() handleClick() end or nil
end)
```

## Children Management

### Unified Children Syntax

All elements handle children the same way:

```lua
Rex("Frame") {
    children = {
        -- Static children
        Rex("TextLabel") { Text = "Header" },
        
        -- Dynamic children
        items:map(function(itemList)
            local children = {}
            for i, item in ipairs(itemList) do
                table.insert(children, ItemComponent { item = item, key = tostring(i) })
            end
            return children
        end),
        
        -- Conditional children
        showButton and Rex("TextButton") { Text = "Action" } or nil,
        
        -- Layout objects
        Rex("UIListLayout") {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 10)
        }
    }
}
```

### Automatic Cleanup

Rex automatically manages parent-child relationships and cleanup:

```lua
-- No need to manually manage Parent property
-- No need to manually disconnect events
-- No need to manually destroy instances
-- Rex handles all of this automatically when components unmount
```

## Property Binding Unification

### Reactive Properties

Any property can be reactive using the same syntax:

```lua
local isPressed = Rex.useState(false)
local theme = Rex.useState("dark")
local count = Rex.useState(0)

Rex("TextButton") {
    -- Static properties
    Font = Enum.Font.SourceSansBold,
    
    -- Reactive properties (direct state binding)
    Text = count:map(function(c) return "Count: " .. tostring(c) end),
    Size = isPressed:map(function(pressed) 
        return pressed and UDim2.fromOffset(110, 35) or UDim2.fromOffset(120, 40)
    end),
    
    -- Computed reactive properties
    BackgroundColor3 = Rex.useComputed(function()
        local dark = theme:get() == "dark"
        local pressed = isPressed:get()
        
        if dark then
            return pressed and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(50, 50, 70)
        else
            return pressed and Color3.fromRGB(200, 200, 220) or Color3.fromRGB(240, 240, 240)
        end
    end, {theme, isPressed})
}
```

## Error Handling and Validation

### Consistent Error Messages

Rex provides clear, actionable error messages:

```lua
-- ❌ Invalid class name
Rex("InvalidFrameType") { } -- Error: Unknown Roblox class 'InvalidFrameType'

-- ❌ Invalid property
Rex("Frame") {
    InvalidProperty = "value"    -- Error: 'InvalidProperty' is not a valid property of Frame
}

-- ❌ Invalid event
Rex("Frame") {
    onInvalidEvent = function() end  -- Error: 'onInvalidEvent' is not a valid event for Frame
}
```

### Runtime Validation

Rex validates properties and provides helpful feedback:

```lua
-- Rex validates property types at runtime
Rex("Frame") {
    Size = "invalid size"  -- Error: Size must be a UDim2, got string
}

-- Rex validates enum values
Rex("TextLabel") {
    Font = "InvalidFont"   -- Error: Font must be a valid Enum.Font value
}
```

## API Extensibility

### Custom Component Integration

Custom components integrate seamlessly with the unified API:

```lua
local function CustomButton(props)
    return Rex("TextButton") {
        Text = props.text or "Button",
        Size = props.size or UDim2.fromOffset(120, 40),
        BackgroundColor3 = props.color or Color3.fromRGB(70, 130, 255),
        onClick = props.onClick,
        children = props.children
    }
end

-- Use custom components exactly like built-in ones
Rex("Frame") {
    children = {
        CustomButton {
            text = "Save",
            color = Color3.fromRGB(80, 200, 80),
            onClick = handleSave
        },
        CustomButton {
            text = "Cancel",
            color = Color3.fromRGB(200, 80, 80), 
            onClick = handleCancel
        }
    }
}
```

### Higher-Order Components

Create reusable patterns that work with any element:

```lua
local function withTooltip(Component, tooltipText)
    return function(props)
        local showTooltip = Rex.useState(false)
        
        return Rex("Frame") {
            children = {
                Component {
                    ...props,
                    onHover = function()
                        showTooltip:set(true)
                        if props.onHover then props.onHover() end
                    end,
                    onLeave = function()
                        showTooltip:set(false)
                        if props.onLeave then props.onLeave() end
                    end
                },
                showTooltip:map(function(show)
                    return show and Tooltip { text = tooltipText } or nil
                end)
            }
        }
    end
end

-- Apply to any component
local TooltipButton = withTooltip(Rex("TextButton"), "Click to save your changes")
```

## Performance Optimization

### Efficient Updates

Rex's unified API enables smart optimizations:

```lua
-- Rex only updates properties that actually changed
Rex("Frame") {
    BackgroundColor3 = theme:map(function(t) 
        return t == "dark" and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(240, 240, 240)
    end)
}
-- Only updates BackgroundColor3 when theme actually changes

-- Rex batches property updates
Rex.batch(function()
    setTheme("light")
    setFontSize(16)
    setLanguage("en")
end)
-- All UI updates happen in a single frame
```

### Memory Management

The unified API enables automatic resource management:

```lua
-- Rex automatically:
// - Disconnects event connections when components unmount
// - Destroys instances that are no longer needed
// - Cleans up state subscriptions
// - Manages parent-child relationships

// No manual cleanup needed!
```

## Comparison with Traditional Roblox UI

### Traditional Approach Problems

```lua
-- ❌ Traditional Roblox UI code has many issues:

-- 1. Inconsistent patterns
local frame = Instance.new("Frame")
local label = Instance.new("TextLabel")
local button = Instance.new("TextButton")

-- 2. Manual parent management
frame.Parent = playerGui
label.Parent = frame
button.Parent = frame

-- 3. Verbose event handling
local connection1 = button.MouseButton1Click:Connect(function() end)
local connection2 = button.MouseEnter:Connect(function() end)

-- 4. Manual cleanup required
connection1:Disconnect()
connection2:Disconnect()
frame:Destroy()

-- 5. No reactivity
-- Must manually update UI when state changes
local function updateUI()
    label.Text = "Count: " .. tostring(count)
    button.BackgroundColor3 = count > 0 and Color3.green or Color3.red
end
```

### Rex Approach Benefits

```lua
-- ✅ Rex solves all these problems:

-- 1. Consistent patterns
Rex("Frame") { },
Rex("TextLabel") { },
Rex("TextButton") { }

-- 2. Automatic parent management
Rex("Frame") {
    children = {
        Rex("TextLabel") { },  -- Automatically parented
        Rex("TextButton") { }  -- Automatically parented
    }
}

-- 3. Unified event handling
Rex("TextButton") {
    onClick = function() end,
    onHover = function() end
}

-- 4. Automatic cleanup
-- Rex handles all cleanup automatically

-- 5. Built-in reactivity
Rex("TextLabel") {
    Text = count:map(function(c) return "Count: " .. tostring(c) end)
},
Rex("TextButton") {
    BackgroundColor3 = count:map(function(c) 
        return c > 0 and Color3.green or Color3.red 
    end)
}
```

## Design Trade-offs

### Benefits of Unified API

1. **Consistency** - Same patterns everywhere reduce cognitive load
2. **Predictability** - Once you learn one element, you know them all
3. **Maintainability** - Consistent code is easier to modify and debug
4. **Reactivity** - Built-in state binding eliminates manual updates
5. **Automatic Cleanup** - No memory leaks or orphaned connections

### Considerations

1. **Learning Curve** - Developers need to learn Rex's patterns
2. **Abstraction** - Some direct Roblox instance access is abstracted away
3. **Bundle Size** - Rex adds framework overhead (though minimal)

### When to Use Rex vs Traditional

**Use Rex when:**

- Building complex, interactive UIs
- Working with dynamic, reactive data
- Want consistent, maintainable code
- Need automatic cleanup and memory management

**Consider traditional Roblox when:**

- Building very simple, static UIs
- Working with existing large codebases
- Need direct instance manipulation
- Bundle size is extremely critical

Rex's unified API design provides a modern, consistent foundation for building sophisticated Roblox UIs while maintaining the flexibility and performance developers expect.
