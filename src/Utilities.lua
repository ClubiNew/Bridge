--[=[
    @class Utilities
    Utilities contains 3rd-party packages required by Bridge. You can also use them from here, or import them yourself.
]=]
local Utilities = {}

--[=[
    @prop Signal Signal
    @within Utilities
    See the Signal documentation [here](https://sleitnick.github.io/RbxUtil/api/Signal/).
]=]
Utilities.Signal = require(script.Parent.Parent:WaitForChild("Signal"))

--[=[
    @prop Janitor Janitor
    @within Utilities
    See the Janitor documentation [here](https://howmanysmall.github.io/Janitor/).
]=]
Utilities.Janitor = require(script.Parent.Parent:WaitForChild("Janitor"))

table.freeze(Utilities)
return Utilities
