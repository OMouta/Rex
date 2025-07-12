---
title: "Deep Reactivity and Nested State"
description: "Managing complex nested data structures with Rex's deep reactive state system."
category: "Advanced Features"
order: 1
 
lastUpdated: 2025-06-23
---

Rex supports deep reactive states that can track changes to nested tables and complex data structures. This enables you to work with sophisticated application state while maintaining the simplicity of reactive updates throughout your component tree.

## Understanding Deep Reactivity

Regular `useState` only triggers updates when the top-level reference changes. Deep reactivity goes further by tracking changes within nested objects and arrays, making it perfect for:

- User profiles with nested settings
- Shopping carts with item details
- Game state with player inventories
- Form data with validation states
- Complex UI state management

## Basic Deep Reactive State

Use `Rex.useDeepState` to create deeply reactive state:

```lua
local function UserProfileExample()
    local user = Rex.useDeepState({
        personal = {
            name = "John Doe",
            age = 30,
            email = "john@example.com"
        },
        preferences = {
            theme = "dark",
            language = "en",
            notifications = {
                email = true,
                push = false,
                sms = true
            }
        },
        stats = {
            level = 5,
            experience = 1250,
            achievements = {"first_login", "level_up"}
        }
    })
    
    return Rex("Frame") {
        children = {
            -- Display user name (automatically updates when changed)
            Rex("TextLabel") {
                Text = user:map(function(userData)
                    return "Hello, " .. userData.personal.name
                end)
            },
            
            -- Update nested properties
            Rex("TextButton") {
                Text = "Change Name",
                onClick = function()
                    user:update(function(current)
                        current.personal.name = "Jane Smith"
                        return current
                    end)
                end
            },
            
            -- Toggle deep nested properties
            Rex("TextButton") {
                Text = user:map(function(userData)
                    return userData.preferences.notifications.email and "Disable Email" or "Enable Email"
                end),
                onClick = function()
                    user:update(function(current)
                        current.preferences.notifications.email = not current.preferences.notifications.email
                        return current
                    end)
                end
            },
            
            -- Add to nested array
            Rex("TextButton") {
                Text = "Add Achievement",
                onClick = function()
                    user:update(function(current)
                        table.insert(current.stats.achievements, "button_clicker")
                        return current
                    end)
                end
            }
        }
    }
end
```

## Working with Arrays and Lists

Deep reactivity excels at managing dynamic arrays:

