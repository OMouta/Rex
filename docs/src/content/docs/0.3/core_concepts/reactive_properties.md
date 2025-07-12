---
title: "Reactive Properties"
description: "Learn how to create dynamic UIs with Rex's universal reactivity system - direct state binding with automatic type conversion."
category: "Core Concepts"
order: 3

lastUpdated: 2025-07-13
---

Rex features a **universal reactivity system** that automatically detects and handles reactive values, making it incredibly simple to create dynamic UIs. You can bind state directly to any property, and Rex will automatically convert types and handle updates.

## Universal Direct Binding

Rex's universal reactivity means you can bind state objects directly to any property without manual conversion:

```luau
local function UniversalReactivityExample()
    local count = Rex.useState(42)
    local isVisible = Rex.useState(true)
    local message = Rex.useState("Hello, Rex!")
    local color = Rex.useState(Color3.fromRGB(255, 100, 50))
    
    return Rex("TextLabel") {
        -- Direct state binding - automatically reactive!
        Text = count,              -- Number → String (auto-converted)
        Visible = isVisible,       -- Boolean → Boolean (direct)
        BackgroundColor3 = color,  -- Color3 → Color3 (direct)
        Size = UDim2.fromScale(0.5, 0.5), -- Static value
        
        -- Even complex expressions work
        TextTransparency = isVisible:map(function(visible)
            return visible and 0 or 1
        end)
    }
end
```

**What happens automatically:**

- Numbers are converted to strings for `Text` properties
- Booleans work directly with `Visible` properties  
- Color3 values bind directly to color properties
- Rex detects reactive values and sets up automatic updates
- Static values are set normally

## Auto-Type Conversion

Rex automatically converts between compatible types:

```luau
local function AutoConversionExample()
    local health = Rex.useState(75)      -- Number
    local isAlive = Rex.useState(true)   -- Boolean
    local level = Rex.useState(10)       -- Number
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                -- Number automatically converts to string
                Text = health,  -- Shows "75"
                -- Boolean converts to visibility
                Visible = isAlive,
                Size = UDim2.new(1, 0, 0, 30)
            },
            Rex("TextLabel") {
                -- Complex auto-conversion
                Text = level,  -- Shows "10"
                -- Number can convert to transparency (0-1 range)
                BackgroundTransparency = health:map(function(h) return (100 - h) / 100 end),
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 30)
            }
        }
    }
end
```

**Supported auto-conversions:**

- `number` → `string` (for Text properties)
- `boolean` → `boolean` (for Visible properties)  
- `number` → `number` (for transparency, size values)
- Any type can use `:map()` for custom conversion

## State Transformations with `map`

Use the `map` method to transform state values before applying them to properties:

```luau
local function TransformExample()
    local count = Rex.useState(0)
    local isVisible = Rex.useState(true)
    
    return Rex("TextLabel") {
        -- Transform number to string with formatting
        Text = count:map(function(value)
            if value == 0 then
                return "No items"
            elseif value == 1 then
                return "1 item"
            else
                return `{value} items`
            end
        end),
        
        -- Transform boolean to transparency
        BackgroundTransparency = isVisible:map(function(visible)
            return visible and 0 or 1
        end),
        
        -- Transform count to color (red when 0, green when > 0)
        BackgroundColor3 = count:map(function(value)
            return value > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end)
    }
end
```

## Computed Properties

Use computed states for complex property calculations:

