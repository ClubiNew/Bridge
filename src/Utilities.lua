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
Utilities.Signal = require(script.Parent.Parent.Parent:WaitForChild("sleitnick_signal@1.2.0"):WaitForChild("signal"))

--[=[
    @prop Janitor Janitor
    @within Utilities
    See the Janitor documentation [here](https://howmanysmall.github.io/Janitor/).
]=]
Utilities.Janitor = require(script.Parent.Parent.Parent:WaitForChild("howmanysmall_janitor@1.14.1"):WaitForChild("janitor"))

table.freeze(Utilities)
return Utilities
