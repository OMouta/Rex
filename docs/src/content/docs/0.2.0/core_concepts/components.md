---
title: "Components"
description: "Learn how to build reusable, composable components in Rex and patterns for component architecture and data flow."
category: "Core Concepts"
order: 5
version: "0.2.0"
lastUpdated: 2025-06-23
---

Components are the building blocks of Rex applications. They are functions that return Rex elements and can accept props for customization. Rex promotes composition over inheritance, allowing you to build complex UIs from simple, reusable components.

## Basic Components

A component is simply a function that returns a Rex element:

```luau
local function Button(props)
    return Rex("TextButton") {
        Text = props.text or "Button",
        Size = props.size or UDim2.fromOffset(100, 40),
        onClick = props.onClick
    }
end

-- Usage
local myButton = Button {
    text = "Click me!",
    size = UDim2.fromOffset(150, 50),
    onClick = function() print("Clicked!") end
}
```

## Component Props

Props are the way to pass data to components. They make components reusable and customizable:

```luau
local function PlayerCard(props)
    return Rex("Frame") {
        Size = UDim2.fromOffset(200, 100),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        children = {
            Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
            Rex("UIPadding") { 
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            },
            Rex("TextLabel") {
                Text = props.playerName or "Unknown Player",
                Size = UDim2.new(1, 0, 0.5, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                Font = Enum.Font.SourceSansBold
            },
            Rex("TextLabel") {
                Text = `Level {props.level or 1}`,
                Size = UDim2.new(1, 0, 0.5, 0),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                TextScaled = true
            }
        }
    }
end

-- Usage
local card = PlayerCard {
    playerName = "Alex",
    level = 25
}
```

## Stateful Components

Components can have their own internal state:

```luau
local function Counter(props)
    local count = Rex.useState(props.initialValue or 0)
    local isHovered = Rex.useState(false)
    
    return Rex("Frame") {
        Size = UDim2.fromOffset(200, 100),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        children = {
            Rex("TextLabel") {
                Text = count:map(function(c) return `Count: {c}` end),
                Size = UDim2.new(1, 0, 0.5, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true
            },
            Rex("TextButton") {
                Text = "Increment",
                Size = UDim2.new(1, 0, 0.5, 0),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = isHovered:map(function(hovered)
                    return hovered and Color3.fromRGB(90, 150, 255) or Color3.fromRGB(70, 130, 255)
                end),
                onClick = function()
                    count:update(function(current) return current + 1 end)
                    -- Call parent callback if provided
                    if props.onCountChange then
                        props.onCountChange(count:get())
                    end
                end,
                onHover = function() isHovered:set(true) end,
                onLeave = function() isHovered:set(false) end
            }
        }
    }
end
```

## Component Composition

Build complex components by composing simpler ones:

```luau
-- Base components
local function IconButton(props)
    return Rex("TextButton") {
        Text = props.icon or "?",
        Size = props.size or UDim2.fromOffset(30, 30),
        BackgroundColor3 = props.color or Color3.fromRGB(70, 130, 255),
        TextColor3 = Color3.new(1, 1, 1),
        onClick = props.onClick
    }
end

local function Badge(props)
    return Rex("Frame") {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -10, 0, -10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 100, 100),
        children = {
            Rex("UICorner") { CornerRadius = UDim.new(0.5, 0) },
            Rex("TextLabel") {
                Text = tostring(props.count or 0),
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                Font = Enum.Font.SourceSansBold
            }
        }
    }
end

-- Composed component
local function NotificationButton(props)
    local notificationCount = props.notificationCount or 0
    
    return Rex("Frame") {
        Size = UDim2.fromOffset(30, 30),
        BackgroundTransparency = 1,
        children = {
            IconButton {
                icon = "🔔",
                onClick = props.onClick,
                color = Color3.fromRGB(255, 150, 0)
            },
            -- Conditionally render badge
            notificationCount > 0 and Badge { count = notificationCount } or nil
        }
    }
end
```

## Higher-Order Components

Create components that enhance other components:

```luau
local function withLoading(WrappedComponent)
    return function(props)
        local isLoading = props.isLoading or false
        
        if isLoading then
            return Rex("Frame") {
                Size = props.size or UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                children = {
                    Rex("TextLabel") {
                        Text = "Loading...",
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true
                    }
                }
            }
        end
        
        return WrappedComponent(props)
    end
end

-- Usage
local LoadablePlayerCard = withLoading(PlayerCard)

local card = LoadablePlayerCard {
    playerName = "Alex",
    level = 25,
    isLoading = false
}
```

## Children Props Pattern

Components can accept and render children:

```luau
local function Card(props)
    return Rex("Frame") {
        Size = props.size or UDim2.fromOffset(300, 200),
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        children = {
            Rex("UICorner") { CornerRadius = UDim.new(0, 12) },
            Rex("UIPadding") { 
                PaddingTop = UDim.new(0, 15),
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingBottom = UDim.new(0, 15)
            },
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            },
            -- Render children passed from parent
            props.children
        }
    }
end

-- Usage with children
local myCard = Card {
    size = UDim2.fromOffset(400, 300),
    children = {
        Rex("TextLabel") {
            Text = "Card Title",
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.SourceSansBold
        },
        Rex("TextLabel") {
            Text = "Card content goes here...",
            LayoutOrder = 2,
            Size = UDim2.new(1, 0, 1, -40),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextWrapped = true
        }
    }
}
```

## Render Props Pattern

Pass functions as props to share logic:

```luau
local function DataProvider(props)
    local data = Rex.useState(nil)
    local loading = Rex.useState(true)
    local error = Rex.useState(nil)
    
    -- Simulate data fetching
    Rex.useEffect(function()
        loading:set(true)
        error:set(nil)
        
        task.spawn(function()
            wait(1) -- Simulate network delay
            
            local success, result = pcall(props.fetchData)
            if success then
                data:set(result)
            else
                error:set("Failed to fetch data")
            end
            loading:set(false)
        end)
    end, {})
    
    -- Call render prop with current state
    return props.render({
        data = data:get(),
        loading = loading:get(),
        error = error:get()
    })
end

-- Usage
local function App()
    return DataProvider {
        fetchData = function()
            return {
                name = "Player",
                level = 10,
                coins = 1500
            }
        end,
        render = function(state)
            if state.loading then
                return Rex("TextLabel") { Text = "Loading..." }
            end
            
            if state.error then
                return Rex("TextLabel") { 
                    Text = `Error: {state.error}`,
                    TextColor3 = Color3.fromRGB(255, 100, 100)
                }
            end
            
            return PlayerCard {
                playerName = state.data.name,
                level = state.data.level
            }
        end
    }
end
```

## Custom Hooks Pattern

Extract stateful logic into reusable functions:

```luau
-- Custom hook for toggle functionality
local function useToggle(initialValue)
    local value = Rex.useState(initialValue or false)
    
    local toggle = function()
        value:update(function(current) return not current end)
    end
    
    local setTrue = function() value:set(true) end
    local setFalse = function() value:set(false) end
    
    return value, {
        toggle = toggle,
        setTrue = setTrue,
        setFalse = setFalse
    }
end

-- Custom hook for API data
local function useApiData(endpoint, dependencies)
    local data = Rex.useState(nil)
    local loading = Rex.useState(false)
    local error = Rex.useState(nil)
    
    local fetchData = function()
        loading:set(true)
        error:set(nil)
        
        task.spawn(function()
            local success, result = pcall(function()
                -- Simulate API call
                wait(0.5)
                return fetchFromApi(endpoint)
            end)
            
            if success then
                data:set(result)
            else
                error:set("Failed to fetch data")
            end
            loading:set(false)
        end)
    end
    
    Rex.useEffect(fetchData, dependencies or {})
    
    return {
        data = data,
        loading = loading,
        error = error,
        refetch = fetchData
    }
end

-- Using custom hooks
local function ToggleButton()
    local isToggled, toggle = useToggle(false)
    
    return Rex("TextButton") {
        Text = isToggled:map(function(toggled) return toggled and "ON" or "OFF" end),
        onClick = toggle.toggle
    }
end

local function PlayerProfile(props)
    local playerData = useApiData(`/players/{props.playerId}`, {props.playerId})
    
    if playerData.loading:get() then
        return Rex("TextLabel") { Text = "Loading player..." }
    end
    
    if playerData.error:get() then
        return Rex("TextLabel") { 
            Text = `Error: {playerData.error:get()}`,
            TextColor3 = Color3.fromRGB(255, 100, 100)
        }
    end
    
    return PlayerCard {
        playerName = playerData.data:get().name,
        level = playerData.data:get().level
    }
end
```

