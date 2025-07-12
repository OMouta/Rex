---
title: "Event Handling"
description: "Learn how to handle user interactions in Rex with unified camelCase event system for buttons, text inputs, and other UI elements."
category: "Core Concepts"
order: 2

lastUpdated: 2025-07-13
---

Rex provides a unified, intuitive event handling system that uses camelCase naming conventions familiar to web developers. Instead of remembering Roblox's specific event names, you can use consistent, predictable event handlers.

## Basic Event Handling

Events are passed as props to Rex elements using camelCase naming:

```luau
Rex("TextButton") {
    Text = "Click me!",
    Size = UDim2.fromOffset(100, 40),
    onClick = function()
        print("Button was clicked!")
    end
}
```

## Common Event Types

### Click Events

```luau
Rex("TextButton") {
    Text = "Interactive Button",
    
    -- Left click (most common)
    onClick = function()
        print("Left clicked!")
    end,
    
    -- Right click
    onRightClick = function()
        print("Right clicked!")
    end,
    
    -- Generic activation (Enter key, etc.)
    onActivated = function()
        print("Button activated!")
    end
}
```

### Hover Events

```luau
local function HoverButton()
    local isHovered = Rex.useState(false)
    
    return Rex("TextButton") {
        Text = "Hover me!",
        BackgroundColor3 = isHovered:map(function(hovered)
            return hovered and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(70, 130, 255)
        end),
        
        onHover = function()
            isHovered:set(true)
            print("Mouse entered!")
        end,
        
        onLeave = function()
            isHovered:set(false)
            print("Mouse left!")
        end
    }
end
```

### Focus Events

```luau
Rex("TextBox") {
    PlaceholderText = "Enter your name...",
    
    onFocus = function()
        print("TextBox gained focus")
    end,
    
    onBlur = function(instance, enterPressed, inputObject)
        print("TextBox lost focus")
        print("Enter was pressed:", enterPressed)
    end,
    
    -- Alternative name for onBlur
    onFocusLost = function(instance, enterPressed, inputObject)
        print("Same as onBlur")
    end
}
```

### Text Input Events

```luau
local function SearchBox()
    local searchText = Rex.useState("")
    
    return Rex("TextBox") {
        PlaceholderText = "Search...",
        Text = searchText,
        
        onTextChanged = function(instance)
            searchText:set(instance.Text)
            print("Search text:", instance.Text)
        end,
        
        onFocusLost = function(instance, enterPressed)
            if enterPressed then
                print("Search submitted:", searchText:get())
            end
        end
    end
end
```

## Event Handler Patterns

### State Updates in Events

```luau
local function Counter()
    local count = Rex.useState(0)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = count:map(function(c) return `Count: {c}` end)
            },
            Rex("TextButton") {
                Text = "+",
                onClick = function()
                    count:update(function(current) return current + 1 end)
                end
            },
            Rex("TextButton") {
                Text = "-",
                onClick = function()
                    count:update(function(current) return math.max(0, current - 1) end)
                end
            },
            Rex("TextButton") {
                Text = "Reset",
                onClick = function()
                    count:set(0)
                end
            }
        }
    end
end
```

### Conditional Event Handlers

```luau
local function ConditionalButton()
    local isEnabled = Rex.useState(true)
    local clickCount = Rex.useState(0)
    
    return Rex("TextButton") {
        Text = isEnabled:map(function(enabled) 
            return enabled and "Click me!" or "Disabled"
        end),
        
        BackgroundColor3 = isEnabled:map(function(enabled)
            return enabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(100, 100, 100)
        end),
        
        -- Conditional event handler
        onClick = isEnabled:map(function(enabled)
            return enabled and function()
                clickCount:update(function(count) return count + 1 end)
                
                -- Disable after 5 clicks
                if clickCount:get() >= 5 then
                    isEnabled:set(false)
                end
            end or nil
        end)
    end
end
```

### Event Handler with Cleanup

