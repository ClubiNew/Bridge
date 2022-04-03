"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[105],{64863:function(e){e.exports=JSON.parse('{"functions":[{"name":"newSignal","desc":"","params":[],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"static","source":{"line":27,"path":"src/BridgeServer.lua"}},{"name":"newRemote","desc":"","params":[],"returns":[{"desc":"","lua_type":"Remote"}],"function_type":"static","source":{"line":33,"path":"src/BridgeServer.lua"}},{"name":"newService","desc":"","params":[{"name":"name","desc":"","lua_type":"string"},{"name":"MiddlewarePriority","desc":"","lua_type":"MiddlewarePriority?"}],"returns":[{"desc":"","lua_type":"Service"}],"function_type":"static","source":{"line":80,"path":"src/BridgeServer.lua"}},{"name":"toService","desc":"Get another service to access it\'s methods. Must run `BridgeServer.Deploy()` first.","params":[{"name":"serviceName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Service"}],"function_type":"static","source":{"line":119,"path":"src/BridgeServer.lua"}},{"name":"addGlobalInboundMiddleware","desc":"Add global inbound middleware, which will run before any method of any service is called. Note that global inbound middleware always runs first.","params":[{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":147,"path":"src/BridgeServer.lua"}},{"name":"addGlobalOutboundMiddleware","desc":"Add global outbound middleware, which will run after any method of any service is called. Note that global outbound middleware always runs last.","params":[{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":158,"path":"src/BridgeServer.lua"}},{"name":"addInboundMiddleware","desc":"Add universal inbound middleware to the provided service, which will run before any method of that service is called.","params":[{"name":"Service","desc":"","lua_type":"Service"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":170,"path":"src/BridgeServer.lua"}},{"name":"addInboundClientMiddleware","desc":"Add client inbound middleware to the provided service, which will run before any client method of that service is called.","params":[{"name":"Service","desc":"","lua_type":"Service"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":182,"path":"src/BridgeServer.lua"}},{"name":"addInboundServerMiddleware","desc":"Add server inbound middleware to the provided service, which will run before any server method of that service is called.","params":[{"name":"Service","desc":"","lua_type":"Service"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":194,"path":"src/BridgeServer.lua"}},{"name":"addOutboundMiddleware","desc":"Add universal outbound middleware to the provided service, which will run after any method of that service is called.","params":[{"name":"Service","desc":"","lua_type":"Service"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":206,"path":"src/BridgeServer.lua"}},{"name":"addOutboundClientMiddleware","desc":"Add client outbound middleware to the provided service, which will run after any client method of that service is called.","params":[{"name":"Service","desc":"","lua_type":"Service"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":218,"path":"src/BridgeServer.lua"}},{"name":"addOutboundServerMiddleware","desc":"Add server outbound middleware to the provided service, which will run after any server method of that service is called.","params":[{"name":"Service","desc":"","lua_type":"Service"},{"name":"middleware","desc":"","lua_type":"MiddlewareFunction"}],"returns":[],"function_type":"static","source":{"line":230,"path":"src/BridgeServer.lua"}},{"name":"deploy","desc":"Initialize, construct and deploy all services.","params":[{"name":"verbose","desc":"","lua_type":"boolean?"}],"returns":[],"function_type":"static","source":{"line":253,"path":"src/BridgeServer.lua"}}],"properties":[{"name":"MiddlewarePriorities","desc":"","lua_type":"MiddlewarePriorities","readonly":true,"source":{"line":46,"path":"src/BridgeServer.lua"}}],"types":[{"name":"MiddlewarePriorities","desc":"","fields":[{"name":"UniversalFirst","lua_type":"userdata","desc":""},{"name":"UniversalLast","lua_type":"userdata","desc":""}],"source":{"line":40,"path":"src/BridgeServer.lua"}},{"name":"MiddlewarePriority","desc":"One of `BridgeServer.MiddlewarePriorities`. Use `UniversalFirst` to have universal middleware run before client/server middleware and `UniversalLast` to have client/server middleware run before universal middleware.","lua_type":"userdata","source":{"line":52,"path":"src/BridgeServer.lua"}},{"name":"Service","desc":"Remotes and methods within the `Bridge` are accessible by clients! The construct function is run during deployment for each service asynchronously. The deploy function is run during deployment for all services synchronously. It is safe to access other controllers after the construct function has run.","fields":[{"name":"Bridge","lua_type":"{Remote | function}","desc":""},{"name":"Construct","lua_type":"function?","desc":""},{"name":"Deploy","lua_type":"function?","desc":""},{"name":"...","lua_type":"Signal | function | any","desc":""}],"source":{"line":72,"path":"src/BridgeServer.lua"}},{"name":"MiddlewareFunction","desc":"All middleware functions are given the service name, method name and the arguments being passed to or returned from the method. To block the method from running or returning, simply throw an error. The middleware should return the arguments with any changes to be used by other middleware and the method.","lua_type":"(serviceName: string, methodName: string, args: any) -> any","source":{"line":140,"path":"src/BridgeServer.lua"}}],"name":"BridgeServer","desc":"","realm":["Server"],"source":{"line":13,"path":"src/BridgeServer.lua"}}')}}]);