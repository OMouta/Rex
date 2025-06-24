---
title: "Rendering API"
description: "Complete API reference for Rex's rendering system including element creation, mounting, refs, fragments, and providers."
category: "API Reference"
order: 2
version: "0.1.0"
lastUpdated: 2025-06-23
---

Rex's rendering system provides declarative UI creation, component mounting, and lifecycle management. All rendering functions integrate seamlessly with Rex's reactive state system.

## Element Creation

### `Rex(className: string): (props: RexProps?) -> RexElement`

Creates a Rex element for the specified Roblox class. This is the primary way to create UI elements.

**Parameters:**

- `className: string` - Valid Roblox UI class name (e.g., "Frame", "TextLabel", "TextButton")

**Returns:** Function that accepts props and returns a RexElement

**Example:**

```luau
-- Basic element creation
local frame = Rex("Frame") {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
    children = {
        Rex("TextLabel") {
            Text = "Hello, Rex!",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            TextColor3 = Color3.new(1, 1, 1)
        }
    }
}

-- Element with reactive properties
local count = Rex.useState(0)
local button = Rex("TextButton") {
    Text = count:map(function(c) return `Count: {c}` end),
    Size = UDim2.fromOffset(100, 40),
    onClick = function()
        count:update(function(current) return current + 1 end)
    end
}
```

## Component Rendering

### `Rex.render(elementOrRenderFn: RexElement | (() -> RexElement), container: Instance, options: {mode: string?}?): any`

Renders a Rex component tree into a Roblox container. Supports both static and reactive rendering.

**Parameters:**

- `elementOrRenderFn: RexElement | (() -> RexElement)` - Element to render or render function
- `container: Instance` - Roblox instance to render into (e.g., PlayerGui, workspace)
- `options: {mode: string?}?` - Optional rendering options
  - `mode: "static" | "reactive"` - Rendering mode (auto-detected if not specified)

**Returns:**

- For static rendering: The created Instance
- For reactive rendering: Cleanup function

**Example:**

```luau
-- Static rendering (renders once)
local staticElement = Rex("Frame") {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(50, 50, 60)
}

local instance = Rex.render(staticElement, player.PlayerGui)

-- Reactive rendering (updates when state changes)
local function App()
    local count = Rex.useState(0)
    
    return Rex("ScreenGui") {
        children = {
            Rex("TextLabel") {
                Text = count:map(function(c) return `Count: {c}` end)
            },
            Rex("TextButton") {
                Text = "Increment",
                onClick = function() count:set(count:get() + 1) end
            }
        }
    }
end

local cleanup = Rex.render(App, player.PlayerGui)

-- Clean up reactive rendering when done
cleanup()
```

### `Rex.component<T>(name: string, renderFn: (props: T) -> RexElement): RexComponent<T>`

Creates a typed Rex component with a name for debugging.

**Parameters:**

- `name: string` - Component name for debugging
- `renderFn: (props: T) -> RexElement` - Component render function

**Returns:** `RexComponent<T>` - The component function

**Example:**

```luau
local Button = Rex.component("Button", function(props)
    local isHovered = Rex.useState(false)
    
    return Rex("TextButton") {
        Text = props.text or "Button",
        Size = props.size or UDim2.fromOffset(100, 40),
        BackgroundColor3 = isHovered:map(function(hovered)
            return hovered and Color3.fromRGB(90, 150, 255) or Color3.fromRGB(70, 130, 255)
        end),
        onClick = props.onClick,
        onHover = function() isHovered:set(true) end,
        onLeave = function() isHovered:set(false) end
    }
end)

-- Usage
local myButton = Button {
    text = "Click me!",
    onClick = function() print("Clicked!") end
}
```

## Fragments

### `Rex.Fragment(props: {children: RexChildren, key: string?}): RexFragment`

Groups multiple elements without creating a wrapper instance. Useful for returning multiple elements from a component.

**Parameters:**

- `props.children: RexChildren` - Child elements to group
- `props.key: string?` - Optional key for list reconciliation

**Returns:** `RexFragment` - Fragment object

**Example:**

```luau
local function MultipleElements()
    return Rex.Fragment {
        children = {
            Rex("TextLabel") {
                Text = "First Element",
                Size = UDim2.new(1, 0, 0, 30)
            },
            Rex("TextLabel") {
                Text = "Second Element",
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 30)
            },
            Rex("TextButton") {
                Text = "Third Element",
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 60)
            }
        }
    }
end

-- Or use the shorthand in children arrays
local container = Rex("Frame") {
    children = {
        Rex.Fragment {
            children = {
                Rex("TextLabel") { Text = "Group 1 Item 1" },
                Rex("TextLabel") { Text = "Group 1 Item 2" }
            }
        },
        Rex.Fragment {
            children = {
                Rex("TextLabel") { Text = "Group 2 Item 1" },
                Rex("TextLabel") { Text = "Group 2 Item 2" }
            }
        }
    }
}
```

