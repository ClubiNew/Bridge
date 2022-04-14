--[=[
    @class Remote
    Remotes allow you to send signals from the server to the client. They can be created using `Bridge.newRemote()`.
    :::caution
    Remotes can **only** be created server-side in the `.Bridge` of a [service](/api/BridgeServer#Service).
    :::
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Bridge = require(ReplicatedStorage.Bridge)

    local SomeService = Bridge.newService(script.Name)
    SomeService.Bridge.SomeRemote = Bridge.newRemote()

    return SomeService
    ```
]=]
local Remote = {}
Remote.__index = Remote

--[=[
    @prop RemoteEvent RemoteEvent
    @within Remote
    @readonly
    @private
]=]

--[=[
    @prop BindableEvent BindableEvent
    @within Remote
    @readonly
    @private
]=]

--[=[
    @function new
    @within Remote
    @private
    @server
    @return Remote
]=]
function Remote.new()
    local self = setmetatable({}, Remote)
    self.RemoteEvent = Instance.new("RemoteEvent")
    self.BindableEvent = Instance.new("BindableEvent")
    return self
end

--[=[
    @function Is
    @within Remote
    @param remote table
    @return boolean
    @private
    Returns `true` if the passed table is a Remote.
]=]
function Remote.Is(remote)
    return type(remote) == "table" and getmetatable(remote) == Remote
end

--[=[
    @method FireClient
    @within Remote
    @param Player Player
    @param ... any
    @server
    Fire the remote for the given player and any server scripts connected to the remote with the given arguments.
]=]
function Remote:FireClient(Player: Player, ...)
    assert(Player and typeof(Player) == "Instance", "[BRIDGE] Expected first argument to be a player, got " .. typeof(Player) .. ".")
    assert(Player:IsA("Player"), "[BRIDGE] Expected first argument to be a player, got " .. Player.ClassName .. ".")
    self.RemoteEvent:FireClient(Player, ...)
    self.BindableEvent:Fire(Player, ...)
end

--[=[
    @method FireAllClients
    @within Remote
    @param ... any
    @server
    Fire the remote for all players and any server scripts connected to the remote with the given arguments.
]=]
function Remote:FireAllClients(...)
    self.RemoteEvent:FireAllClients(...)
    self.BindableEvent:Fire(...)
end

--[=[
    @method Connect
    @within Remote
    @param f function
    @return RBXScriptConnection
    Connect the remote to the provided function.
    :::note
    Both [services](/api/BridgeServer#Service) and [controllers](/api/BridgeClient#Controller) can connect to remotes! If the remote is fired for a specific client, that client will be passed as the first argument to any connected services.
    :::
]=]
function Remote:Connect(f)
    return self.BindableEvent.Event:Connect(f)
end

--[=[
    @method Wait
    @within Remote
    @return any
    Waits for the remote to be fired and returns the arguments it was fired with.
    :::note
    Both [services](/api/BridgeServer#Service) and [controllers](/api/BridgeClient#Controller) can wait on remotes! If the remote is fired for a specific client, that client will be passed as the first argument to any connected services.
    :::
]=]
function Remote:Wait()
    return self.BindableEvent.Event:Wait()
end

return Remote