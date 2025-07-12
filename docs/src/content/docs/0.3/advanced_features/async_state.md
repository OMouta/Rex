---
title: "Async State Management"
description: "Handling asynchronous operations, data fetching, and loading states with Rex's async utilities."
category: "Advanced Features"
order: 3

lastUpdated: 2025-06-23
---

Rex provides powerful utilities for handling asynchronous operations such as API calls, data fetching, file loading, and other async tasks. The `useAsyncState` hook and related patterns make it easy to manage loading states, error handling, and data updates in a reactive way.

## Understanding Async State

Async state in Rex automatically tracks three key aspects of asynchronous operations:

1. **Loading State** - Whether the operation is currently running
2. **Data State** - The successful result of the operation
3. **Error State** - Any errors that occurred during the operation

This eliminates the need to manually manage these states and provides a consistent pattern for all async operations.

## Basic Async State Usage

Use `Rex.useAsyncState` to handle simple asynchronous operations:

```lua
local function UserProfileExample()
    local userId = Rex.useState(123)
    
    -- Async state that fetches user data
    local userAsync = Rex.useAsyncState(function()
        local currentUserId = userId:get()
        print("Fetching user data for ID:", currentUserId)
        
        -- Simulate API call
        task.wait(2) -- Simulate network delay
        
        if currentUserId == 999 then
            error("User not found") -- Simulate error
        end
        
        return {
            id = currentUserId,
            name = "User " .. tostring(currentUserId),
            email = "user" .. tostring(currentUserId) .. "@example.com",
            avatar = "rbxasset://textures/face.png",
            joinDate = os.date("%Y-%m-%d", os.time() - currentUserId * 86400)
        }
    end, {userId}) -- Re-run when userId changes
    
    return Rex("Frame") {
        Size = UDim2.fromOffset(400, 300),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        
        children = {
            Rex("UIListLayout") {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 10)
            },
            
            -- Loading indicator
            userAsync.loading:map(function(isLoading)
                return isLoading and Rex("Frame") {
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                    children = {
                        Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
                        Rex("TextLabel") {
                            Text = "Loading user data...",
                            Size = UDim2.fromScale(1, 1),
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            TextScaled = true
                        }
                    }
                } or nil
            end),
            
            -- Error display
            userAsync.error:map(function(error)
                return error and Rex("Frame") {
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundColor3 = Color3.fromRGB(80, 30, 30),
                    children = {
                        Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
                        Rex("TextLabel") {
                            Text = "Error: " .. tostring(error),
                            Size = UDim2.fromScale(1, 1),
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.fromRGB(255, 150, 150),
                            TextScaled = true
                        }
                    }
                } or nil
            end),
            
            -- User data display
            userAsync.data:map(function(userData)
                return userData and Rex("Frame") {
                    Size = UDim2.new(1, 0, 0, 200),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                    children = {
                        Rex("UICorner") { CornerRadius = UDim.new(0, 8) },
                        Rex("UIPadding") {
                            PaddingTop = UDim.new(0, 15),
                            PaddingBottom = UDim.new(0, 15),
                            PaddingLeft = UDim.new(0, 15),
                            PaddingRight = UDim.new(0, 15)
                        },
                        Rex("UIListLayout") {
                            FillDirection = Enum.FillDirection.Vertical,
                            Padding = UDim.new(0, 8)
                        },
                        Rex("TextLabel") {
                            Text = "Name: " .. userData.name,
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.new(1, 1, 1),
                            TextScaled = true,
                            TextXAlignment = Enum.TextXAlignment.Left
                        },
                        Rex("TextLabel") {
                            Text = "Email: " .. userData.email,
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            TextScaled = true,
                            TextXAlignment = Enum.TextXAlignment.Left
                        },
                        Rex("TextLabel") {
                            Text = "Joined: " .. userData.joinDate,
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.fromRGB(150, 150, 150),
                            TextScaled = true,
                            TextXAlignment = Enum.TextXAlignment.Left
                        }
                    }
                } or nil
            end),
            
            -- Controls
            Rex("Frame") {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                children = {
                    Rex("UIListLayout") {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 10)
                    },
                    Rex("TextButton") {
                        Text = "Load User 456",
                        Size = UDim2.fromOffset(120, 40),
                        BackgroundColor3 = Color3.fromRGB(70, 130, 255),
                        TextColor3 = Color3.new(1, 1, 1),
                        onClick = function() userId:set(456) end
                    },
                    Rex("TextButton") {
                        Text = "Load User 999 (Error)",
                        Size = UDim2.fromOffset(150, 40),
                        BackgroundColor3 = Color3.fromRGB(255, 100, 100),
                        TextColor3 = Color3.new(1, 1, 1),
                        onClick = function() userId:set(999) end
                    },
                    Rex("TextButton") {
                        Text = "Reload",
                        Size = UDim2.fromOffset(80, 40),
                        BackgroundColor3 = Color3.fromRGB(100, 200, 100),
                        TextColor3 = Color3.new(1, 1, 1),
                        onClick = function() userAsync.reload() end
                    }
                }
            }
        }
    }
end
```

