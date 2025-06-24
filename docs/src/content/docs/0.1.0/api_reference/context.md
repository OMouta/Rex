---
title: "Context API "
description: "Complete API reference for context creation, providers, and consumption in Rex."
category: "API Reference"
order: 3
version: "0.1.0"
lastUpdated: 2025-06-23
---

The Context API in Rex provides a way to share data and state across component trees without prop drilling. This is particularly useful for themes, authentication, global settings, and other application-wide concerns.

## `Rex.createContext<T>(defaultValue: T): RexContext<T>`

Creates a new context object that can hold and share values across components.

**Parameters:**

- `defaultValue: T` - The default value that will be returned when `useContext` is called outside of a provider tree. This value is used as a fallback when no provider is found.

**Returns:** `RexContext<T>` object that can be used with `Rex.Provider` and `Rex.useContext`.

**Examples:**

```luau
-- Simple value context
local CountContext = Rex.createContext(0)

-- Object context with default structure
local ThemeContext = Rex.createContext({
    primaryColor = Color3.fromRGB(70, 130, 255),
    backgroundColor = Color3.fromRGB(30, 30, 30),
    textColor = Color3.new(1, 1, 1)
})

-- Nil context (require provider)
local UserContext = Rex.createContext(nil)
```

```luau
local AppStateContext = Rex.createContext({
    user = {
        id = nil,
        name = "Guest",
        isAuthenticated = false
    },
    settings = {
        theme = "dark",
        language = "en",
        soundEnabled = true
    },
    ui = {
        sidebarOpen = false,
        modalStack = {}
    }
})
```

## `Rex.Provider<T>(props: {context: RexContext<T>, value: T, children: RexChildren}): RexElement`

A special component that provides context values to its children. All descendant components can access the provided value using `useContext`.

**Parameters:**

- `context: RexContext<T>` - The context object created by `createContext`
- `value: T` - The current value to provide to all descendant components
- `children: RexChildren` - Array of child components that will have access to the context value

**Examples:**

```luau
local function App()
    local theme = {
        primaryColor = Color3.fromRGB(70, 130, 255),
        backgroundColor = Color3.fromRGB(30, 30, 30)
    }
    
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

```luau
local function ThemeProvider(props)
    local isDarkMode = Rex.useState(true)
    local primaryHue = Rex.useState(220)
    
    local themeValue = Rex.useComputed(function()
        local hue = primaryHue:get()
        local isDark = isDarkMode:get()
        
        return {
            isDark = isDark,
            primaryColor = Color3.fromHSV(hue / 360, 0.8, 0.9),
            backgroundColor = isDark and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(250, 250, 250),
            textColor = isDark and Color3.new(1, 1, 1) or Color3.new(0, 0, 0),
            
            -- Actions
            toggleDarkMode = function()
                isDarkMode:update(function(current) return not current end)
            end,
            setPrimaryHue = function(newHue)
                primaryHue:set(newHue)
            end
        }
    end, {isDarkMode, primaryHue})
    
    return Rex.Provider {
        context = ThemeContext,
        value = themeValue,
        children = props.children
    }
end
```

```luau
local function AppProviders(props)
    return Rex.Provider {
        context = AuthContext,
        value = authState,
        children = {
            Rex.Provider {
                context = ThemeContext,
                value = themeState,
                children = {
                    Rex.Provider {
                        context = SettingsContext,
                        value = settingsState,
                        children = props.children
                    }
                }
            }
        }
    }
end
```

## `Rex.useContext<T>(context: RexContext<T>): T`

Hook that allows components to consume values from the nearest provider ancestor.

**Parameters:**

- `context: RexContext<T>` - The context object created by `createContext`

**Returns:** `T` - The current context value provided by the nearest `Rex.Provider` ancestor. If no provider is found, returns the default value passed to `createContext`.

**Examples:**

```luau
local function ThemedButton(props)
    local theme = Rex.useContext(ThemeContext)
    
    return Rex("TextButton") {
        Text = props.text,
        BackgroundColor3 = theme.primaryColor,
        TextColor3 = theme.textColor,
        onClick = props.onClick
    }
