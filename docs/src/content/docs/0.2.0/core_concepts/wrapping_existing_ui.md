---
title: "Wrapping Existing UI"
description: "Learn how to enhance existing Roblox UI instances with Rex's reactive functionality using Rex.define()."
category: "Core Concepts"
order: 8
version: "0.2.0"
lastUpdated: 2025-06-29
---

One of Rex's most powerful features is the ability to wrap and enhance existing Roblox UI instances, allowing for incremental migration from traditional UI to reactive UI. This is especially valuable when working with Studio-created interfaces or integrating Rex into existing projects.

## Why Wrap Existing UI?

**Incremental Migration**: Instead of rebuilding entire interfaces from scratch, you can gradually add Rex functionality to existing UI elements.

**Designer-Developer Workflow**: Designers can continue working in Studio while developers add reactive behavior and logic through code.

**Lower Barrier to Entry**: Teams can start using Rex without abandoning their existing UI investment.

**Preserve Layouts**: Studio's visual layout tools remain intact while adding programmatic behavior.

## Basic Wrapping

The `Rex.define()` function allows you to wrap any existing Roblox Instance:

```luau
-- Create a traditional UI element
local button = Instance.new("TextButton")
button.Text = "Click Me"
button.Size = UDim2.fromOffset(100, 40)
button.Parent = someFrame

-- Wrap it with Rex to add reactive behavior
local enhancedButton = Rex.define(button) {
    -- Override properties
    BackgroundColor3 = Color3.fromRGB(70, 130, 255),
    
    -- Add event handlers
    onClick = function()
        print("Button clicked!")
    end,
    
    -- Add reactive properties
    TextColor3 = isEnabled:map(function(enabled)
        return enabled and Color3.new(1, 1, 1) or Color3.new(0.5, 0.5, 0.5)
    end)
}
```

## Studio Integration

When working with Studio-created UI, you can reference elements by their Instance directly or by name:

```luau
-- Assuming you have a ScreenGui with a Frame containing buttons
local screenGui = game.Players.LocalPlayer.PlayerGui.MyInterface
local mainFrame = screenGui.MainFrame

-- Wrap the main frame
local function EnhancedInterface()
    local playerCoins = Rex.useState(100)
    
    return Rex.define(mainFrame) {
        -- Override frame properties
        BackgroundColor3 = Color3.fromRGB(40, 44, 52),
        
        children = {
            -- Reference existing children by name
            Rex.define("TitleLabel") {
                Text = "Enhanced Shop Interface",
                TextColor3 = Color3.fromRGB(97, 218, 251)
            },
            
            Rex.define("CoinsDisplay") {
                Text = playerCoins:map(function(coins)
                    return `Coins: {coins}`
                end)
            },
            
            Rex.define("BuyButton") {
                onClick = function()
                    if playerCoins:get() >= 50 then
                        playerCoins:decrement(50)
                        -- Purchase logic here
                    end
                end
            }
        }
    }
end
```

## Property Override Behavior

When you wrap an existing instance, Rex.define preserves all original properties unless explicitly overridden:

```luau
-- Original button: Text="Buy", Size=UDim2.fromOffset(100,40), BackgroundColor3=Color3.new(0,1,0)

Rex.define(originalButton) {
    Text = "Enhanced Buy",  -- Overrides original text
    onClick = handleClick   -- Adds new functionality
    -- Size and BackgroundColor3 remain unchanged
}
```

This selective override approach means you can enhance specific aspects of your UI without losing the original design.

## Children Management

One of the most powerful features is managing children of existing containers:

```luau
Rex.define(existingFrame) {
    children = {
        -- Reference existing children to enhance them
        Rex.define("ExistingButton") {
            onClick = newClickHandler,
            Text = dynamicText
        },
        
        -- Add completely new children
        Rex("TextLabel") {
            Text = "New Dynamic Label",
            TextColor3 = Color3.fromRGB(255, 255, 255)
        },
        
        -- Existing children not referenced remain unchanged
        -- For example, if the frame has a "StaticLabel", it stays as-is
    }
}
```

## Event System Integration

Rex.define integrates seamlessly with Rex's event system, allowing you to add modern event handling to legacy UI:

```luau
Rex.define(oldButton) {
    -- Modern event handling
    onClick = function() print("Clicked!") end,
    onHover = function() 
        -- Visual feedback
        oldButton.BackgroundTransparency = 0.2
    end,
    onLeave = function()
        oldButton.BackgroundTransparency = 0
    end,
    
    -- Reactive properties
    BackgroundColor3 = buttonState:map(function(state)
        return state == "active" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200)
    end)
}
```

