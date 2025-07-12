---
title: "Contexts and Global State"
description: "Sharing state and logic across components with React-like context patterns."
category: "Core Concepts"
order: 4

lastUpdated: 2025-06-23
---

Contexts in Rex provide a way to share state and functionality across multiple components without prop drilling. This is similar to React's Context API and is perfect for themes, user authentication, global settings, and other application-wide state.

## Understanding Context

Context solves the problem of "prop drilling" - passing data through many component layers just to reach a deeply nested child component. Instead of passing props down through every level, context allows you to:

1. **Create** a context with a default value
2. **Provide** the context value at a high level in your component tree  
3. **Consume** the context value in any descendant component

## Creating a Context

Use `Rex.createContext` to create a new context with a default value:

```lua
local ThemeContext = Rex.createContext({
    primaryColor = Color3.fromRGB(70, 130, 255),
    backgroundColor = Color3.fromRGB(30, 30, 30),
    textColor = Color3.new(1, 1, 1),
    borderRadius = 8
})
```

## Providing Context Values

Use `Rex.Provider` to make a context value available to child components:

```lua
local function App()
    local darkMode = Rex.useState(true)
    
    local theme = Rex.useComputed(function()
        local isDark = darkMode:get()
        return {
            primaryColor = Color3.fromRGB(70, 130, 255),
            backgroundColor = isDark and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(240, 240, 240),
            textColor = isDark and Color3.new(1, 1, 1) or Color3.new(0, 0, 0),
            borderRadius = 8,
            isDark = isDark,
            toggleDarkMode = function()
                darkMode:update(function(current) return not current end)
            end
        }
    end, {darkMode})
    
    return Rex.Provider {
        context = ThemeContext,
        value = theme,
        children = {
            Header(),
            MainContent(),
            Footer()
        }
    }
end
```

## Consuming Context Values

Use `Rex.useContext` to access the current context value in any descendant component:

```lua
local function ThemedButton(props)
    local theme = Rex.useContext(ThemeContext)
    
    return Rex("TextButton") {
        Text = props.text,
        Size = props.size or UDim2.fromOffset(120, 40),
        BackgroundColor3 = theme.primaryColor,
        TextColor3 = theme.textColor,
        children = {
            Rex("UICorner") {
                CornerRadius = UDim.new(0, theme.borderRadius)
            }
        },
        onClick = props.onClick
    }
end

local function ThemeToggle()
    local theme = Rex.useContext(ThemeContext)
    
    return ThemedButton {
        text = theme.isDark and "Light Mode" or "Dark Mode",
        onClick = theme.toggleDarkMode
    }
end
```

## Multiple Contexts

You can use multiple contexts in the same application:

```lua
-- User authentication context
local AuthContext = Rex.createContext({
    user = nil,
    isAuthenticated = false,
    login = function() end,
    logout = function() end
})

-- App settings context  
local SettingsContext = Rex.createContext({
    language = "en",
    soundEnabled = true,
    musicVolume = 0.8
})

local function AppProvider(props)
    -- Auth state
    local user = Rex.useState(nil)
    local isAuthenticated = Rex.useComputed(function()
        return user:get() ~= nil
    end, {user})
    
    local login = function(userData)
        user:set(userData)
    end
    
    local logout = function()
        user:set(nil)
    end
    
    local authValue = {
        user = user,
        isAuthenticated = isAuthenticated,
        login = login,
        logout = logout
    }
    
    -- Settings state
    local language = Rex.useState("en")
    local soundEnabled = Rex.useState(true)
    local musicVolume = Rex.useState(0.8)
    
    local settingsValue = {
        language = language,
        soundEnabled = soundEnabled,
        musicVolume = musicVolume,
        setLanguage = function(lang) language:set(lang) end,
        toggleSound = function() soundEnabled:update(function(current) return not current end) end,
        setMusicVolume = function(volume) musicVolume:set(volume) end
    }
    
    return Rex.Provider {
        context = AuthContext,
        value = authValue,
        children = {
            Rex.Provider {
                context = SettingsContext,
                value = settingsValue,
                children = props.children
            }
        }
    }
end

-- Using multiple contexts
local function UserProfile()
    local auth = Rex.useContext(AuthContext)
    local settings = Rex.useContext(SettingsContext)
    
    if not auth.isAuthenticated:get() then
        return Rex("TextLabel") {
            Text = "Please log in"
        }
    end
    
    local userData = auth.user:get()
    local currentLanguage = settings.language:get()
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = string.format("Welcome, %s! Language: %s", userData.name, currentLanguage)
            }
        }
    }
end
```

## Advanced Context Patterns

### Context with Custom Hook

Create custom hooks to encapsulate context logic:

