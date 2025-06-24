---
title: "Quick Start Guide"
description: "Get up and running with Rex in under 10 minutes with this fast-track tutorial"
category: "Getting Started"
order: 3
version: "0.1.0"
lastUpdated: 2025-06-23
---

Ready to start building with Rex? This quick start guide will have you creating interactive UIs in under 10 minutes. We'll build a simple todo app that demonstrates all of Rex's core features.

## What We'll Build

A fully functional todo application with:

- Add/remove items
- Mark items as complete
- Filter by status (all/active/completed)
- Persistent state
- Responsive design

## Step 1: Basic Setup (2 minutes)

First, make sure you have Rex installed ([Installation Guide](/0.1.0/installation)). Then create your main script:

```luau
-- TodoApp.client.lua
local Players = game:GetService("Players")
local Rex = require(path.to.Rex)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- We'll build the app here...
```

## Step 2: Create the Todo Item Component (3 minutes)

Let's start with a reusable component for individual todo items:

```luau
local function TodoItem(props)
    local isHovered = Rex.useState(false)
    
    return Rex("Frame") {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = isHovered:map(function(hovered)
            return hovered and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(255, 255, 255)
        end),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(230, 230, 230),
        
        onHover = function() isHovered:set(true) end,
        onLeave = function() isHovered:set(false) end,
        
        children = {
            -- Checkbox
            Rex("TextButton") {
                Size = UDim2.fromOffset(30, 30),
                Position = UDim2.fromOffset(5, 5),
                BackgroundColor3 = props.completed:map(function(done)
                    return done and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(255, 255, 255)
                end),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(200, 200, 200),
                Text = props.completed:map(function(done) return done and "✓" or "" end),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                onClick = function()
                    props.onToggle(props.id)
                end
            },
            
            -- Todo text
            Rex("TextLabel") {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.fromOffset(45, 0),
                BackgroundTransparency = 1,
                Text = props.text,
                TextColor3 = props.completed:map(function(done)
                    return done and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(50, 50, 50)
                end),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                TextStrikethrough = props.completed
            },
            
            -- Delete button
            Rex("TextButton") {
                Size = UDim2.fromOffset(30, 30),
                Position = UDim2.new(1, -35, 0, 5),
                BackgroundColor3 = Color3.fromRGB(244, 67, 54),
                BorderSizePixel = 0,
                Text = "×",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                onClick = function()
                    props.onDelete(props.id)
                end
            }
        }
    }
end
```

## Step 3: Build the Main App (4 minutes)

Now let's create the main application component:

