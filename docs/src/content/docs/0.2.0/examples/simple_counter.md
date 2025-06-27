---
title: "Simple Counter"
description: "Learn Rex fundamentals with a simple counter that demonstrates reactive state, computed values, event handling, and component lifecycle."
category: "Examples"
order: 1
version: "0.2.0"
lastUpdated: 2025-06-23
---

This example demonstrates the core concepts of Rex through a simple counter application using the new universal reactivity system. You'll learn about direct state binding, auto-conversion, enhanced state helpers, and component lifecycle.

## Basic Counter with Universal Reactivity

Let's start with a minimal counter implementation using Rex's new features:

```luau
local Rex = require(game.ReplicatedStorage.Rex)
local Players = game:GetService("Players")

local function SimpleCounter()
    local count = Rex.useState(0)
    
    return Rex("ScreenGui") {
        Name = "CounterApp",
        children = {
            Rex("Frame") {
                Size = UDim2.fromOffset(300, 150),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                children = {
                    Rex("UICorner") { CornerRadius = UDim.new(0, 12) },
                    Rex("UIPadding") {
                        PaddingTop = UDim.new(0, 20),
                        PaddingLeft = UDim.new(0, 20),
                        PaddingRight = UDim.new(0, 20),
                        PaddingBottom = UDim.new(0, 20)
                    },
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Vertical,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 15)
                    },
                    
                    -- Display count with custom formatting
                    Rex("TextLabel") {
                        Text = count:map(function(c) return `Count: {c}` end),
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansBold,
                        LayoutOrder = 1
                    },
                    
                    -- Increment button
                    Rex("TextButton") {
                        Text = "Increment",
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundColor3 = Color3.fromRGB(70, 130, 255),
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        LayoutOrder = 2,
                        onClick = function()
                            -- Use increment helper method
                            count:increment()
                        end,
                        children = {
                            Rex("UICorner") { CornerRadius = UDim.new(0, 8) }
                        }
                    }
                }
            }
        }
    }
end

-- Render the app
local cleanup = Rex.render(SimpleCounter, Players.LocalPlayer.PlayerGui)
```

## Enhanced Counter with Computed State

Let's enhance the counter with computed values and more sophisticated state management:

