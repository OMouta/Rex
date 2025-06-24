--!strict

local Types = require('./Types')
local Props = require('./Props')

type RexElement = Types.RexElement
type RexProps = Types.RexProps
type RexChildren = Types.RexChildren
type RexFragment = Types.RexFragment

local ElementBuilder = {}

-- Global registry for reactive bindings
local reactiveBindings: {[Instance]: {() -> ()}} = {}

-- Enhanced element creation with key support
function ElementBuilder.create(className: string, props: RexProps?): RexElement
	local element: RexElement = {
		className = className,
		props = props or {},
		children = nil,
		instance = nil,
		key = nil,
	}
	
	-- Extract key and children from props
	if props then
		element.key = props.key
		local children = props.children or props[Props.Children]
		if children then
			element.children = children
		end
	end
	
	return element
end

-- Create a Fragment (multiple elements without wrapper)
function ElementBuilder.createFragment(children: {RexElement}, key: string?): RexFragment
	return {
		__rexFragment = true,
		children = children,
		key = key,
	}
end

-- Key-based diffing algorithm
local function createKeyMap(elements: {RexElement}): {[string]: RexElement}
	local keyMap = {}
	for i, element in ipairs(elements) do
		local key = element.key or tostring(i)
		keyMap[key] = element
	end
	return keyMap
end

-- Efficient children reconciliation with keys
function ElementBuilder.reconcileChildren(
	parent: Instance,
	oldChildren: {RexElement}?,
	newChildren: {RexElement}?
): ()
	if not newChildren then
		-- Remove all children
		if oldChildren then
			for _, child in ipairs(oldChildren) do
				if child.instance then
					child.instance:Destroy()
				end
			end
		end
		return
	end
		if not oldChildren then
		-- Add all new children (filter out nil elements)
		for _, child in ipairs(newChildren) do
			if child then
				ElementBuilder.instantiate(child, parent)
			end
		end
		return
	end
	
	-- Create key maps for efficient lookup
	local oldKeyMap = createKeyMap(oldChildren)
	local newKeyMap = createKeyMap(newChildren)
	
	-- Track which elements are reused
	local reusedKeys: {[string]: boolean} = {}
		-- Phase 1: Update existing elements and mark reused
	for i, newChild in ipairs(newChildren) do
		-- Skip nil children
		if not newChild then
			continue
		end
		
		local key = newChild.key or tostring(i)
		local oldChild = oldKeyMap[key]
				if oldChild then
			-- Element exists, update it
			reusedKeys[key] = true
			if oldChild.instance and ElementBuilder.areCompatible(oldChild, newChild) then
				-- Compatible elements - update in place
				newChild.instance = oldChild.instance
				ElementBuilder.updateInstance(oldChild.instance, oldChild.props, newChild.props)
				
				-- Recursively update children
				if newChild.children and oldChild.children then
					local oldChildrenArray = ElementBuilder.normalizeChildrenToArray(oldChild.children)
					local newChildrenArray = ElementBuilder.normalizeChildrenToArray(newChild.children)
					ElementBuilder.reconcileChildren(oldChild.instance, oldChildrenArray, newChildrenArray)
				end
			else
				-- Incompatible elements - replace
				if oldChild.instance then
					oldChild.instance:Destroy()
				end
				ElementBuilder.instantiate(newChild, parent)
			end
		else
			-- New element - create it
			ElementBuilder.instantiate(newChild, parent)
		end
	end
	
	-- Phase 2: Remove elements that are no longer needed
	for key, oldChild in pairs(oldKeyMap) do
		if not reusedKeys[key] and oldChild.instance then
			oldChild.instance:Destroy()
		end
	end
	
	-- Phase 3: Reorder elements to match new order
	ElementBuilder.reorderChildren(parent, newChildren)
end

