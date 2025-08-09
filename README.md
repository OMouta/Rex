**Rex is currently undergoing a major internal change, please use another framework until this change is done**

---

<div align="center">

![Rex Banner](assets/RexBannerBackground.png)

## The Reactive Roblox Framework

Build reactive, component-based user interfaces with Rex—a declarative UI framework inspired by React/VueJs patterns, designed specifically for Roblox and Luau.

[![Version](https://img.shields.io/badge/version-0.2-blue.svg)](https://github.com/OMouta/Rex)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

## ✨ Features

- 🔧 **Declarative Syntax** - Write UI with intuitive Luau syntax
- ⚡ **Universal Reactivity** - Direct state binding with automatic type conversion
- 🚀 **Enhanced State Helpers** - Built-in `increment()`, `toggle()`, `push()`, `setPath()` and more
- 🧩 **Component-Based** - Build reusable, composable UI components
- 🎯 **Smart List Rendering** - Simplified `items:each()` syntax with automatic reconciliation
- 🔄 **Lifecycle Hooks** - useEffect, onMount, onUnmount for component lifecycle
- 🌐 **Context API** - Share state across component trees without prop drilling
- 🚀 **Performance Optimized** - Key-based diffing and batched updates
- 📘 **Type Safety** - Full Luau type support for better development experience
- 🔮 **Auto-Conversion** - Intelligent type conversion (number→string, Vector2→UDim2, etc.)

## 🚀 Quick Start

### Installation

#### Manual

- Download the latest release from [Releases](https://github.com/OMouta/Rex/releases)
- Place the `Rex` folder in your `ReplicatedStorage`

#### Jelly (with Rojo)

```bash
jelly install omouta/rex
```

#### Wally (with Rojo)

- Add `rex = "omouta/rex@0.2.2"` to your wally.toml and then run:

```bash
wally install
```

### Require Rex in your scripts

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
                        Text = count,
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
                            count:increment()
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

Rex provides powerful state primitives with enhanced operation helpers:

```lua
-- Basic reactive state with enhanced helpers
local count = Rex.useState(0)
count:increment()      -- Add 1
count:increment(5)     -- Add 5  
count:decrement()      -- Subtract 1
count:set(10)          -- Direct set
local value = count:get() -- Get current value

-- Boolean state with toggle helper
local isVisible = Rex.useState(true)
isVisible:toggle()     -- Flip boolean state

-- Array state with array helpers
local items = Rex.useState({"apple", "banana"})
items:push("cherry")           -- Add item
items:push("date", "elderberry") -- Add multiple
local removed = items:pop()    -- Remove and return last
items:removeAt(2)             -- Remove by index
items:remove("banana")        -- Remove by value
items:clear()                 -- Clear all

-- Object state with path helpers
local user = Rex.useDeepState({
    name = "Player",
    settings = { theme = "dark", volume = 0.8 }
})
user:setPath("settings.theme", "light")    -- Set nested property
local theme = user:getPath("settings.theme") -- Get nested property

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

Render lists efficiently with the new simplified `each` syntax:

```lua
local function TodoList()
    local todos = Rex.useState({"Learn Rex", "Build awesome UI", "Ship to production"})
    
    return Rex("ScrollingFrame") {
        children = {
            Rex("UIListLayout") {},
            
            -- 🚀 New simplified list rendering!
            todos:each(function(todo, index)
                return Rex("Frame") {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 60),
                    key = todo, -- Automatic key-based reconciliation
                    
                    children = {
                        Rex("TextLabel") {
                            Text = todo,
                            Size = UDim2.new(0.8, 0, 1, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.new(1, 1, 1),
                        },
                        Rex("TextButton") {
                            Text = "Remove",
                            Size = UDim2.new(0.2, 0, 1, 0),
                            Position = UDim2.new(0.8, 0, 0, 0),
                            onClick = function()
                                todos:removeAt(index) -- Enhanced helper!
                            end
                        }
                    }
                }
            end)
        }
    }
end
```

### Wrapping Existing UI with Rex.define

Transform Studio-created UI into reactive Rex components effortlessly:

```lua
-- Your existing UI hierarchy from Studio
local existingUI = script.Parent.ShopFrame

-- Wrap it with Rex reactivity!
local ShopComponent = Rex.define(existingUI) {
    -- Override properties reactively
    Visible = isShopOpen,
    BackgroundColor3 = theme:map(function(t) return t.primary end),
    
    -- Reference children by name and enhance them
    children = {
        -- Wrap the buy button and add click handler
        buyButton = Rex.define() {
            onClick = function()
                purchaseItem(selectedItem:get())
            end,
            BackgroundColor3 = canAfford:map(function(affordable)
                return affordable and Color3.new(0, 1, 0) or Color3.new(0.5, 0.5, 0.5)
            end)
        },
        
        -- Wrap the item list with reactive content
        itemList = {
            children = items:each(function(item)
                return ItemComponent { item = item, key = item.id }
            end)
        }
    }
}

-- Mount your enhanced component
Rex.render(ShopComponent, playerGui)
```

**Perfect for migration**: Start with Studio UI, then gradually add Rex features like state management, reactive properties, and event handling without rebuilding everything from scratch!

**Universal Auto-Conversion**: Rex automatically converts between compatible types:

```lua
local count = Rex.useState(42)
local isVisible = Rex.useState(true)
local position = Rex.useState(Vector2.new(100, 50))

Rex("Frame") {
    Text = count,           -- number → string (automatic!)
    Visible = isVisible,    -- boolean → boolean (direct)
    Position = position,    -- Vector2 → UDim2 (automatic!)
}
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

1. **Use the new state helpers** - `count:increment()` instead of `count:update(c => c + 1)`
2. **Leverage auto-conversion** - Use `Text = numberState` instead of manual mapping
3. **Use `each` for lists** - Simpler syntax with automatic key management
4. **Batch state updates** with `Rex.batch()` for multiple simultaneous changes
5. **Memoize expensive computations** with `Rex.useComputed()`
6. **Use path helpers for objects** - `user:setPath("settings.theme", "dark")` is more efficient
7. **Clean up effects** by returning cleanup functions
8. **Prefer direct state binding** over manual reactive mapping when possible

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

- [x] **v0.1.0**: Core reactivity and component system
- [x] **v0.2.0**: Direct state binding with auto-conversion
- [x] **v0.3.0**: Rex.define for wrapping and enhancing existing Roblox UI instances
- [ ] **v1.0.0**: Stable API and comprehensive documentation
- [ ] **v1.1.0**: Dev tools and debugging utilities
- [ ] **v1.2.0**: Animation and transition system
- [ ] **v1.3.0**: Advanced performance optimizations

---

<div align="center">

## Built with ❤️ by OMouta

[Documentation](https://rex.tigas.dev) • [Examples](https://rex.tigas.dev/docs/0.2/examples/simple_counter) • [API Reference](https://rex.tigas.dev/docs/0.2/api_reference/state)

</div>
