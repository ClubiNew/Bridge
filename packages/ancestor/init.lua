--[=[
    @class Ancestor
    `Ancestor = "minstrix/ancestor@^0.1"`

    Wraps instances to allow for easy handling of `nil` children, properties, or methods.

    ```lua
    -- without Ancestor
    local character = player.Character
    local humanoid = character and character.Humanoid
    local health = humanoid and humanoid.Health or 0

    -- with Ancestor
    local health = Ancestor(Player).Character.Humanoid.Health:Or(0)
    ```
]=]

local Option = require(script.Parent.Option)

local Ancestor = {}

--[=[
    @return Ancestor

    Wraps the object in an Ancestor class. You can then index children and properties or call methods on the object or it's children that may be `nil` without throwing errors.
]=]
function Ancestor.new(object: any)
    return setmetatable({
        __object = Option.Wrap(object),
    }, Ancestor)
end

function Ancestor:__index(index)
    if Ancestor[index] then
        return Ancestor[index]
    end

    local success, object = pcall(function()
        return self.__object:Unwrap()[index]
    end)

    if success and type(object) == "function" then
        rawset(self, "__method", index)
        return self
    else
        return Ancestor.new(if success then object else nil)
    end
end

function Ancestor:__call(...)
    if not rawget(self, "__method") then
        return Ancestor.new(nil)
    end

    local success, result = pcall(function(_, ...)
        local unwrapped = self.__object:Unwrap()
        return unwrapped[self.__method](unwrapped, ...)
    end, ...)

    return Ancestor.new(if success then result else nil)
end

--[=[
    Unwraps and returns the object, or the provided default if the object is `nil`.
]=]
function Ancestor:Or(default: any): any
    return self.__object:UnwrapOr(default)
end

--[=[
    @return Ancestor
    Calls the provided function if the unwrapped object is `nil` and returns the wrapper for chain calls.
]=]
function Ancestor:IfNil(func: () -> ())
    self.__object:UnwrapOrElse(func)
    return self
end

--[=[
    @return Ancestor
    Calls the provided function with the unwrapped object if it is not `nil` and returns the wrapper for chain calls.
]=]
function Ancestor:IfNotNil(func: (any) -> ())
    if self.__object:IsSome() then
        func(self.__object:Unwrap())
    end

    return self
end

return Ancestor.new