## Component Communication Patterns

### Parent-Child Communication

```luau
local function ParentComponent()
    local childData = Rex.useState("Hello from parent")
    local childResponse = Rex.useState("")
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = `Child said: {childResponse:get()}`
            },
            ChildComponent {
                data = childData:get(),
                onResponse = function(response)
                    childResponse:set(response)
                end
            }
        }
    }
end

local function ChildComponent(props)
    return Rex("TextButton") {
        Text = `Received: {props.data}`,
        onClick = function()
            props.onResponse("Hello from child!")
        end
    }
end
```

### Sibling Communication via Context

```luau
local AppStateContext = Rex.createContext({
    user = nil,
    notifications = {}
})

local function App()
    local appState = Rex.useState({
        user = { name = "Player", level = 1 },
        notifications = {}
    })
    
    return Rex.Provider {
        context = AppStateContext,
        value = appState,
        children = {
            Header(),
            MainContent(),
            NotificationPanel()
        }
    }
end

local function Header()
    local appState = Rex.useContext(AppStateContext)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = appState:map(function(state) 
                    return `Welcome, {state.user.name}!`
                end)
            }
        }
    }
end

local function NotificationPanel()
    local appState = Rex.useContext(AppStateContext)
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = appState:map(function(state)
                    return `{#state.notifications} notifications`
                end)
            }
        }
    }
end
```

## Component Best Practices

### 1. Single Responsibility Principle

```luau
-- Good: Component has single responsibility
local function UserAvatar(props)
    return Rex("ImageLabel") {
        Image = props.avatarUrl,
        Size = props.size or UDim2.fromOffset(50, 50)
    }
end

local function UserInfo(props)
    return Rex("Frame") {
        children = {
            UserAvatar { avatarUrl = props.user.avatar, size = props.avatarSize },
            Rex("TextLabel") { Text = props.user.name }
        }
    }
end

-- Less ideal: Component doing too much
local function UserEverything(props)
    -- Handles avatar, info, settings, notifications, etc.
end
```

### 2. Prop Validation

```luau
local function Button(props)
    -- Validate required props
    assert(props.text, "Button requires text prop")
    assert(typeof(props.onClick) == "function", "Button requires onClick function")
    
    return Rex("TextButton") {
        Text = props.text,
        onClick = props.onClick
    }
end
```

### 3. Default Props

```luau
local function Card(props)
    -- Set defaults
    local size = props.size or UDim2.fromOffset(300, 200)
    local backgroundColor = props.backgroundColor or Color3.fromRGB(50, 50, 60)
    local cornerRadius = props.cornerRadius or UDim.new(0, 8)
    
    return Rex("Frame") {
        Size = size,
        BackgroundColor3 = backgroundColor,
        children = {
            Rex("UICorner") { CornerRadius = cornerRadius },
            props.children
        }
    }
end
```

### 4. Composable Design

```luau
-- Good: Small, composable components
local function Icon(props) ... end
local function Text(props) ... end
local function Button(props) ... end

local function IconButton(props)
    return Button {
        children = {
            Icon { name = props.icon },
            Text { content = props.text }
        },
        onClick = props.onClick
    }
end

-- Less ideal: Monolithic components
local function MegaComponent(props)
    -- Tries to handle everything internally
end
```

Components are the heart of Rex applications. By following these patterns and principles, you can build maintainable, reusable, and composable user interfaces that scale with your application's complexity.
