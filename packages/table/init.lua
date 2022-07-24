--[=[
    @class Table
    `Table = "minstrix/table@^0.1"`

    A collection of functions for tables.

    :::note
    All functions except [Array.slice] will create new tables or otherwise not mutate the original table.
    :::
]=]

local Table = {}

--[=[
    @prop Array Array
    @readonly
    @within Table
    A collection of functions specifically for array tables.
]=]

Table.Array = require(script.Array)

--[=[
    Returns a key/value pair from the given table that returns `true` when passed to the provided filter function.
]=]
function Table.first<K, V>(table: { [K]: V }, filter: (key: K, value: V) -> boolean): (K, V)
    for key, value in table do
        if filter(key, value) then
            return key, value
        end
    end
end

--[=[
    Returns a new table without key/value pairs that return `false` when passed to the given filter function.
]=]
function Table.filter<K, V>(table: { [K]: V }, filter: (key: K, value: V) -> boolean): { [K]: V }
    local filteredTable = {}

    for key, value in table do
        if filter(key, value) then
            filteredTable[key] = value
        end
    end

    return filteredTable
end

--[=[
    Returns a new table where `newTable[key] = map(key, oldTable[key])`.
]=]
function Table.map<K, V>(table: { [K]: V }, map: (key: K, value: V) -> any): { [K]: any }
    local mappedTable = {}

    for key, value in table do
        mappedTable[key] = map(key, value)
    end

    return mappedTable
end

--[=[
    @return any -- the result of the final function call

    Calls the provided function for each element of a table with the previous result and the current element as arguments, starting with the `initialValue` as the previous result.

    ```lua
    local sum = Table.reduce({1, 2, 3}, 0, function(accumulator, index, value)
        return accumulator + value
    end)

    print(sum) --> 6
    ```
]=]
function Table.reduce<K, V>(
    table: { [K]: V },
    initialValue: any,
    reduce: (accumulator: any, key: K, value: V) -> any
): any
    local accumulator = initialValue

    for key, value in table do
        accumulator = reduce(accumulator, key, value)
    end

    return accumulator
end

--[=[
    Returns the sum of the values in the given table.
]=]
function Table.sum(table: { [any]: number }): number
    return Table.reduce(table, 0, function(accumulator, _, value)
        return accumulator + value
    end)
end

--[=[
    Returns the maximum value in the given table, or `nil` if the table is empty.
]=]
function Table.max(table: { [any]: number }): number?
    return Table.reduce(table, nil, function(accumulator, _, value)
        if accumulator == nil or value > accumulator then
            return value
        else
            return accumulator
        end
    end)
end

--[=[
    Returns the minimum value in the given table, or `nil` if the table is empty.
]=]
function Table.min(table: { [any]: number }): number?
    return Table.reduce(table, nil, function(accumulator, _, value)
        if accumulator == nil or value < accumulator then
            return value
        else
            return accumulator
        end
    end)
end

--[=[
    @param deep boolean? -- defaults to `false`, will recursively clone sub-tables if `true`
    Clones the key/value pairs of the given table into a new table.
]=]
function Table.clone(table: table, deep: boolean?): table
    local clone = {}

    for key, value in table do
        if deep and type(value) == "table" then
            clone[key] = Table.clone(value, deep)
        else
            clone[key] = value
        end
    end

    return clone
end

--[=[
    Returns the key/value pairs of the given table.
]=]
function Table.pairs<K, V>(table: { [K]: V }): { { key: K, value: V } }
    return Table.reduce(table, {}, function(accumulator, key, value)
        table.insert(accumulator, {
            key = key,
            value = value,
        })

        return accumulator
    end)
end

--[=[
    Returns an array of the given table's keys.
]=]
function Table.keys<T>(table: { [T]: any }): { T }
    return Table.reduce(table, {}, function(accumulator, key, _)
        table.insert(accumulator, key)
        return accumulator
    end)
end

--[=[
    Returns an array of the given table's values.
    :::caution
    When called on a non-array table, this will return an array table. When called on a table that is already an array, the returned table will have the same keys, but values may be at different indices than they previously were.
    :::
]=]
function Table.values<T>(table: { [any]: T }): { T }
    return Table.reduce(table, {}, function(accumulator, _, value)
        table.insert(accumulator, value)
        return accumulator
    end)
end

--[=[
    Returns `true` if all elements return `true` when passed to the provided filter function.
]=]
function Table.all(table: table, filter: (key: any, value: any) -> boolean): boolean
    return Table.reduce(table, true, function(accumulator, key, value)
        return accumulator and filter(key, value)
    end)
end

--[=[
    Behaves the same as [Array.random], but for non-array tables with potentially non-numeric keys.
]=]
function Table.random<K, V>(table: { [K]: V }): (K, V)
    local _, randomKey = require(script.Array).random(Table.keys(table))
    return randomKey, table[randomKey]
end

--[=[
    Behaves the same as [Array.randomWeighted], but for non-array tables with potentially non-numeric keys.
]=]
function Table.randomWeighted<K, V>(table: { [K]: V }, weight: (key: K, value: V) -> number): (K, V)
    local _, randomPair = require(script.Array).randomWeighted(Table.keys(table), function(_, pair)
        return weight(pair.key, pair.value)
    end)

    return randomPair.key, randomPair.value
end

table.freeze(Table)
return Table
