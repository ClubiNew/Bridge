-- methods used on normal tables and arrays
local Generic = {}

--[=[
    @within Table
    Returns a key/value pair from the given table that returns `true` when passed to the provided filter function.
]=]
function Generic.first<K, V>(tbl: { [K]: V }, filter: (key: K, value: V) -> boolean): (K, V)
    for key, value in tbl do
        if filter(key, value) then
            return key, value
        end
    end
end

--[=[
    @within Table
    Returns a new table without key/value pairs that return `false` when passed to the given filter function.
]=]
function Generic.filter<K, V>(tbl: { [K]: V }, filter: (key: K, value: V) -> boolean): { [K]: V }
    local filteredTable = {}

    for key, value in tbl do
        if filter(key, value) then
            filteredTable[key] = value
        end
    end

    return filteredTable
end

--[=[
    @within Table
    Returns a new table where `newTable[key] = map(key, oldTable[key])`.
]=]
function Generic.map<K, V>(tbl: { [K]: V }, map: (key: K, value: V) -> any): { [K]: any }
    local mappedTable = {}

    for key, value in tbl do
        mappedTable[key] = map(key, value)
    end

    return mappedTable
end

--[=[
    @within Table
    @return any -- the result of the final function call

    Calls the provided function for each element of a table with the previous result and the current element as arguments, starting with the `initialValue` as the previous result.

    ```lua
    local sum = Table.reduce({1, 2, 3}, 0, function(accumulator, index, value)
        return accumulator + value
    end)

    print(sum) --> 6
    ```
]=]
function Generic.reduce<K, V>(
    tbl: { [K]: V },
    initialValue: any,
    reduce: (accumulator: any, key: K, value: V) -> any
): any
    local accumulator = initialValue

    for key, value in tbl do
        accumulator = reduce(accumulator, key, value)
    end

    return accumulator
end

--[=[
    @within Table
    Returns the sum of the values in the given table.
]=]
function Generic.sum(tbl: { [any]: number }): number
    return Generic.reduce(tbl, 0, function(accumulator, _, value)
        return accumulator + value
    end)
end

--[=[
    @within Table
    Returns the maximum value in the given table, or `nil` if the table is empty.
]=]
function Generic.max(tbl: { [any]: number }): number?
    return Generic.reduce(tbl, nil, function(accumulator, _, value)
        if accumulator == nil or value > accumulator then
            return value
        else
            return accumulator
        end
    end)
end

--[=[
    @within Table
    Returns the minimum value in the given table, or `nil` if the table is empty.
]=]
function Generic.min(tbl: { [any]: number }): number?
    return Generic.reduce(tbl, nil, function(accumulator, _, value)
        if accumulator == nil or value < accumulator then
            return value
        else
            return accumulator
        end
    end)
end

--[=[
    @within Table
    @param deep boolean? -- defaults to `false`, will recursively clone sub-tables if `true`
    Clones the key/value pairs of the given table into a new table.
]=]
function Generic.clone(tbl: table, deep: boolean?): table
    local clone = {}

    for key, value in tbl do
        if deep and type(value) == "table" then
            clone[key] = Generic.clone(value, deep)
        else
            clone[key] = value
        end
    end

    return clone
end

--[=[
    @within Table
    Returns the key/value pairs of the given table.
]=]
function Generic.pairs<K, V>(tbl: { [K]: V }): { { key: K, value: V } }
    return Generic.reduce(tbl, {}, function(accumulator, key, value)
        table.insert(accumulator, {
            key = key,
            value = value,
        })

        return accumulator
    end)
end

--[=[
    @within Table
    Returns an array of the given table's keys.
]=]
function Generic.keys<T>(tbl: { [T]: any }): { T }
    return Generic.reduce(tbl, {}, function(accumulator, key, _)
        table.insert(accumulator, key)
        return accumulator
    end)
end

--[=[
    @within Table
    Returns an array of the given table's values.
    :::caution
    When called on a non-array table, this will return an array table. When called on a table that is already an array, the returned table will have the same keys, but values may be at different indices than they previously were.
    :::
]=]
function Generic.values<T>(tbl: { [any]: T }): { T }
    return Generic.reduce(tbl, {}, function(accumulator, _, value)
        table.insert(accumulator, value)
        return accumulator
    end)
end

--[=[
    @within Table
    Returns `true` if all elements return `true` when passed to the provided filter function.
]=]
function Generic.all(tbl: table, filter: (key: any, value: any) -> boolean): boolean
    return Generic.reduce(tbl, true, function(accumulator, key, value)
        return accumulator and filter(key, value)
    end)
end

return Generic