## Practical Migration Strategy

Here's a recommended approach for migrating existing UI to Rex:

### Phase 1: Wrap Containers

Start by wrapping your main containers without changing their children:

```luau
-- Just wrap the main frame to establish Rex context
Rex.define(mainFrame) {
    -- Maybe add some reactive styling
    BackgroundColor3 = themeColor,
}
```

### Phase 2: Add Event Handlers

Enhance interactive elements with proper event handling:

```luau
Rex.define(mainFrame) {
    children = {
        Rex.define("PlayButton") {
            onClick = startGame,
            onHover = showTooltip
        },
        Rex.define("SettingsButton") {
            onClick = openSettings
        }
    }
}
```

### Phase 3: Make Properties Reactive

Add reactive properties to make the UI dynamic:

```luau
Rex.define(mainFrame) {
    children = {
        Rex.define("PlayerName") {
            Text = playerName, -- Reactive state
            TextColor3 = playerStatus:map(function(status)
                return status == "online" and Color3.new(0, 1, 0) or Color3.new(0.5, 0.5, 0.5)
            end)
        }
    }
}
```

### Phase 4: Add New Components

Introduce new Rex components alongside existing ones:

```luau
Rex.define(mainFrame) {
    children = {
        -- Existing enhanced elements
        Rex.define("OldButton") { onClick = handler },
        
        -- New Rex components
        ModernTooltip { text = "This is a new Rex component" },
        DynamicList { items = gameItems }
    }
}
```

### Phase 5: Full Migration

Eventually, you can replace entire sections with pure Rex components while keeping the parts that work well as-is.

## Best Practices

### Preserve Visual Design

Don't override styling properties unless necessary. Let Studio's visual design remain intact:

```luau
-- ✅ Good - only add behavior
Rex.define(studioButton) {
    onClick = handleClick,
    onHover = handleHover
}

-- ❌ Avoid - unnecessary styling changes
Rex.define(studioButton) {
    BackgroundColor3 = Color3.new(1, 0, 0), -- Studio already set this
    Size = UDim2.fromOffset(100, 40),        -- Studio already set this
    onClick = handleClick
}
```

### Use String References for Children

When working with Studio UI, use string names for child references:

```luau
Rex.define(mainFrame) {
    children = {
        Rex.define("Header"),     -- Clean and maintainable
        Rex.define("Content"),
        Rex.define("Footer")
    }
}
```

### Avoid Unnecessary Reparenting

Structure your Rex components to match your existing UI hierarchy:

```luau
-- ✅ Good - matches existing structure
Rex.define(existingScreenGui) {
    children = {
        Rex.define("MainFrame") {
            children = {
                Rex.define("Button") { onClick = handler }
            }
        }
    }
}

-- ❌ Avoid - forces reparenting
Rex("ScreenGui") {
    children = {
        Rex.define(existingMainFrame) { ... } -- This will move the frame
    }
}
```

## Common Patterns

### Enhancing Form Inputs

```luau
local function EnhancedForm()
    local formData = Rex.useState({
        username = "",
        email = ""
    })
    
    return Rex.define(formFrame) {
        children = {
            Rex.define("UsernameBox") {
                Text = formData:map(function(data) return data.username end),
                onTextChanged = function(textBox)
                    formData:update(function(current)
                        return {
                            username = textBox.Text,
                            email = current.email
                        }
                    end)
                end
            },
            
            Rex.define("SubmitButton") {
                onClick = function()
                    submitForm(formData:get())
                end
            }
        }
    }
end
```

### Progressive Enhancement

```luau
local function ProgressiveShop()
    -- Start with basic enhancement
    local coins = Rex.useState(100)
    
    return Rex.define(shopFrame) {
        children = {
            -- Phase 1: Just add reactivity to existing elements
            Rex.define("CoinsLabel") {
                Text = coins:map(function(amount)
                    return `Coins: {amount}`
                end)
            },
            
            -- Phase 2: Add new interactive elements
            NewInventoryPanel { coins = coins },
            
            -- Phase 3: Keep some elements as-is
            -- "StaticShopTitle" remains unchanged
        }
    }
end
```

Rex.define makes it possible to modernize existing UI incrementally, allowing teams to adopt reactive patterns gradually while preserving their existing work and design investments.