```luau
local function ComputedPropertiesExample()
    local health = Rex.useState(100)
    local maxHealth = Rex.useState(100)
    
    -- Computed health percentage
    local healthPercent = Rex.useComputed(function()
        return health:get() / maxHealth:get()
    end, {health, maxHealth})
    
    return Rex("Frame") {
        children = {
            -- Health bar background
            Rex("Frame") {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = Color3.fromRGB(100, 100, 100),
                children = {
                    -- Health bar fill (reactive width)
                    Rex("Frame") {
                        Size = healthPercent:map(function(percent)
                            return UDim2.new(percent, 0, 1, 0)
                        end),
                        BackgroundColor3 = healthPercent:map(function(percent)
                            -- Red when low health, green when full
                            if percent > 0.6 then
                                return Color3.fromRGB(0, 255, 0)
                            elseif percent > 0.3 then
                                return Color3.fromRGB(255, 255, 0)
                            else
                                return Color3.fromRGB(255, 0, 0)
                            end
                        end)
                    }
                }
            },
            -- Health text
            Rex("TextLabel") {
                Text = healthPercent:map(function(percent)
                    return `{math.floor(percent * 100)}%`
                end),
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 25),
                BackgroundTransparency = 1
            }
        }
    }
end
```

## Deep State Properties

When using deep reactive state, you can bind to nested properties:

```luau
local function PlayerStatsExample()
    local player = Rex.useDeepState({
        name = "Player",
        level = 1,
        stats = {
            health = 100,
            mana = 50,
            experience = 0
        },
        appearance = {
            theme = "dark",
            color = Color3.fromRGB(70, 130, 255)
        }
    })
    
    return Rex("Frame") {
        -- Bind to nested properties using map
        BackgroundColor3 = player:map(function(p) return p.appearance.color end),
        
        children = {
            Rex("TextLabel") {
                Text = player:map(function(p) 
                    return `{p.name} (Level {p.level})`
                end),
                TextColor3 = player:map(function(p)
                    return p.appearance.theme == "dark" and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
                end)
            },
            Rex("TextLabel") {
                Text = player:map(function(p)
                    return `HP: {p.stats.health} | MP: {p.stats.mana}`
                end)
            }
        }
    }
end
```

## Conditional Properties

Create conditional properties that change based on state:

```luau
local function ConditionalExample()
    local mode = Rex.useState("normal") -- "normal", "warning", "error"
    local isEnabled = Rex.useState(true)
    
    return Rex("TextButton") {
        Text = mode:map(function(m)
            if m == "error" then return "Error!"
            elseif m == "warning" then return "Warning!"
            else return "Normal"
            end
        end),
        
        -- Conditional styling based on mode
        BackgroundColor3 = mode:map(function(m)
            if m == "error" then return Color3.fromRGB(255, 100, 100)
            elseif m == "warning" then return Color3.fromRGB(255, 200, 100)
            else return Color3.fromRGB(100, 150, 255)
            end
        end),
        
        -- Conditional event handlers
        onClick = isEnabled:map(function(enabled)
            return enabled and function()
                print("Button clicked in", mode:get(), "mode")
            end or nil
        end),
        
        -- Conditional transparency
        BackgroundTransparency = isEnabled:map(function(enabled)
            return enabled and 0 or 0.5
        end)
    }
end
```

## Animation-Ready Properties

Combine reactive properties with tweening for smooth animations:

```luau
local function AnimatedExample()
    local isExpanded = Rex.useState(false)
    local currentSize = Rex.useState(UDim2.fromOffset(100, 100))
    
    -- Animate size changes
    Rex.useEffect(function()
        local targetSize = isExpanded:get() and UDim2.fromOffset(200, 200) or UDim2.fromOffset(100, 100)
        
        -- Create tween
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Since we can't tween state directly, we'll tween a temporary object
        local proxy = { Size = currentSize:get() }
        local tween = game:GetService("TweenService"):Create(proxy, tweenInfo, { Size = targetSize })
        
        local connection = tween:GetPropertyChangedSignal("PlaybackState"):Connect(function()
            if tween.PlaybackState == Enum.PlaybackState.Playing then
                -- Update state during tween
                game:GetService("RunService").Heartbeat:Connect(function()
                    if tween.PlaybackState == Enum.PlaybackState.Playing then
                        currentSize:set(proxy.Size)
                    end
                end)
            end
        end)
        
        tween:Play()
        
        return function()
            connection:Disconnect()
            tween:Destroy()
        end
    end, {isExpanded})
    
    return Rex("TextButton") {
        Text = isExpanded:map(function(expanded) return expanded and "Collapse" or "Expand" end),
        Size = currentSize, -- Reactive animated size
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        
        onClick = function()
            isExpanded:update(function(current) return not current end)
        end
    }
end
```