-- Reorder children to match the desired order
function ElementBuilder.reorderChildren(parent: Instance, children: {RexElement}): ()
	for i, child in ipairs(children) do
		if child.instance then
			-- Move to correct position (Roblox doesn't have direct ordering, so we rely on creation order)
			-- This is a limitation of Roblox - true ordering would require custom layout
			child.instance.Parent = parent
		end
	end
end

-- Normalize children to array format for diffing
function ElementBuilder.normalizeChildrenToArray(children: RexChildren): {RexElement}?
	if not children then
		return nil
	end
	
	if typeof(children) == "table" then
		-- Check if it's a fragment
		if (children :: any).__rexFragment then
			return (children :: RexFragment).children
		end
		
		-- Check if it's a single element
		if (children :: any).className then
			return {children :: RexElement}
		end
		
		-- Check if it's a reactive state object
		if ElementBuilder.isRexState(children) then
			-- For reactive state, we need to get the current value
			local currentValue = (children :: any):get()
			return ElementBuilder.normalizeChildrenToArray(currentValue)
		end
		
		-- Check if it's a reactive children object
		if ElementBuilder.isReactiveChildren(children) then
			local currentValue = (children :: any).get()
			return ElementBuilder.normalizeChildrenToArray(currentValue)
		end
		
		-- It's an array - check each element and expand reactive ones
		local normalizedArray = {}
		for _, child in ipairs(children :: {any}) do
			if child then
				if ElementBuilder.isRexState(child) or ElementBuilder.isReactiveChildren(child) then
					-- This is a reactive child in a mixed array - we can't handle this statically
					-- Return nil to indicate this needs special reactive handling
					return nil
				elseif typeof(child) == "table" and (child :: any).className then
					-- Regular RexElement
					table.insert(normalizedArray, child)
				end
			end
		end
		
		return normalizedArray
	end
	
	return nil
end

-- Enhanced instantiation with fragment support
function ElementBuilder.instantiate(element: RexElement | RexFragment, parent: Instance?): Instance?
	-- Handle nil elements
	if not element then
		warn("Rex.ElementBuilder: Attempted to instantiate nil element. This usually happens when a component returns nil or when accessing undefined variables.\n" ..
			"📖 Learn more: https://rex.tigas.dev/docs/0.1.0/core_concepts/components\n" ..
			"💡 Tip: Check that your component functions return valid RexElement objects, and that all variables are properly defined.")
		return nil
	end
	
	-- Handle fragments
	if typeof(element) == "table" and (element :: any).__rexFragment then
		local fragment = element :: RexFragment
		for _, child in ipairs(fragment.children) do
			ElementBuilder.instantiate(child, parent)
		end
		return nil -- Fragments don't have instances
	end
	
	local rexElement = element :: RexElement
		-- Validate className
	if not rexElement.className or rexElement.className == "" then
		warn(`Rex.ElementBuilder: Invalid className: "{rexElement.className}". Elements must have a valid Roblox class name.\n` ..
			"📖 Learn more: https://rex.tigas.dev/docs/0.1.0/core_concepts/components#element-creation\n" ..
			"💡 Tip: Use valid Roblox Instance class names like 'Frame', 'TextLabel', 'TextButton', etc.\n" ..
			"💡 Example: Rex('Frame') { ... } instead of Rex('') { ... }")
		return nil
	end
	
	-- Create the instance
	local success, instance = pcall(function()
		return Instance.new(rexElement.className)
	end)
		if not success then
		error(`Rex.ElementBuilder: Failed to create instance of class "{rexElement.className}". This class name is not a valid Roblox Instance type.\n` ..
			"📖 Learn more: https://rex.tigas.dev/docs/0.1.0/core_concepts/components#element-creation\n" ..
			`💡 Error details: {instance}\n` ..
			"💡 Tip: Check the Roblox documentation for valid Instance class names, or verify the spelling and capitalization.\n" ..
			"💡 Common classes: Frame, TextLabel, TextButton, ImageLabel, ScrollingFrame, UIListLayout, etc.")
	end
	
	-- Apply properties
	ElementBuilder.applyProps(instance, rexElement.props)
		-- Handle children with enhanced diffing
	local children = rexElement.children or rexElement.props.children or rexElement.props[Props.Children]
	if children then
		-- Check if children need reactive handling
		if ElementBuilder.isReactiveChildren(children) then
			ElementBuilder.setupReactiveChildren(instance, children)
		elseif ElementBuilder.isRexState(children) then
			ElementBuilder.setupReactiveStateChildren(instance, children)
		elseif typeof(children) == "table" and ElementBuilder.hasMixedReactiveChildren(children) then
			-- Handle mixed static + reactive children
			ElementBuilder.setupMixedReactiveChildren(instance, children)
		else
			-- Handle static children with diffing
			local childrenArray = ElementBuilder.normalizeChildrenToArray(children)
			if childrenArray then
				ElementBuilder.reconcileChildren(instance, nil, childrenArray)
			end
		end
	end
	
	-- Set parent
	if parent then
		instance.Parent = parent
	end
	
	-- Store reference
	rexElement.instance = instance
	
	return instance
end

-- Enhanced property application with better event handling
function ElementBuilder.applyProps(instance: Instance, props: RexProps): ()
	for key, value in pairs(props) do
		if Props.isSpecialProp(key) then
			-- Handle special Rex properties
			if key == Props.Children then
				continue
			elseif key == Props.Ref then
				if typeof(value) == "table" then
					value.current = instance
				end
			end		elseif key == "children" or key == "key" then
			-- Skip children and key - handled separately
			continue		elseif Props.isEventProp(key) then
			-- Handle unified event props
			Props.setupEventHandler(instance, key, value)
		elseif Props.isPropHelper(value) then
			-- Apply prop helper
			value.apply(instance)
		elseif typeof(key) == "string" then
			-- Check if value is reactive
			if ElementBuilder.isRexState(value) then
				-- Set initial value
				Props.setProperty(instance, key, value:get())
				-- Set up reactive binding
				ElementBuilder.setupReactiveBinding(instance, key, value)
			else
				-- Standard property
				Props.setProperty(instance, key, value)
			end
		end
	end
end

function ElementBuilder.areCompatible(oldElement: RexElement, newElement: RexElement): boolean
	return oldElement.className == newElement.className and oldElement.key == newElement.key
end

function ElementBuilder.updateInstance(instance: Instance, oldProps: RexProps, newProps: RexProps): ()
	-- Clean up old reactive bindings
	ElementBuilder.cleanupReactiveBindings(instance)
	-- Apply new props
	ElementBuilder.applyProps(instance, newProps)
end

-- Check if an array has mixed static and reactive children
function ElementBuilder.hasMixedReactiveChildren(children: any): boolean
	if typeof(children) ~= "table" then
		return false
	end
	
	local hasStatic = false
	local hasReactive = false
	
	for _, child in ipairs(children :: {any}) do
		if child then
			if ElementBuilder.isRexState(child) or ElementBuilder.isReactiveChildren(child) then
				hasReactive = true
			elseif typeof(child) == "table" and (child :: any).className then
				hasStatic = true
			end
		end
	end
	
	return hasStatic and hasReactive
end

-- Setup mixed reactive children (static + reactive elements in same array)
function ElementBuilder.setupMixedReactiveChildren(instance: Instance, mixedChildren: any): ()
	if not reactiveBindings[instance] then
		reactiveBindings[instance] = {}
	end
	
	local currentChildren: {RexElement} = {}
	
	local function updateChildren()
		local expandedChildren = {}
		
		-- Process each child in the mixed array
		for _, child in ipairs(mixedChildren :: {any}) do
			if child then
				if ElementBuilder.isRexState(child) or ElementBuilder.isReactiveChildren(child) then
					-- Reactive child - get current value and expand
					local reactiveValue = if ElementBuilder.isRexState(child) then child:get() else child.get()
					local normalized = ElementBuilder.normalizeChildrenToArray(reactiveValue)
					if normalized then
						for _, expandedChild in ipairs(normalized) do
							table.insert(expandedChildren, expandedChild)
						end
					end
				elseif typeof(child) == "table" and (child :: any).className then
					-- Static child - add directly
					table.insert(expandedChildren, child)
				end
			end
		end
		
		-- Use enhanced reconciliation
		ElementBuilder.reconcileChildren(instance, currentChildren, expandedChildren)
		currentChildren = expandedChildren
	end
	
	-- Initial render
	updateChildren()
	
	-- Set up reactive updates for reactive children only
	for _, child in ipairs(mixedChildren :: {any}) do
		if child and (ElementBuilder.isRexState(child) or ElementBuilder.isReactiveChildren(child)) then
			local disconnect = if ElementBuilder.isRexState(child) 
				then child:onChange(updateChildren)
				else child.onChange(updateChildren)
			table.insert(reactiveBindings[instance], disconnect)
		end
	end
end

-- Keep existing reactive functionality
function ElementBuilder.isRexState(value: any): boolean
	return typeof(value) == "table" 
		and typeof(value.get) == "function"
		and typeof(value.set) == "function"
		and typeof(value.onChange) == "function"
end

function ElementBuilder.isReactiveChildren(value: any): boolean
	return typeof(value) == "table" 
		and value.__rexReactiveChildren == true
		and typeof(value.get) == "function"
		and typeof(value.onChange) == "function"
end

function ElementBuilder.setupReactiveBinding(instance: Instance, propertyName: string, state: any): ()
	if not reactiveBindings[instance] then
		reactiveBindings[instance] = {}
	end
	
	local disconnect = state:onChange(function(newValue: any)
		Props.setProperty(instance, propertyName, newValue)
	end)
	
	table.insert(reactiveBindings[instance], disconnect)
	
	-- Clean up when instance is destroyed
	local connection
	connection = instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			ElementBuilder.cleanupReactiveBindings(instance)
			connection:Disconnect()
		end
	end)
