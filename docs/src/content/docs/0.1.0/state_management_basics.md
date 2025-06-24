---
title: "State Management Basics"
description: "Master Rex's state management system with practical examples and best practices"
category: "Getting Started"
order: 4
version: "0.1.0"
lastUpdated: 2025-06-23
---

State is at the heart of any interactive application. Rex provides a powerful, reactive state management system that makes building dynamic UIs simple and predictable. This guide will teach you everything you need to know about managing state in Rex.

## What is State?

State represents data that can change over time in your application. Examples include:

- User input (text in a form field)
- UI state (whether a modal is open)
- Application data (list of items, user preferences)
- Loading states (is data being fetched?)

Rex makes state **reactive** - when state changes, your UI automatically updates to reflect those changes.

## Creating State with useState

The most basic way to create state in Rex is with `useState`:

```luau
local Rex = require(path.to.Rex)

local function Counter()
    -- Create state with initial value of 0
    local count = Rex.useState(0)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = "Count: " .. tostring(count:get()),
                Size = UDim2.fromScale(1, 0.5)
            },
            Rex("TextButton") {
                Text = "Increment",
                Size = UDim2.fromScale(1, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                onClick = function()
                    count:set(count:get() + 1)
                end
            }
        }
    }
end
```

### State Methods

Every state object has several methods:

- `state:get()` - Get the current value
- `state:set(newValue)` - Set a new value
- `state:update(function)` - Update based on current value
- `state:map(function)` - Create a computed value

## Reactive Properties

Instead of manually reading state with `:get()`, you can make properties reactive:

```luau
local function ColorChanger()
    local color = Rex.useState(Color3.fromRGB(255, 0, 0))
    
    return Rex("Frame") {
        -- Reactive property - updates automatically when color changes
        BackgroundColor3 = color,
        Size = UDim2.fromScale(1, 1),
        
        children = {
            Rex("TextButton") {
                Text = "Change Color",
                onClick = function()
                    -- Generate random color
                    local r = math.random(0, 255)
                    local g = math.random(0, 255)
                    local b = math.random(0, 255)
                    color:set(Color3.fromRGB(r, g, b))
                end
            }
        }
    }
end
```

## Updating State Safely

Always use state methods to update state, never modify the value directly:

```luau
-- ❌ Wrong - Don't do this
local items = Rex.useState({"apple", "banana"})
table.insert(items:get(), "orange") -- This won't trigger updates!

-- ✅ Correct - Use :update() for safe mutations
local items = Rex.useState({"apple", "banana"})
items:update(function(currentItems)
    local newItems = {}
    for i, item in ipairs(currentItems) do
        table.insert(newItems, item)
    end
    table.insert(newItems, "orange")
    return newItems
end)

-- ✅ Or use :set() with a new array
items:set({"apple", "banana", "orange"})
```

## Computed State with useComputed

Sometimes you need values derived from other state. Use `useComputed` for this:

```luau
local function ShoppingCart()
    local items = Rex.useState({
        {name = "Apple", price = 1.50, quantity = 2},
        {name = "Banana", price = 0.75, quantity = 3}
    })
    
    -- Computed value that recalculates when items change
    local total = Rex.useComputed(function()
        local sum = 0
        for _, item in ipairs(items:get()) do
            sum = sum + (item.price * item.quantity)
        end
        return sum
    end, {items}) -- Dependencies
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = "Total: $" .. string.format("%.2f", total:get()),
                Size = UDim2.fromScale(1, 0.2)
            },
            -- Item list would go here...
        }
    }
end
```

### Auto-Tracked Computed

For simpler cases, use `useAutoComputed` which automatically tracks dependencies:

```luau
local function TemperatureConverter()
    local celsius = Rex.useState(0)
    
    -- Auto-tracks celsius dependency
    local fahrenheit = Rex.useAutoComputed(function()
        return celsius:get() * 9/5 + 32
    end)
    
    return Rex("Frame") {
        children = {
            Rex("TextBox") {
                PlaceholderText = "Celsius",
                onTextChanged = function(instance)
                    local value = tonumber(instance.Text) or 0
                    celsius:set(value)
                end
            },
            Rex("TextLabel") {
                Text = "Fahrenheit: " .. tostring(fahrenheit:get())
            }
        }
    }
end
```

## Working with Complex State

For objects and arrays, Rex provides `useDeepState` for nested reactivity:

```luau
local function UserProfile()
    local user = Rex.useDeepState({
        name = "John Doe",
        email = "john@example.com",
        preferences = {
            theme = "dark",
            notifications = true
        }
    })
    
    return Rex("Frame") {
        children = {
            Rex("TextBox") {
                Text = user.name, -- Reactive to name changes
                onTextChanged = function(instance)
                    user.name:set(instance.Text)
                end
            },
            Rex("TextButton") {
                Text = "Toggle Theme",
                onClick = function()
                    -- Access nested state
                    local currentTheme = user.preferences.theme:get()
                    local newTheme = currentTheme == "dark" and "light" or "dark"
                    user.preferences.theme:set(newTheme)
                end
            },
            Rex("TextLabel") {
                Text = "Theme: " .. user.preferences.theme:get()
            }
        }
    }
end
```

## State Best Practices

### 1. Keep State Minimal

Only store what needs to be reactive:

```luau
-- ❌ Don't store computed values in state
local function Component()
    local firstName = Rex.useState("John")
    local lastName = Rex.useState("Doe")
    local fullName = Rex.useState("John Doe") -- Unnecessary!
    
    -- Update fullName whenever first/last changes...
end

-- ✅ Use computed values instead
local function Component()
    local firstName = Rex.useState("John")
    local lastName = Rex.useState("Doe")
    local fullName = Rex.useComputed(function()
        return firstName:get() .. " " .. lastName:get()
    end, {firstName, lastName})
end
```

