--[=[
    @class Hooks
    `Hooks = "minstrix/hooks@^0.1"`

    Hooks allows you to easily attach behavior to [CollectionService](https://developer.roblox.com/en-us/api-reference/class/CollectionService) tags. See the [Hook] interface for more information.

    ```lua
    local PartyBrickHook = {}

    function PartyBrickHook:Attach()
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

    Hooks.add("PartyBrick", PartyBrickHook)
    ```
]=]

local Janitor = require(script.Parent.Janitor)
local CollectionService = game:GetService("CollectionService")

local Hooks = {}

--[=[
    @interface Hook
    @within Hooks
    .Attach (Hook) -> ()
    .Janitor Janitor
    .Instance Instance
    .... any

    Hooks are used to bind to [CollectionService](https://developer.roblox.com/en-us/api-reference/class/CollectionService) tags. When the tag specified in [Hooks.add] is added to an instance, a new copy of the Hook is created, the `Instance` and [`Janitor`](https://howmanysmall.github.io/Janitor/api/Janitor) properties are set, and the `Attach` method is called. When the instance is removed, the [Janitor](https://howmanysmall.github.io/Janitor/api/Janitor)'s clean-up method will be called.

    See the [Janitor docs](https://howmanysmall.github.io/Janitor/api/Janitor) for more information on using Janitors.
]=]
type Hook = table

--[=[
    Attaches the provided hook to the given [CollectionService](https://developer.roblox.com/en-us/api-reference/class/CollectionService) tag.

    :::tip
    It's recommended to use `script.Name` as your collection tag.
    :::
]=]
function Hooks.add(collectionTag: string, hook: Hook)
    assert(typeof(hook) == "table", "Expected the hook to be a table!")
    assert(hook.Attach, "The hook for " .. collectionTag .. " is missing an attach method!")

    hook.__index = hook
    local janitors = {}

    local function createHook(instance)
        local janitor = Janitor.new()
        janitors[instance] = janitor

        local newHook = setmetatable({
            Instance = instance,
            Janitor = janitor,
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

table.freeze(Hooks)
return Hooks
