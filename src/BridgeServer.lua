
if not game:GetService("RunService"):IsServer() then
    error("[BRIDGE] The client cannot access BridgeServer, please require the main Bridge module instead!")
end

local Signal = require(script.Parent:WaitForChild("Signal"))
local Remote = require(script.Parent:WaitForChild("Remote"))

--[=[
    @class BridgeServer
    @server
]=]
local Bridge = {
    newSignal = Signal.new;
    newRemote = Remote.new;
    MiddlewarePriorities = {
        UniversalFirst = newproxy(true);
        UniversalLast = newproxy(true);
    };
}

--[=[
    @function newSignal
    @within BridgeServer
    @return Signal
]=]

--[=[
    @function newRemote
    @within BridgeServer
    @return Remote
]=]

--[=[
    @interface MiddlewarePriorities
    @within BridgeServer
    .UniversalFirst userdata
    .UniversalLast userdata
]=]

--[=[
    @prop MiddlewarePriorities MiddlewarePriorities
    @within BridgeServer
    @readonly
]=]

--[=[
    @type MiddlewarePriority userdata
    @within BridgeServer
    One of `BridgeServer.MiddlewarePriorities`. Use `UniversalFirst` to have universal middleware run before client/server middleware and `UniversalLast` to have client/server middleware run before universal middleware.
]=]

local Services = {}

local GlobalInboundMiddleware = {}
local GlobalOutboundMiddleware = {}

local isDeployed = false

local ServicesFolder = Instance.new("Folder")
ServicesFolder.Name = "Services"

--[=[
    @interface Service
    @within BridgeServer
    .Bridge {Remote | function}
    .Construct function?
    .Deploy function?
    .... Signal | function | any
    Remotes and methods within the `Bridge` are accessible by clients! The construct function is run during deployment for each service asynchronously. The deploy function is run during deployment for all services synchronously. It is safe to access other controllers after the construct function has run.
]=]

--[=[
    @function newService
    @within BridgeServer
    @param name string
    @param MiddlewarePriority MiddlewarePriority?
    @return Service
]=]
function Bridge.newService(name: string, MiddlewarePriority: userdata?)
    assert(typeof(name) == "string", "[BRIDGE] Expected name to be a string, got " .. typeof(name) .. ".")

    if Services[name] then
        error("[BRIDGE] There is already a service called " .. name .. "!")
    end

    if isDeployed then
        error("[BRIDGE] Cannot add new services after Bridge has deployed!")
    end

    Services[name] = {
        MiddlewarePriority =
            MiddlewarePriority or Bridge.MiddlewarePriorities.UniversalFirst;
        InboundMiddleware = {
            Universal = {};
            Server = {};
            Client = {};
        };
        OutboundMiddleware = {
            Universal = {};
            Server = {};
            Client = {};
        };
    }

    local Service = setmetatable({Bridge = {}}, Services[name])
    Services[name].Service = Service

    return Service
end

--[=[
    @function toService
    @within BridgeServer
    @param serviceName string
    @return Service
    Get another service to access it's methods. Must run `BridgeServer.Deploy()` first.
]=]
function Bridge.toService(serviceName: string)
    assert(typeof(serviceName) == "string", "[BRIDGE] Expected service name to be a string, got " .. typeof(serviceName) .. ".")
    assert(Services[serviceName], "[BRIDGE] Service '" .. serviceName .. "' does not exist!")
    assert(isDeployed, "[BRIDGE] Cannot access services before Bridge deploys!")
    return Services[serviceName].Service
end

local function getServiceMetatable(Service: table?)
    assert(typeof(Service) == "table", "[BRIDGE] Expected first argument to be a table, got " .. typeof(Service) .. ".")

    local metatable = getmetatable(Service)
    assert(metatable and metatable.Service == Service, "[BRIDGE] Expected first argument to be a service.")

    return metatable
end

--[=[
    @type MiddlewareFunction (serviceName: string, methodName: string, args: any) -> any
    @within BridgeServer
    All middleware functions are given the service name, method name and the arguments being passed to or returned from the method. To block the method from running or returning, simply throw an error. The middleware should return the arguments with any changes to be used by other middleware and the method.
]=]

