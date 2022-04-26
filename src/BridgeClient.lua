
if game:GetService("RunService"):IsServer() then
    error("[BRIDGE] The server cannot access BridgeClient, please require the main Bridge module instead!")
end

local Signal = require(script.Parent:WaitForChild("Signal"))

--[=[
    @class BridgeClient
    @client
]=]
local Bridge = {
    newSignal = Signal.new;
}

--[=[
    @function newSignal
    @within BridgeClient
    @return Signal
]=]

--[=[
    @property isReady boolean
    @within BridgeClient
    @readonly
    If `true`, Bridge has deployed and controllers can be accessed. If `false`, controllers are not yet accessible.
]=]
Bridge.isReady = false

--[=[
    @property Ready Signal
    @within BridgeClient
    @readonly
    Fires when Bridge deploys and is ready for controllers to be accessed.
    :::caution
    This Signal is destroyed after Bridge deploys. It is recommended to first check [`Bridge.isReady`](/api/BridgeClient#isReady).
    :::
]=]
Bridge.Ready = Signal.new()

local Controllers = {}
local Services = {}

local GlobalInboundMiddleware = {}
local GlobalOutboundMiddleware = {}

--[=[
    @interface Controller
    @within BridgeClient
    .Construct function?
    .Deploy function?
    .... Signal | function | any
    The construct function is run during deployment for each service asynchronously. The deploy function is run during deployment for all services synchronously. It is safe to access other services after the construct function has run.
]=]

--[=[
    @function newController
    @within BridgeClient
    @param name string
    @return Controller
]=]
function Bridge.newController(name: string)
    assert(typeof(name) == "string", "[BRIDGE] Expected name to be a string, got " .. typeof(name) .. ".")

    if Controllers[name] then
        error("[BRIDGE] There is already a controller called " .. name .. "!")
    end

    if Bridge.isReady then
        error("[BRIDGE] Cannot add new controllers after Bridge has deployed!")
    end

    Controllers[name] = {
        InboundMiddleware = {};
        OutboundMiddleware = {};
    }

    local Controller = setmetatable({}, Controllers[name])
    Controllers[name].Controller = Controller

    return Controller
end

--[=[
    @function toController
    @within BridgeClient
    @param controllerName string
    @return Controller
    Get another controller to access it's methods. Must run `BridgeClient.Deploy()` first.
]=]
function Bridge.toController(controllerName: string)
    assert(typeof(controllerName) == "string", "[BRIDGE] Expected controller name to be a string, got " .. typeof(controllerName) .. ".")
    assert(Controllers[controllerName], "[BRIDGE] Controller '" .. controllerName .. "' does not exist!")
    assert(Bridge.isReady, "[BRIDGE] Cannot access controllers before Bridge deploys!")
    return Controllers[controllerName].Controller
end

--[=[
    @interface Service
    @within BridgeClient
    .... Remote | function
]=]

--[=[
    @function toService
    @within BridgeClient
    @param serviceName string
    @return Service
    Use to access the remotes and methods within the Bridge of a service. Safe to call immediately, but may yield if the server has not finished deploying.
]=]
function Bridge.toService(serviceName: string)
    assert(typeof(serviceName) == "string", "[BRIDGE] Expected service name to be a string, got " .. typeof(serviceName) .. ".")

    if Services[serviceName] then
        return Services[serviceName]
    elseif not script.Parent:GetAttribute("ServerReady") then
        script.Parent:GetAttributeChangedSignal("ServerReady"):Wait()
    end

    local serviceFolder = script.Parent.Services:FindFirstChild(serviceName)
    if serviceFolder then
        local Service = {}

        for _, remote in pairs(serviceFolder:GetChildren()) do
            if remote:IsA("RemoteEvent") then
                Service[remote.Name] = {
                    Connect = function(_, f)
                        return remote.OnClientEvent:Connect(f)
                    end;
                    Wait = function()
                        return remote.OnClientEvent:Wait()
                    end;
                }
            elseif remote:IsA("RemoteFunction") then
                Service[remote.Name] = function(_, ...)
                    return remote:InvokeServer(...)
                end
            end
        end

        Services[serviceName] = Service
        return Service
    else
        assert(Services[serviceName], "[BRIDGE] Service '" .. serviceName .. "' does not exist!")
    end
end

local function getControllerMetatable(Controller: table?)
    assert(typeof(Controller) == "table", "[BRIDGE] Expected first argument to be a table, got " .. typeof(Controller) .. ".")

    local metatable = getmetatable(Controller)
    assert(metatable and metatable.Controller == Controller, "[BRIDGE] Expected first argument to be a controller.")

    return metatable
end

--[=[
    @type MiddlewareFunction (controllerName: string, methodName: string, args: any) -> any
    @within BridgeClient
    All middleware functions are given the controller name, method name and the arguments being passed to or returned from the method. To block the method from running or returning, simply throw an error. The middleware should return the arguments with any changes to be used by other middleware and the method.
]=]

--[=[
    @function addGlobalInboundMiddleware
    @within BridgeClient
    @param middleware MiddlewareFunction
    Add global inbound middleware, which will run before any method of any controller is called. Note that global inbound middleware always runs first.
]=]
function Bridge.addGlobalInboundMiddleware(middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(GlobalInboundMiddleware, middleware)
end

--[=[
    @function addGlobalOutboundMiddleware
    @within BridgeClient
    @param middleware MiddlewareFunction
    Add global outbound middleware, which will run after any method of any controller is called. Note that global outbound middleware always runs last.
]=]
function Bridge.addGlobalOutboundMiddleware(middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(GlobalOutboundMiddleware, middleware)
end

--[=[
    @function addInboundMiddleware
    @within BridgeClient
    @param Controller Controller
    @param middleware MiddlewareFunction
    Add inbound middleware to the provided controller, which will run before any method of that controller is called.
]=]
function Bridge.addInboundMiddleware(Controller, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getControllerMetatable(Controller).InboundMiddleware, middleware)
end

--[=[
    @function addOutboundMiddleware
    @within BridgeClient
    @param Controller Controller
    @param middleware MiddlewareFunction
    Add outbound middleware to the provided controller, which will run after any method of that controller is called.
]=]
function Bridge.addOutboundMiddleware(Controller, middleware)
    assert(typeof(middleware) == "function", "[BRIDGE] Expected middleware to be a function, got " .. typeof(middleware) .. ".")
    table.insert(getControllerMetatable(Controller).OutboundMiddleware, middleware)
end

local function runMiddleware(middlewareFunctions, direction, controllerName, methodName, args)
    for _, middleware in pairs(middlewareFunctions) do
        local success, result = pcall(middleware, controllerName, methodName, table.unpack(args))
        if success then
            args = table.pack(result)
        else
            error("[BRIDGE] Request to " .. controllerName .. "'s " .. methodName .. " method rejected by " .. direction .. " middleware: " .. result)
        end
    end
    return args
end

--[=[
    @function deploy
    @within BridgeClient
    @param verbose boolean?
    Initialize, construct and deploy all controllers.
]=]
function Bridge.deploy(verbose: boolean?)
    if verbose then
        print("[BRIDGE] Initializing controllers...")
    end

    for controllerName, Controller in pairs(Controllers) do
        for index, value in pairs(Controller.Controller) do
            if index == "Construct" or index == "Deploy" then
                continue
            elseif typeof(value) == "function" then
                Controller.Controller[index] = function(_, ...)
                    local args = runMiddleware(GlobalInboundMiddleware, "inbound", controllerName, index, table.pack(...))
                    args = runMiddleware(Controller.InboundMiddleware, "inbound", controllerName, index, args)

                    local result = table.pack(value(Controller.Controller, table.unpack(args)))
                    result = runMiddleware(Controller.OutboundMiddleware, "outbound", controllerName, index, result)
                    result = runMiddleware(GlobalOutboundMiddleware, "outbound", controllerName, index, result)

                    return table.unpack(result)
                end
            end
        end
    end

    local constructionStart = tick()

    if verbose then
        print("[BRIDGE] Constructing controllers...")
    end

    for controllerName, Controller in pairs(Controllers) do
        if Controller.Controller.Construct then
            if verbose then
                print("\t\t⤷ Constructing", controllerName)
            end
            Controller.Controller:Construct()
            Controller.Controller.Construct = nil
        end
    end

    if verbose then
        print("[BRIDGE] Finished constructing controllers in", math.round((tick() - constructionStart) * 1000), "ms")
        print("[BRIDGE] Deploying controllers...")
    end

    Bridge.isReady = true
    Bridge.Ready:Fire()
    Bridge.Ready:Destroy()

    for controllerName, Controller in pairs(Controllers) do
        if Controller.Controller.Deploy then
            if verbose then
                print("\t\t⤷ Deploying", controllerName)
            end
            task.spawn(Controller.Controller.Deploy, Controller.Controller)
            Controller.Controller.Deploy = nil
        end
    end

    print("[BRIDGE] Finished deploying!")
end

return Bridge