```lua
-- Create context
local CartContext = Rex.createContext(nil)

-- Custom hook for using cart context
local function useCart()
    local context = Rex.useContext(CartContext)
    if not context then
        error("useCart must be used within a CartProvider")
    end
    return context
end

-- Cart provider component
local function CartProvider(props)
    local items = Rex.useState({})
    local total = Rex.useComputed(function()
        local sum = 0
        for _, item in ipairs(items:get()) do
            sum = sum + (item.price * item.quantity)
        end
        return sum
    end, {items})
    
    local addItem = function(product, quantity)
        items:update(function(currentItems)
            local newItems = {unpack(currentItems)}
            
            -- Check if item already exists
            for i, item in ipairs(newItems) do
                if item.id == product.id then
                    newItems[i] = {
                        id = item.id,
                        name = item.name,
                        price = item.price,
                        quantity = item.quantity + quantity
                    }
                    return newItems
                end
            end
            
            -- Add new item
            table.insert(newItems, {
                id = product.id,
                name = product.name,
                price = product.price,
                quantity = quantity
            })
            return newItems
        end)
    end
    
    local removeItem = function(productId)
        items:update(function(currentItems)
            local newItems = {}
            for _, item in ipairs(currentItems) do
                if item.id ~= productId then
                    table.insert(newItems, item)
                end
            end
            return newItems
        end)
    end
    
    local updateQuantity = function(productId, newQuantity)
        if newQuantity <= 0 then
            removeItem(productId)
            return
        end
        
        items:update(function(currentItems)
            local newItems = {}
            for _, item in ipairs(currentItems) do
                if item.id == productId then
                    table.insert(newItems, {
                        id = item.id,
                        name = item.name,
                        price = item.price,
                        quantity = newQuantity
                    })
                else
                    table.insert(newItems, item)
                end
            end
            return newItems
        end)
    end
    
    local clearCart = function()
        items:set({})
    end
    
    local cartValue = {
        items = items,
        total = total,
        addItem = addItem,
        removeItem = removeItem,
        updateQuantity = updateQuantity,
        clearCart = clearCart
    }
    
    return Rex.Provider {
        context = CartContext,
        value = cartValue,
        children = props.children
    }
end

-- Using the custom hook
local function ProductCard(props)
    local cart = useCart()
    local product = props.product
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = string.format("%s - $%.2f", product.name, product.price)
            },
            Rex("TextButton") {
                Text = "Add to Cart",
                onClick = function()
                    cart.addItem(product, 1)
                end
            }
        }
    }
end

local function CartSummary()
    local cart = useCart()
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = cart.total:map(function(totalAmount)
                    return string.format("Total: $%.2f", totalAmount)
                end)
            },
            Rex("TextLabel") {
                Text = cart.items:map(function(itemList)
                    return string.format("Items: %d", #itemList)
                end)
            }
        }
    }
end
```

### Nested Providers and Context Composition

```lua
-- Multiple provider wrapper
local function AppProviders(props)
    return Rex.Provider {
        context = ThemeContext,
        value = createTheme(),
        children = {
            Rex.Provider {
                context = AuthContext,
                value = createAuth(),
                children = {
                    CartProvider {
                        children = {
                            Rex.Provider {
                                context = SettingsContext,
                                value = createSettings(),
                                children = props.children
                            }
                        }
                    }
                }
            }
        }
    }
end

-- Or using a helper function for cleaner nesting
local function withProviders(providers, children)
    local function buildProviders(index)
        if index > #providers then
            return children
        end
        
        local provider = providers[index]
        return Rex.Provider {
            context = provider.context,
            value = provider.value,
            children = { buildProviders(index + 1) }
        }
    end
    
    return buildProviders(1)
end

local function App()
    return withProviders({
        { context = ThemeContext, value = createTheme() },
        { context = AuthContext, value = createAuth() },
        { context = SettingsContext, value = createSettings() }
    }, {
        MainApp()
    })
end
```

## Context Performance Considerations

### Avoid Large Context Objects

Split large contexts into smaller, focused ones:

```lua
-- ❌ Avoid: Large monolithic context
local AppContext = Rex.createContext({
    user = nil,
    theme = {},
    cart = {},
    settings = {},
    notifications = {},
    -- ... many more fields
})

-- ✅ Better: Split into focused contexts
local UserContext = Rex.createContext(nil)
local ThemeContext = Rex.createContext({})
local CartContext = Rex.createContext({})
local SettingsContext = Rex.createContext({})
```

### Optimize Context Value Updates

Avoid creating new objects on every render:

```lua
-- ❌ Avoid: New object on every render
local function ThemeProvider(props)
    local darkMode = Rex.useState(true)
    
    return Rex.Provider {
        context = ThemeContext,
        value = { -- New object every time!
            isDark = darkMode:get(),
            toggle = function() darkMode:update(function(current) return not current end) end
        },
        children = props.children
    }
end

-- ✅ Better: Use computed state or memoization
local function ThemeProvider(props)
    local darkMode = Rex.useState(true)
    
    local themeValue = Rex.useComputed(function()
        return {
            isDark = darkMode:get(),
            toggle = function() darkMode:update(function(current) return not current end) end
        }
    end, {darkMode})
    
    return Rex.Provider {
        context = ThemeContext,
        value = themeValue,
        children = props.children
    }
end
```