```luau
local function TodoApp()
    -- State for all todos
    local todos = Rex.useState({})
    local nextId = Rex.useState(1)
    
    -- State for new todo input
    local newTodoText = Rex.useState("")
    
    -- State for filter
    local filter = Rex.useState("all") -- "all", "active", "completed"
    
    -- Computed values
    local filteredTodos = Rex.useComputed(function()
        local allTodos = todos:get()
        local currentFilter = filter:get()
        
        if currentFilter == "all" then
            return allTodos
        elseif currentFilter == "active" then
            local active = {}
            for _, todo in ipairs(allTodos) do
                if not todo.completed then
                    table.insert(active, todo)
                end
            end
            return active
        else -- completed
            local completed = {}
            for _, todo in ipairs(allTodos) do
                if todo.completed then
                    table.insert(completed, todo)
                end
            end
            return completed
        end
    end, {todos, filter})
    
    local activeCount = Rex.useComputed(function()
        local count = 0
        for _, todo in ipairs(todos:get()) do
            if not todo.completed then
                count = count + 1
            end
        end
        return count
    end, {todos})
    
    -- Functions
    local function addTodo()
        local text = newTodoText:get():match("^%s*(.-)%s*$") -- Trim whitespace
        if text ~= "" then
            todos:update(function(current)
                local new = {}
                for i, todo in ipairs(current) do
                    table.insert(new, todo)
                end
                table.insert(new, {
                    id = nextId:get(),
                    text = text,
                    completed = false
                })
                return new
            end)
            nextId:update(function(current) return current + 1 end)
            newTodoText:set("")
        end
    end
    
    local function toggleTodo(id)
        todos:update(function(current)
            local new = {}
            for _, todo in ipairs(current) do
                if todo.id == id then
                    table.insert(new, {
                        id = todo.id,
                        text = todo.text,
                        completed = not todo.completed
                    })
                else
                    table.insert(new, todo)
                end
            end
            return new
        end)
    end
    
    local function deleteTodo(id)
        todos:update(function(current)
            local new = {}
            for _, todo in ipairs(current) do
                if todo.id ~= id then
                    table.insert(new, todo)
                end
            end
            return new
        end)
    end
    
    return Rex("Frame") {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(250, 250, 250),
        
        children = {
            -- Header
            Rex("TextLabel") {
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Color3.fromRGB(63, 81, 181),
                Text = "Todo App",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                Font = Enum.Font.GothamBold
            },
            
            -- Input section
            Rex("Frame") {
                Size = UDim2.new(1, 0, 0, 50),
                Position = UDim2.fromOffset(0, 60),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(230, 230, 230),
                
                children = {
                    Rex("TextBox") {
                        Size = UDim2.new(1, -60, 1, -10),
                        Position = UDim2.fromOffset(5, 5),
                        BackgroundTransparency = 1,
                        Text = newTodoText,
                        PlaceholderText = "What needs to be done?",
                        TextColor3 = Color3.fromRGB(50, 50, 50),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextScaled = true,
                        Font = Enum.Font.Gotham,
                        ClearTextOnFocus = false,
                        
                        onTextChanged = function(instance)
                            newTodoText:set(instance.Text)
                        end,
                        
                        onFocusLost = function(instance, enterPressed)
                            if enterPressed then
                                addTodo()
                            end
                        end
                    },
                    
                    Rex("TextButton") {
                        Size = UDim2.fromOffset(50, 40),
                        Position = UDim2.new(1, -55, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(76, 175, 80),
                        BorderSizePixel = 0,
                        Text = "+",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        onClick = addTodo
                    }
                }
            },
            
            -- Filter buttons
            Rex("Frame") {
                Size = UDim2.new(1, 0, 0, 40),
                Position = UDim2.fromOffset(0, 110),
                BackgroundColor3 = Color3.fromRGB(245, 245, 245),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(230, 230, 230),
                
                children = {
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 10)
                    },
                    
                    Rex("TextButton") {
                        Size = UDim2.fromOffset(60, 30),
                        BackgroundColor3 = filter:map(function(f)
                            return f == "all" and Color3.fromRGB(63, 81, 181) or Color3.fromRGB(255, 255, 255)
                        end),
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.fromRGB(200, 200, 200),
                        Text = "All",
                        TextColor3 = filter:map(function(f)
                            return f == "all" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
                        end),
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        onClick = function() filter:set("all") end
                    },
                    
                    Rex("TextButton") {
                        Size = UDim2.fromOffset(60, 30),
                        BackgroundColor3 = filter:map(function(f)
                            return f == "active" and Color3.fromRGB(63, 81, 181) or Color3.fromRGB(255, 255, 255)
                        end),
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.fromRGB(200, 200, 200),
                        Text = "Active",
                        TextColor3 = filter:map(function(f)
                            return f == "active" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
                        end),
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        onClick = function() filter:set("active") end
                    },
                    
                    Rex("TextButton") {
                        Size = UDim2.fromOffset(80, 30),
                        BackgroundColor3 = filter:map(function(f)
                            return f == "completed" and Color3.fromRGB(63, 81, 181) or Color3.fromRGB(255, 255, 255)
                        end),
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.fromRGB(200, 200, 200),
                        Text = "Completed",
                        TextColor3 = filter:map(function(f)
                            return f == "completed" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
                        end),
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        onClick = function() filter:set("completed") end
                    }
                }
            },
            
            -- Status bar
            Rex("TextLabel") {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.fromOffset(0, 150),
                BackgroundColor3 = Color3.fromRGB(240, 240, 240),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(230, 230, 230),
                Text = activeCount:map(function(count)
                    return tostring(count) .. " item" .. (count == 1 and "" or "s") .. " left"
                end),
                TextColor3 = Color3.fromRGB(100, 100, 100),
                TextScaled = true,
                Font = Enum.Font.Gotham
            },
            
            -- Todo list
            Rex("ScrollingFrame") {
                Size = UDim2.new(1, 0, 1, -180),
                Position = UDim2.fromOffset(0, 180),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ScrollBarThickness = 8,
                
                children = {
                    Rex("UIListLayout") {
                        SortOrder = Enum.SortOrder.LayoutOrder
                    },
                    
                    -- Reactive list of todos
                    filteredTodos:map(function(todoList)
                        local children = {}
                        for i, todo in ipairs(todoList) do
                            table.insert(children, TodoItem {
                                id = todo.id,
                                text = todo.text,
                                completed = Rex.useState(todo.completed),
                                onToggle = toggleTodo,
                                onDelete = deleteTodo,
                                key = tostring(todo.id) -- Important for performance
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

## Step 4: Render the App (1 minute)

Finally, render your app to the screen:

```luau
-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TodoApp"
screenGui.Parent = playerGui

