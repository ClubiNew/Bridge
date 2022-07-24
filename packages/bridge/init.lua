--[=[
    @class Bridge
    `Bridge = "minstrix/bridge@^0.3"`

    Bridge is used to simplify client-server communication.

    Server scripts [define](#blueprint) and [construct](#construct) "bridges" that clients can then [request](#to) and listen to events or call functions on. Additionally, [processors](#Processor) can be added to a [Bridge] to add pre or post processing to requests.

    ```lua
    -- In a server script:

    local function doubleArgs(...)
        local args = table.pack(...)

        for index, arg in args do
            if typeof(arg) == "number" then
                args[index] = arg * 2
            end
        end

        return table.unpack(args)
    end

    local BadMathBridge = Bridge.blueprint({
        name = "BadMath",
        events = {"SomeEvent"},
        inboundProcessors = {doubleArgs},
        outboundProcessors = {doubleArgs},
    })

    function BadMathBridge:Add(player, x, y)
        self.Events.SomeEvent:FireAllClients("Add called!")
        return x + y
    end

    Bridge.construct(BadMathBridge)

    -- In a local script:

    local BadMathBridge = Bridge.to("BadMath")

    BadMathBridge.Events.SomeEvent.OnClientEvent:Connect(function(msg)
        print(msg) --> Add called!
    end)

    print(BadMathBridge:Add(1, 2)) --> 12
    ```
]=]

local RunService = game:GetService("RunService")

local Bridge = {}
local bridges: {
    [string]: {
        bridge: Bridge,
        inboundProcessors: { Processor },
        outboundProcessors: { Processor },
    },
} =
    {}

--[=[
    @interface Bridge
    @within Bridge
    .Events {string: RemoteEvent}
    .... (Bridge, any) -> (any)

    A bridge is used to allow for communication between the client and server. The `Events` array is created by [Bridge.blueprint] and is available to both the server and clients. Similarly, when [Bridge.construct] is called for a bridge, it will internally create a [RemoteFunction](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction) for any methods on that bridge. The client can then [Bridge.to] that bridge and call the methods on it using the internal [RemoteFunctions](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction).

    :::note
    The intention is that `Events` are fired by the server, but the server can also listen for events being fired by clients if a response is not necessary, but no inbound/outbound processing will take place.
    :::
]=]
type Bridge = {
    Events: { [string]: RemoteEvent },
    [any]: (Bridge, any) -> (any),
}

--[=[
    @interface Blueprint
    @within Bridge
    .name string
    .events {string}
    .inboundProcessors {Processor}
    .outboundProcessors {Processor}

    A blueprint is used to define a [Bridge] when calling [Bridge.blueprint]. Read the [Processor] interface for more information on the inbound/outbound processor arrays.

    :::tip
    It's recommended to use `script.Name` as the name.
    :::
]=]
type Blueprint = {
    name: string,
    events: { string },
    inboundProcessors: { (any) -> (any) },
    outboundProcessors: { (any) -> (any) },
}

--[=[
    @type Processor (any) -> (any)
    @within Bridge

    A processor is a function that is called either before or after a [Bridge] method is called by the client, with the arguments passed to or returned by the method or previous processor. Processors can either return a tuple of arguments to be used by the method and/or following processor(s), or throw an error to halt the request.

    :::tip
    Processors will be called in the order they appear in the inbound/outbound arrays of the [Blueprint] that is used to define the [Bridge]. Be mindful that processors return the arguments expected by the next processor(s) in the array.
    :::

    :::caution
    Processors are not used for connections to a [RemoteEvent] in the `Events` array of the [Bridge].
    :::
]=]
type Processor = (any) -> (any)

--[=[
    @server
]=]
function Bridge.blueprint(blueprint: Blueprint): Bridge
    assert(RunService:IsServer(), "Bridges can only be created by the server!")
    assert(not bridges[blueprint.name], "Cannot have two bridges with the same name!")
    local newBridge: Bridge = { Events = {} }

    if blueprint.events then
        for _, eventName in blueprint.events do
            assert(not newBridge.Events[eventName], "Cannot have two events with the same name!")
            local RemoteEvent = Instance.new("RemoteEvent")
            newBridge.Events[eventName] = RemoteEvent
        end
    end

    bridges[blueprint.name] = {
        bridge = newBridge,
        inboundProcessors = blueprint.inboundProcessors or {},
        outboundProcessors = blueprint.outboundProcessors or {},
    }

    return newBridge
end

--[=[
    @server
    :::caution
    Once a [Bridge] has been constructed, you can no longer add new methods to it.
    :::
]=]
function Bridge.construct(bridge: Bridge)
    assert(RunService:IsServer(), "Bridges can only be added by the server!")
    local bridgeName, bridgeInfo

    for name, info in bridges do
        if info.bridge == bridge then
            bridgeName = name
            bridgeInfo = info
            break
        end
    end

    assert(bridgeName and bridgeInfo, "Bridges must be created with Bridge.blueprint()!")
    assert(not script:FindFirstChild(bridgeName), "Cannot add a bridge more than once!")

    local folder = Instance.new("Folder")
    folder.Name = bridgeName

    local eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "Events"

    for remoteName, remoteEvent in pairs(bridge.Events) do
        remoteEvent.Name = remoteName
        remoteEvent.Parent = eventsFolder
    end

    local functionsFolder = Instance.new("Folder")
    functionsFolder.Name = "Functions"

    for funcName, func in pairs(bridges) do
        if typeof(func) == "function" then
            local remoteFunction = Instance.new("RemoteFunction")
            remoteFunction.Name = funcName

            -- Create processing sequence
            local processors = {}

            for _, processor in ipairs(bridgeInfo.inboundProcessors) do
                table.insert(processors, processor)
            end

            table.insert(processors, func)

            for _, processor in ipairs(bridgeInfo.outboundProcessors) do
                table.insert(processors, processor)
            end

            -- Process invocations
            remoteFunction.OnServerInvoke = function(...)
                local args = table.pack(...)

                for _, processor in ipairs(processors) do
                    if processor == func then
                        args = table.pack(func(bridge, table.unpack(args)))
                    else
                        args = table.pack(processor(table.unpack(args)))
                    end
                end

                return table.unpack(args)
            end

            remoteFunction.Parent = functionsFolder
        end
    end

    eventsFolder.Parent = folder
    functionsFolder.Parent = folder
    folder.Parent = script
end

--[=[
    @client
    @yields
    :::tip
    This method will yield until the requested [Bridge] is [constructed](#construct). After every 30 seconds of yielding, a warning will be printed to notify you if something isn't constructing correctly.
    :::
]=]
function Bridge.to(bridgeName: string)
    assert(not RunService:IsServer(), "Bridges can only be requested by the client!")
    local bridgeFolder = script:FindFirstChild(bridgeName)

    if not bridgeFolder then
        task.spawn(function()
            local totalTime = 0
            while task.wait(30) do
                if bridgeFolder then
                    break
                else
                    totalTime += 30
                    warn("Bridge '", bridgeName, "' has been yielding for", totalTime, "seconds!")
                end
            end
        end)

        while not bridgeFolder do
            script.ChildAdded:Wait()
            bridgeFolder = script:FindFirstChild(bridgeFolder)
        end
    end

    local interface = { Events = {} }

    for _, remoteEvent in pairs(bridgeFolder:WaitForChild("Events"):GetChildren()) do
        interface.Events[remoteEvent.Name] = remoteEvent
    end

    for _, remoteFunction in pairs(bridgeFolder:WaitForChild("Functions"):GetChildren()) do
        interface[remoteFunction.Name] = function(_, ...)
            return remoteFunction:InvokeServer(...)
        end
    end

    return interface
end

table.freeze(Bridge)
return Bridge