```luau
local function TimerButton()
    local isRunning = Rex.useState(false)
    local timeLeft = Rex.useState(10)
    
    Rex.useEffect(function()
        if not isRunning:get() then
            return
        end
        
        local connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            timeLeft:update(function(current)
                local newTime = current - deltaTime
                if newTime <= 0 then
                    isRunning:set(false)
                    return 10 -- Reset timer
                end
                return newTime
            end)
        end)
        
        -- Cleanup function
        return function()
            connection:Disconnect()
        end
    end, {isRunning})
    
    return Rex("TextButton") {
        Text = isRunning:map(function(running)
            return running and `Time: {math.ceil(timeLeft:get())}` or "Start Timer"
        end),
        
        onClick = function()
            isRunning:update(function(current) return not current end)
        end
    }
end
```

## Event Mapping Reference

Rex automatically maps camelCase event names to Roblox events:

### Core Events

| Rex Event | Roblox Event | Description |
|-----------|--------------|-------------|
| `onClick` | `MouseButton1Click` | Left mouse button click |
| `onRightClick` | `MouseButton2Click` | Right mouse button click |
| `onHover` | `MouseEnter` | Mouse enters the element |
| `onLeave` | `MouseLeave` | Mouse leaves the element |
| `onFocus` | `Focused` | Element gains focus |
| `onBlur` | `FocusLost` | Element loses focus |
| `onFocusLost` | `FocusLost` | Alternative to onBlur |
| `onTextChanged` | `Changed` | Text content changes (TextBox) |
| `onActivated` | `Activated` | Button activation (Enter key, etc.) |

### Mouse Events

| Rex Event | Roblox Event | Description |
|-----------|--------------|-------------|
| `onMouseEnter` | `MouseEnter` | Alternative to onHover |
| `onMouseLeave` | `MouseLeave` | Alternative to onLeave |
| `onMouseMoved` | `MouseMoved` | Mouse moves over element |
| `onMouseWheelForward` | `MouseWheelForward` | Mouse wheel scrolled forward |
| `onMouseWheelBackward` | `MouseWheelBackward` | Mouse wheel scrolled backward |
| `onMouseDown` | `MouseButton1Down` | Left mouse button pressed down |
| `onMouseUp` | `MouseButton1Up` | Left mouse button released |
| `onRightMouseDown` | `MouseButton2Down` | Right mouse button pressed down |
| `onRightMouseUp` | `MouseButton2Up` | Right mouse button released |
| `onDoubleClick` | `MouseButton1DoubleClick` | Double-click detected |

### Touch Events

| Rex Event | Roblox Event | Description |
|-----------|--------------|-------------|
| `onTouchTap` | `TouchTap` | Touch tap gesture |
| `onTouchLongPress` | `TouchLongPress` | Touch long press gesture |
| `onTouchPan` | `TouchPan` | Touch pan/drag gesture |
| `onTouchPinch` | `TouchPinch` | Touch pinch gesture |
| `onTouchRotate` | `TouchRotate` | Touch rotate gesture |

### Input Events

| Rex Event | Roblox Event | Description |
|-----------|--------------|-------------|
| `onInputBegan` | `InputBegan` | Input begins (keyboard, gamepad, etc.) |
| `onInputChanged` | `InputChanged` | Input changes |
| `onInputEnded` | `InputEnded` | Input ends |

### Selection Events

| Rex Event | Roblox Event | Description |
|-----------|--------------|-------------|
| `onSelectionGained` | `SelectionGained` | Element gains selection focus |
| `onSelectionLost` | `SelectionLost` | Element loses selection focus |

### GuiObject Events

| Rex Event | Roblox Event | Description |
|-----------|--------------|-------------|
| `onChanged` | `Changed` | Property changes on the element |
| `onAncestryChanged` | `AncestryChanged` | Element's ancestry changes |
| `onChildAdded` | `ChildAdded` | Child added to element |
| `onChildRemoved` | `ChildRemoved` | Child removed from element |
| `onDescendantAdded` | `DescendantAdded` | Descendant added to element |
| `onDescendantRemoving` | `DescendantRemoving` | Descendant being removed |

