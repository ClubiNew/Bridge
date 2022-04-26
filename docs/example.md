---
sidebar_position: 4
---

# Example

**game.ServerStorage.Services.RandomService.lua:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bridge = require(ReplicatedStorage.Bridge)

local RandomService = Bridge.newService(script.Name)

function RandomService:Construct()
    self.Random = Random.new(tick())
end

function RandomService:Range(min, max)
    return self.Random:NextInteger(min, max)
end

return RandomService
```

**game.ServerStorage.Services.PointsService.lua:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Bridge = require(ReplicatedStorage.Bridge)
local PointsService = Bridge.newService(script.Name)

function PointsService:Construct()
    self.PlayerPoints = {}

    Players.PlayerAdded:Connect(function(Player)
        self.PlayerPoints[Player.UserId] = 0
    end)

    for _, Player in pairs(Players:GetPlayers()) do
        self.PlayerPoints[Player.UserId] = 0
    end
end

PointsService.Bridge.PointsChanged = Bridge.newRemote()
function PointsService:Deploy()
    local RandomService = Bridge.toService("RandomService")
    while task.wait(1) do
        for _, Player in pairs(Players:GetPlayers()) do
            self.PlayerPoints[Player.UserId] += RandomService:Range(1, 100)
            self.Bridge.PointsChanged:FireClient(Player, self:GetPoints(Player))
        end
    end
end

function PointsService:GetPoints(Player)
    return self.PlayerPoints[Player.UserId]
end

function PointsService.Bridge:GetPoints(Player)
    return self:GetPoints(Player)
end

Bridge.addInboundMiddleware(PointsService, function(serviceName, methodName, args)
    print("The", methodName, "method of", serviceName, "was called with args:", args)
    return args
end)

Bridge.addOutboundMiddleware(PointsService, function(serviceName, methodName, args)
    print("The", methodName, "method of", serviceName, "returned args:", args)
    return args
end)

return PointsService
```

**Script:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Bridge = require(ReplicatedStorage.Bridge)

for _, Service in pairs(ServerStorage.Services:GetChildren()) do
    require(Service)
end

Bridge.deploy(true)
```

**game.ReplicatedStorage.Controllers.PointsController.lua:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bridge = require(ReplicatedStorage.Bridge)

local PointsController = Bridge.newController(script.Name)
local PointsService = Bridge.toService("PointsService")

function PointsController:Construct()
    self.Points = PointsService:GetPoints()
    self.Updated = Bridge.newSignal()
    PointsService.PointsChanged:Connect(function(newPoints)
        self.Points = newPoints
        self.Updated:Fire(newPoints)
    end)
end

function PointsController:GetPoints()
    return self.Points
end

return PointsController
```

**game.ReplicatedStorage.Controllers.OtherController.lua:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bridge = require(ReplicatedStorage.Bridge)

local OtherController = Bridge.newController(script.Name)

function OtherController:Deploy()
    local PointsController = Bridge.toController("PointsController")
    print(PointsController:GetPoints())
    PointsController.Updated:Connect(function(newPoints)
        print(newPoints)
    end)
end

return OtherController
```

**LocalScript:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bridge = require(ReplicatedStorage.Bridge)

for _, Controller in pairs(ReplicatedStorage.Controllers:GetChildren()) do
    require(Controller)
end

Bridge.addGlobalInboundMiddleware(function(controllerName, methodName, args)
    print("The", methodName, "method of", controllerName, "was called with args:", args)
    return args
end)

Bridge.deploy(true)
```