```lua
local function InventoryManagerExample()
    local inventory = Rex.useDeepState({
        items = {
            { id = 1, name = "Sword", type = "weapon", quantity = 1, rarity = "common" },
            { id = 2, name = "Health Potion", type = "consumable", quantity = 5, rarity = "common" },
            { id = 3, name = "Magic Ring", type = "accessory", quantity = 1, rarity = "rare" }
        },
        categories = {
            weapon = { displayName = "Weapons", icon = "⚔️" },
            consumable = { displayName = "Consumables", icon = "🧪" },
            accessory = { displayName = "Accessories", icon = "💍" }
        },
        filters = {
            selectedCategory = "all",
            selectedRarity = "all",
            searchText = ""
        }
    })
    
    local addItem = function(name, type, rarity)
        inventory:update(function(current)
            local newId = 0
            for _, item in ipairs(current.items) do
                newId = math.max(newId, item.id)
            end
            newId = newId + 1
            
            table.insert(current.items, {
                id = newId,
                name = name,
                type = type,
                quantity = 1,
                rarity = rarity
            })
            return current
        end)
    end
    
    local updateQuantity = function(itemId, newQuantity)
        inventory:update(function(current)
            for _, item in ipairs(current.items) do
                if item.id == itemId then
                    item.quantity = math.max(0, newQuantity)
                    break
                end
            end
            return current
        end)
    end
    
    local removeItem = function(itemId)
        inventory:update(function(current)
            for i, item in ipairs(current.items) do
                if item.id == itemId then
                    table.remove(current.items, i)
                    break
                end
            end
            return current
        end)
    end
    
    -- Computed filtered items
    local filteredItems = Rex.useComputed(function()
        local data = inventory:get()
        local items = data.items
        local filters = data.filters
        
        local filtered = {}
        for _, item in ipairs(items) do
            local matchesCategory = filters.selectedCategory == "all" or item.type == filters.selectedCategory
            local matchesRarity = filters.selectedRarity == "all" or item.rarity == filters.selectedRarity
            local matchesSearch = filters.searchText == "" or 
                                string.find(string.lower(item.name), string.lower(filters.searchText))
            
            if matchesCategory and matchesRarity and matchesSearch then
                table.insert(filtered, item)
            end
        end
        return filtered
    end, {inventory})
    
    return Rex("Frame") {
        children = {
            -- Filter controls
            Rex("Frame") {
                children = {
                    Rex("TextBox") {
                        PlaceholderText = "Search items...",
                        onTextChanged = function(textBox)
                            inventory:update(function(current)
                                current.filters.searchText = textBox.Text
                                return current
                            end)
                        end
                    },
                    
                    -- Category filter buttons
                    Rex("TextButton") {
                        Text = "All Categories",
                        onClick = function()
                            inventory:update(function(current)
                                current.filters.selectedCategory = "all"
                                return current
                            end)
                        end
                    },
                    
                    inventory:map(function(data)
                        local children = {}
                        for categoryType, categoryInfo in pairs(data.categories) do
                            table.insert(children, Rex("TextButton") {
                                Text = categoryInfo.icon .. " " .. categoryInfo.displayName,
                                onClick = function()
                                    inventory:update(function(current)
                                        current.filters.selectedCategory = categoryType
                                        return current
                                    end)
                                end,
                                key = categoryType
                            })
                        end
                        return children
                    end)
                }
            },
            
            -- Item list
            Rex("ScrollingFrame") {
                children = {
                    filteredItems:map(function(items)
                        local children = {}
                        for _, item in ipairs(items) do
                            table.insert(children, Rex("Frame") {
                                children = {
                                    Rex("TextLabel") {
                                        Text = string.format("%s (x%d) - %s", 
                                                           item.name, item.quantity, item.rarity)
                                    },
                                    Rex("TextButton") {
                                        Text = "+",
                                        onClick = function()
                                            updateQuantity(item.id, item.quantity + 1)
                                        end
                                    },
                                    Rex("TextButton") {
                                        Text = "-",
                                        onClick = function()
                                            updateQuantity(item.id, item.quantity - 1)
                                        end
                                    },
                                    Rex("TextButton") {
                                        Text = "Remove",
                                        onClick = function()
                                            removeItem(item.id)
                                        end
                                    }
                                },
                                key = tostring(item.id)
                            })
                        end
                        return children
                    end)
                }
            },
            
            -- Add item section
            Rex("TextButton") {
                Text = "Add Legendary Sword",
                onClick = function()
                    addItem("Legendary Sword", "weapon", "legendary")
                end
            }
        }
    }
end
```

## Form State Management

Deep reactivity is perfect for complex forms with validation:

```lua
local function ContactFormExample()
    local formState = Rex.useDeepState({
        data = {
            personal = {
                firstName = "",
                lastName = "",
                email = "",
                phone = ""
            },
            address = {
                street = "",
                city = "",
                state = "",
                zipCode = ""
            },
            preferences = {
                newsletter = false,
                marketing = false,
                notifications = "email" -- "email", "sms", "none"
            }
        },
        validation = {
            personal = {
                firstName = { isValid = true, message = "" },
                lastName = { isValid = true, message = "" },
                email = { isValid = true, message = "" },
                phone = { isValid = true, message = "" }
            },
            address = {
                street = { isValid = true, message = "" },
                city = { isValid = true, message = "" },
                state = { isValid = true, message = "" },
                zipCode = { isValid = true, message = "" }
            }
        },
        ui = {
            currentStep = 1, -- 1: personal, 2: address, 3: preferences
            isSubmitting = false,
            submitMessage = ""
        }
    })
    
    local validateField = function(section, field, value)
        formState:update(function(current)
            local validation = current.validation[section][field]
            
            if field == "email" then
                validation.isValid = string.match(value, "^[%w%._%+%-]+@[%w%._%+%-]+%.%w+$") ~= nil
                validation.message = validation.isValid and "" or "Please enter a valid email address"
            elseif field == "zipCode" then
                validation.isValid = string.match(value, "^%d%d%d%d%d$") ~= nil
                validation.message = validation.isValid and "" or "Please enter a 5-digit zip code"
            else
                validation.isValid = string.len(value) > 0
                validation.message = validation.isValid and "" or "This field is required"
            end
            
            return current
        end)
    end
    
    local updateField = function(section, field, value)
        formState:update(function(current)
            current.data[section][field] = value
            return current
        end)
        validateField(section, field, value)
    end
    
    local isStepValid = Rex.useComputed(function()
        local state = formState:get()
        local currentStep = state.ui.currentStep
        
        if currentStep == 1 then
            -- Check personal info validation
            for _, validation in pairs(state.validation.personal) do
                if not validation.isValid then return false end
            end
            -- Check that required fields have values
            local personal = state.data.personal
            return personal.firstName ~= "" and personal.lastName ~= "" and personal.email ~= ""
        elseif currentStep == 2 then
            -- Check address validation
            for _, validation in pairs(state.validation.address) do
                if not validation.isValid then return false end
            end
            -- Check that required fields have values
            local address = state.data.address
            return address.street ~= "" and address.city ~= "" and address.state ~= ""
        else
            return true -- Preferences step is always valid
        end
    end, {formState})
    
    local nextStep = function()
        formState:update(function(current)
            current.ui.currentStep = math.min(3, current.ui.currentStep + 1)
            return current
        end)
    end
    
    local prevStep = function()
        formState:update(function(current)
            current.ui.currentStep = math.max(1, current.ui.currentStep - 1)
            return current
        end)
    end
    
    return Rex("Frame") {
        children = {
            -- Step indicator
            Rex("Frame") {
                children = {
                    formState:map(function(state)
                        local children = {}
                        for i = 1, 3 do
                            local stepNames = {"Personal", "Address", "Preferences"}
                            table.insert(children, Rex("TextLabel") {
                                Text = stepNames[i],
                                TextColor3 = i == state.ui.currentStep and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150),
                                key = tostring(i)
                            })
                        end
                        return children
                    end)
                }
            },
            
            -- Form content based on current step
            formState:map(function(state)
                if state.ui.currentStep == 1 then
                    -- Personal information step
                    return Rex("Frame") {
                        children = {
                            Rex("TextBox") {
                                PlaceholderText = "First Name",
                                Text = state.data.personal.firstName,
                                onTextChanged = function(textBox)
                                    updateField("personal", "firstName", textBox.Text)
                                end
                            },
                            Rex("TextBox") {
                                PlaceholderText = "Last Name", 
                                Text = state.data.personal.lastName,
                                onTextChanged = function(textBox)
                                    updateField("personal", "lastName", textBox.Text)
                                end
                            },
                            Rex("TextBox") {
                                PlaceholderText = "Email",
                                Text = state.data.personal.email,
                                onTextChanged = function(textBox)
                                    updateField("personal", "email", textBox.Text)
                                end
                            },
                            -- Validation messages
                            state.validation.personal.email.isValid and nil or Rex("TextLabel") {
                                Text = state.validation.personal.email.message,
                                TextColor3 = Color3.fromRGB(255, 100, 100)
                            }
                        }
                    }
                elseif state.ui.currentStep == 2 then
                    -- Address step
                    return Rex("Frame") {
                        children = {
                            Rex("TextBox") {
                                PlaceholderText = "Street Address",
                                Text = state.data.address.street,
                                onTextChanged = function(textBox)
                                    updateField("address", "street", textBox.Text)
                                end
                            },
                            Rex("TextBox") {
                                PlaceholderText = "City",
                                Text = state.data.address.city,
                                onTextChanged = function(textBox)
                                    updateField("address", "city", textBox.Text)
                                end
                            },
                            Rex("TextBox") {
                                PlaceholderText = "Zip Code",
                                Text = state.data.address.zipCode,
                                onTextChanged = function(textBox)
                                    updateField("address", "zipCode", textBox.Text)
                                end
                            }
                        }
                    }
                else
                    -- Preferences step
                    return Rex("Frame") {
                        children = {
                            Rex("TextButton") {
                                Text = state.data.preferences.newsletter and "✓ Newsletter" or "☐ Newsletter",
                                onClick = function()
                                    formState:update(function(current)
                                        current.data.preferences.newsletter = not current.data.preferences.newsletter
                                        return current
                                    end)
                                end
                            }
                        }
                    }
                end
            end),
            
            -- Navigation buttons
            Rex("Frame") {
                children = {
                    formState:map(function(state)
                        return state.ui.currentStep > 1 and Rex("TextButton") {
                            Text = "Previous",
                            onClick = prevStep
                        } or nil
                    end),
                    
                    formState:map(function(state)
                        if state.ui.currentStep < 3 then
                            return Rex("TextButton") {
                                Text = "Next",
                                BackgroundColor3 = isStepValid:map(function(valid)
                                    return valid and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(150, 150, 150)
                                end),
                                onClick = isStepValid:map(function(valid)
                                    return valid and nextStep or nil
                                end)
                            }
                        else
                            return Rex("TextButton") {
                                Text = "Submit",
                                onClick = function()
                                    formState:update(function(current)
                                        current.ui.isSubmitting = true
                                        current.ui.submitMessage = "Form submitted successfully!"
                                        return current
                                    end)
                                end
                            }
                        end
                    end)
                }
            }
        }
    }
end
```

