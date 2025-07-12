---
title: "Installation & Setup"
description: "How to install Rex and set up your development environment for building reactive UIs in Roblox."
category: "Getting Started"
order: 2

lastUpdated: 2025-06-23
---

This guide will walk you through installing Rex and setting up your development environment to start building reactive UIs for Roblox using Rex's new universal reactivity system.

## Installation Methods

### Method 1: GitHub Releases

For the latest version or specific releases:

1. Visit the [Rex GitHub releases page](https://github.com/OMouta/Rex/releases)
2. Download the latest `.rbxm` file
3. In Roblox Studio, right-click **ReplicatedStorage**
4. Select **Insert from File** and choose the downloaded file

### Method 2: Rojo with Jelly

1. Install Jelly with aftman

    ```bash
    aftman add OMouta/jelly
    ```

2. Install rex with Jelly

    ```bash
    jelly install omouta/rex
    ```

### Method 3: Rojo with Wally

1. Install Wally with aftman

    ```bash
    aftman add UpliftGames/wally
    ```

2. Add rex to wally.toml

    ```toml
    rex = "omouta/rex@0..3.2-beta"
    ```

3. Install rex with Wally

    ```bash
    wally install
    ```

## Project Structure

After installation, your project structure should look like this:

```txt
StarterPlayer/
  StarterPlayerScripts/
    YourApp.client.lua        -- Your main client script
ReplicatedStorage/
  Rex/                       -- Rex framework
    init.luau               -- Main Rex module
    Types.luau              -- Type definitions
    ElementBuilder.luau     -- Element creation
    State.luau              -- State management
    Props.luau              -- Property handling
    Renderer.luau           -- Rendering system
```

## Basic Setup

### 1. Create Your Main Script

Create a new LocalScript in `StarterPlayer/StarterPlayerScripts` called `App.client.lua`:

```lua
-- StarterPlayer/StarterPlayerScripts/App.client.lua
local Rex = require(game.ReplicatedStorage.Rex)

local function App()
    return Rex("ScreenGui") {
        Name = "MyApp",
        ResetOnSpawn = false,
        
        children = {
            Rex("Frame") {
                Size = UDim2.fromOffset(300, 200),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(30, 30, 40),
                
                children = {
                    Rex("UICorner") { CornerRadius = UDim.new(0, 12) },
                    Rex("TextLabel") {
                        Text = "Hello, Rex!",
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextScaled = true,
                        Font = Enum.Font.SourceSansBold
                    }
                }
            }
        }
    }
end

-- Render the app
local player = game:GetService("Players").LocalPlayer
local cleanup = Rex.render(App, player.PlayerGui)

-- Optional: Cleanup when the player leaves
game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        cleanup()
    end
end)
```

### 2. Test Your Setup

1. Save the script
2. Press **F5** to test your game
3. You should see a dark rounded frame with "Hello, Rex!" in the center

If you see the UI, congratulations! Rex is properly installed and working.

## Development Environment Setup

### Recommended Tools

For the best Rex development experience, we recommend:

#### 1. Roblox Studio Extensions

- **Rojo** - For version control and external editing
- **Luau Language Server** - For better autocomplete and error detection

#### 2. Code Editor Setup

If you're using Visual Studio Code or other external editors:

**Install Luau Language Server:**

```bash
# For VS Code
code --install-extension JohnnyMorganz.luau-lsp
```

**Configure type checking** by adding this to your script headers:

```lua
--!strict
local Rex = require(game.ReplicatedStorage.Rex)
```

#### 3. Type Definitions (Optional)

For better IntelliSense and type safety, Rex includes comprehensive type definitions:

```lua
-- At the top of your files for better autocomplete
local Rex = require(game.ReplicatedStorage.Rex)
local Types = require(game.ReplicatedStorage.Rex.Types)

-- Now you get full type checking and autocomplete!
```

## Project Organization

### Recommended File Structure

```tx
ReplicatedStorage/
  Rex/                       -- Framework (don't modify)
  Shared/
    Components/              -- Reusable UI components
      Button.luau
      Modal.luau
      Card.luau
    Hooks/                   -- Custom hooks
      useLocalStorage.luau
      useTimer.luau
    Utils/                   -- Utility functions
      themes.luau
      validation.luau
    Types/                   -- Your type definitions
      AppTypes.luau

StarterPlayer/
  StarterPlayerScripts/
    App.client.lua           -- Main application entry
    Screens/                 -- Main app screens
      HomeScreen.luau
      SettingsScreen.luau
    Services/                -- Client services
      DataService.luau
      UIService.luau
```

### Component Organization Example

```lua
-- ReplicatedStorage/Shared/Components/Button.luau
local Rex = require(game.ReplicatedStorage.Rex)

local function Button(props)
    local isHovered = Rex.useState(false)
    
    return Rex("TextButton") {
        Text = props.text or "Button",
        Size = props.size or UDim2.fromOffset(120, 40),
        -- Direct state binding - automatically reactive!
        BackgroundColor3 = isHovered:map(function(hovered)
            return hovered and Color3.fromRGB(90, 150, 255) or Color3.fromRGB(70, 130, 255)
        end),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        BorderSizePixel = 0,
        
        children = {
            Rex("UICorner") { CornerRadius = UDim.new(0, 6) }
        },
        
        onHover = function() isHovered:set(true) end,
        onLeave = function() isHovered:set(false) end,
        onClick = props.onClick
    }
end

return Button
```

```lua
-- Using the component in your app
local Button = require(game.ReplicatedStorage.Shared.Components.Button)

local function MyScreen()
    return Rex("Frame") {
        children = {
            Button {
                text = "Save Changes",
                onClick = function()
                    print("Saving...")
                end
            }
        }
    }
end
```

## Configuration Options

### Performance Settings

Rex includes several configuration options for optimization:

```lua
-- At the top of your main script
local Rex = require(game.ReplicatedStorage.Rex)

-- Configure Rex for your needs
Rex.configure({
    -- Enable development mode for better error messages
    developmentMode = true,
    
    -- Batch update frequency (lower = more responsive, higher = more efficient)
    batchUpdateRate = 60, -- Updates per second
    
    -- Enable performance profiling
    enableProfiling = true,
    
    -- Maximum component tree depth (prevents infinite loops)
    maxDepth = 100
})
```

### Theme Setup

Set up a global theme system:

```lua
-- ReplicatedStorage/Shared/Utils/themes.luau
local themes = {
    dark = {
        colors = {
            primary = Color3.fromRGB(70, 130, 255),
            background = Color3.fromRGB(30, 30, 30),
            surface = Color3.fromRGB(40, 40, 40),
            text = Color3.new(1, 1, 1),
            textSecondary = Color3.fromRGB(180, 180, 180)
        },
        spacing = {
            xs = 4, sm = 8, md = 16, lg = 24, xl = 32
        },
        borderRadius = {
            sm = 4, md = 8, lg = 12
        }
    },
    light = {
        colors = {
            primary = Color3.fromRGB(70, 130, 255),
            background = Color3.fromRGB(250, 250, 250),
            surface = Color3.fromRGB(255, 255, 255),
            text = Color3.fromRGB(30, 30, 30),
            textSecondary = Color3.fromRGB(100, 100, 100)
        },
        spacing = {
            xs = 4, sm = 8, md = 16, lg = 24, xl = 32
        },
        borderRadius = {
            sm = 4, md = 8, lg = 12
        }
    }
}

return themes
```

```lua
-- Using themes in your app
local Rex = require(game.ReplicatedStorage.Rex)
local themes = require(game.ReplicatedStorage.Shared.Utils.themes)

local ThemeContext = Rex.createContext(themes.dark)

local function App()
    local currentTheme = Rex.useState("dark")
    
    local themeValue = Rex.useComputed(function()
        return themes[currentTheme:get()]
    end, {currentTheme})
    
    return Rex.Provider {
        context = ThemeContext,
        value = themeValue,
        children = {
            -- Your app components here
        }
    }
end
```

## Troubleshooting

### Common Setup Issues

#### 1. "Rex is not a valid member of ReplicatedStorage"

**Problem:** Rex module isn't in the right location.

**Solution:** Make sure the Rex folder is directly inside ReplicatedStorage, not in Workspace or ServerStorage.

#### 2. "attempt to index nil with 'useState'"

**Problem:** Rex module didn't load properly.

**Solution:** Check that your require path is correct:

```lua
local Rex = require(game.ReplicatedStorage.Rex) -- Correct
-- NOT: require(game.ReplicatedStorage.Rex.init)
```

#### 3. UI doesn't appear

**Problem:** Script location or rendering target issues.

**Solution:**

- Make sure your script is in `StarterPlayerScripts` (for client UI)
- Check that you're rendering to the correct parent:

```lua
local player = game:GetService("Players").LocalPlayer
Rex.render(App, player.PlayerGui) -- For player-specific UI
```

#### 4. Performance issues

**Problem:** Too many reactive updates or large component trees.

**Solutions:**

- Use `Rex.batch()` for multiple state updates
- Add `key` props to list items
- Use `useComputed` for expensive calculations
- Enable development mode to see performance warnings

### Getting Help

If you run into issues:

1. **Check the console** - Rex provides detailed error messages in development mode
2. **Read the documentation** - Most common patterns are covered in the guides
3. **Check examples** - Look at the example projects for reference implementations
4. **Community support** - Visit our Discord or GitHub discussions

## Next Steps

Now that Rex is installed and configured:

1. **Read the [Your First Component](./your-first-component)** guide to learn component basics
2. **Explore [State Management Basics](./state-basics)** to understand reactive state
3. **Try the [Quick Start Guide](./quick-start)** for a complete mini-project
4. **Browse the [Examples](../examples/)** section for real-world patterns

You're ready to start building amazing reactive UIs with Rex!
