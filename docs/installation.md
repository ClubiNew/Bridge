---
sidebar_position: 2
---

# Installation

The intended installation workflow is to install the modules you need using [Wally](https://github.com/UpliftGames/wally) packages and then synchronize the files into Roblox Studio using a tool like [Rojo](https://github.com/rojo-rbx/rojo).

The Wally dependency for each package can be found at the top of the [API](/api) page for that module. Packages are versioned using the [Semantic Versioning](https://semver.org/) system and you can see a full list of available versions by running `wally search minstrix/package-name`. It's always recommended that you use the most recent patch for your selected major/minor version to ensure you avoid any bugs.

If you are unable to use Wally + Rojo, you can also manually copy & paste the code from the [GitHub repository](https://github.com/ClubiNew/RbxPackages) directly into [module scripts](https://developer.roblox.com/en-us/api-reference/class/ModuleScript) in Roblox Studio.