end
```

```luau
local function UserProfile()
    local user = Rex.useContext(UserContext)
    
    if not user or not user.isAuthenticated then
        return Rex("TextLabel") {
            Text = "Please log in to view your profile"
        }
    end
    
    return Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = "Welcome, " .. user.name
            },
            Rex("TextLabel") {
                Text = "Email: " .. user.email
            }
        }
    }
end
```

```luau
local function Dashboard()
    local auth = Rex.useContext(AuthContext)
    local theme = Rex.useContext(ThemeContext)
    local settings = Rex.useContext(SettingsContext)
    
    return Rex("Frame") {
        BackgroundColor3 = theme.backgroundColor,
        children = {
            Rex("TextLabel") {
                Text = string.format("Welcome, %s!", auth.user.name),
                TextColor3 = theme.textColor
            },
            Rex("TextLabel") {
                Text = "Language: " .. settings.language,
                TextColor3 = theme.textColor
            }
        }
    }
end
```

## `Rex.withContext<T>(Component: (props: any) -> RexElement, contextProviders: {ContextProvider}): (props: any) -> RexElement`

Higher-order function that wraps a component with context providers. This is a convenience utility for applying multiple contexts.

**Parameters:**

- `Component: (props: any) -> RexElement` - The component to wrap with contexts
- `contextProviders: {ContextProvider}` - Array of context provider configurations

**Example:**

```luau
-- Define context providers
local contextProviders = {
    {
        context = ThemeContext,
        value = function() return createThemeValue() end
    },
    {
        context = AuthContext,
        value = function() return createAuthValue() end
    }
}

-- Wrap component with contexts
local EnhancedApp = Rex.withContext(App, contextProviders)

-- Usage
local function Root()
    return EnhancedApp()
end
```

## Advanced Patterns

### Custom Context Hook

Create custom hooks that encapsulate context usage and validation:

```luau
local ThemeContext = Rex.createContext(nil)

local function useTheme()
    local context = Rex.useContext(ThemeContext)
    if not context then
        error("useTheme must be used within a ThemeProvider")
    end
    return context
end

-- Export both context and hook
return {
    ThemeContext = ThemeContext,
    useTheme = useTheme
}
```

### Context Composition

Combine multiple contexts into a single provider:

```luau
local function CombinedProvider(props)
    local authState = useAuthState()
    local themeState = useThemeState()
    local settingsState = useSettingsState()
    
    -- Combine all states
    local combinedValue = Rex.useComputed(function()
        return {
            auth = authState,
            theme = themeState,
            settings = settingsState
        }
    end, {authState, themeState, settingsState})
    
    return Rex.Provider {
        context = AppContext,
        value = combinedValue,
        children = props.children
    }
end
```

### Context with Reducer Pattern

Use context to implement a reducer-like pattern for complex state management:

```luau
local StateContext = Rex.createContext(nil)
local DispatchContext = Rex.createContext(nil)

local function useAppState()
    local state = Rex.useContext(StateContext)
    if not state then
        error("useAppState must be used within StateProvider")
    end
    return state
end

local function useAppDispatch()
    local dispatch = Rex.useContext(DispatchContext)
    if not dispatch then
        error("useAppDispatch must be used within StateProvider")
    end
    return dispatch
end