--[=[
    @function addGlobalInboundMiddleware
    @within BridgeServer
    @param middleware MiddlewareFunction
    Add global inbound middleware, which will run before any method of any service is called. Note that global inbound middleware always runs first.
]=]
function Bridge.addGlobalInboundMiddleware(middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(GlobalInboundMiddleware, middleware)
end

--[=[
    @function addGlobalOutboundMiddleware
    @within BridgeServer
    @param middleware MiddlewareFunction
    Add global outbound middleware, which will run after any method of any service is called. Note that global outbound middleware always runs last.
]=]
function Bridge.addGlobalOutboundMiddleware(middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(GlobalOutboundMiddleware, middleware)
end

--[=[
    @function addInboundMiddleware
    @within BridgeServer
    @param Service Service
    @param middleware MiddlewareFunction
    Add universal inbound middleware to the provided service, which will run before any method of that service is called.
]=]
function Bridge.addInboundMiddleware(Service, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getServiceMetatable(Service).InboundMiddleware.Universal, middleware)
end

--[=[
    @function addInboundClientMiddleware
    @within BridgeServer
    @param Service Service
    @param middleware MiddlewareFunction
    Add client inbound middleware to the provided service, which will run before any client method of that service is called.
]=]
function Bridge.addInboundClientMiddleware(Service, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getServiceMetatable(Service).InboundMiddleware.Client, middleware)
end

--[=[
    @function addInboundServerMiddleware
    @within BridgeServer
    @param Service Service
    @param middleware MiddlewareFunction
    Add server inbound middleware to the provided service, which will run before any server method of that service is called.
]=]
function Bridge.addInboundServerMiddleware(Service, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getServiceMetatable(Service).InboundMiddleware.Server, middleware)
end

--[=[
    @function addOutboundMiddleware
    @within BridgeServer
    @param Service Service
    @param middleware MiddlewareFunction
    Add universal outbound middleware to the provided service, which will run after any method of that service is called.
]=]
function Bridge.addOutboundMiddleware(Service, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getServiceMetatable(Service).OutboundMiddleware.Universal, middleware)
end

--[=[
    @function addOutboundClientMiddleware
    @within BridgeServer
    @param Service Service
    @param middleware MiddlewareFunction
    Add client outbound middleware to the provided service, which will run after any client method of that service is called.
]=]
function Bridge.addOutboundClientMiddleware(Service, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getServiceMetatable(Service).OutboundMiddleware.Client, middleware)
end

--[=[
    @function addOutboundServerMiddleware
    @within BridgeServer
    @param Service Service
    @param middleware MiddlewareFunction
    Add server outbound middleware to the provided service, which will run after any server method of that service is called.
]=]
function Bridge.addOutboundServerMiddleware(Service, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getServiceMetatable(Service).OutboundMiddleware.Server, middleware)
end

local function runMiddleware(middlewareFunctions, direction, serviceName, methodName, args)
    for _, middleware in pairs(middlewareFunctions) do
        local success, result = pcall(middleware, serviceName, methodName, table.unpack(args))
        if success then
            args = table.pack(result)
        else
            error("[BRIDGE] Request to " .. serviceName .. "'s " .. methodName .. " method rejected by " .. direction .. " middleware: " .. result)
        end
    end
    return args
end

--[=[
    @function deploy
    @within BridgeServer
    @param verbose boolean?
    Initialize, construct and deploy all services.
]=]
function Bridge.deploy(verbose: boolean?)
    if verbose then
        print("[BRIDGE] Initializing services...")
    end

    for serviceName, Service in pairs(Services) do
        local serviceFolder = Instance.new("Folder")
        serviceFolder.Name = serviceName
        for index, value in pairs(Service.Service) do
            if index == "Construct" or index == "Deploy" then
                continue
            elseif typeof(value) == "function" then
                Service.Service[index] = function(_, ...)
                    local args = runMiddleware(GlobalInboundMiddleware, "inbound", serviceName, index, table.pack(...))

                    if Service.MiddlewarePriority == Bridge.MiddlewarePriorities.UniversalFirst then
                        args = runMiddleware(Service.InboundMiddleware.Universal, "inbound", serviceName, index, args)
                        args = runMiddleware(Service.InboundMiddleware.Server, "inbound", serviceName, index, args)
                    else
                        args = runMiddleware(Service.InboundMiddleware.Server, "inbound", serviceName, index, args)
                        args = runMiddleware(Service.InboundMiddleware.Universal, "inbound", serviceName, index, args)
                    end

                    local result = table.pack(value(Service.Service, table.unpack(args)))

                    if Service.MiddlewarePriority == Bridge.MiddlewarePriorities.UniversalFirst then
                        result = runMiddleware(Service.OutboundMiddleware.Universal, "outbound", serviceName, index, result)
                        result = runMiddleware(Service.OutboundMiddleware.Server, "outbound", serviceName, index, result)
                    else
                        result = runMiddleware(Service.OutboundMiddleware.Server, "outbound", serviceName, index, result)
                        result = runMiddleware(Service.OutboundMiddleware.Universal, "outbound", serviceName, index, result)
                    end

                    result = runMiddleware(GlobalOutboundMiddleware, "outbound", serviceName, index, result)

                    return table.unpack(result)
                end
            elseif index == "Bridge" then
                for methodName, method in pairs(value) do
                    if typeof(method) == "function" then
                        local func = function(...)
                            local serviceNameBridge = serviceName .. "'s Bridge"
                            local args = runMiddleware(GlobalInboundMiddleware, "inbound", serviceNameBridge, methodName, table.pack(...))

                            if Service.MiddlewarePriority == Bridge.MiddlewarePriorities.UniversalFirst then
                                args = runMiddleware(Service.InboundMiddleware.Universal, "inbound", serviceNameBridge, methodName, args)
                                args = runMiddleware(Service.InboundMiddleware.Client, "inbound", serviceNameBridge, methodName, args)
                            else
                                args = runMiddleware(Service.InboundMiddleware.Client, "inbound", serviceNameBridge, methodName, args)
                                args = runMiddleware(Service.InboundMiddleware.Universal, "inbound", serviceNameBridge, methodName, args)
                            end

                            local result = table.pack(method(Service.Service, table.unpack(args)))

                            if Service.MiddlewarePriority == Bridge.MiddlewarePriorities.UniversalFirst then
                                result = runMiddleware(Service.OutboundMiddleware.Universal, "outbound", serviceNameBridge, methodName, result)
                                result = runMiddleware(Service.OutboundMiddleware.Client, "outbound", serviceNameBridge, methodName, result)
                            else
                                result = runMiddleware(Service.OutboundMiddleware.Client, "outbound", serviceNameBridge, methodName, result)
                                result = runMiddleware(Service.OutboundMiddleware.Universal, "outbound", serviceNameBridge, methodName, result)
                            end

                            result = runMiddleware(GlobalOutboundMiddleware, "outbound", serviceNameBridge, methodName, result)

                            return table.unpack(result)
                        end

                        local RemoteFunction = Instance.new("RemoteFunction")
                        RemoteFunction.OnServerInvoke = func
                        RemoteFunction.Name = methodName
                        RemoteFunction.Parent = serviceFolder

                        Service.Service.Bridge[methodName] = function(_, ...)
                            func(...)
                        end
                    elseif Remote.Is(method) then
                        method.RemoteEvent.Name = methodName
                        method.RemoteEvent.Parent = serviceFolder
                    else
                        warn("[BRIDGE] Only methods and remotes can be in the bridge.", methodName, "is neither and will be removed from", serviceName .. "'s bridge!")
                        Service.Service.Bridge[methodName] = nil
                    end
                end
            elseif Remote.Is(value) then
                warn("[BRIDGE] Remote", index, "is not in", serviceName .. "'s bridge! Clients will not be able to access it.")
            end
        end
        serviceFolder.Parent = ServicesFolder
    end

    ServicesFolder.Parent = script.Parent
    local constructionStart = tick()

    if verbose then
        print("[BRIDGE] Constructing services...")
    end

    for serviceName, Service in pairs(Services) do
        if Service.Service.Construct then
            if verbose then
                print("\t\t⤷ Constructing", serviceName)
            end
            Service.Service:Construct()
            Service.Service.Construct = nil
        end
    end

    if verbose then
        print("[BRIDGE] Finished constructing services in", math.round((tick() - constructionStart) * 1000), "ms")
        print("[BRIDGE] Deploying services...")
    end

    isDeployed = true

    for serviceName, Service in pairs(Services) do
        if Service.Service.Deploy then
            if verbose then
                print("\t\t⤷ Deploying", serviceName)
            end
            task.spawn(Service.Service.Deploy, Service.Service)
            Service.Service.Deploy = nil
        end
    end

    script.Parent:SetAttribute("ServerDeployed", true)
    print("[BRIDGE] Finished deploying!")
end

return Bridge
