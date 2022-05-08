--[=[
    @class HookManager
    The hook manager allows you to create new [hooks](/api/HookManager#Hook).
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Bridge = require(ReplicatedStorage.Packages.Bridge)

    local PartHook = {}

    function PartHook:Attach()
        print(self.Instance, "got added!")

        local debounce = false
        self.Janitor:Add(self.Instance.Touched:Connect(function()
            if not debounce then
                debounce = true
                self.Instance.BrickColor = BrickColor.Random()
                task.wait(0.1)
                debounce = false
            end
        end))

        self.Janitor:Add(function()
            print(self.Instance, "got removed!")
        end)
    end

    Bridge.Hooks.add("PartHook", PartHook)
    ```
]=]
local HookManager = {}

local Janitor = require(script.Parent:WaitForChild("Utilities")).Janitor

local CollectionService = game:GetService("CollectionService")

--[=[
    @interface Hook
    @within HookManager
    .Attach (Hook) -> ()
    .Janitor Janitor
    .Instance Instance
    .... any
    Hooks are used to bind to [CollectionService](https://developer.roblox.com/en-us/api-reference/class/CollectionService) tags. When the tag specified in [`HookManager.add()`](/api/HookManager#add) is added to an instance, a new copy of the Hook is created, the `Instance` and [`Janitor`](https://howmanysmall.github.io/Janitor/api/Janitor) properties are set, and the `Attach` method is called. When the instance is removed, the [`Janitor`](https://howmanysmall.github.io/Janitor/api/Janitor)'s clean-up method will be called.

    See the [Janitor docs](https://howmanysmall.github.io/Janitor/api/Janitor) for more information on using Janitors.
]=]
type Hook = {
    Attach: (Instance, {}) -> ()
}

--[=[
    @function add
    @within HookManager
    @param collectionTag string
    @param hook Hook
    Adds a new hook for the provided class and [CollectionService](https://developer.roblox.com/en-us/api-reference/class/CollectionService) tag.
    :::note
    It is recommended that you use `script.Name` as your collection tag.
    :::
]=]
function HookManager.add(collectionTag: string, hook: Hook)
    assert(typeof(hook) == "table", "[BRIDGE] Expected hook class to be a table!")
    assert(hook.Attach, "[BRIDGE] The hook class is missing an attach method!")

    hook.__index = hook
    local janitors = {}

    local function createHook(instance)
        local janitor = Janitor.new()
        janitors[instance] = janitor

        local newHook = setmetatable({
            Instance = instance;
            Janitor = janitor;
        }, hook)

        newHook:Attach(newHook)
    end

    CollectionService:GetInstanceRemovedSignal(collectionTag):Connect(function(instance)
        janitors[instance]:Cleanup()
    end)

    CollectionService:GetInstanceAddedSignal(collectionTag):Connect(function(instance)
        createHook(instance)
    end)

    for _, instance in pairs(CollectionService:GetTagged(collectionTag)) do
        createHook(instance)
    end
end

table.freeze(HookManager)
return HookManager