-- Render the app
Rex.render(screenGui, {
    TodoApp()
})
```

## Complete Code

Here's the complete `TodoApp.client.lua` file:

```luau
-- TodoApp.client.lua
local Players = game:GetService("Players")
local Rex = require(path.to.Rex)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function TodoItem(props)
    local isHovered = Rex.useState(false)
    
    return Rex("Frame") {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = isHovered:map(function(hovered)
            return hovered and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(255, 255, 255)
        end),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(230, 230, 230),
        
        onHover = function() isHovered:set(true) end,
        onLeave = function() isHovered:set(false) end,
        
        children = {
            Rex("TextButton") {
                Size = UDim2.fromOffset(30, 30),
                Position = UDim2.fromOffset(5, 5),
                BackgroundColor3 = props.completed:map(function(done)
                    return done and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(255, 255, 255)
                end),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(200, 200, 200),
                Text = props.completed:map(function(done) return done and "✓" or "" end),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                onClick = function() props.onToggle(props.id) end
            },
            
            Rex("TextLabel") {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.fromOffset(45, 0),
                BackgroundTransparency = 1,
                Text = props.text,
                TextColor3 = props.completed:map(function(done)
                    return done and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(50, 50, 50)
                end),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                TextStrikethrough = props.completed
            },
            
            Rex("TextButton") {
                Size = UDim2.fromOffset(30, 30),
                Position = UDim2.new(1, -35, 0, 5),
                BackgroundColor3 = Color3.fromRGB(244, 67, 54),
                BorderSizePixel = 0,
                Text = "×",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                onClick = function() props.onDelete(props.id) end
            }
        }
    }
end

