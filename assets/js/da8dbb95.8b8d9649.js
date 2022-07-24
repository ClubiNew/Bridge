"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[218],{44640:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Wraps the object in an Ancestor class. You can then index children and properties or call methods on the object or it\'s children that may be `nil` without throwing errors.","params":[{"name":"object","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"Ancestor"}],"function_type":"static","source":{"line":27,"path":"packages/ancestor/init.lua"}},{"name":"Or","desc":"Unwraps and returns the object, or the provided default if the object is `nil`.","params":[{"name":"default","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"any\\n"}],"function_type":"method","source":{"line":66,"path":"packages/ancestor/init.lua"}},{"name":"IfNil","desc":"Calls the provided function if the unwrapped object is `nil` and returns the wrapper for chain calls.","params":[{"name":"func","desc":"","lua_type":"() -> ()"}],"returns":[{"desc":"","lua_type":"Ancestor"}],"function_type":"method","source":{"line":74,"path":"packages/ancestor/init.lua"}},{"name":"IfNotNil","desc":"Calls the provided function with the unwrapped object if it is not `nil` and returns the wrapper for chain calls.","params":[{"name":"func","desc":"","lua_type":"(any) -> ()"}],"returns":[{"desc":"","lua_type":"Ancestor"}],"function_type":"method","source":{"line":83,"path":"packages/ancestor/init.lua"}}],"properties":[],"types":[],"name":"Ancestor","desc":"`Ancestor = \\"minstrix/ancestor@^0.1\\"`\\n\\nWraps instances to allow for easy handling of `nil` children, properties, or methods.\\n\\n```lua\\n-- without Ancestor\\nlocal character = player.Character\\nlocal humanoid = character and character.Humanoid\\nlocal health = humanoid and humanoid.Health or 0\\n\\n-- with Ancestor\\nlocal health = Ancestor(Player).Character.Humanoid.Health:Or(0)\\n```","source":{"line":17,"path":"packages/ancestor/init.lua"}}')}}]);