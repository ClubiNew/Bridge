--[=[
    @class MiddlewareManager
    The middleware manager allows you to create new [middleware](/api/MiddlewareManager#Middleware).
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Bridge = require(ReplicatedStorage.Packages.Bridge)

    -- In a server script:

    local function doubleArgs(...)
        local args = table.pack(...)

        for index, arg in pairs(args) do
            if typeof(arg) == "number" then
                args[index] = arg * 2
            end
        end

        return table.unpack(args)
    end

    local BadMathMiddleware = Bridge.Middleware.new("BadMathMiddleware", {
        events = {"SomeEvent"},
        inboundProcessors = {doubleArgs},
        outboundProcessors = {doubleArgs},
    })

    function BadMathMiddleware:Add(player, x, y)
        self.Events.SomeEvent:FireAllClients("Add called!")
        return x + y
    end

    Bridge.Middleware.add(BadMathMiddleware)

    -- In a local script:

    local BadMathMiddleware = Bridge.Middleware.get("BadMathMiddleware")

    BadMathMiddleware.Events.SomeEvent.OnClientEvent:Connect(function(msg)
        print(msg) --> Add called!
    end)

    print(BadMathMiddleware:Add(1, 2)) --> 12
    ```
]=]
local MiddlewareManager = {}

local RunService = game:GetService("RunService")

local middleware: {
    middleware: Middleware,
    inboundProcessors: {(any)->(any)},
    outboundProcessors: {(any)->(any)},
} = {}

--[=[
    @interface Middleware
    @within MiddlewareManager
    .Events {string: RemoteEvent}
    .... (Middleware, any) -> (any)
    Middleware is used to allow for communication between the client and server. Servers [create the middleware](/api/MiddlewareManager#add) and define events and functions, and then clients [request the middleware](/api/MiddlewareManager#) and make calls to the functions and listen to the events.
    :::note
    Servers can also listen for calls from clients to the events if a response is not necessary, but no inbound/outbound processing will take place.
    :::
]=]
type Middleware = {
    Events: {string: RemoteEvent},
    string: (Middleware, any) -> (any),
}

--[=[
    @interface MiddlewareOptions
    @within MiddlewareManager
    .inboundProcessors {(...) -> (...)} | nil
    .outboundProcessors {(...) -> (...)} | nil
    .events {string} | nil
    The functions in the `inboundProcessors` table will be called in order before middleware functions are called. Likewise, the functions in the `outboundProcessors` table will be called in order before returning data to the client. In each function, you can either throw an error to stop the request from going through, or return the arguments with any modifications for the next processor to use.

    Each string in the `events` table will be turned into a [RemoteEvent](https://developer.roblox.com/en-us/api-reference/class/RemoteEvent) in the [Middleware](/api/MiddlewareManager#Middleware).

    :::caution
    Processors are bypassed when listening for client calls to the remote events.
    :::
]=]
type MiddlewareOptions = {
    inboundProcessors: {(any)->(any)} | nil,
    outboundProcessors: {(any)->(any)} | nil,
    events: {string} | nil,
}

--[=[
    @function new
    @within MiddlewareManager
    @param middlewareName string
    @param middlewareOptions MiddlewareOptions
    @return Middleware
    @server
    :::note
    It is recommended that you use `script.Name` as your middleware name.
    :::
]=]
function MiddlewareManager.new(middlewareName: string, middlewareOptions: MiddlewareOptions)
    assert(RunService:IsServer(), "[BRIDGE] Middleware can only be created by the server!")
    assert(not middleware[middlewareName], "[BRIDGE] Cannot have two middleware with the same name!")
    local newMiddleware: Middleware = { Events = {} }

    if middlewareOptions.events then
        for _, eventName in pairs(middlewareOptions.events) do
            local RemoteEvent = Instance.new("RemoteEvent")
            newMiddleware.Events[eventName] = RemoteEvent
        end
    end

    middleware[middlewareName] = {
        middleware = newMiddleware,
        inboundProcessors = middlewareOptions.inboundProcessors or {},
        outboundProcessors = middlewareOptions.outboundProcessors or {},
    }

    return newMiddleware
end

--[=[
    @function add
    @within MiddlewareManager
    @param middleware Middleware
    @server
    :::caution
    Once middleware has been added to the middleware manager, you can no longer add new methods to it.
    :::
]=]
function MiddlewareManager.add(newMiddleware: Middleware)
    assert(RunService:IsServer(), "[BRIDGE] Middleware can only be added by the server!")
    local middlewareName, middlewareData

    for name, data in pairs(middleware) do
        if data.middleware == newMiddleware then
            middlewareName = name
            middlewareData = data
            break
        end
    end

    assert(middlewareName and middlewareData, "[BRIDGE] Middleware must be created with Bridge.Middleware.new()!")
    assert(not script:FindFirstChild(middleware), "[BRIDGE] Cannot add middleware more than once!")

    local folder = Instance.new("Folder")
    folder.Name = middlewareName

    local eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "Events"

    for remoteName, RemoteEvent in pairs(newMiddleware.Events) do
        RemoteEvent.Name = remoteName
        RemoteEvent.Parent = eventsFolder
    end

    local functionsFolder = Instance.new("Folder")
    functionsFolder.Name = "Functions"

    for funcName, func in pairs(newMiddleware) do
        if typeof(func) == "function" then
            local RemoteFunction = Instance.new("RemoteFunction")
            RemoteFunction.Name = funcName

            -- Create processing sequence
            local processors = {}

            for _, processor in ipairs(middlewareData.inboundProcessors) do
                table.insert(processors, processor)
            end

            table.insert(processors, func)

            for _, processor in ipairs(middlewareData.outboundProcessors) do
                table.insert(processors, processor)
            end

            -- Process invocations
            RemoteFunction.OnServerInvoke = function(...)
                local args = table.pack(...)

                for _, processor in ipairs(processors) do
                    if processor == func then
                        args = table.pack(func(newMiddleware, table.unpack(args)))
                    else
                        args = table.pack(processor(table.unpack(args)))
                    end
                end

                return table.unpack(args)
            end

            RemoteFunction.Parent = functionsFolder
        end
    end

    eventsFolder.Parent = folder
    functionsFolder.Parent = folder
    folder.Parent = script
end

--[=[
    @function get
    @within MiddlewareManager
    @param middlewareName string
    @return Middleware
    @client
    @yields
    :::caution
    This method will yield until the requested [Middleware](/api/MiddlewareManager#Middleware) is added to the middleware manager. After every 30 seconds of yielding, a warning will be output so you can see which middle wares aren't added correctly.
    :::
]=]
function MiddlewareManager.get(middlewareName: string)
    assert(not RunService:IsServer(), "[BRIDGE] Middleware can only be requested by the client!")
    local middlewareFolder = script:FindFirstChild(middlewareName)

    if not middlewareFolder then
        task.spawn(function()
            local totalTime = 0
            while task.wait(30) do
                if middlewareFolder then
                    break
                else
                    totalTime += 30
                    warn("[BRIDGE] Middleware '" .. middlewareName .. "' has been yielding for", totalTime, "seconds!")
                end
            end
        end)

        while not middlewareFolder do
            script.ChildAdded:Wait()
            middlewareFolder = script:FindFirstChild(middlewareName)
        end
    end

    local middlewareInterface = { Events = {} }

    for _, RemoteEvent in pairs(middlewareFolder:WaitForChild("Events"):GetChildren()) do
        middlewareInterface.Events[RemoteEvent.Name] = RemoteEvent
    end

    for _, RemoteFunction in pairs(middlewareFolder:WaitForChild("Functions"):GetChildren()) do
        middlewareInterface[RemoteFunction.Name] = function(_, ...)
            return RemoteFunction:InvokeServer(...)
        end
    end

    return middlewareInterface
end

table.freeze(MiddlewareManager)
return MiddlewareManager