end

function ElementBuilder.setupReactiveChildren(instance: Instance, reactiveChildren: any): ()
	if not reactiveBindings[instance] then
		reactiveBindings[instance] = {}
	end
	
	local currentChildren: {RexElement} = {}
	
	local function updateChildren()
		local newChildrenData = reactiveChildren.get()
		local newChildren = ElementBuilder.normalizeChildrenToArray(newChildrenData)
		
		-- Use enhanced reconciliation
		ElementBuilder.reconcileChildren(instance, currentChildren, newChildren)
		currentChildren = newChildren or {}
	end
	
	-- Initial render
	updateChildren()
	
	-- Set up reactive updates
	local disconnect = reactiveChildren.onChange(updateChildren)
	table.insert(reactiveBindings[instance], disconnect)
end

function ElementBuilder.setupReactiveStateChildren(instance: Instance, childrenState: any): ()
	if not reactiveBindings[instance] then
		reactiveBindings[instance] = {}
	end
	
	local currentChildren: {RexElement} = {}
	
	local function updateChildren()
		local newChildrenData = childrenState:get()
		local newChildren = ElementBuilder.normalizeChildrenToArray(newChildrenData)
		
		-- Use enhanced reconciliation
		ElementBuilder.reconcileChildren(instance, currentChildren, newChildren)
		currentChildren = newChildren or {}
	end
	
	-- Initial render
	updateChildren()
	
	-- Set up reactive updates
	local disconnect = childrenState:onChange(updateChildren)
	table.insert(reactiveBindings[instance], disconnect)
end

function ElementBuilder.cleanupReactiveBindings(instance: Instance): ()
	local disconnects = reactiveBindings[instance]
	if disconnects then
		for _, disconnect in ipairs(disconnects) do
			disconnect()
		end
		reactiveBindings[instance] = nil
	end
end

return ElementBuilder
