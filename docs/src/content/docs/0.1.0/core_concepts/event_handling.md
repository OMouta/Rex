---
title: "Event Handling"
description: "Learn how to handle user interactions in Rex with unified camelCase event system for buttons, text inputs, and other UI elements."
category: "Core Concepts"
order: 2
version: "0.1.0"
lastUpdated: 2025-06-23
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
    }
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
    }
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
    }
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

## Advanced Event Patterns

### Form Handling

```luau
local function ContactForm()
    local name = Rex.useState("")
    local email = Rex.useState("")
    local message = Rex.useState("")
    
    local isValid = Rex.useComputed(function()
        return name:get() ~= "" and 
               email:get():match("@") and 
               message:get() ~= ""
    end, {name, email, message})
    
    local function handleSubmit()
        if isValid:get() then
            print("Submitting:", {
                name = name:get(),
                email = email:get(),
                message = message:get()
            })
            -- Reset form
            name:set("")
            email:set("")
            message:set("")
        end
    end
    
    return Rex("Frame") {
        children = {
            Rex("TextBox") {
                PlaceholderText = "Name",
                Text = name,
                onTextChanged = function(instance)
                    name:set(instance.Text)
                end
            },
            Rex("TextBox") {
                PlaceholderText = "Email",
                Text = email,
                onTextChanged = function(instance)
                    email:set(instance.Text)
                end
            },
            Rex("TextBox") {
                PlaceholderText = "Message",
                Text = message,
                onTextChanged = function(instance)
                    message:set(instance.Text)
                end,
                onFocusLost = function(instance, enterPressed)
                    if enterPressed and isValid:get() then
                        handleSubmit()
                    end
                end
            },
            Rex("TextButton") {
                Text = "Submit",
                BackgroundColor3 = isValid:map(function(valid)
                    return valid and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(100, 100, 100)
                end),
                onClick = handleSubmit
            }
        }
    }
end
```

### Event Delegation Pattern

```luau
local function ButtonList()
    local items = Rex.useState({"Apple", "Banana", "Cherry"})
    local selectedItem = Rex.useState(nil)
    
    local function handleItemClick(item)
        return function()
            selectedItem:set(item)
            print("Selected:", item)
        end
    end
    
    return Rex("ScrollingFrame") {
        children = {
            Rex("UIListLayout") {},
            items:map(function(itemList)
                local children = {}
                for i, item in ipairs(itemList) do
                    table.insert(children, Rex("TextButton") {
                        Text = item,
                        key = item,
                        BackgroundColor3 = selectedItem:map(function(selected)
                            return selected == item and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(70, 130, 255)
                        end),
                        onClick = handleItemClick(item)
                    })
                end
                return children
            end)
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