local function TodoApp()
    local todos = Rex.useState({})
    local nextId = Rex.useState(1)
    local newTodoText = Rex.useState("")
    local filter = Rex.useState("all")
    
    local filteredTodos = Rex.useComputed(function()
        local allTodos = todos:get()
        local currentFilter = filter:get()
        
        if currentFilter == "all" then
            return allTodos
        elseif currentFilter == "active" then
            local active = {}
            for _, todo in ipairs(allTodos) do
                if not todo.completed then
                    table.insert(active, todo)
                end
            end
            return active
        else
            local completed = {}
            for _, todo in ipairs(allTodos) do
                if todo.completed then
                    table.insert(completed, todo)
                end
            end
            return completed
        end
    end, {todos, filter})
    
    local activeCount = Rex.useComputed(function()
        local count = 0
        for _, todo in ipairs(todos:get()) do
            if not todo.completed then
                count = count + 1
            end
        end
        return count
    end, {todos})
    
    local function addTodo()
        local text = newTodoText:get():match("^%s*(.-)%s*$")
        if text ~= "" then
            todos:update(function(current)
                local new = {}
                for i, todo in ipairs(current) do
                    table.insert(new, todo)
                end
                table.insert(new, {
                    id = nextId:get(),
                    text = text,
                    completed = false
                })
                return new
            end)
            nextId:update(function(current) return current + 1 end)
            newTodoText:set("")
        end
    end
    
    local function toggleTodo(id)
        todos:update(function(current)
            local new = {}
            for _, todo in ipairs(current) do
                if todo.id == id then
                    table.insert(new, {
                        id = todo.id,
                        text = todo.text,
                        completed = not todo.completed
                    })
                else
                    table.insert(new, todo)
                end
            end
            return new
        end)
    end
    
    local function deleteTodo(id)
        todos:update(function(current)
            local new = {}
            for _, todo in ipairs(current) do
                if todo.id ~= id then
                    table.insert(new, todo)
                end
            end
            return new
        end)
    end
    
    return Rex("Frame") {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(250, 250, 250),
        
        children = {
            Rex("TextLabel") {
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Color3.fromRGB(63, 81, 181),
                Text = "Todo App",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                Font = Enum.Font.GothamBold
            },
            
            Rex("Frame") {
                Size = UDim2.new(1, 0, 0, 50),
                Position = UDim2.fromOffset(0, 60),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(230, 230, 230),
                
                children = {
                    Rex("TextBox") {
                        Size = UDim2.new(1, -60, 1, -10),
                        Position = UDim2.fromOffset(5, 5),
                        BackgroundTransparency = 1,
                        Text = newTodoText,
                        PlaceholderText = "What needs to be done?",
                        TextColor3 = Color3.fromRGB(50, 50, 50),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextScaled = true,
                        Font = Enum.Font.Gotham,
                        ClearTextOnFocus = false,
                        
                        onTextChanged = function(instance)
                            newTodoText:set(instance.Text)
                        end,
                        
                        onFocusLost = function(instance, enterPressed)
                            if enterPressed then
                                addTodo()
                            end
                        end
                    },
                    
                    Rex("TextButton") {
                        Size = UDim2.fromOffset(50, 40),
                        Position = UDim2.new(1, -55, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(76, 175, 80),
                        BorderSizePixel = 0,
                        Text = "+",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        onClick = addTodo
                    }
                }
            },
            
            -- Continue with filter buttons, status bar, and todo list...
            -- (Same as in Step 3)
        }
    }
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TodoApp"
screenGui.Parent = playerGui

Rex.render(screenGui, {
    TodoApp()
})
```

## What You've Learned

In just 10 minutes, you've built a complete todo application and learned:

1. **Component Structure** - Building reusable components
2. **State Management** - Using `useState` and `useComputed`
3. **Event Handling** - Responding to clicks and text input
4. **Reactive UI** - Making properties update automatically
5. **List Rendering** - Dynamically displaying arrays of data
6. **Conditional Logic** - Filtering and displaying different states

## Key Rex Concepts Demonstrated

### Reactive Properties

```luau
BackgroundColor3 = isHovered:map(function(hovered)
    return hovered and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(255, 255, 255)
end)
```

Properties automatically update when state changes.

### Computed Values

```luau
local filteredTodos = Rex.useComputed(function()
    -- Complex filtering logic
end, {todos, filter})
```

Derived state that recalculates when dependencies change.

### Event Handling

```luau
onClick = function()
    todos:update(function(current)
        -- Update logic
    end)
end
```

Clean, declarative event handling.

### Dynamic Lists

```luau
filteredTodos:map(function(todoList)
    local children = {}
    for i, todo in ipairs(todoList) do
        table.insert(children, TodoItem { ... })
    end
    return children
end)
```

Reactive lists that update when data changes.

## Next Steps

Now that you've built your first Rex app, explore these areas:

1. **[Core Concepts](/0.1.0/core_concepts/state)** - Deeper understanding of Rex's systems
2. **[Advanced Features](/0.1.0/advanced_features/memoization)** - Performance optimization and complex patterns
3. **[API Reference](/0.1.0/api_reference/state)** - Complete API documentation
4. **[Examples](/0.1.0/examples/dynamic_list)** - More real-world examples

## Challenges to Try

Extend your todo app with these features:

1. **Persistence** - Save todos to DataStore
2. **Categories** - Add todo categories/tags
3. **Due Dates** - Add date picker and sorting
4. **Animations** - Add smooth transitions
5. **Multi-user** - Share todos between players

## Common Issues

### My list doesn't update when I add items

Make sure you're using `:update()` to modify arrays, not direct mutation.

### Components aren't rendering

Check that you're calling `Rex.render()` and your components return valid Rex elements.

### Performance is slow with many items

Add `key` props to list items and consider using `useComputed` for expensive operations.

Ready to build something amazing? The full power of Rex is at your fingertips!