### Specialized Events

| Rex Event | Roblox Event | Description |
|-----------|--------------|-------------|
| `onCanvasPositionChanged` | `CanvasPositionChanged` | ScrollingFrame canvas position changes |
| `onPropertyChanged` | `PropertyChangedSignal` | Generic property change signal |

## Extended Event Examples

### Mouse Events

```luau
local function MouseTracker()
    local mousePosition = Rex.useState(Vector2.new(0, 0))
    local isPressed = Rex.useState(false)
    
    return Rex("Frame") {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        
        onMouseMoved = function(x, y)
            mousePosition:set(Vector2.new(x, y))
        end,
        
        onMouseDown = function()
            isPressed:set(true)
        end,
        
        onMouseUp = function()
            isPressed:set(false)
        end,
        
        onMouseWheelForward = function()
            print("Scrolled up")
        end,
        
        onMouseWheelBackward = function()
            print("Scrolled down")
        end,
        
        children = {
            Rex("TextLabel") {
                Text = mousePosition:map(function(pos)
                    return `Mouse: {math.floor(pos.X)}, {math.floor(pos.Y)}`
                end),
                TextColor3 = isPressed:map(function(pressed)
                    return pressed and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
                end)
            }
        }
    }
end
```

### Touch Events

```luau
local function TouchGestureDemo()
    local gestureInfo = Rex.useState("No gesture")
    
    return Rex("Frame") {
        Size = UDim2.fromScale(0.8, 0.8),
        Position = UDim2.fromScale(0.1, 0.1),
        BackgroundColor3 = Color3.fromRGB(70, 130, 255),
        
        onTouchTap = function()
            gestureInfo:set("Tapped!")
        end,
        
        onTouchLongPress = function()
            gestureInfo:set("Long pressed!")
        end,
        
        onTouchPan = function(positions, totalTranslation, velocity, state)
            gestureInfo:set(`Panning: {state}`)
        end,
        
        onTouchPinch = function(touchPositions, scale, velocity, state)
            gestureInfo:set(`Pinching: Scale {scale}`)
        end,
        
        onTouchRotate = function(touchPositions, rotation, velocity, state)
            gestureInfo:set(`Rotating: {math.deg(rotation)}°`)
        end,
        
        children = {
            Rex("TextLabel") {
                Text = gestureInfo,
                Size = UDim2.fromScale(1, 1),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }
        }
    end
end
```

### Input Events

```luau
local function KeyboardListener()
    local currentKey = Rex.useState("None")
    local keyState = Rex.useState("Released")
    
    return Rex("Frame") {
        Size = UDim2.fromScale(1, 1),
        
        onInputBegan = function(input, gameProcessed)
            if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey:set(input.KeyCode.Name)
                keyState:set("Pressed")
            end
        end,
        
        onInputEnded = function(input, gameProcessed)
            if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                keyState:set("Released")
            end
        end,
        
        children = {
            Rex("TextLabel") {
                Text = Rex.useComputed(function()
                    return `Last Key: {currentKey:get()} ({keyState:get()})`
                end, {currentKey, keyState}),
                Size = UDim2.fromScale(1, 0.1),
                BackgroundTransparency = 1,
                TextScaled = true
            }
        }
    }
end
```

### ScrollingFrame Events

```luau
local function ScrollableContent()
    local scrollPosition = Rex.useState(Vector2.new(0, 0))
    
    return Rex("ScrollingFrame") {
        Size = UDim2.fromScale(0.8, 0.6),
        Position = UDim2.fromScale(0.1, 0..3),
        CanvasSize = UDim2.fromOffset(0, 1000),
        ScrollBarThickness = 8,
        
        onCanvasPositionChanged = function()
            -- Note: This event doesn't pass the canvas position directly
            -- You'd need to access it via the instance if needed
        end,
        
        children = {
            Rex("UIListLayout") {
                SortOrder = Enum.SortOrder.LayoutOrder
            },
            -- Generate content
            (function()
                local content = {}
                for i = 1, 20 do
                    table.insert(content, Rex("TextLabel") {
                        Text = `Item {i}`,
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(255, 255, 255),
                        LayoutOrder = i
                    })
                end
                return content
            end)()
        }
    }
end
```

