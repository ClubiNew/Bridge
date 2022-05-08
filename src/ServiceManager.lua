--[=[
    @class ServiceManager
    The service manager allows you to create new [services](/api/ServiceManager#Service).
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Bridge = require(ReplicatedStorage.Packages.Bridge)

    -- In ServiceA.lua

    local ServiceA = {}

    function ServiceA:OnInit()
        print("Initialized!")
        self.SomeVariable = "Some string"
    end

    function ServiceA:OnStart()
        print("Started!")
    end

    function ServiceA:SomeMethod()
        print(self.SomeVariable)
    end

    Bridge.Services.add("ServiceA", ServiceA)

    -- In ServiceB.lua

    local ServiceB = {}

    function ServiceB:OnInit()
        print("Initialized!")
    end

    function ServiceB:OnStart()
        print("Started!")

        local ServiceA = Bridge.Services.get("ServiceA")
        ServiceA:SomeMethod() --> "Some string"
    end

    Bridge.Services.add("ServiceB", ServiceB)

    -- In a script

    Bridge.Services.start()
    ```
]=]
local ServiceManager = {}

local Signal = require(script.Parent:WaitForChild("Utilities")).Signal

local isStarted = false
local started = Signal.new()

local services: {string: Service} = {}

--[=[
    @interface Service
    @within ServiceManager
    .OnInit (Service) -> () | nil
    .OnStart (Service) -> () | nil
    .... any
    Services are essentially just tables with two optional [life cycle methods](/docs/lifecycle). As such, you can store anything in them that could go in a normal table.
    :::note
    If you do not need either life cycle method, it is recommended you use a standard module instead of a service.
    :::
]=]
type Service = {
    OnInit: (Service) -> () | nil,
    OnStart: (Service) -> () | nil,
    [any]: any
}

--[=[
    @function add
    @within ServiceManager
    @param serviceName string
    @param service Service
    :::note
    It is recommended that you use `script.Name` as your service name.
    :::
]=]
function ServiceManager.add(serviceName: string, service: Service)
    assert(not isStarted, "[BRIDGE] Cannot create new services after starting services!")
    assert(not services[serviceName], "[BRIDGE] Cannot have two services with the same name!")
    services[serviceName] = service
end

--[=[
    @function get
    @within ServiceManager
    @param serviceName string
    @return Service
    @yields
    :::caution
    This method will yield until [`ServiceManager.start()`](/api/ServiceManager#start) is called and services have initialized. Using it in a service during initialization may cause an infinite yield!
    :::
]=]
function ServiceManager.get(serviceName: string): Service
    if not isStarted then
        started:Wait()
    end

    assert(services[serviceName], "[BRIDGE] Service '" .. serviceName .. "' does not exist!")
    return services[serviceName]
end

--[=[
    @function start
    @within ServiceManager
    @param verbose boolean?
    Runs all of the service life cycle methods and makes them accessible via [`ServiceManager.get()`](/api/ServiceManager#get). Set the `verbose` parameter to `true` to print a message as each service is started.
    :::caution
    Once this method has been called, you will not longer be able to [add new services](/api/ServiceManager#add)!
    :::
]=]
local startDebounce = false
function ServiceManager.start(verbose: boolean?): nil
    if not startDebounce then
        startDebounce = true

        if verbose then
            print("[BRIDGE] Initializing services...")
        end

        for serviceName, service in pairs(services) do
            if service.OnInit then
                if verbose then
                    print("\t\t⤷ Initializing", serviceName)
                end
                debug.setmemorycategory(serviceName .. "_Init")
                service:OnInit(service)
                debug.resetmemorycategory()
            end
        end

        isStarted = true
        started:Fire()

        if verbose then
            print("[BRIDGE] Starting services...")
        end

        for serviceName, service in pairs(services) do
            if service.OnStart then
                if verbose then
                    print("\t\t⤷ Starting", serviceName)
                end
                task.spawn(function()
                    debug.setmemorycategory(serviceName .. "_Start")
                    service:OnStart(service)
                end)
            end
        end

        if verbose then
            print("[BRIDGE] Startup complete!")
        end
    end
end

table.freeze(ServiceManager)
return ServiceManager