## Real-World Example: Complete Theme System

```lua
-- Theme context with comprehensive styling
local ThemeContext = Rex.createContext(nil)

local function useTheme()
    local context = Rex.useContext(ThemeContext)
    if not context then
        error("useTheme must be used within ThemeProvider")
    end
    return context
end

local function ThemeProvider(props)
    local currentTheme = Rex.useState("dark")
    
    local themes = {
        dark = {
            name = "dark",
            colors = {
                primary = Color3.fromRGB(70, 130, 255),
                secondary = Color3.fromRGB(100, 160, 255),
                background = Color3.fromRGB(30, 30, 30),
                surface = Color3.fromRGB(40, 40, 40),
                text = Color3.new(1, 1, 1),
                textSecondary = Color3.fromRGB(180, 180, 180),
                border = Color3.fromRGB(60, 60, 60),
                success = Color3.fromRGB(40, 200, 40),
                warning = Color3.fromRGB(255, 200, 40),
                error = Color3.fromRGB(255, 100, 100)
            },
            spacing = {
                xs = 4,
                sm = 8,
                md = 16,
                lg = 24,
                xl = 32
            },
            borderRadius = {
                sm = 4,
                md = 8,
                lg = 12,
                xl = 16
            }
        },
        light = {
            name = "light",
            colors = {
                primary = Color3.fromRGB(70, 130, 255),
                secondary = Color3.fromRGB(100, 160, 255),
                background = Color3.fromRGB(250, 250, 250),
                surface = Color3.fromRGB(255, 255, 255),
                text = Color3.fromRGB(30, 30, 30),
                textSecondary = Color3.fromRGB(100, 100, 100),
                border = Color3.fromRGB(200, 200, 200),
                success = Color3.fromRGB(40, 200, 40),
                warning = Color3.fromRGB(255, 160, 40),
                error = Color3.fromRGB(255, 100, 100)
            },
            spacing = {
                xs = 4,
                sm = 8,
                md = 16,
                lg = 24,
                xl = 32
            },
            borderRadius = {
                sm = 4,
                md = 8,
                lg = 12,
                xl = 16
            }
        }
    }
    
    local theme = Rex.useComputed(function()
        return themes[currentTheme:get()]
    end, {currentTheme})
    
    local setTheme = function(themeName)
        if themes[themeName] then
            currentTheme:set(themeName)
        end
    end
    
    local toggleTheme = function()
        currentTheme:update(function(current)
            return current == "dark" and "light" or "dark"
        end)
    end
    
    local themeValue = Rex.useComputed(function()
        return {
            current = theme:get(),
            setTheme = setTheme,
            toggleTheme = toggleTheme,
            availableThemes = {"dark", "light"}
        }
    end, {theme})
    
    return Rex.Provider {
        context = ThemeContext,
        value = themeValue,
        children = props.children
    }
end

-- Themed components using the context
local function ThemedCard(props)
    local theme = useTheme()
    
    return Rex("Frame") {
        Size = props.size or UDim2.fromOffset(300, 200),
        BackgroundColor3 = theme.current.colors.surface,
        BorderColor3 = theme.current.colors.border,
        BorderSizePixel = 1,
        children = {
            Rex("UICorner") {
                CornerRadius = UDim.new(0, theme.current.borderRadius.md)
            },
            Rex("UIPadding") {
                PaddingTop = UDim.new(0, theme.current.spacing.md),
                PaddingBottom = UDim.new(0, theme.current.spacing.md),
                PaddingLeft = UDim.new(0, theme.current.spacing.md),
                PaddingRight = UDim.new(0, theme.current.spacing.md)
            },
            props.children
        }
    }
end

local function ThemedButton(props)
    local theme = useTheme()
    local variant = props.variant or "primary"
    local hovered = Rex.useState(false)
    
    local backgroundColor = Rex.useComputed(function()
        local color = theme.current.colors[variant] or theme.current.colors.primary
        return hovered:get() and color:lerp(Color3.new(1, 1, 1), 0.1) or color
    end, {hovered, theme})
    
    return Rex("TextButton") {
        Text = props.text or "Button",
        Size = props.size or UDim2.fromOffset(120, 40),
        BackgroundColor3 = backgroundColor,
        TextColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        children = {
            Rex("UICorner") {
                CornerRadius = UDim.new(0, theme.current.borderRadius.sm)
            }
        },
        onHover = function() hovered:set(true) end,
        onLeave = function() hovered:set(false) end,
        onClick = props.onClick
    }
end
```

Context provides a powerful way to manage global state and share functionality across your Rex application. Use it wisely for truly global concerns, and prefer props for component-specific data.
