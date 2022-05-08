"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[689],{41848:function(e){e.exports=JSON.parse('{"functions":[{"name":"new","desc":":::note\\nIt is recommended that you use `script.Name` as your middleware name.\\n:::","params":[{"name":"middlewareName","desc":"","lua_type":"string"},{"name":"middlewareOptions","desc":"","lua_type":"MiddlewareOptions"}],"returns":[{"desc":"","lua_type":"Middleware"}],"function_type":"static","realm":["Server"],"source":{"line":102,"path":"src/MiddlewareManager.lua"}},{"name":"add","desc":":::caution\\nOnce middleware has been added to the middleware manager, you can no longer add new methods to it.\\n:::","params":[{"name":"middleware","desc":"","lua_type":"Middleware"}],"returns":[],"function_type":"static","realm":["Server"],"source":{"line":132,"path":"src/MiddlewareManager.lua"}},{"name":"get","desc":":::caution\\nThis method will yield until the requested [Middleware](/api/MiddlewareManager#Middleware) is added to the middleware manager. After every 30 seconds of yielding, a warning will be output so you can see which middle wares aren\'t added correctly.\\n:::","params":[{"name":"middlewareName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Middleware"}],"function_type":"static","realm":["Client"],"yields":true,"source":{"line":214,"path":"src/MiddlewareManager.lua"}}],"properties":[],"types":[{"name":"Middleware","desc":"Middleware is used to allow for communication between the client and server. Servers [create the middleware](/api/MiddlewareManager#add) and define events and functions, and then clients [request the middleware](/api/MiddlewareManager#) and make calls to the functions and listen to the events.\\n:::note\\nServers can also listen for calls from clients to the events if a response is not necessary, but no inbound/outbound processing will take place.\\n:::","fields":[{"name":"Events","lua_type":"{string: RemoteEvent}","desc":""},{"name":"...","lua_type":"(Middleware, any) -> (any)","desc":""}],"source":{"line":66,"path":"src/MiddlewareManager.lua"}},{"name":"MiddlewareOptions","desc":"The functions in the `inboundProcessors` table will be called in order before middleware functions are called. Likewise, the functions in the `outboundProcessors` table will be called in order before returning data to the client. In each function, you can either throw an error to stop the request from going through, or return the arguments with any modifications for the next processor to use.\\n\\nEach string in the `events` table will be turned into a [RemoteEvent](https://developer.roblox.com/en-us/api-reference/class/RemoteEvent) in the [Middleware](/api/MiddlewareManager#Middleware).\\n\\n:::caution\\nProcessors are bypassed when listening for client calls to the remote events.\\n:::","fields":[{"name":"inboundProcessors","lua_type":"{(...) -> (...)} | nil","desc":""},{"name":"outboundProcessors","lua_type":"{(...) -> (...)} | nil","desc":""},{"name":"events","lua_type":"{string} | nil","desc":""}],"source":{"line":85,"path":"src/MiddlewareManager.lua"}}],"name":"MiddlewareManager","desc":"The middleware manager allows you to create new [middleware](/api/MiddlewareManager#Middleware).\\n```lua\\nlocal ReplicatedStorage = game:GetService(\\"ReplicatedStorage\\")\\nlocal Bridge = require(ReplicatedStorage.Packages.Bridge)\\n\\n-- In a server script:\\n\\nlocal function doubleArgs(...)\\n    local args = table.pack(...)\\n\\n    for index, arg in pairs(args) do\\n        if typeof(arg) == \\"number\\" then\\n            args[index] = arg * 2\\n        end\\n    end\\n\\n    return table.unpack(args)\\nend\\n\\nlocal BadMathMiddleware = Bridge.Middleware.new(\\"BadMathMiddleware\\", {\\n    events = {\\"SomeEvent\\"},\\n    inboundProcessors = {doubleArgs},\\n    outboundProcessors = {doubleArgs},\\n})\\n\\nfunction BadMathMiddleware:Add(player, x, y)\\n    self.Events.SomeEvent:FireAllClients(\\"Add called!\\")\\n    return x + y\\nend\\n\\nBridge.Middleware.add(BadMathMiddleware)\\n\\n-- In a local script:\\n\\nlocal BadMathMiddleware = Bridge.Middleware.get(\\"BadMathMiddleware\\")\\n\\nBadMathMiddleware.Events.SomeEvent.OnClientEvent:Connect(function(msg)\\n    print(msg) --\x3e Add called!\\nend)\\n\\nprint(BadMathMiddleware:Add(1, 2)) --\x3e 12\\n```","source":{"line":46,"path":"src/MiddlewareManager.lua"}}')}}]);