"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[823],{57387:function(e){e.exports=JSON.parse('{"functions":[{"name":"newSignal","desc":"","params":[],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"static","source":{"line":21,"path":"src/BridgeClient.lua"}},{"name":"newController","desc":"","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Controller"}],"function_type":"static","source":{"line":45,"path":"src/BridgeClient.lua"}},{"name":"toController","desc":"Get another controller to access it\'s methods. Must run `BridgeClient.Deploy()` first.","params":[{"name":"controllerName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Controller"}],"function_type":"static","source":{"line":74,"path":"src/BridgeClient.lua"}},{"name":"toService","desc":"Used to access the remotes and methods within the `.Bridge` of a service. Safe to call immediately, but may yield if the server has not finished deploying.","params":[{"name":"serviceName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Service"}],"function_type":"static","source":{"line":94,"path":"src/BridgeClient.lua"}},{"name":"addGlobalInboundMiddleware","desc":"Add global inbound middleware, which will run before any method of any controller is called. Note that global inbound middleware always runs first.","params":[{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":152,"path":"src/BridgeClient.lua"}},{"name":"addGlobalOutboundMiddleware","desc":"Add global outbound middleware, which will run after any method of any controller is called. Note that global outbound middleware always runs last.","params":[{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":163,"path":"src/BridgeClient.lua"}},{"name":"addInboundMiddleware","desc":"Add inbound middleware to the provided controller, which will run before any method of that controller is called.","params":[{"name":"Controller","desc":"","lua_type":"Controller"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":175,"path":"src/BridgeClient.lua"}},{"name":"addOutboundMiddleware","desc":"Add outbound middleware to the provided controller, which will run after any method of that controller is called.","params":[{"name":"Controller","desc":"","lua_type":"Controller"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":187,"path":"src/BridgeClient.lua"}},{"name":"deploy","desc":"Initialize, construct and deploy all controllers.","params":[{"name":"verbose","desc":"","lua_type":"boolean?"}],"returns":[],"function_type":"static","source":{"line":210,"path":"src/BridgeClient.lua"}}],"properties":[],"types":[{"name":"Controller","desc":"The construct function is run during deployment for each service asynchronously. The deploy function is run during deployment for all services synchronously. It is safe to access other services after the construct function has run.","fields":[{"name":"Construct","lua_type":"function?","desc":""},{"name":"Deploy","lua_type":"function?","desc":""},{"name":"...","lua_type":"Signal | function | any","desc":""}],"source":{"line":38,"path":"src/BridgeClient.lua"}},{"name":"Service","desc":"","fields":[{"name":"...","lua_type":"Remote | function","desc":""}],"source":{"line":86,"path":"src/BridgeClient.lua"}},{"name":"MiddlewareFunction","desc":"All middleware functions are given the controller name, method name and the arguments being passed to or returned from the method. To block the method from running or returning, simply throw an error. The middleware should return the arguments with any changes to be used by other middleware and the method.","lua_type":"(controllerName: string, methodName: string, args: any) -> any","source":{"line":145,"path":"src/BridgeClient.lua"}}],"name":"BridgeClient","desc":"","realm":["Client"],"source":{"line":12,"path":"src/BridgeClient.lua"}}')}}]);