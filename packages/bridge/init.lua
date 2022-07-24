--[=[
    @class Bridge
    `Bridge = "minstrix/bridge@^0.3"`

    Bridge is used to simplify client-server communication.

    Server scripts [define](#blueprint) and [construct](#construct) "bridges" that clients can then [request](#to) and listen to events or call functions on. Additionally, [processors](#Processor) can be added to a [Bridge] to add pre or post processing to requests.

    ```lua
    -- In a server script:

    local function printArgs(...)
        print(...)
        return ...
    end

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
        inboundProcessors = {printArgs}, --> player, 1, 2
    })

    BadMathBridge.addMethod("Add", function(player, x, y)
        BadMathBridge.Events.SomeEvent:FireAllClients("Add called!")
        return x + y
    end).withInboundProcessors({doubleArgs}).withOutboundProcessors({doubleArgs})

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
        constructed: boolean,
        bridge: Bridge,

        events: { [string]: RemoteEvent },
        methods: {
            [string]: {
                func: (any) -> (any),
                inboundProcessors: { Processor },
                outboundProcessors: { Processor },
            },
        },

        inboundProcessors: { Processor },
        outboundProcessors: { Processor },
    },
} =
    {}

--[=[
    @interface Bridge
    @within Bridge
    .Events {string: RemoteEvent}
    .addMethod (string, (any) -> (any)) -> MethodConstructor

    A bridge is used to allow for communication between the client and server. Bridges are made using [Bridge.blueprint] which will automatically create the `Events` array based on the given [Blueprint]. You can then add methods to the Bridge using the `addMethod` function and once all methods have been added, you can [construct](#construct) the Bridge. Clients will then be able to [request](#to) the bridge and call the methods or listen to the events on it.

    :::note
    The intention is that `Events` are fired by the server, but the server can also listen for events being fired by clients if a response is not necessary.
    :::

    :::tip
    Once the Bridge is [constructed](#construct), all of the methods added with `addMethod` will be added to the Bridge's table. This means that methods can call each other, just be aware that there will be no inbound/outbound processing between methods.
    :::
]=]
type Bridge = {
    Events: { [string]: RemoteEvent },
    [any]: (Bridge, any) -> (any),
}

--[=[
    @type Processor (any) -> (any)
    @within Bridge

    A processor is a function that is called either before or after a [Bridge] method is called by the client, with the arguments passed to or returned by the method or previous processor. Processors can either return a tuple of arguments to be used by the method and/or following processor(s), or throw an error to halt the request.

    You can add processors to a [Bridge] in the [Blueprint], or add them to specific methods on a [Bridge] using a [MethodConstructor].

    :::tip
    Processors will be called in the order they appear in the inbound/outbound arrays. Be mindful that processors return the arguments expected by the next processor(s) in the array.
    :::

    :::caution
    Processors are not used for connections to a [RemoteEvent] in the `Events` array of the [Bridge].
    :::
]=]
type Processor = (any) -> (any)

--[=[
    @interface Blueprint
    @within Bridge
    .name string
    .events {string}
    .inboundProcessors {Processor}
    .outboundProcessors {Processor}

    A blueprint is used to define a [Bridge] when calling the [blueprint] method. Read the [Processor] interface for more information on the inbound/outbound processor arrays.

    :::tip
    It's recommended to use `script.Name` as the name.
    :::

    :::caution
    [Blueprint] inbound processors will always run before inbound processors added to a [MethodConstructor], and [Blueprint] outbound processors will always run after outbound processors added to a [MethodConstructor].
    :::
]=]
type Blueprint = {
    name: string,
    events: { string },
    inboundProcessors: { (any) -> (any) },
    outboundProcessors: { (any) -> (any) },
}

--[=[
    @interface MethodConstructor
    @within Bridge
    .withInboundProcessors ({Processor}) -> MethodConstructor
    .withOutboundProcessors ({Processor}) -> MethodConstructor

    A method constructor is returned when `addMethod` is called on an un-constructed [Bridge]. You can then use the `withInboundProcessors` and `withOutboundProcessors` functions to add [processors](#Processor) to that method without adding them to the whole [Bridge]. Read the [Processor] interface for more information.

    :::caution
    Method-specific processors will always run *after* the [Blueprint] inbound processors and *before* the outbound [Blueprint] processors.
    :::
]=]
type MethodConstructor = {
    withInboundProcessors: ({ Processor }) -> MethodConstructor,
    withOutboundProcessors: ({ Processor }) -> MethodConstructor,
}

local function addProcessors(processors, newProcessors)
    for _, processor in ipairs(newProcessors) do
        table.insert(processors, processor)
    end
end

--[=[
    @server
]=]
function Bridge.blueprint(blueprint: Blueprint): Bridge
    assert(RunService:IsServer(), "Bridges can only be created by the server!")
    assert(not bridges[blueprint.name], "Cannot have two bridges with the same name!")
    local bridge: Bridge = { Events = {} }

    if blueprint.events then
        for _, eventName in blueprint.events do
            assert(not bridge.Events[eventName], "Cannot have two events with the same name!")
            bridge.Events[eventName] = Instance.new("RemoteEvent")
        end
    end

    table.freeze(bridge.Events)

    bridges[blueprint.name] = {
        constructed = false,
        bridge = bridge,

        events = bridge.Events,
        methods = {},

        inboundProcessors = blueprint.inboundProcessors or {},
        outboundProcessors = blueprint.outboundProcessors or {},
    }

    bridge.addMethod = function(name, func)
        assert(not bridges[blueprint.name].methods[name], "Cannot have two methods with the same name!")

        local method = {
            func = func,
            inboundProcessors = {},
            outboundProcessors = {},
        }

        local methodConstructor: MethodConstructor = {}

        methodConstructor.withInboundProcessors = function(newProcessors)
            addProcessors(method.inboundProcessors, newProcessors)
            return methodConstructor
        end

        methodConstructor.withOutboundProcessors = function(newProcessors)
            addProcessors(method.outboundProcessors, newProcessors)
            return methodConstructor
        end

        bridges[blueprint.name].methods[name] = method
        return methodConstructor
    end

    return bridge
end

--[=[
    @server

    Adds the methods to the given [Bridge] and internally creates a [RemoteFunction] for each, making the [Bridge] available to the client.

    :::caution
    Once a [Bridge] has been constructed, you can no longer add new methods to it.
    :::
]=]
function Bridge.construct(bridge: Bridge)
    assert(RunService:IsServer(), "Bridges can only be added by the server!")
    local bridgeName, bridgeConfig

    for name, config in bridges do
        if config.bridge == bridge then
            bridgeName = name
            bridgeConfig = config
            break
        end
    end

    assert(bridgeName and bridgeConfig, "Bridges must be created with Bridge.blueprint()!")
    assert(not bridgeConfig.constructed, "Cannot add a bridge more than once!")
    bridgeConfig.constructed = true

    local folder = Instance.new("Folder")
    folder.Name = bridgeName

    local eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "Events"

    for eventName, remoteEvent in pairs(bridgeConfig.events) do
        remoteEvent.Name = eventName
        remoteEvent.Parent = eventsFolder
    end

    local functionsFolder = Instance.new("Folder")
    functionsFolder.Name = "Functions"

    for methodName, methodConfig in bridgeConfig.methods do
        local remoteFunction = Instance.new("RemoteFunction")
        remoteFunction.Name = methodName

        if bridge[methodName] then
            warn(
                "Method '"
                    .. methodName
                    .. "' was not added to the Bridge's table, as it would overwrite an existing field!"
            )
        else
            bridge[methodName] = methodConfig.func
        end

        -- Create processing sequence
        local processors = {}

        for _, processor in ipairs(bridgeConfig.inboundProcessors) do
            table.insert(processors, processor)
        end

        for _, processor in ipairs(methodConfig.inboundProcessors) do
            table.insert(processors, processor)
        end

        table.insert(processors, methodConfig.func)

        for _, processor in ipairs(methodConfig.outboundProcessors) do
            table.insert(processors, processor)
        end

        for _, processor in ipairs(bridgeConfig.outboundProcessors) do
            table.insert(processors, processor)
        end

        -- Process invocations
        remoteFunction.OnServerInvoke = function(...)
            local args = table.pack(...)

            for _, processor in ipairs(processors) do
                args = table.pack(processor(table.unpack(args)))
            end

            return table.unpack(args)
        end

        remoteFunction.Parent = functionsFolder
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
