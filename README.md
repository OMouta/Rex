<div align="center">

# Rex UI Framework

![Rex Banner](assets/RexBannerBackground.png)

## A modern, declarative UI framework for Roblox

Bringing React/VueJs-inspired patterns to Roblox development

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/your-username/rex)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Roblox](https://img.shields.io/badge/platform-Roblox-red.svg)](https://roblox.com)

</div>

## ✨ Features

- 🔧 **Declarative Syntax** - Write UI with Templated Luau syntax
- ⚡ **Reactive State Management** - Automatic UI updates when data changes
- 🧩 **Component-Based** - Build reusable, composable UI components
- 🎯 **Virtual DOM** - Efficient reconciliation and rendering
- 🔄 **Lifecycle Hooks** - useEffect, onMount, onUnmount for component lifecycle
- 🌐 **Context API** - Share state across component trees without prop drilling
- 🚀 **Performance Optimized** - Key-based diffing and batched updates
- 📘 **Type Safety** - Full Luau type support for better development experience

## 🚀 Quick Start

### Installation

1. Download the latest release from [Releases](https://github.com/your-username/rex/releases)
2. Place the `Rex` folder in your `ReplicatedStorage`
3. Require Rex in your scripts:

```lua
local Rex = require(game.ReplicatedStorage.Rex)
```

### Your First Component

```lua
local Rex = require(game.ReplicatedStorage.Rex)

local function Counter()
    local count = Rex.useState(0)
    
    return Rex("ScreenGui") {
        children = {
            Rex("Frame") {
                Size = UDim2.fromOffset(200, 100),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                children = {
                    Rex("TextLabel") {
                        Text = count:map(function(c) return `Count: {c}` end),
                        Size = UDim2.new(1, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                    },
                    Rex("TextButton") {
                        Text = "Click me!",
                        Size = UDim2.new(1, 0, 0.5, 0),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        onClick = function()
                            count:update(function(current) return current + 1 end)
                        end
                    }
                }
            }
        }
    }
end

-- Render to player's GUI
local Players = game:GetService("Players")
Rex.render(Counter, Players.LocalPlayer.PlayerGui)
```

## 📖 Core Concepts

### State Management

Rex provides multiple state primitives for different use cases:

```lua
-- Basic reactive state
local count = Rex.useState(0)
count:set(10)
local value = count:get()

-- Deep reactive state for complex objects
local user = Rex.useDeepState({
    name = "Player",
    inventory = { coins = 100, items = {} }
})

-- Computed state that updates automatically
local displayText = Rex.useComputed(function()
    return `Player has {user:get().inventory.coins} coins`
end, {user})

-- Async state for API calls or async operations
local userData = Rex.useAsyncState(function()
    return fetchPlayerData()
end)
-- Access: userData.data, userData.loading, userData.error
```

### Event Handling

Rex uses intuitive camelCase event names:

```lua
Rex("TextButton") {
    Text = "Interactive Button",
    onClick = function() print("Clicked!") end,
    onHover = function() print("Hovered!") end,
    onLeave = function() print("Mouse left") end,
    onFocusLost = function(instance, enterPressed)
        print("Focus lost, enter pressed:", enterPressed)
    end
}
```

### Dynamic Lists

Render lists efficiently with automatic reconciliation:

```lua
local function TodoList()
    local todos = Rex.useState({"Learn Rex", "Build awesome UI", "Ship to production"})
    
    return Rex("ScrollingFrame") {
        children = {
            Rex("UIListLayout") {},
            todos:map(function(todoList)
                local children = {}
                for i, todo in ipairs(todoList) do
                    table.insert(children, Rex("TextLabel") {
                        Text = todo,
                        key = tostring(i), -- Important for efficient updates!
                        Size = UDim2.new(1, 0, 0, 30)
                    })
                end
                return children
            end)
        }
    }
end
```

### Component Lifecycle

Use effects and lifecycle hooks for side effects:

```lua
local function TimerComponent()
    local seconds = Rex.useState(0)
    
    -- Effect with cleanup
    Rex.useEffect(function()
        local connection = game:GetService("RunService").Heartbeat:Connect(function()
            seconds:update(function(s) return s + 1 end)
        end)
        
        -- Cleanup function
        return function()
            connection:Disconnect()
        end
    end, {}) -- Empty dependency array = run once on mount
    
    -- Mount hook
    Rex.onMount(function()
        print("Timer started!")
    end)
    
    return Rex("TextLabel") {
        Text = seconds:map(function(s) return `Time: {s}s` end)
    }
end
```

## 🏗️ Architecture

Rex is built with modularity and performance in mind:

```txt
Rex/
├── init.luau              # Main API and exports
├── Types.luau             # Type definitions
├── State.luau             # State management system
├── ElementBuilder.luau    # Element creation and reconciliation
├── Props.luau             # Property and event handling
└── Renderer.luau          # Rendering and mounting
```

### Key Features

- **Virtual DOM**: Efficient diffing algorithm minimizes actual DOM manipulations
- **Key-based Reconciliation**: Stable list updates using element keys
- **Reactive Bindings**: Automatic cleanup when components unmount
- **Context System**: Share state without prop drilling
- **Type Safety**: Full Luau type annotations for better DX

## 📚 Examples

Check out the `/src/Client` directory for complete examples:

- **SimpleCounter** - Basic state and event handling
- **DynamicList** - List rendering with add/remove functionality
- **ModularComponents** - Component composition patterns

## 🔧 Advanced Usage

### Context for Global State

```lua
-- Create a theme context
local ThemeContext = Rex.createContext({
    primary = Color3.fromRGB(70, 130, 255),
    background = Color3.fromRGB(30, 30, 40)
})

-- Provide theme to app
local function App()
    local theme = Rex.useState({
        primary = Color3.fromRGB(70, 130, 255),
        background = Color3.fromRGB(30, 30, 40)
    })
    
    return Rex.Provider {
        context = ThemeContext,
        value = theme,
        children = {
            MainUI()
        }
    }
end

-- Consume theme in components
local function ThemedButton()
    local theme = Rex.useContext(ThemeContext)
    
    return Rex("TextButton") {
        BackgroundColor3 = theme.primary,
        -- ... other props
    }
end
```

### Custom Hooks Pattern

```lua
-- Create reusable stateful logic
local function useToggle(initialValue)
    local value = Rex.useState(initialValue or false)
    
    local toggle = function()
        value:update(function(current) return not current end)
    end
    
    return value, toggle
end

-- Use in components
local function ToggleButton()
    local isOn, toggle = useToggle(false)
    
    return Rex("TextButton") {
        Text = isOn:map(function(on) return on and "ON" or "OFF" end),
        onClick = toggle
    }
end
```

## 🎯 Performance Tips

1. **Use keys for dynamic lists** to enable efficient reconciliation
2. **Batch state updates** with `Rex.batch()` for multiple changes
3. **Memoize expensive computations** with `Rex.useComputed()`
4. **Prefer flat state structures** over deeply nested objects
5. **Clean up effects** by returning cleanup functions
6. **Define event handlers outside render** to avoid recreating functions

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

Rex is [MIT licensed](LICENSE).

## 🔮 Roadmap

- [ ] **v0.2.0**: Dev tools and debugging utilities  
- [ ] **v0.3.0**: Server-side rendering capabilities
- [ ] **v1.0.0**: Stable API and comprehensive documentation

---

<div align="center">

## Built with ❤️ by OMouta and the Community

[Documentation](https://rex.tigas.dev) • [Examples](./src/Client) • [API Reference](https://rex.tigas.dev/api)

</div>
