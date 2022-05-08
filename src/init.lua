--[=[
    @class Bridge
    Core module, used to access managers.
]=]
local Bridge = {}

--[=[
    @prop Middleware MiddlewareManager
    @within Bridge
    @readonly
]=]
Bridge.Middleware = require(script:WaitForChild("MiddlewareManager"))

--[=[
    @prop Services ServiceManager
    @within Bridge
    @readonly
]=]
Bridge.Services = require(script:WaitForChild("ServiceManager"))

--[=[
    @prop Hooks HookManager
    @within Bridge
    @readonly
]=]
Bridge.Hooks = require(script:WaitForChild("HookManager"))

--[=[
    @prop Utilities Utilities
    @within Bridge
    @readonly
]=]
Bridge.Utilities = require(script:WaitForChild("Utilities"))

table.freeze(Bridge)
return Bridge
