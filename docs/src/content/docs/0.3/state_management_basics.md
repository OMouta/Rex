---
title: "State Management Basics"
description: "Master Rex's enhanced state management system with universal reactivity and helper methods"
category: "Getting Started"
order: 4

lastUpdated: 2025-06-27
---

State is at the heart of any interactive application. Rex provides a powerful, reactive state management system with universal reactivity and enhanced helpers that make building dynamic UIs simple and predictable. This guide will teach you everything you need to know about managing state in Rex.

## What is State?

State represents data that can change over time in your application. Examples include:

- User input (text in a form field)
- UI state (whether a modal is open)
- Application data (list of items, user preferences)
- Loading states (is data being fetched?)

Rex makes state **reactive** with **universal auto-conversion** - when state changes, your UI automatically updates and values are intelligently converted to the right types.

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
                Text = count,
                Size = UDim2.fromScale(1, 0.5)
            },
            Rex("TextButton") {
                Text = "Increment",
                Size = UDim2.fromScale(1, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                onClick = function()
                    count:increment()
                end
            }
        }
    }
end
```

## Enhanced State Operation Helpers

Rex now includes powerful helper methods that eliminate boilerplate:

### Numeric State Helpers

```luau
local count = Rex.useState(0)

-- Instead of: count:update(function(c) return c + 1 end)
count:increment()        -- Add 1
count:increment(5)       -- Add 5
count:decrement()        -- Subtract 1
count:decrement(3)       -- Subtract 3
```

### Boolean State Helpers

```luau
local isVisible = Rex.useState(true)

-- Instead of: isVisible:update(function(v) return not v end)
isVisible:toggle()       -- Flip the boolean value
```

### Array State Helpers

```luau
local items = Rex.useState({"apple", "banana"})

-- Adding items
items:push("cherry")                    -- Add one item
items:push("date", "elderberry")        -- Add multiple items

-- Removing items
local removed = items:pop()             -- Remove and return last item
items:removeAt(2)                       -- Remove item at index 2
items:remove("banana")                  -- Remove by value
items:clear()                           -- Remove all items
```

### Object State Helpers (Path Operations)

```luau
local user = Rex.useState({
    name = "Player",
    settings = { 
        theme = "dark", 
        volume = 0.8 
    }
})

-- Instead of complex nested updates
user:setPath("settings.theme", "light")    -- Set nested property
user:setPath("settings.volume", 0.5)