## Performance Considerations with Deep State

While deep reactivity is powerful, it requires careful consideration for performance:

### 1. Minimize Deep Nesting

```lua
-- ✅ Good: Reasonable nesting depth
local state = Rex.useDeepState({
    user = { name = "John", settings = { theme = "dark" } }
})

-- ❌ Avoid: Excessive nesting
local state = Rex.useDeepState({
    app = {
        modules = {
            user = {
                profile = {
                    personal = {
                        details = {
                            name = { first = "John", last = "Doe" }
                        }
                    }
                }
            }
        }
    }
})
```

### 2. Split Large States

```lua
-- ✅ Good: Split related but independent concerns
local userState = Rex.useDeepState({ name: "John", email: "john@example.com" })
local cartState = Rex.useDeepState({ items: [], total: 0 })
local uiState = Rex.useDeepState({ sidebarOpen: false, theme: "dark" })

-- ❌ Avoid: Monolithic state object
local appState = Rex.useDeepState({
    user: { /* large user object */ },
    cart: { /* large cart object */ },
    ui: { /* large UI state */ },
    data: { /* large data cache */ }
})
```

### 3. Use Immutable Updates

Always update deep state immutably for predictable behavior:

```lua
-- ✅ Good: Immutable update
state:update(function(current)
    return {
        ...current,
        user = {
            ...current.user,
            name = "New Name"
        }
    }
end)

-- ❌ Bad: Direct mutation
state:update(function(current)
    current.user.name = "New Name" -- Direct mutation!
    return current
end)
```

## Best Practices

### 1. Use Deep State for Complex Objects

Deep state is ideal for objects with nested properties that need reactive updates:

```lua
-- ✅ Good use case: User profile with nested settings
local profile = Rex.useDeepState({
    personal: { name: "", email: "" },
    settings: { theme: "dark", notifications: true },
    preferences: { language: "en", timezone: "UTC" }
})
```

### 2. Prefer Regular State for Simple Values

For simple values, regular state is more efficient:

```lua
-- ✅ Good: Simple values
local count = Rex.useState(0)
local isVisible = Rex.useState(true)
local currentTab = Rex.useState("home")

-- ❌ Unnecessary: Deep state for simple values
local state = Rex.useDeepState({
    count: 0,
    isVisible: true,
    currentTab: "home"
})
```

### 3. Validate Data Structure

Consider adding validation for complex deep state:

```lua
local function createValidatedUserState(initialData) 
    local state = Rex.useDeepState(initialData)
    
    -- Wrap update to add validation
    local originalUpdate = state.update
    state.update = function(updateFn)
        return originalUpdate(function(current)
            local newState = updateFn(current)
            
            -- Validate the new state
            if not newState.personal or not newState.personal.email then
                error("Invalid user state: missing required email")
            end
            
            return newState
        end)
    end
    
    return state
end
```

Deep reactivity in Rex enables sophisticated state management patterns while maintaining the simplicity and predictability of reactive updates. Use it when you need to track changes in complex, nested data structures.