```luau
local function EnhancedCounter()
    local count = Rex.useState(0)
    
    -- Computed state that depends on count
    local displayText = Rex.useComputed(function()
        local currentCount = count:get()
        if currentCount == 0 then
            return "Click to start counting!"
        elseif currentCount == 1 then
            return "You clicked once!"
        elseif currentCount < 10 then
            return `You clicked {currentCount} times!`
        else
            return `Wow! {currentCount} clicks!`
        end
    end, {count})
    
    -- Computed color based on count
    local countColor = Rex.useComputed(function()
        local currentCount = count:get()
        if currentCount < 5 then
            return Color3.fromRGB(100, 150, 255)  -- Blue
        elseif currentCount < 10 then
            return Color3.fromRGB(255, 200, 100)  -- Orange
        else
            return Color3.fromRGB(100, 255, 150)  -- Green
        end
    end, {count})
    
    -- Check if count is even (for demonstration)
    local isEven = Rex.useComputed(function()
        return count:get() % 2 == 0
    end, {count})
    
    return Rex("ScreenGui") {
        Name = "EnhancedCounterApp",
        children = {
            Rex("Frame") {
                Size = UDim2.fromOffset(400, 250),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(30, 30, 40),
                children = {
                    Rex("UICorner") { CornerRadius = UDim.new(0, 16) },
                    Rex("UIPadding") {
                        PaddingTop = UDim.new(0, 25),
                        PaddingLeft = UDim.new(0, 25),
                        PaddingRight = UDim.new(0, 25),
                        PaddingBottom = UDim.new(0, 25)
                    },
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Vertical,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 15)
                    },
                    
                    -- Title
                    Rex("TextLabel") {
                        Text = "Enhanced Counter",
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansBold,
                        LayoutOrder = 1
                    },
                    
                    -- Dynamic display text
                    Rex("TextLabel") {
                        Text = displayText,
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundTransparency = 1,
                        TextColor3 = countColor,
                        TextScaled = true,
                        Font = Enum.Font.SourceSans,
                        LayoutOrder = 2
                    },
                    
                    -- Even/odd indicator
                    Rex("TextLabel") {
                        Text = isEven:map(function(even)
                            return count:get() == 0 and "" or (even and "Even number!" or "Odd number!")
                        end),
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansItalic,
                        LayoutOrder = 3
                    },
                    
                    -- Button container
                    Rex("Frame") {
                        Size = UDim2.new(1, 0, 0, 50),
                        BackgroundTransparency = 1,
                        LayoutOrder = 4,
                        children = {
                            Rex("UIListLayout") {
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 10)
                            },
                            
                            -- Decrement button
                            Rex("TextButton") {
                                Text = "-",
                                Size = UDim2.fromOffset(60, 50),
                                BackgroundColor3 = Color3.fromRGB(255, 100, 100),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 1,
                                onClick = function()
                                    -- Use decrement helper with minimum value
                                    count:decrement()
                                    if count:get() < 0 then
                                        count:set(0)
                                    end
                                end,
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 8) }
                                }
                            },
                            
                            -- Increment button
                            Rex("TextButton") {
                                Text = "+",
                                Size = UDim2.fromOffset(60, 50),
                                BackgroundColor3 = Color3.fromRGB(100, 255, 150),
                                TextColor3 = Color3.fromRGB(30, 30, 30),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 2,
                                onClick = function()
                                    -- Use increment helper
                                    count:increment()
                                end,
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 8) }
                                }
                            },
                            
                            -- Reset button
                            Rex("TextButton") {
                                Text = "Reset",
                                Size = UDim2.fromOffset(80, 50),
                                BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSans,
                                LayoutOrder = 3,
                                onClick = function()
                                    count:set(0)
                                end,
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 8) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end
```

## Counter with Effects and Lifecycle

This version demonstrates effects and component lifecycle:

```luau
local function CounterWithEffects()
    local count = Rex.useState(0)
    local totalClicks = Rex.useState(0)
    local isActive = Rex.useState(true)
    
    -- Effect: Log count changes
    Rex.useEffect(function()
        local currentCount = count:get()
        print(`Count changed to: {currentCount}`)                        -- Update total clicks when count increases
                        if currentCount > 0 then
                            totalClicks:increment()
                        end
    end, {count})
    
    -- Effect: Achievement check
    Rex.useEffect(function()
        local currentCount = count:get()
        if currentCount == 10 then
            print("Achievement unlocked: First 10 clicks!")
        elseif currentCount == 50 then
            print("Achievement unlocked: Clicking master!")
        elseif currentCount == 100 then
            print("Achievement unlocked: Century club!")
        end
    end, {count})
    
    -- Effect: Auto-increment when active
    Rex.useEffect(function()
        if not isActive:get() then
            return
        end
        
        local connection = task.spawn(function()
            while isActive:get() do
                wait(2) -- Auto-increment every 2 seconds
                if isActive:get() then
                    count:update(function(current) return current + 1 end)
                end
            end
        end)
        
        -- Cleanup function
        return function()
            task.cancel(connection)
        end
    end, {isActive})
    
    -- Mount effect
    Rex.onMount(function()
        print("Counter component mounted!")
        
        return function()
            print("Counter component unmounting...")
        end
    end)
    
    return Rex("ScreenGui") {
        Name = "CounterWithEffectsApp",
        children = {
            Rex("Frame") {
                Size = UDim2.fromOffset(450, 300),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                children = {
                    Rex("UICorner") { CornerRadius = UDim.new(0, 20) },
                    Rex("UIPadding") {
                        PaddingTop = UDim.new(0, 30),
                        PaddingLeft = UDim.new(0, 30),
                        PaddingRight = UDim.new(0, 30),
                        PaddingBottom = UDim.new(0, 30)
                    },
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Vertical,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 15)
                    },
                    
                    -- Title
                    Rex("TextLabel") {
                        Text = "Counter with Effects",
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansBold,
                        LayoutOrder = 1
                    },
                    
                    -- Current count
                    Rex("TextLabel") {
                        Text = count:map(function(c) return `Current: {c}` end),
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(100, 200, 255),
                        TextScaled = true,
                        Font = Enum.Font.SourceSans,
                        LayoutOrder = 2
                    },
                    
                    -- Total clicks
                    Rex("TextLabel") {
                        Text = totalClicks:map(function(total) return `Total clicks: {total}` end),
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(150, 150, 150),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansItalic,
                        LayoutOrder = 3
                    },
                    
                    -- Auto-increment status
                    Rex("TextLabel") {
                        Text = isActive:map(function(active) 
                            return active and "Auto-increment: ON" or "Auto-increment: OFF"
                        end),
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundTransparency = 1,
                        TextColor3 = isActive:map(function(active)
                            return active and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
                        end),
                        TextScaled = true,
                        Font = Enum.Font.SourceSans,
                        LayoutOrder = 4
                    },
                    
                    -- Control buttons
                    Rex("Frame") {
                        Size = UDim2.new(1, 0, 0, 60),
                        BackgroundTransparency = 1,
                        LayoutOrder = 5,
                        children = {
                            Rex("UIListLayout") {
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 10)
                            },
                            
                            -- Manual increment
                            Rex("TextButton") {
                                Text = "+1",
                                Size = UDim2.fromOffset(70, 60),
                                BackgroundColor3 = Color3.fromRGB(70, 130, 255),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSansBold,
                                LayoutOrder = 1,
                                onClick = function()
                                    -- Use increment helper
                                    count:increment()
                                end,
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 10) }
                                }
                            },
                            
                            -- Toggle auto-increment
                            Rex("TextButton") {
                                Text = isActive:map(function(active) 
                                    return active and "Stop Auto" or "Start Auto"
                                end),
                                Size = UDim2.fromOffset(100, 60),
                                BackgroundColor3 = isActive:map(function(active)
                                    return active and Color3.fromRGB(255, 150, 100) or Color3.fromRGB(100, 255, 150)
                                end),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSans,
                                LayoutOrder = 2,
                                onClick = function()
                                    -- Use toggle helper
                                    isActive:toggle()
                                end,
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 10) }
                                }
                            },
                            
                            -- Reset all
                            Rex("TextButton") {
                                Text = "Reset All",
                                Size = UDim2.fromOffset(90, 60),
                                BackgroundColor3 = Color3.fromRGB(200, 100, 100),
                                TextColor3 = Color3.new(1, 1, 1),
                                TextScaled = true,
                                Font = Enum.Font.SourceSans,
                                LayoutOrder = 3,
                                onClick = function()
                                    count:set(0)
                                    totalClicks:set(0)
                                    isActive:set(true)
                                end,
                                children = {
                                    Rex("UICorner") { CornerRadius = UDim.new(0, 10) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end

-- Render the enhanced counter
local cleanup = Rex.render(CounterWithEffects, Players.LocalPlayer.PlayerGui)
```

## Key Concepts Demonstrated

### 1. Reactive State

- `Rex.useState()` creates reactive state that automatically updates the UI
- State changes trigger re-renders of dependent UI elements

### 2. Computed Values

- `Rex.useComputed()` creates derived state that updates when dependencies change
- Computed values are memoized for performance

### 3. State Transformations

- The `:map()` method transforms state values for UI binding
- Enables dynamic text, colors, and conditional rendering

### 4. Event Handling

- `onClick` and other camelCase event handlers
- State updates in event handlers trigger UI updates

### 5. Effects and Lifecycle

- `Rex.useEffect()` runs side effects when dependencies change
- `Rex.onMount()` and `Rex.onUnmount()` for component lifecycle
- Effects support cleanup functions for resource management

### 6. Immutable Updates

- Use `:update()` method for safe state modifications
- Prevents accidental mutations and ensures proper reactivity

Try these examples in your Roblox Studio to see Rex's reactive system in action! Each example builds on the previous one, introducing new concepts and patterns you'll use in real applications.
