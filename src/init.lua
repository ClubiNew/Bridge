if game:GetService("RunService"):IsServer() then
    return require(script:WaitForChild("BridgeServer"))
else
    return require(script:WaitForChild("BridgeClient"))
end