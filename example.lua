-- Everything

local Bridge = require(the module lol)

-- Server Module

local Players = game:GetService("Players")

local PointsService = Bridge.newService(Bridge.MiddlewarePriority.UniversalFirst)

Bridge.addMiddleware(PointsService, function(method, ...)
    print("PointsService method '" .. method .. "' called with args (", table.concat(table.pack(...), ', '), ")")
    return ...
end)

Bridge.addServerMiddleware(PointsService, function(method, ...)
    print("PointsService server method '" .. method .. "' called with args (", table.concat(table.pack(...), ', '), ")")
    return ...
end)

Bridge.addClientMiddleware(PointsService, function(method, Player, ...)
    print(Player.Name, "called PointsService client method '" .. method .. "' with args (", table.concat(table.pack(...), ', '), ")")
    local Character = Player.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    assert(HumanoidRootPart, "No HumanoidRootPart found!")
    return Player, HumanoidRootPart, ...
end)

function PointsService:Construct()
    self.PlayerPoints = {}
end

function PointsService:Deploy()
    -- it is now safe to access other services
    local DataService = Bridge.toService("DataService")

    Players.PlayerAdded:Connect(function(Player)
        self.PlayerPoints[Player.UserId] = DataService:GetSave(Player)
    end)

    for _, Player in pairs(Players:GetPlayers()) do
        if not self.PlayerPoints[Player.UserId] then
            self.PlayerPoints[Player.UserId] = DataService:GetSave(Player)
        end
    end
end

PointsService.PointsIncremented = Bridge.newSignal()
function PointsService:AddPoints(Player, points)
    local currentPoints = self.PlayerPoints[Player.UserId]
    currentPoints += points

    self.PlayerPoints[Player.UserId] += currentPoints
    PointsService.PointsIncremented:Fire(Player, currentPoints)

    return currentPoints
end

PointsService.Bridge.PointsIncremented = Bridge.newRemote()
function PointsService.Bridge:AddPoints(Player, HumanoidRootPart)
    if HumanoidRootPart.Anchored then -- idk lol
        local newPoints = self:AddPoints(Player, 5)
        self.Bridge.PointsIncremented:FireAll(Player, newPoints)
    end
end

function PointsService.Bridge:GetPoints(Player, _)
    assert(self.PlayerPoints[Player.UserId], "Missing point data!")
    return self.PlayerPoints[Player.UserId]
end

return PointsService

-- Server Script

for _, Service in pairs(script:GetChildren()) do
    require(Service)
end

Bridge.addGlobalMiddleware(function(service, method, ...)
    print("The '" .. method .. "' method of", service, "was called with args (", table.concat(table.pack(...), ","), ")")
    return ...
end)

Bridge.deploy(true) -- boolean to toggle 'verbose' mode
 
-- Client Module

local Players = game:GetService("Players")
local LocalPlayer: Player = Players.LocalPlayer

local PointsService = Bridge.toService("PointsService")

local PointsController = Bridge.newController()

Bridge.addMiddleware(PointsController, function(method, ...)
    print("PointsController method '" .. method .. "' called with args (", table.concat(table.pack(...), ', '), ")")
    return ...
end)

PointsController.PointedIncremented = Bridge.newSignal()

function PointsController:Construct()
    self.Points = PointsService:GetPoints()
    -- create some UI
end

function PointsController:Deploy()
    -- it is now safe to access other controllers
    Bridge.toController("GunController"):SetPoints(self.Points)
    PointsService.PointsIncremented:Connect(function(Player, newPoints)
        if Player == LocalPlayer then
            self.Points = newPoints
            self.PointedIncremented:Fire(newPoints)
        end
        -- update ui or something idk
    end)
end

function PointsController:CompleteTask()
    PointsService:AddPoints()
end

return PointsController

-- Client Script

for _, Controller in pairs(script:GetChildren()) do
    require(Controller)
end

Bridge.addGlobalMiddleware(function(controller, method, ...)
    print("The '" .. method .. "' method of", controller, "was called with args (", table.concat(table.pack(...), ","), ")")
    return ...
end)

Bridge.deploy(true) -- boolean to toggle 'verbose' mode