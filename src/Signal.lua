--[=[
    @class Signal
    Signals allow you to send events in-between controllers or signals, but not from services to controllers or vice-versa. They can be created using `Bridge.newSignal()`, for example:
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Bridge = require(ReplicatedStorage.Bridge)

    local SomeController = Bridge.newController(script.Name)
    SomeController.SomeSignal = Bridge.newSignal()

    return SomeController
    ```
]=]
local Signal = {}
Signal.__index = Signal

--[=[
    @prop BindableEvent BindableEvent
    @within Signal
    @readonly
    @private
]=]

--[=[
    @function new
    @within Signal
    @private
    @return Signal
]=]
function Signal.new()
    local self = setmetatable({}, Signal)
    self.BindableEvent = Instance.new("BindableEvent")
    return self
end

--[=[
    @function Is
    @within Signal
    @param signal table
    @return boolean
    @private
    Returns `true` if the passed table is a Signal.
]=]
function Signal.Is(signal)
    return type(signal) == "table" and getmetatable(signal) == Signal
end

--[=[
    @method Fire
    @within Signal
    @param ... any
    Fires the signal with the given arguments.
]=]
function Signal:Fire(...)
    self.BindableEvent:Fire(...)
end

--[=[
    @method Connect
    @within Signal
    @param f function
    @return RBXScriptConnection
    Connect the signal to the provided function.
]=]
function Signal:Connect(f)
    return self.BindableEvent.Event:Connect(f)
end

--[=[
    @method Wait
    @within Signal
    @return any
    Waits for the signal to be fired and returns the arguments it was fired with.
]=]
function Signal:Wait()
    return self.BindableEvent.Event:Wait()
end

--[=[
    @method Destroy
    @within Signal
    Destroys the Signal. The Signal cannot be used after this is called.
]=]
function Signal:Destroy()
    self.BindableEvent:Destroy()
end

return Signal