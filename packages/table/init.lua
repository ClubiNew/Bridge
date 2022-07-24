--[=[
    @class Table
    `Table = "minstrix/table@^0.1"`

    A collection of functions for tables.

    :::note
    All functions except [Array.slice] will create new tables or otherwise not mutate the original table.
    :::
]=]
local Table = setmetatable({}, { __index = require(script:WaitForChild("Generic")) })

--[=[
    @prop Array Array
    @readonly
    @within Table
    A collection of functions specifically for array tables.
]=]
Table.Array = require(script:WaitForChild("Array"))

--[=[
    Behaves the same as [Array.random], but for non-array tables with potentially non-numeric keys.
]=]
function Table.random<K, V>(tbl: { [K]: V }): (K, V)
    local _, randomKey = Table.Array.random(Table.keys(tbl))
    return randomKey, tbl[randomKey]
end

--[=[
    Behaves the same as [Array.randomWeighted], but for non-array tables with potentially non-numeric keys.
]=]
function Table.randomWeighted<K, V>(tbl: { [K]: V }, weight: (key: K, value: V) -> number): (K, V)
    local _, randomPair = Table.Array.randomWeighted(Table.pairs(tbl), function(_, pair)
        return weight(pair.key, pair.value)
    end)

    return randomPair.key, randomPair.value
end

table.freeze(Table)
return Table
