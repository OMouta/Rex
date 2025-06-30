---
title: "Introduction to Rex"
description: "Rex is a modern, declarative UI framework for Roblox, written in Luau. Inspired by React and Vue.js, Rex brings component-based architecture, reactive state management, and efficient rendering to Roblox development."
category: "Getting Started"
order: 1
version: "0.2.0"
lastUpdated: 2025-06-23
---

Rex is a modern UI framework that brings the best practices from web development to Roblox. Built with Luau and inspired by React and Vue.js, Rex makes building complex, interactive UIs both intuitive and efficient.

## Key Features

- 🔧 **Declarative Syntax**: Write UI with intuitive Luau syntax using `Rex("ClassName") { props }`
- ⚡ **Universal Reactivity**: Direct state binding with automatic type conversion
- 🚀 **Enhanced State Helpers**: Built-in `increment()`, `toggle()`, `push()`, `setPath()` and more
- 🧩 **Component-Based Architecture**: Build reusable, composable UI components
- 🎯 **Smart List Rendering**: Simplified `items:each()` syntax with automatic reconciliation
- 🔄 **Lifecycle Hooks**: `useEffect`, `onMount`, `onUnmount` for component lifecycle management
- 🌐 **Context API**: Share state across component trees without prop drilling
- 🚀 **Performance Optimized**: Batched updates, memoization, and efficient reactive bindings
- 📘 **Type Safety**: Full Luau type support for better development experience
- 🎮 **Event Handling**: Unified camelCase event system (`onClick`, `onHover`, etc.)
- 🔮 **Auto-Conversion**: Intelligent type conversion (number→string, Vector2→UDim2, etc.)
- 🏗️ **Legacy Integration**: Wrap existing Studio UI with `Rex.define()` for gradual migration

## Philosophy

Rex follows these core principles:

1. **Declarative over Imperative**: Describe what your UI should look like, not how to build it
2. **Reactive by Default**: State changes automatically update the UI
3. **Component Composition**: Build complex UIs from simple, reusable components
4. **Performance First**: Efficient rendering and minimal UI updates
5. **Developer Experience**: Intuitive APIs with comprehensive type safety

## Quick Example

```luau
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
Rex.render(Counter, game.Players.LocalPlayer.PlayerGui)
```

## Why Rex?

Traditional Roblox UI development involves:

- Manual instance creation and property setting
- Imperative event handling and cleanup
- Complex state synchronization across UI elements
- Verbose, repetitive code patterns
- Difficult component reuse and composition

Rex solves these challenges by:

- **Reducing boilerplate**: Declarative syntax eliminates verbose instance creation
- **Automatic updates**: Reactive state keeps UI in sync with data
- **Component reuse**: Build once, use anywhere with customizable props
- **Predictable patterns**: Consistent APIs and lifecycle management
- **Better performance**: Optimized rendering with virtual DOM diffing

Rex isn't just a framework—it's a modern approach to building maintainable, scalable, and performant UIs in Roblox.

## Getting Started

Ready to start building with Rex? Follow this learning path:

1. **[Installation](./installation)** - Set up Rex in your project
2. **[Basic Component Tutorial](./basic_component_tutorial)** - Create your first interactive component in 5 minutes
3. **[Your First Component](./your_first_component)** - Build a complete like button with advanced features
4. **[State Management Basics](./state_management_basics)** - Master Rex's reactive state system
5. **[Quick Start Guide](./quick_start_guide)** - Build a full todo app in 10 minutes

### Next Steps

After completing the getting started guides, explore:

- **[Core Concepts](./core_concepts/states)** - Deep dive into Rex's architecture
- **[Examples](./examples/simple_counter)** - Real-world component examples  
- **[API Reference](./api_reference/state)** - Complete API documentation
- **[Advanced Features](./advanced_features/memoization)** - Performance and complex patterns