## Advanced Async Patterns

### Data Fetching with Parameters

Handle async operations that depend on multiple parameters:

```lua
local function SearchExample()
    local searchQuery = Rex.useState("")
    local category = Rex.useState("all")
    local sortBy = Rex.useState("relevance")
    
    local searchResults = Rex.useAsyncState(function()
        local query = searchQuery:get()
        local cat = category:get()
        local sort = sortBy:get()
        
        -- Don't search if query is empty
        if query == "" then
            return { results = {}, total = 0 }
        end
        
        print(string.format("Searching for '%s' in '%s' sorted by '%s'", query, cat, sort))
        
        -- Simulate search API call
        task.wait(1 + math.random() * 2) -- Variable delay
        
        -- Simulate some results
        local results = {}
        local searchTerms = {"apple", "banana", "cherry", "date", "elderberry"}
        
        for i, term in ipairs(searchTerms) do
            if string.find(string.lower(term), string.lower(query)) then
                table.insert(results, {
                    id = i,
                    title = term:gsub("^%l", string.upper),
                    description = "Description for " .. term,
                    category = cat == "all" and ({"fruit", "food", "organic"})[math.random(3)] or cat,
                    relevance = math.random(100)
                })
            end
        end
        
        -- Sort results
        if sort == "relevance" then
            table.sort(results, function(a, b) return a.relevance > b.relevance end)
        elseif sort == "alphabetical" then
            table.sort(results, function(a, b) return a.title < b.title end)
        end
        
        return {
            results = results,
            total = #results,
            query = query,
            category = cat,
            sortBy = sort
        }
    end, {searchQuery, category, sortBy})
    
    -- Debounced search - only search after user stops typing
    local debouncedSearch = Rex.useAsyncState(function()
        local query = searchQuery:get()
        if query == "" then return nil end
        
        -- Wait for user to stop typing
        task.wait(0.5)
        
        -- Check if query is still the same (user didn't keep typing)
        if searchQuery:get() ~= query then
            return nil -- Cancel this search
        end
        
        return searchResults.reload()
    end, {searchQuery})
    
    return Rex("Frame") {
        children = {
            -- Search controls
            Rex("Frame") {
                children = {
                    Rex("TextBox") {
                        PlaceholderText = "Search...",
                        Text = searchQuery,
                        onTextChanged = function(textBox)
                            searchQuery:set(textBox.Text)
                        end
                    },
                    Rex("TextButton") {
                        Text = category:map(function(cat) 
                            return cat == "all" and "All Categories" or cat:gsub("^%l", string.upper)
                        end),
                        onClick = function()
                            category:update(function(current)
                                local categories = {"all", "fruit", "food", "organic"}
                                local currentIndex = 1
                                for i, cat in ipairs(categories) do
                                    if cat == current then
                                        currentIndex = i
                                        break
                                    end
                                end
                                return categories[(currentIndex % #categories) + 1]
                            end)
                        end
                    }
                }
            },
            
            -- Loading and results
            searchResults.loading:map(function(isLoading)
                return isLoading and Rex("TextLabel") {
                    Text = "Searching...",
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                } or nil
            end),
            
            searchResults.data:map(function(data)
                if not data or #data.results == 0 then
                    return Rex("TextLabel") {
                        Text = searchQuery:get() == "" and "Enter a search query" or "No results found",
                        TextColor3 = Color3.fromRGB(150, 150, 150)
                    }
                end
                
                local children = {
                    Rex("TextLabel") {
                        Text = string.format("Found %d results for '%s'", data.total, data.query),
                        key = "header"
                    }
                }
                
                for _, result in ipairs(data.results) do
                    table.insert(children, Rex("Frame") {
                        children = {
                            Rex("TextLabel") {
                                Text = result.title .. " (" .. result.category .. ")"
                            },
                            Rex("TextLabel") {
                                Text = result.description,
                                TextColor3 = Color3.fromRGB(180, 180, 180)
                            }
                        },
                        key = tostring(result.id)
                    })
                end
                
                return children
            end)
        }
    }
end
```

