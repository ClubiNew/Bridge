"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[341],{17958:function(e){e.exports=JSON.parse('{"functions":[{"name":"new","desc":"","params":[],"returns":[{"desc":"","lua_type":"Remote"}],"function_type":"static","realm":["Server"],"private":true,"source":{"line":38,"path":"src/Remote.lua"}},{"name":"Is","desc":"Returns `true` if the passed table is a Remote.","params":[{"name":"remote","desc":"","lua_type":"table"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","private":true,"source":{"line":53,"path":"src/Remote.lua"}},{"name":"FireClient","desc":"Fire the remote for the given player and any server scripts connected to the remote with the given arguments.","params":[{"name":"Player","desc":"","lua_type":"Player"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","realm":["Server"],"source":{"line":65,"path":"src/Remote.lua"}},{"name":"FireAllClients","desc":"Fire the remote for all players and any server scripts connected to the remote with the given arguments.","params":[{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","realm":["Server"],"source":{"line":79,"path":"src/Remote.lua"}},{"name":"Connect","desc":"Connect the remote to the provided function.","params":[{"name":"f","desc":"","lua_type":"function"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection"}],"function_type":"method","source":{"line":91,"path":"src/Remote.lua"}},{"name":"Wait","desc":"Waits for the remote to be fired and returns the arguments it was fired with.","params":[],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","source":{"line":101,"path":"src/Remote.lua"}}],"properties":[{"name":"RemoteEvent","desc":"","lua_type":"RemoteEvent","private":true,"readonly":true,"source":{"line":23,"path":"src/Remote.lua"}},{"name":"BindableEvent","desc":"","lua_type":"BindableEvent","private":true,"readonly":true,"source":{"line":30,"path":"src/Remote.lua"}}],"types":[],"name":"Remote","desc":"Remotes allow you to send signals from the server to the client. They can be created in the bridge of a service, for example:\\n```lua\\nlocal ReplicatedStorage = game:GetService(\\"ReplicatedStorage\\")\\nlocal Bridge = require(ReplicatedStorage.Bridge)\\n\\nlocal SomeService = Bridge.newService(script.Name)\\nSomeService.Bridge.SomeRemote = Bridge.newRemote()\\n\\nreturn SomeService\\n```","source":{"line":14,"path":"src/Remote.lua"}}')}}]);