### GuiObject Lifecycle Events

```luau
local function LifecycleTracker()
    local events = Rex.useState({})
    
    local function addEvent(eventType)
        events:update(function(current)
            local new = table.clone(current)
            table.insert(new, `{eventType} at {os.clock()}`)
            -- Keep only last 10 events
            if #new > 10 then
                table.remove(new, 1)
            end
            return new
        end)
    end
    
    return Rex("Frame") {
        Size = UDim2.fromScale(0.8, 0.8),
        Position = UDim2.fromScale(0.1, 0.1),
        
        onAncestryChanged = function()
            addEvent("Ancestry Changed")
        end,
        
        onChildAdded = function(child)
            addEvent(`Child Added: {child.Name}`)
        end,
        
        onChildRemoved = function(child)
            addEvent(`Child Removed: {child.Name}`)
        end,
        
        onDescendantAdded = function(descendant)
            addEvent(`Descendant Added: {descendant.Name}`)
        end,
        
        onDescendantRemoving = function(descendant)
            addEvent(`Descendant Removing: {descendant.Name}`)
        end,
        
        children = {
            Rex("ScrollingFrame") {
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.fromOffset(0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                children = {
                    Rex("UIListLayout") {
                        SortOrder = Enum.SortOrder.LayoutOrder
                    },
                    events:map(function(eventList)
                        local children = {}
                        for i, event in ipairs(eventList) do
                            table.insert(children, Rex("TextLabel") {
                                Text = event,
                                Size = UDim2.new(1, 0, 0, 25),
                                BackgroundTransparency = 1,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                LayoutOrder = i,
                                key = tostring(i)
                            })
                        end
                        return children
                    end)
                }
            }
        }
    }
end
```

## Best Practices

### 1. Use Descriptive Handler Names

```luau
-- Good: Descriptive function names
local function handleAddItem() ... end
local function handleRemoveItem(index) ... end
local function handleToggleVisibility() ... end

-- Less ideal: Generic names
local function onClick() ... end
local function handleEvent() ... end
```

### 2. Avoid Inline Functions for Complex Logic

```luau
-- Good: Extract complex logic
local function ComplexComponent()
    local function handleComplexClick()
        -- Complex logic here
        doSomethingComplex()
        updateMultipleStates()
        performValidation()
    end
    
    return Rex("TextButton") {
        onClick = handleComplexClick
    }
end

-- Less ideal: Inline complex logic
local function ComplexComponent()
    return Rex("TextButton") {
        onClick = function()
            -- Lots of complex logic inline
        end
    }
end
```

### 3. Use State Updates for Predictable Behavior

```luau
-- Good: State-driven updates
local function ToggleButton()
    local isToggled = Rex.useState(false)
    
    return Rex("TextButton") {
        Text = isToggled:map(function(toggled) return toggled and "ON" or "OFF" end),
        onClick = function()
            isToggled:update(function(current) return not current end)
        end
    }
end
```

### 4. Handle Edge Cases

```luau
local function SafeButton()
    local isProcessing = Rex.useState(false)
    
    return Rex("TextButton") {
        Text = isProcessing:map(function(processing) 
            return processing and "Processing..." or "Click me"
        end),
        
        onClick = isProcessing:map(function(processing)
            -- Prevent double-clicks during processing
            return processing and nil or function()
                isProcessing:set(true)
                
                -- Simulate async operation
                task.spawn(function()
                    wait(2)
                    isProcessing:set(false)
                end)
            end
        end)
    }
end
```
