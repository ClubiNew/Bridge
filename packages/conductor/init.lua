--[=[
    @class Conductor
    `Conductor = "minstrix/conductor@^0.1"`

    Conductor allows you to create and orchestrate services. Read the [Service] interface for more information.

    ```lua
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

    Conductor.add("ServiceA", ServiceA)

    -- In ServiceB.lua

    local ServiceB = {}

    function ServiceB:OnInit()
        print("Initialized!")
    end

    function ServiceB:OnStart()
        print("Started!")

        local ServiceA = Conductor.get("ServiceA")
        ServiceA:SomeMethod() --> "Some string"
    end

    Conductor.add("ServiceB", ServiceB)

    -- In a script

    Conductor.start()
    ```
]=]

local Signal = require(script.Parent.Signal)

local Conductor = {}

local isStarted = false
local startDebounce = false
local started = Signal.new()

local services: { [string]: Service } = {}

--[=[
    @interface Service
    @within Conductor
    .OnInit (Service) -> () | nil
    .OnStart (Service) -> () | nil
    .... any
    Services are essentially just tables with two optional life cycle methods: `OnInit` and `OnStart`.

    `OnInit` is called when [Conductor.start] is called and services cannot be accessed until all services have finished running `OnInit`. Then `OnStart` will be called in parallel for all services and access to services will be available.

    :::tip
    If you do not need either life cycle method, it is recommended you use a standard module instead of a service.
    :::
]=]
type Service = {
    OnInit: (Service) -> () | nil,
    OnStart: (Service) -> () | nil,
    [any]: any,
}

--[=[
    Adds a new [Service] to [Conductor].
    :::tip
    It's recommended to use `script.Name` as your service name.
    :::
]=]
function Conductor.add(serviceName: string, service: Service)
    assert(not isStarted, "Cannot create new services after starting services!")
    assert(not services[serviceName], "Cannot have two services with the same name!")
    services[serviceName] = service
end

--[=[
    @yields
    :::caution
    This method will yield until [Conductor.start] is called and all services have initialized. Using it in a [Service] during initialization may cause an infinite yield!
    :::
]=]
function Conductor.get(serviceName: string): Service
    if not isStarted then
        started:Wait()
    end

    assert(services[serviceName], "Service '" .. serviceName .. "' does not exist!")
    return services[serviceName]
end

--[=[
    Runs all of the service life cycle methods and makes them accessible via [Conductor.get]. Set the `verbose` parameter to `true` to print a message as each service is started.
    :::caution
    Once this method has been called, you will not longer be able to [add new services](#add)!
    :::
]=]
function Conductor.start(verbose: boolean?): nil
    if not startDebounce then
        startDebounce = true

        if verbose then
            print("Initializing services...")
        end

        for serviceName, service in pairs(services) do
            if service.OnInit then
                if verbose then
                    print("\t\t⤷ Initializing", serviceName)
                end
                service:OnInit(service)
            end
        end

        isStarted = true
        started:Fire()

        if verbose then
            print("Starting services...")
        end

        for serviceName, service in pairs(services) do
            if service.OnStart then
                if verbose then
                    print("\t\t⤷ Starting", serviceName)
                end
                task.spawn(function()
                    service:OnStart(service)
                end)
            end
        end

        if verbose then
            print("Startup complete!")
        end
    end
end

table.freeze(Conductor)
return Conductor
