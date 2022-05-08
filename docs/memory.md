---
sidebar_position: 3
---

# Memory Tracking

Bridge sets [debugger](https://developer.roblox.com/en-us/api-reference/lua-docs/debug) memory categories so that you can track down memory leaks in your code.

Before calling the `:OnInit()` and `:OnStart()` methods of [services](/api/ServiceManager#Service), the memory category will be set to `NAME_Init` or `NAME_Start` respectively, where `NAME` is the service name.

This means you can easily and accurately determine memory usage for a service by opening the [developer console](https://developer.roblox.com/en-us/articles/Developer-Console), navigating to the memory tab, selecting client or server, and then searching the name of your service.