-- Get nested values
local theme = user:getPath("settings.theme")  -- Returns "light"
local volume = user:getPath("settings.volume") -- Returns 0.5
```

### State Methods

Every state object has several methods:

- `state:get()` - Get the current value
- `state:set(newValue)` - Set a new value
- `state:update(function)` - Update based on current value
- `state:map(function)` - Create a computed value
- `state:each(function)` - Reactive list rendering for arrays

## Practical Example: Task Manager

Here's a complete example combining state helpers with reactive list rendering:

```luau
local function TaskManager()
    local tasks = Rex.useState({
        {id = 1, text = "Learn Rex", completed = false},
        {id = 2, text = "Build UI", completed = false}
    })
    local newTaskText = Rex.useState("")
    local nextId = Rex.useState(3)
    
    local function addTask()
        local text = newTaskText:get():gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
        if text ~= "" then
            tasks:push({
                id = nextId:get(),
                text = text,
                completed = false
            })
            nextId:increment() -- Use increment helper
            newTaskText:set("") -- Clear input
        end
    end
    
    local function toggleTask(taskId)
        tasks:update(function(currentTasks)
            local newTasks = table.clone(currentTasks)
            for i, task in ipairs(newTasks) do
                if task.id == taskId then
                    newTasks[i].completed = not newTasks[i].completed
                    break
                end
            end
            return newTasks
        end)
    end
    
    local function removeTask(taskId)
        tasks:update(function(currentTasks)
            local newTasks = {}
            for _, task in ipairs(currentTasks) do
                if task.id ~= taskId then
                    table.insert(newTasks, task)
                end
            end
            return newTasks
        end)
    end
    
    return Rex("Frame") {
        Size = UDim2.fromOffset(400, 500),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(40, 44, 52),
        
        children = {
            Rex("UIListLayout") { Padding = UDim.new(0, 10) },
            Rex("UIPadding") { 
                PaddingTop = UDim.new(0, 20),
                PaddingLeft = UDim.new(0, 20),
                PaddingRight = UDim.new(0, 20),
                PaddingBottom = UDim.new(0, 20)
            },
            
            -- Title with task count
            Rex("TextLabel") {
                Text = tasks:map(function(taskList)
                    local completed = 0
                    for _, task in ipairs(taskList) do
                        if task.completed then completed = completed + 1 end
                    end
                    return `Tasks: {completed}/{#taskList} completed`
                end),
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                LayoutOrder = 1
            },
            
            -- Add task input
            Rex("Frame") {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                
                children = {
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 10)
                    },
                    
                    Rex("TextBox") {
                        Text = newTaskText,
                        PlaceholderText = "Enter new task...",
                        Size = UDim2.new(0.8, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(60, 64, 72),
                        TextColor3 = Color3.new(1, 1, 1),
                        onTextChanged = function(textBox)
                            newTaskText:set(textBox.Text)
                        end,
                        LayoutOrder = 1
                    },
                    
                    Rex("TextButton") {
                        Text = "Add",
                        Size = UDim2.new(0..3, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(67, 181, 129),
                        TextColor3 = Color3.new(1, 1, 1),
                        onClick = addTask,
                        LayoutOrder = 2
                    }
                }
            },
            
            -- Task list using :each() method
            Rex("ScrollingFrame") {
                Size = UDim2.new(1, 0, 1, -100),
                BackgroundTransparency = 1,
                LayoutOrder = 3,
                
                children = {
                    Rex("UIListLayout") { Padding = UDim.new(0, 5) },
                    
                    tasks:each(function(task, index)
                        return Rex("Frame") {
                            Size = UDim2.new(1, 0, 0, 50),
                            BackgroundColor3 = task.completed 
                                and Color3.fromRGB(67, 181, 129)  -- Green when completed
                                or Color3.fromRGB(60, 64, 72),    -- Gray when pending
                            key = tostring(task.id), -- Use stable ID as key
                            
                            children = {
                                Rex("UIListLayout") {
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    Padding = UDim.new(0, 10)
                                },
                                
                                -- Task text
                                Rex("TextLabel") {
                                    Text = task.text,
                                    Size = UDim2.new(0.6, 0, 1, 0),
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.new(1, 1, 1),
                                    TextStrikethrough = task.completed,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    LayoutOrder = 1
                                },
                                
                                -- Toggle button
                                Rex("TextButton") {
                                    Text = task.completed and "↶" or "✓",
                                    Size = UDim2.new(0..3, 0, 0.8, 0),
                                    BackgroundColor3 = task.completed
                                        and Color3.fromRGB(255, 200, 100)
                                        or Color3.fromRGB(100, 200, 255),
                                    onClick = function()
                                        toggleTask(task.id)
                                    end,
                                    LayoutOrder = 2
                                },
                                
                                -- Remove button
                                Rex("TextButton") {
                                    Text = "✕",
                                    Size = UDim2.new(0..3, 0, 0.8, 0),
                                    BackgroundColor3 = Color3.fromRGB(231, 76, 60),
                                    TextColor3 = Color3.new(1, 1, 1),
                                    onClick = function()
                                        removeTask(task.id)
                                    end,
                                    LayoutOrder = 3
                                }
                            }
                        }
                    end)
                }
            }
        }
    }
end
```

This example demonstrates:

- **Array helpers**: `push()` to add tasks, `increment()` for ID management
- **Reactive lists**: `tasks:each()` for dynamic task rendering  
- **State mapping**: `tasks:map()` for computed task count display
- **Proper keys**: Using `task.id` for efficient list updates
- **Interactive state**: Toggle and remove operations with state updates

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
                Size = UDim2.fromScale(1, 0..3)
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

- Try the [Quick Start Guide](./quick_start_guide) for hands-on practice
- Learn about [Component Lifecycle](./core_concepts/lifecycle_hooks)
- Explore [Advanced State Patterns](./advanced_features/deep_reactivity)
- Understand [Context](./core_concepts/contexts) for sharing state across components

## Common Questions

**Q: When should I use `useState` vs `useDeepState`?**

A: Use `useState` for simple values (numbers, strings, booleans). Use `useDeepState` when you need to track changes to nested object properties.

**Q: Can I use multiple state objects in one component?**

A: Absolutely! Components can have as many state objects as needed. Group related state together for better organization.

**Q: How do I share state between components?**

A: Use [Context](./core_concepts/contexts) for sharing state across multiple components, or pass state as props for parent-child communication.

**Q: Why isn't my computed value updating?**

A: Make sure you've included all dependencies in the dependency array for `useComputed`, or use `useAutoComputed` for automatic dependency tracking.