## Performance Considerations

### 1. Avoid Expensive Transformations

```luau
-- Good: Simple transformation
local text = count:map(function(c) return tostring(c) end)

-- Less ideal: Expensive transformation
local text = count:map(function(c)
    -- Expensive operation on every change
    local result = ""
    for i = 1, c do
        result = result .. "expensive calculation"
    end
    return result
end)
```

### 2. Use Computed States for Complex Logic

```luau
-- Good: Use computed state for expensive calculations
local expensiveResult = Rex.useComputed(function()
    return performExpensiveCalculation(data:get())
end, {data})

local element = Rex("TextLabel") {
    Text = expensiveResult -- Simple binding to computed state
}

-- Less ideal: Expensive calculation in map
local element = Rex("TextLabel") {
    Text = data:map(function(d)
        return performExpensiveCalculation(d) -- Recalculated every time
    end)
}
```

### 3. Memoize Computed Properties

```luau
-- Use memoization for expensive computed properties
local expensiveProperty = Rex.useComputed(function()
    return heavyCalculation(input:get())
end, {input}, "expensivePropertyKey") -- Memoization key
```

## Common Patterns

### Theme System

```luau
local function ThemedComponent()
    local theme = Rex.useContext(ThemeContext)
    
    return Rex("Frame") {
        BackgroundColor3 = theme:map(function(t) return t.backgroundColor end),
        BorderColor3 = theme:map(function(t) return t.borderColor end),
        
        children = {
            Rex("TextLabel") {
                TextColor3 = theme:map(function(t) return t.textColor end),
                Font = theme:map(function(t) return t.font end)
            }
        }
    }
end
```

### Responsive Design

```luau
local function ResponsiveComponent()
    local screenSize = Rex.useState(workspace.CurrentCamera.ViewportSize)
    
    -- Update screen size on resize
    Rex.useEffect(function()
        local connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            screenSize:set(workspace.CurrentCamera.ViewportSize)
        end)
        return function() connection:Disconnect() end
    end, {})
    
    return Rex("Frame") {
        -- Responsive size based on screen size
        Size = screenSize:map(function(size)
            local scale = math.min(size.X / 1920, size.Y / 1080)
            return UDim2.fromOffset(400 * scale, 300 * scale)
        end),
        
        -- Responsive text size
        children = {
            Rex("TextLabel") {
                TextScaled = false,
                TextSize = screenSize:map(function(size)
                    return math.max(12, size.Y / 50) -- Minimum 12px, scales with height
                end)
            }
        }
    }
end
```

### Data-Driven UI

```luau
local function DataDrivenList()
    local items = Rex.useState({
        {name = "Apple", color = Color3.fromRGB(255, 0, 0), price = 1.50},
        {name = "Banana", color = Color3.fromRGB(255, 255, 0), price = 0.75},
        {name = "Cherry", color = Color3.fromRGB(200, 0, 100), price = 2.00}
    })
    
    return Rex("ScrollingFrame") {
        children = {
            Rex("UIListLayout") {},
            items:map(function(itemList)
                local children = {}
                for i, item in ipairs(itemList) do
                    table.insert(children, Rex("Frame") {
                        key = item.name,
                        BackgroundColor3 = item.color,
                        Size = UDim2.new(1, 0, 0, 50),
                        children = {
                            Rex("TextLabel") {
                                Text = `{item.name} - ${item.price}`,
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

Reactive properties are the heart of Rex's declarative approach. By binding state directly to UI properties, you create dynamic, responsive interfaces that automatically stay in sync with your application's data.