## Refs

### `Rex.useRef<T>(initialValue: T?): RexRef<T>`

Creates a ref object for storing mutable values or accessing instances directly.

**Parameters:**

- `initialValue: T?` - Optional initial value

**Returns:** `RexRef<T>` with property:

- `current: T?` - The current ref value

**Example:**

```luau
local function ComponentWithRef()
    local frameRef = Rex.useRef()
    local inputRef = Rex.useRef()
    
    Rex.useEffect(function()
        -- Access instances directly when needed
        local frameInstance = frameRef.current
        local inputInstance = inputRef.current
        
        if frameInstance then
            frameInstance.Position = UDim2.fromScale(0.5, 0.5)
        end
        
        if inputInstance then
            inputInstance:CaptureFocus()
        end
    end)
    
    return Rex("Frame") {
        [Rex.Ref] = frameRef, -- Assign ref using special prop
        Size = UDim2.fromOffset(200, 100),
        children = {
            Rex("TextBox") {
                [Rex.Ref] = inputRef,
                PlaceholderText = "Enter text...",
                Size = UDim2.fromScale(1, 1)
            }
        }
    }
end

-- Refs for storing values
local function Timer()
    local timeRef = Rex.useRef(0)
    local connectionRef = Rex.useRef()
    
    Rex.onMount(function()
        connectionRef.current = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            timeRef.current = timeRef.current + deltaTime
        end)
        
        return function()
            if connectionRef.current then
                connectionRef.current:Disconnect()
            end
        end
    end)
    
    return Rex("TextLabel") {
        Text = "Timer running..." -- Would need state for reactive updates
    }
end
```

## Context Providers

### `Rex.Provider<T>(props: {context: RexContext<T>, value: T | RexState<T>, children: RexChildren}): RexElement`

Provides a context value to all child components. Supports both static values and reactive state.

**Parameters:**

- `props.context: RexContext<T>` - The context to provide
- `props.value: T | RexState<T>` - Value to provide (can be reactive state)
- `props.children: RexChildren` - Child elements that can access the context

**Returns:** `RexElement` - Provider element (invisible Frame wrapper)

**Example:**

```luau
-- Create context
local ThemeContext = Rex.createContext({
    primary = Color3.fromRGB(70, 130, 255),
    background = Color3.fromRGB(30, 30, 40),
    text = Color3.new(1, 1, 1)
})

-- Static provider
local function AppWithStaticTheme()
    local darkTheme = {
        primary = Color3.fromRGB(70, 130, 255),
        background = Color3.fromRGB(30, 30, 40),
        text = Color3.new(1, 1, 1)
    }
    
    return Rex.Provider {
        context = ThemeContext,
        value = darkTheme,
        children = {
            ThemedComponent(),
            AnotherThemedComponent()
        }
    }
end

-- Reactive provider (updates all consumers when theme changes)
local function AppWithReactiveTheme()
    local currentTheme = Rex.useState({
        primary = Color3.fromRGB(70, 130, 255),
        background = Color3.fromRGB(30, 30, 40),
        text = Color3.new(1, 1, 1)
    })
    
    return Rex.Provider {
        context = ThemeContext,
        value = currentTheme, -- Reactive state
        children = {
            ThemeToggleButton { 
                theme = currentTheme,
                onToggle = function()
                    currentTheme:update(function(current)
                        return current.primary.R > 0.5 and lightTheme or darkTheme
                    end)
                end
            },
            ThemedComponent(),
            AnotherThemedComponent()
        }
    }
end

-- Consumer component
local function ThemedComponent()
    local theme = Rex.useContext(ThemeContext)
    
    return Rex("Frame") {
        BackgroundColor3 = theme.background,
        children = {
            Rex("TextLabel") {
                Text = "Themed Text",
                TextColor3 = theme.text
            }
        }
    }
end
```

## Special Props

Rex elements support several special props for advanced functionality:

### `children: RexChildren`

Specifies child elements. Can be static elements, reactive state, or mixed arrays.

```luau
-- Static children
children = {
    Rex("TextLabel") { Text = "Child 1" },
    Rex("TextLabel") { Text = "Child 2" }
}

-- Reactive children
children = items:map(function(itemList)
    local childElements = {}
    for _, item in ipairs(itemList) do
        table.insert(childElements, Rex("TextLabel") {
            Text = item.name,
            key = item.id
        })
    end
    return childElements
end)

-- Mixed static and reactive
children = {
    Rex("TextLabel") { Text = "Header" }, -- Static
    items:map(function(itemList) ... end), -- Reactive
    Rex("TextLabel") { Text = "Footer" }   -- Static
}
```