### Cached Async Data

Implement caching to avoid repeated requests:

```lua
local function CachedDataExample()
    -- Simple cache implementation
    local cache = {}
    local cacheExpiry = {} -- Timestamps for cache expiration
    local CACHE_DURATION = 300 -- 5 minutes in seconds
    
    local selectedDataId = Rex.useState("user_123")
    
    local cachedData = Rex.useAsyncState(function()
        local dataId = selectedDataId:get()
        local currentTime = os.time()
        
        -- Check if we have cached data that hasn't expired
        if cache[dataId] and cacheExpiry[dataId] and currentTime < cacheExpiry[dataId] then
            print("Using cached data for:", dataId)
            return cache[dataId]
        end
        
        print("Fetching fresh data for:", dataId)
        
        -- Simulate API call
        task.wait(2)
        
        local data = {
            id = dataId,
            content = "Fresh data for " .. dataId,
            timestamp = os.date("%H:%M:%S", currentTime),
            details = {
                randomValue = math.random(1000),
                status = "active"
            }
        }
        
        -- Cache the data
        cache[dataId] = data
        cacheExpiry[dataId] = currentTime + CACHE_DURATION
        
        return data
    end, {selectedDataId})
    
    local clearCache = function()
        cache = {}
        cacheExpiry = {}
        cachedData.reload()
    end
    
    return Rex("Frame") {
        children = {
            -- Data selection
            Rex("Frame") {
                children = {
                    Rex("TextButton") {
                        Text = "Load User 123",
                        onClick = function() selectedDataId:set("user_123") end
                    },
                    Rex("TextButton") {
                        Text = "Load User 456",
                        onClick = function() selectedDataId:set("user_456") end
                    },
                    Rex("TextButton") {
                        Text = "Load Product ABC",
                        onClick = function() selectedDataId:set("product_abc") end
                    },
                    Rex("TextButton") {
                        Text = "Clear Cache",
                        onClick = clearCache,
                        BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                    }
                }
            },
            
            -- Data display
            cachedData.loading:map(function(isLoading)
                return isLoading and Rex("TextLabel") {
                    Text = "Loading data..."
                } or nil
            end),
            
            cachedData.data:map(function(data)
                return data and Rex("Frame") {
                    children = {
                        Rex("TextLabel") {
                            Text = "ID: " .. data.id
                        },
                        Rex("TextLabel") {
                            Text = "Content: " .. data.content
                        },
                        Rex("TextLabel") {
                            Text = "Fetched at: " .. data.timestamp
                        },
                        Rex("TextLabel") {
                            Text = "Random Value: " .. tostring(data.details.randomValue)
                        }
                    }
                } or nil
            end)
        }
    }
end
```

### Sequential Async Operations

Chain multiple async operations together:

```lua
local function SequentialAsyncExample()
    local userId = Rex.useState(1)
    
    -- First: Load user profile
    local userProfile = Rex.useAsyncState(function()
        local id = userId:get()
        print("Step 1: Loading user profile for ID:", id)
        
        task.wait(1) -- Simulate API call
        
        return {
            id = id,
            name = "User " .. tostring(id),
            departmentId = id + 10
        }
    end, {userId})
    
    -- Second: Load department info (depends on user profile)
    local departmentInfo = Rex.useAsyncState(function()
        local user = userProfile.data:get()
        if not user then return nil end
        
        print("Step 2: Loading department info for ID:", user.departmentId)
        
        task.wait(1) -- Simulate API call
        
        return {
            id = user.departmentId,
            name = "Department " .. tostring(user.departmentId),
            managerId = user.departmentId + 100
        }
    end, {userProfile.data})
    
    -- Third: Load manager info (depends on department info)
    local managerInfo = Rex.useAsyncState(function()
        local dept = departmentInfo.data:get()
        if not dept then return nil end
        
        print("Step 3: Loading manager info for ID:", dept.managerId)
        
        task.wait(1) -- Simulate API call
        
        return {
            id = dept.managerId,
            name = "Manager " .. tostring(dept.managerId),
            email = "manager" .. tostring(dept.managerId) .. "@company.com"
        }
    end, {departmentInfo.data})
    
    -- Combined loading state
    local isAnyLoading = Rex.useComputed(function()
        return userProfile.loading:get() or departmentInfo.loading:get() or managerInfo.loading:get()
    end, {userProfile.loading, departmentInfo.loading, managerInfo.loading})
    
    return Rex("Frame") {
        children = {
            -- Progress indicator
            isAnyLoading:map(function(loading)
                return loading and Rex("Frame") {
                    children = {
                        Rex("TextLabel") {
                            Text = "Loading chain in progress..."
                        },
                        Rex("Frame") { -- Progress bar
                            Size = UDim2.new(1, 0, 0, 4),
                            BackgroundColor3 = Color3.fromRGB(70, 130, 255),
                            Size = Rex.useComputed(function()
                                local steps = 0
                                if userProfile.data:get() then steps = steps + 1 end
                                if departmentInfo.data:get() then steps = steps + 1 end
                                if managerInfo.data:get() then steps = steps + 1 end
                                return UDim2.new(steps / 3, 0, 0, 4)
                            end, {userProfile.data, departmentInfo.data, managerInfo.data})
                        }
                    }
                } or nil
            end),
            
            -- Step results
            userProfile.data:map(function(user)
                return user and Rex("TextLabel") {
                    Text = "✓ User: " .. user.name,
                    TextColor3 = Color3.fromRGB(100, 255, 100)
                } or Rex("TextLabel") {
                    Text = userProfile.loading:get() and "⏳ Loading user..." or "⚪ User",
                    TextColor3 = Color3.fromRGB(150, 150, 150)
                }
            end),
            
            departmentInfo.data:map(function(dept)
                return dept and Rex("TextLabel") {
                    Text = "✓ Department: " .. dept.name,
                    TextColor3 = Color3.fromRGB(100, 255, 100)
                } or Rex("TextLabel") {
                    Text = departmentInfo.loading:get() and "⏳ Loading department..." or "⚪ Department",
                    TextColor3 = Color3.fromRGB(150, 150, 150)
                }
            end),
            
            managerInfo.data:map(function(manager)
                return manager and Rex("TextLabel") {
                    Text = "✓ Manager: " .. manager.name .. " (" .. manager.email .. ")",
                    TextColor3 = Color3.fromRGB(100, 255, 100)
                } or Rex("TextLabel") {
                    Text = managerInfo.loading:get() and "⏳ Loading manager..." or "⚪ Manager",
                    TextColor3 = Color3.fromRGB(150, 150, 150)
                }
            end),
            
            -- Controls
            Rex("TextButton") {
                Text = "Load User 2",
                onClick = function() userId:set(2) end
            }
        }
    }
end
```

## Error Handling Patterns

### Retry Logic

Implement automatic retry for failed requests:

```lua
local function RetryExample()
    local maxRetries = 3
    local retryDelay = 1 -- seconds
    
    local unreliableData = Rex.useAsyncState(function()
        local function attemptFetch(attempt)
            print("Attempt", attempt, "of", maxRetries + 1)
            
            task.wait(1) -- Simulate network request
            
            -- Randomly fail 70% of the time
            if math.random() < 0.7 then
                error("Network error: Connection timeout")
            end
            
            return {
                data = "Success on attempt " .. tostring(attempt),
                timestamp = os.time()
            }
        end
        
        local lastError = nil
        
        for attempt = 1, maxRetries + 1 do
            local success, result = pcall(attemptFetch, attempt)
            
            if success then
                return result
            else
                lastError = result
                
                if attempt <= maxRetries then
                    print("Retrying in", retryDelay, "seconds...")
                    task.wait(retryDelay)
                end
            end
        end
        
        error("Failed after " .. tostring(maxRetries + 1) .. " attempts: " .. tostring(lastError))
    end, {})
    
    return Rex("Frame") {
        children = {
            unreliableData.loading:map(function(isLoading)
                return isLoading and Rex("TextLabel") {
                    Text = "Attempting to fetch data (with retries)...",
                    TextColor3 = Color3.fromRGB(200, 200, 100)
                } or nil
            end),
            
            unreliableData.error:map(function(error)
                return error and Rex("Frame") {
                    children = {
                        Rex("TextLabel") {
                            Text = "Failed: " .. tostring(error),
                            TextColor3 = Color3.fromRGB(255, 100, 100)
                        },
                        Rex("TextButton") {
                            Text = "Try Again",
                            onClick = function() unreliableData.reload() end,
                            BackgroundColor3 = Color3.fromRGB(255, 150, 50)
                        }
                    }
                } or nil
            end),
            
            unreliableData.data:map(function(data)
                return data and Rex("TextLabel") {
                    Text = "Success: " .. data.data,
                    TextColor3 = Color3.fromRGB(100, 255, 100)
                } or nil
            end)
        }
    }
end
```

## Best Practices

### 1. Handle All States

Always handle loading, error, and success states:

```lua
-- ✅ Good: Handle all states
asyncState.loading:map(function(isLoading)
    return isLoading and LoadingSpinner() or nil
end),

asyncState.error:map(function(error)
    return error and ErrorMessage { error = error } or nil
end),

asyncState.data:map(function(data)
    return data and DataDisplay { data = data } or nil
end)
```

### 2. Provide User Feedback

Keep users informed about what's happening:

```lua
-- ✅ Good: Informative loading states
asyncState.loading:map(function(isLoading)
    return isLoading and Rex("Frame") {
        children = {
            LoadingSpinner(),
            Rex("TextLabel") {
                Text = "Fetching your profile data..."
            }
        }
    } or nil
end)
```

### 3. Enable Recovery Actions

Always provide ways for users to recover from errors:

```lua
-- ✅ Good: Recovery options
asyncState.error:map(function(error)
    return error and Rex("Frame") {
        children = {
            Rex("TextLabel") {
                Text = "Failed to load data: " .. tostring(error)
            },
            Rex("TextButton") {
                Text = "Try Again",
                onClick = function() asyncState.reload() end
            },
            Rex("TextButton") {
                Text = "Go Back",
                onClick = function() navigateBack() end
            }
        }
    } or nil
end)
```

### 4. Optimize Dependencies

Be specific about what triggers re-fetching:

```lua
-- ✅ Good: Specific dependencies
local userData = Rex.useAsyncState(fetchUser, {userId})

-- ❌ Bad: Too many dependencies cause unnecessary refetches
local userData = Rex.useAsyncState(fetchUser, {userId, theme, language, unrelatedState})
```

### 5. Consider Caching

Implement caching for expensive or frequently accessed data:

```lua
-- ✅ Good: Cached async operations
local cachedUserData = Rex.useAsyncState(function()
    return cacheWrapper(userId:get(), fetchUserData)
end, {userId})
```

Async state management in Rex provides a robust foundation for handling all kinds of asynchronous operations while maintaining reactive UI updates and excellent user experience.
