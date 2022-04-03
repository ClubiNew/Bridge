"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[634],{98217:function(e){e.exports=JSON.parse('{"functions":[{"name":"new","desc":"","params":[],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"static","private":true,"source":{"line":30,"path":"src/Signal.lua"}},{"name":"Is","desc":"Returns `true` if the passed table is a Signal.","params":[{"name":"signal","desc":"","lua_type":"table"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":43,"path":"src/Signal.lua"}},{"name":"Fire","desc":"Fires the signal with the given arguments.","params":[{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","source":{"line":53,"path":"src/Signal.lua"}},{"name":"Connect","desc":"Connect the signal to the provided function.","params":[{"name":"f","desc":"","lua_type":"function"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection"}],"function_type":"method","source":{"line":64,"path":"src/Signal.lua"}},{"name":"Wait","desc":"Waits for the signal to be fired and returns the arguments it was fired with.","params":[],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","source":{"line":74,"path":"src/Signal.lua"}},{"name":"Destroy","desc":"Destroys the Signal. The Signal cannot be used after this is called.","params":[],"returns":[],"function_type":"method","source":{"line":83,"path":"src/Signal.lua"}}],"properties":[{"name":"BindableEvent","desc":"","lua_type":"BindableEvent","private":true,"readonly":true,"source":{"line":23,"path":"src/Signal.lua"}}],"types":[],"name":"Signal","desc":"Signals allow you to send events in-between controllers or signals, but not from services to controllers or vice-versa. They can be created using `Bridge.newSignal()`, for example:\\n```lua\\nlocal ReplicatedStorage = game:GetService(\\"ReplicatedStorage\\")\\nlocal Bridge = require(ReplicatedStorage.Bridge)\\n\\nlocal SomeController = Bridge.newController(script.Name)\\nSomeController.SomeSignal = Bridge.newSignal()\\n\\nreturn SomeController\\n```","source":{"line":14,"path":"src/Signal.lua"}}')}}]);