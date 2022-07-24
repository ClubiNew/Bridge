"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[226],{94089:e=>{e.exports=JSON.parse('{"functions":[{"name":"blueprint","desc":"","params":[{"name":"blueprint","desc":"","lua_type":"Blueprint"}],"returns":[{"desc":"","lua_type":"Bridge\\n"}],"function_type":"static","realm":["Server"],"source":{"line":167,"path":"packages/bridge/init.lua"}},{"name":"construct","desc":"Adds the methods to the given [Bridge] and internally creates a [RemoteFunction] for each, making the [Bridge] available to the client.\\n\\n:::caution\\nOnce a [Bridge] has been constructed, you can no longer add new methods to it.\\n:::","params":[{"name":"bridge","desc":"","lua_type":"Bridge"}],"returns":[],"function_type":"static","realm":["Server"],"source":{"line":229,"path":"packages/bridge/init.lua"}},{"name":"to","desc":":::tip\\nThis method will yield until the requested [Bridge] is [constructed](#construct). After every 30 seconds of yielding, a warning will be printed to notify you if something isn\'t constructing correctly.\\n:::","params":[{"name":"bridgeName","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","realm":["Client"],"yields":true,"source":{"line":320,"path":"packages/bridge/init.lua"}}],"properties":[],"types":[{"name":"Bridge","desc":"A bridge is used to allow for communication between the client and server. Bridges are made using [Bridge.blueprint] which will automatically create the `Events` array based on the given [Blueprint]. You can then add methods to the Bridge using the `addMethod` function and once all methods have been added, you can [construct](#construct) the Bridge. Clients will then be able to [request](#to) the bridge and call the methods or listen to the events on it.\\n\\n:::note\\nThe intention is that `Events` are fired by the server, but the server can also listen for events being fired by clients if a response is not necessary.\\n:::\\n\\n:::tip\\nOnce the Bridge is [constructed](#construct), all of the methods added with `addMethod` will be added to the Bridge\'s table. This means that methods can call each other, just be aware that there will be no inbound/outbound processing between methods.\\n:::","fields":[{"name":"Events","lua_type":"{string: RemoteEvent}","desc":""},{"name":"addMethod","lua_type":"(string, (any) -> (any)) -> MethodConstructor","desc":""}],"source":{"line":93,"path":"packages/bridge/init.lua"}},{"name":"Processor","desc":"A processor is a function that is called either before or after a [Bridge] method is called by the client, with the arguments passed to or returned by the method or previous processor. Processors can either return a tuple of arguments to be used by the method and/or following processor(s), or throw an error to halt the request.\\n\\nYou can add processors to a [Bridge] in the [Blueprint], or add them to specific methods on a [Bridge] using a [MethodConstructor].\\n\\n:::tip\\nProcessors will be called in the order they appear in the inbound/outbound arrays. Be mindful that processors return the arguments expected by the next processor(s) in the array.\\n:::\\n\\n:::caution\\nProcessors are not used for connections to a [RemoteEvent] in the `Events` array of the [Bridge].\\n:::","lua_type":"(any) -> (any)","source":{"line":114,"path":"packages/bridge/init.lua"}},{"name":"Blueprint","desc":"A blueprint is used to define a [Bridge] when calling the [blueprint] method. Read the [Processor] interface for more information on the inbound/outbound processor arrays.\\n\\n:::tip\\nIt\'s recommended to use `script.Name` as the name.\\n:::\\n\\n:::caution\\n[Blueprint] inbound processors will always run before inbound processors added to a [MethodConstructor], and [Blueprint] outbound processors will always run after outbound processors added to a [MethodConstructor].\\n:::","fields":[{"name":"name","lua_type":"string","desc":""},{"name":"events","lua_type":"{string}","desc":""},{"name":"inboundProcessors","lua_type":"{Processor}","desc":""},{"name":"outboundProcessors","lua_type":"{Processor}","desc":""}],"source":{"line":134,"path":"packages/bridge/init.lua"}},{"name":"MethodConstructor","desc":"A method constructor is returned when `addMethod` is called on an un-constructed [Bridge]. You can then use the `withInboundProcessors` and `withOutboundProcessors` functions to add [processors](#Processor) to that method without adding them to the whole [Bridge]. Read the [Processor] interface for more information.\\n\\n:::caution\\nMethod-specific processors will always run *after* the [Blueprint] inbound processors and *before* the outbound [Blueprint] processors.\\n:::","fields":[{"name":"withInboundProcessors","lua_type":"({Processor}) -> MethodConstructor","desc":""},{"name":"withOutboundProcessors","lua_type":"({Processor}) -> MethodConstructor","desc":""}],"source":{"line":153,"path":"packages/bridge/init.lua"}}],"name":"Bridge","desc":"`Bridge = \\"minstrix/bridge@^0.3\\"`\\n\\nBridge is used to simplify client-server communication.\\n\\nServer scripts [define](#blueprint) and [construct](#construct) \\"bridges\\" that clients can then [request](#to) and listen to events or call functions on. Additionally, [processors](#Processor) can be added to a [Bridge] to add pre or post processing to requests.\\n\\n```lua\\n-- In a server script:\\n\\nlocal function printArgs(...)\\n    print(...)\\n    return ...\\nend\\n\\nlocal function doubleArgs(...)\\n    local args = table.pack(...)\\n\\n    for index, arg in args do\\n        if typeof(arg) == \\"number\\" then\\n            args[index] = arg * 2\\n        end\\n    end\\n\\n    return table.unpack(args)\\nend\\n\\nlocal BadMathBridge = Bridge.blueprint({\\n    name = \\"BadMath\\",\\n    events = {\\"SomeEvent\\"},\\n    inboundProcessors = {printArgs}, --\x3e player, 1, 2\\n})\\n\\nBadMathBridge.addMethod(\\"Add\\", function(player, x, y)\\n    BadMathBridge.Events.SomeEvent:FireAllClients(\\"Add called!\\")\\n    return x + y\\nend).withInboundProcessors({doubleArgs}).withOutboundProcessors({doubleArgs})\\n\\nBridge.construct(BadMathBridge)\\n\\n-- In a local script:\\n\\nlocal BadMathBridge = Bridge.to(\\"BadMath\\")\\n\\nBadMathBridge.Events.SomeEvent.OnClientEvent:Connect(function(msg)\\n    print(msg) --\x3e Add called!\\nend)\\n\\nprint(BadMathBridge:Add(1, 2)) --\x3e 12\\n```","source":{"line":53,"path":"packages/bridge/init.lua"}}')}}]);