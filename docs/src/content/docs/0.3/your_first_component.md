---
title: "Your First Component"
description: "Learn to create your first Rex component with this hands-on tutorial"
category: "Getting Started"
order: 5

lastUpdated: 2025-06-23
---

In this tutorial, you'll create your first Rex component from scratch. We'll build a simple interactive button that demonstrates Rex's core concepts: declarative syntax, state management, and event handling.

## What You'll Build

By the end of this tutorial, you'll have created a `LikeButton` component that:

- Displays a heart icon and like count
- Changes appearance when clicked
- Updates the count reactively
- Shows hover effects

## Prerequisites

Make sure you've completed the [Installation](./installation) guide and have Rex set up in your project.

## Step 1: Create the Component File

Create a new file called `LikeButton.lua` in your project:

```luau
local Rex = require(path.to.Rex)

local function LikeButton(props)
    -- Component logic goes here
end

return LikeButton
```

## Step 2: Add State

Components often need to track changing data. In Rex, we use `useState` to create reactive state:

```luau
local Rex = require(path.to.Rex)

local function LikeButton(props)
    -- Create state for likes count
    local likes = Rex.useState(props.initialLikes or 0)
    
    -- Create state for liked status
    local isLiked = Rex.useState(false)
    
    return Rex("Frame") {
        -- Component UI goes here
    }
end

return LikeButton
```

### Understanding State

- `Rex.useState(initialValue)` creates a state object
- `likes:get()` reads the current value
- `likes:set(newValue)` updates the value
- When state changes, components automatically re-render

## Step 3: Build the UI Structure

Rex uses a declarative syntax similar to React JSX. Let's create the button structure:

```luau
local Rex = require(path.to.Rex)

local function LikeButton(props)
    local likes = Rex.useState(props.initialLikes or 0)
    local isLiked = Rex.useState(false)
    
    return Rex("TextButton") {
        -- Size and position
        Size = UDim2.fromOffset(120, 40),
        Position = props.position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        
        -- Styling
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200, 200, 200),
        
        -- Text content
        Text = "", -- We'll use child elements instead
        
        Rex("TextLabel") {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "❤️ " .. tostring(likes:get()),
            TextColor3 = Color3.fromRGB(50, 50, 50),
            TextScaled = true,
            Font = Enum.Font.Gotham
        }
    }
end

return LikeButton
```

## Step 4: Make It Reactive

With Rex's universal reactivity, components automatically update when state changes. You can bind state directly to properties:

```luau
local Rex = require(path.to.Rex)

local function LikeButton(props)
    local likes = Rex.useState(props.initialLikes or 0)
    local isLiked = Rex.useState(false)
    
    return Rex("TextButton") {
        Size = UDim2.fromOffset(120, 40),
        Position = props.position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        
        -- Direct state binding - automatically reactive!
        BackgroundColor3 = isLiked:map(function(liked)
            return liked and Color3.fromRGB(255, 182, 193) or Color3.fromRGB(255, 255, 255)
        end),
        
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200, 200, 200),
        Text = "",
        
        Rex("TextLabel") {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            
            -- Direct computed binding - no useComputed needed!
            Text = Rex.useComputed(function()
                local icon = isLiked:get() and "❤️" or "🤍"
                return icon .. " " .. tostring(likes:get())
            end, {likes, isLiked}),
            
            TextColor3 = Color3.fromRGB(50, 50, 50),
            TextScaled = true,
            Font = Enum.Font.Gotham
        }
    }
end

return LikeButton
```

### Understanding Universal Reactivity

- Rex automatically detects reactive values and handles updates
- `:map()` creates a computed value that updates when the source state changes
- `Rex.useComputed()` creates computed values that depend on multiple states
- You can bind state objects directly to properties for automatic reactivity

## Step 5: Add Event Handling

Now let's make the button interactive by adding click handling. Rex also provides helpful state methods to make updates easier:

```luau
local Rex = require(path.to.Rex)

local function LikeButton(props)
    local likes = Rex.useState(props.initialLikes or 0)
    local isLiked = Rex.useState(false)
    local isHovered = Rex.useState(false)
    
    return Rex("TextButton") {
        Size = UDim2.fromOffset(120, 40),
        Position = props.position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        
        -- Reactive styling with computed values
        BackgroundColor3 = Rex.useComputed(function()
            if isHovered:get() then
                return isLiked:get() and Color3.fromRGB(255, 160, 180) or Color3.fromRGB(245, 245, 245)
            else
                return isLiked:get() and Color3.fromRGB(255, 182, 193) or Color3.fromRGB(255, 255, 255)
            end
        end, {isLiked, isHovered}),
        
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200, 200, 200),
        Text = "",
        
        -- Event handlers with new helper methods
        onClick = function()
            -- Use toggle helper for boolean state
            isLiked:toggle()
            
            -- Use increment/decrement helpers for numbers
            if isLiked:get() then
                likes:increment()
            else
                likes:decrement()
            end
            
            -- Call optional callback
            if props.onLike then
                props.onLike(likes:get(), isLiked:get())
            end
        end,
        
        onHover = function()
            isHovered:set(true)
        end,
        
        onLeave = function()
            isHovered:set(false)
        end,
        
        Rex("TextLabel") {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            
            Text = Rex.useComputed(function()
                local icon = isLiked:get() and "❤️" or "🤍"
                return icon .. " " .. tostring(likes:get())
            end, {likes, isLiked}),
            
            TextColor3 = Color3.fromRGB(50, 50, 50),
            TextScaled = true,
            Font = Enum.Font.Gotham
        }
    }
end

return LikeButton
```

### Understanding Events

- `onClick`, `onHover`, `onLeave` are Rex's event handlers
- `:toggle()` flips boolean values
- `:increment()` and `:decrement()` modify numbers easily
- `:update()` modifies state based on the current value
- Event handlers can call props callbacks to communicate with parent components

## Step 6: Test Your Component

Create a simple test file to see your component in action:

```luau
-- TestLikeButton.client.lua
local Players = require(game:GetService("Players"))
local Rex = require(path.to.Rex)
local LikeButton = require(path.to.LikeButton)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LikeButtonTest"
screenGui.Parent = playerGui

-- Render the component
Rex.render(screenGui, {
    LikeButton {
        initialLikes = 42,
        position = UDim2.fromScale(0.5, 0.5),
        onLike = function(count, isLiked)
            print("Button", isLiked and "liked" or "unliked", "- Total likes:", count)
        end
    }
})
```

## Complete Component Code

Here's the final `LikeButton.lua`:

```luau
local Rex = require(path.to.Rex)

local function LikeButton(props)
    local likes = Rex.useState(props.initialLikes or 0)
    local isLiked = Rex.useState(false)
    local isHovered = Rex.useState(false)
    
    return Rex("TextButton") {
        Size = UDim2.fromOffset(120, 40),
        Position = props.position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        
        BackgroundColor3 = Rex.useComputed(function()
            if isHovered:get() then
                return isLiked:get() and Color3.fromRGB(255, 160, 180) or Color3.fromRGB(245, 245, 245)
            else
                return isLiked:get() and Color3.fromRGB(255, 182, 193) or Color3.fromRGB(255, 255, 255)
            end
        end, {isLiked, isHovered}),
        
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200, 200, 200),
        Text = "",
        
        onClick = function()
            isLiked:toggle()
            if isLiked:get() then
                likes:increment()
            else
                likes:decrement()
            end
            
            if props.onLike then
                props.onLike(likes:get(), isLiked:get())
            end
        end,
        
        onHover = function()
            isHovered:set(true)
        end,
        
        onLeave = function()
            isHovered:set(false)
        end,
        
        children = {
            Rex("TextLabel") {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                
                Text = Rex.useComputed(function()
                    local icon = isLiked:get() and "❤️" or "🤍"
                    return icon .. " " .. tostring(likes:get())
                end, {likes, isLiked}),
                
                TextColor3 = Color3.fromRGB(50, 50, 50),
                TextScaled = true,
                Font = Enum.Font.Gotham
            }
        }
    }
end

return LikeButton
```

## What You've Learned

Congratulations! You've created your first Rex component. You've learned:

1. **Component Structure**: How to create and export Rex components
2. **State Management**: Using `useState` to track changing data
3. **Reactive Properties**: Making UI update automatically when state changes
4. **Event Handling**: Responding to user interactions
5. **Computed Values**: Deriving values from multiple states
6. **Props**: Accepting and using external configuration

## Next Steps

Now that you understand the basics, you're ready to:

- Learn more about [State Management Basics](./state_management_basics)
- Explore [Core Concepts](./core_concepts/state) in depth
- Try the [Quick Start Guide](./quick_start_guide) for more examples
- Build more complex components with multiple children and layouts

## Common Issues and Solutions

### Component Doesn't Update

- Make sure you're using reactive properties (`:map()` or `useComputed`)
- Check that state dependencies are listed in dependency arrays

### Events Not Working

- Ensure you're using Rex event names (`onClick`, not `MouseButton1Click`)
- Verify event handlers are functions, not function calls

### Performance Issues

- Use `useComputed` for expensive calculations
- Avoid creating new functions in render - define them outside or use callbacks

Ready to continue your Rex journey? Head to [State Management Basics](./state_management_basics) next!
