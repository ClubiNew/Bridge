---
sidebar_position: 3
---

# Memory Tracking

Bridge sets [debugger](https://developer.roblox.com/en-us/api-reference/lua-docs/debug) memory categories so that you can track down memory leaks in your code.

Before calling the `:Construct()` and `:Deploy()` methods of [services](/api/BridgeServer#Service) and [controllers](http://localhost:3000/Bridge/api/BridgeClient#Controller) the memory category will be set to `NAME_Construct` or `NAME_Deploy` respectively, where `NAME` is the controller or service name.

This means you can easily and accurately determine memory usage for a service or controller by opening the [developer console](https://developer.roblox.com/en-us/articles/Developer-Console), navigating to the memory tab, selecting client or server, and then searching the name of your controller or service.