### `key: string`

Provides stable identity for efficient list reconciliation.

```luau
-- Good: Using keys for list items
items:map(function(itemList)
    local children = {}
    for _, item in ipairs(itemList) do
        table.insert(children, Rex("Frame") {
            key = item.id, -- Stable identity
            children = {
                Rex("TextLabel") { Text = item.name }
            }
        })
    end
    return children
end)

-- Less efficient: No keys (reconciliation by position)
items:map(function(itemList)
    local children = {}
    for _, item in ipairs(itemList) do
        table.insert(children, Rex("Frame") {
            -- No key - reconciled by array position
            children = {
                Rex("TextLabel") { Text = item.name }
            }
        })
    end
    return children
end)
```

### `[Rex.Ref]: RexRef<Instance>`

Assigns a ref to access the instance directly.

```luau
local myRef = Rex.useRef()

local element = Rex("Frame") {
    [Rex.Ref] = myRef,
    Size = UDim2.fromOffset(100, 100)
}

-- Later access the instance
print(myRef.current) -- The Frame instance
```

## Event Props

Rex uses camelCase event naming that maps to Roblox events:

```luau
Rex("TextButton") {
    onClick = function() print("Left clicked") end,
    onRightClick = function() print("Right clicked") end,
    onHover = function() print("Mouse entered") end,
    onLeave = function() print("Mouse left") end,
    onFocus = function() print("Gained focus") end,
    onBlur = function(instance, enterPressed) print("Lost focus") end,
    onActivated = function() print("Activated") end
}

Rex("TextBox") {
    onTextChanged = function(instance) print("Text:", instance.Text) end,
    onFocusLost = function(instance, enterPressed) 
        if enterPressed then
            print("Enter pressed")
        end
    end
}
```

## Type Definitions

```luau
export type RexElement = {
    className: string,
    props: RexProps,
    children: RexChildren?,
    instance: Instance?,
    key: string?
}

export type RexProps = {[any]: any}

export type RexChildren = RexElement | {RexElement} | RexState<RexElement | {RexElement}> | nil

export type RexFragment = {
    __rexFragment: true,
    children: {RexElement},
    key: string?
}

export type RexRef<T> = {
    current: T?
}

export type RexComponent<T> = (props: T) -> RexElement
```

## Advanced Rendering Patterns

### Conditional Rendering

```luau
local function ConditionalExample()
    local isLoggedIn = Rex.useState(false)
    local userRole = Rex.useState("guest")
    
    return Rex("Frame") {
        children = {
            -- Simple conditional
            isLoggedIn:get() and Rex("TextLabel") { Text = "Welcome!" } or nil,
            
            -- Conditional with map
            isLoggedIn:map(function(loggedIn)
                return loggedIn and {
                    Rex("TextLabel") { Text = "User Dashboard" },
                    Rex("TextButton") { 
                        Text = "Logout",
                        onClick = function() isLoggedIn:set(false) end
                    }
                } or {
                    Rex("TextLabel") { Text = "Please log in" },
                    Rex("TextButton") { 
                        Text = "Login",
                        onClick = function() isLoggedIn:set(true) end
                    }
                }
            end),
            
            -- Nested conditional
            userRole:map(function(role)
                if role == "admin" then
                    return Rex("TextButton") { Text = "Admin Panel" }
                elseif role == "moderator" then
                    return Rex("TextButton") { Text = "Moderation Tools" }
                else
                    return nil
                end
            end)
        }
    }
end
```

### List Rendering

```luau
local function DynamicList()
    local items = Rex.useState({
        {id = 1, name = "Apple", color = Color3.fromRGB(255, 0, 0)},
        {id = 2, name = "Banana", color = Color3.fromRGB(255, 255, 0)},
        {id = 3, name = "Cherry", color = Color3.fromRGB(200, 0, 100)}
    })
    
    return Rex("ScrollingFrame") {
        Size = UDim2.fromScale(1, 1),
        children = {
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder
            },
            items:map(function(itemList)
                local children = {}
                for i, item in ipairs(itemList) do
                    table.insert(children, Rex("Frame") {
                        key = tostring(item.id), -- Important for efficient updates
                        Size = UDim2.new(1, 0, 0, 50),
                        BackgroundColor3 = item.color,
                        LayoutOrder = i,
                        children = {
                            Rex("TextLabel") {
                                Text = item.name,
                                Size = UDim2.fromScale(1, 1),
                                BackgroundTransparency = 1
                            }
                        }
                    })
                end
                return children
            end)
        }
    }
end
```

Rex's rendering system provides powerful declarative tools for building complex, reactive user interfaces while maintaining excellent performance through efficient reconciliation and batched updates.