### 2. Use the Right State Type

Choose the appropriate state primitive:

```luau
-- Simple values
local count = Rex.useState(0)
local message = Rex.useState("Hello")

-- Objects that need nested reactivity
local user = Rex.useDeepState({name = "John", age = 30})

-- Computed values
local displayName = Rex.useComputed(function()
    return user.name:get() .. " (" .. tostring(user.age:get()) .. ")"
end, {user.name, user.age})

-- Auto-tracked computed (simpler syntax)
local isAdult = Rex.useAutoComputed(function()
    return user.age:get() >= 18
end)
```

### 3. Name State Descriptively

Good state names make code self-documenting:

```luau
-- ❌ Unclear names
local s = Rex.useState(false)
local data = Rex.useState({})

-- ✅ Clear, descriptive names
local isModalOpen = Rex.useState(false)
local userProfiles = Rex.useState({})
local selectedUserId = Rex.useState(nil)
```

### 4. Group Related State

Keep related state together:

```luau
-- ❌ Scattered state
local isLoading = Rex.useState(false)
local error = Rex.useState(nil)
local data = Rex.useState(nil)

-- ✅ Grouped state
local apiState = Rex.useDeepState({
    isLoading = false,
    error = nil,
    data = nil
})

-- Or use a custom hook
local function useApiCall()
    local state = Rex.useDeepState({
        isLoading = false,
        error = nil,
        data = nil
    })
    
    local fetchData = function()
        state.isLoading:set(true)
        -- Fetch logic...
    end
    
    return state, fetchData
end
```

## Common State Patterns

### Toggle Pattern

```luau
local function ToggleButton()
    local isOn = Rex.useState(false)
    
    return Rex("TextButton") {
        Text = isOn:map(function(on) return on and "ON" or "OFF" end),
        BackgroundColor3 = isOn:map(function(on)
            return on and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end),
        onClick = function()
            isOn:update(function(current) return not current end)
        end
    }
end
```

### Counter Pattern

```luau
local function Counter()
    local count = Rex.useState(0)
    
    return Rex("Frame") {
        children = {
            Rex("TextButton") {
                Text = "-",
                onClick = function()
                    count:update(function(current) return math.max(0, current - 1) end)
                end
            },
            Rex("TextLabel") {
                Text = tostring(count:get())
            },
            Rex("TextButton") {
                Text = "+",
                onClick = function()
                    count:update(function(current) return current + 1 end)
                end
            }
        }
    }
end
```

### Form Input Pattern

```luau
local function ContactForm()
    local formData = Rex.useDeepState({
        name = "",
        email = "",
        message = ""
    })
    
    local isValid = Rex.useComputed(function()
        local data = {
            name = formData.name:get(),
            email = formData.email:get(),
            message = formData.message:get()
        }
        return data.name ~= "" and data.email:match("@") and data.message ~= ""
    end, {formData.name, formData.email, formData.message})
    
    return Rex("Frame") {
        children = {
            Rex("TextBox") {
                PlaceholderText = "Name",
                Text = formData.name,
                onTextChanged = function(instance)
                    formData.name:set(instance.Text)
                end
            },
            Rex("TextBox") {
                PlaceholderText = "Email",
                Text = formData.email,
                onTextChanged = function(instance)
                    formData.email:set(instance.Text)
                end
            },
            Rex("TextBox") {
                PlaceholderText = "Message",
                Text = formData.message,
                onTextChanged = function(instance)
                    formData.message:set(instance.Text)
                end
            },
            Rex("TextButton") {
                Text = "Submit",
                BackgroundColor3 = isValid:map(function(valid)
                    return valid and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(128, 128, 128)
                end),
                onClick = isValid:map(function(valid)
                    return valid and function()
                        print("Submitting form...")
                        -- Submit logic here
                    end or nil
                end)
            }
        }
    }
end
```

## Debugging State

Rex provides helpful debugging tools:

```luau
local function DebugExample()
    local count = Rex.useState(0)
    
    -- Watch state changes
    Rex.useEffect(function()
        print("Count changed to:", count:get())
    end, {count})
    
    return Rex("TextButton") {
        Text = "Count: " .. tostring(count:get()),
        onClick = function()
            count:update(function(current) return current + 1 end)
        end
    }
end
```

## What's Next?

Now that you understand state management, you're ready to:

- Try the [Quick Start Guide](/0.1.0/quick_start_guide) for hands-on practice
- Learn about [Component Lifecycle](/0.1.0/core_concepts/lifecycle_hooks)
- Explore [Advanced State Patterns](/0.1.0/advanced_features/deep_reactivity)
- Understand [Context](/0.1.0/core_concepts/contexts) for sharing state across components

## Common Questions

**Q: When should I use `useState` vs `useDeepState`?**

A: Use `useState` for simple values (numbers, strings, booleans). Use `useDeepState` when you need to track changes to nested object properties.

**Q: Can I use multiple state objects in one component?**

A: Absolutely! Components can have as many state objects as needed. Group related state together for better organization.

**Q: How do I share state between components?**

A: Use [Context](/0.1.0/core_concepts/contexts) for sharing state across multiple components, or pass state as props for parent-child communication.

**Q: Why isn't my computed value updating?**

A: Make sure you've included all dependencies in the dependency array for `useComputed`, or use `useAutoComputed` for automatic dependency tracking.