local function StateProvider(props)
    local state = Rex.useState({
        user = nil,
        todos = {},
        ui = { loading = false, error = nil }
    })
    
    local dispatch = function(action)
        state:update(function(currentState)
            if action.type == "SET_USER" then
                return {
                    user = action.payload,
                    todos = currentState.todos,
                    ui = currentState.ui
                }
            elseif action.type == "ADD_TODO" then
                local newTodos = {unpack(currentState.todos)}
                table.insert(newTodos, action.payload)
                return {
                    user = currentState.user,
                    todos = newTodos,
                    ui = currentState.ui
                }
            elseif action.type == "SET_LOADING" then
                return {
                    user = currentState.user,
                    todos = currentState.todos,
                    ui = {
                        loading = action.payload,
                        error = currentState.ui.error
                    }
                }
            end
            return currentState
        end)
    end
    
    return Rex.Provider {
        context = StateContext,
        value = state,
        children = {
            Rex.Provider {
                context = DispatchContext,
                value = dispatch,
                children = props.children
            }
        }
    }
end

-- Usage
local function TodoForm()
    local dispatch = useAppDispatch()
    local text = Rex.useState("")
    
    local addTodo = function()
        dispatch({
            type = "ADD_TODO",
            payload = {
                id = math.random(1000000),
                text = text:get(),
                completed = false
            }
        })
        text:set("")
    end
    
    return Rex("Frame") {
        children = {
            Rex("TextBox") {
                Text = text,
                onTextChanged = function(textBox)
                    text:set(textBox.Text)
                end
            },
            Rex("TextButton") {
                Text = "Add Todo",
                onClick = addTodo
            }
        }
    }
end
```

## Performance Considerations

### Minimize Context Re-renders

Avoid creating new objects in render:

```luau
-- ❌ Bad: Creates new object every render
local function BadProvider(props)
    local user = Rex.useState(nil)
    
    return Rex.Provider {
        context = UserContext,
        value = { -- New object every time!
            user = user:get(),
            setUser = function(newUser) user:set(newUser) end
        },
        children = props.children
    }
end

-- ✅ Good: Use computed state
local function GoodProvider(props)
    local user = Rex.useState(nil)
    
    local contextValue = Rex.useComputed(function()
        return {
            user = user:get(),
            setUser = function(newUser) user:set(newUser) end
        }
    end, {user})
    
    return Rex.Provider {
        context = UserContext,
        value = contextValue,
        children = props.children
    }
end
```

### Split Large Contexts

Instead of one large context, use multiple focused contexts:

```luau
-- ❌ Avoid: Large monolithic context
local AppContext = Rex.createContext({
    user = nil,
    settings = {},
    ui = {},
    data = {},
    cache = {}
})

-- ✅ Better: Multiple focused contexts
local UserContext = Rex.createContext(nil)
local SettingsContext = Rex.createContext({})
local UIContext = Rex.createContext({})
local DataContext = Rex.createContext({})
```

## Error Handling

### Context Validation

```luau
local function useTheme()
    local context = Rex.useContext(ThemeContext)
    
    if not context then
        error("useTheme must be used within a ThemeProvider. " ..
              "Make sure your component is wrapped with <ThemeProvider>.")
    end
    
    return context
end
```

### Development Mode Warnings

```luau
local function createContextWithValidation(defaultValue, displayName)
    local context = Rex.createContext(defaultValue)
    context.displayName = displayName
    
    local originalUseContext = Rex.useContext
    
    Rex.useContext = function(ctx)
        if ctx == context then
            local value = originalUseContext(ctx)
            if value == defaultValue and defaultValue == nil then
                warn(string.format(
                    "useContext(%s) returned default value. " ..
                    "This likely means the component is not wrapped in a provider.",
                    displayName or "Unknown Context"
                ))
            end
            return value
        end
        return originalUseContext(ctx)
    end
    
    return context
end

-- Usage
local ThemeContext = createContextWithValidation(nil, "ThemeContext")
```

## Type Definitions

```luau
export type RexContext<T> = {
    defaultValue: T,
    _contextId: string,
}

export type ContextProvider<T> = {
    context: RexContext<T>,
    value: T | (() -> T),
}

export type RexChildren = RexElement | {RexElement} | RexState<RexElement | {RexElement}> | nil
```

The Context API is a powerful tool for managing global state and avoiding prop drilling in your Rex applications. Use it judiciously for truly global concerns.
