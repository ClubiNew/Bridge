--[=[
    @class Array

    A collection of functions specifically for array tables, accessed via [Table.Array].

    :::note
    [Array] also inherits all of the functions available in [Table]. Functions marked with the override tag will override the functions in [Table].
    :::

    :::tip
    An array table is a table whose keys are consecutive integers beginning at 1.
    ```lua
    -- this is an array!
    local fruitArray = {"apples", "oranges", "bananas"}

    -- this is an array!
    local colorArray = {
        [1] = "red",
        [2] = "green",
        [3] = "blue",
    }

    -- this is not an array!
    local notAnArray = {
        [2] = "Tuesday",
        [4] = "Thursday",
        [6] = "Saturday",
    }
    ```
    :::
]=]

local RNG = Random.new(tick())
local Table = require(script.Parent)

local Array = setmetatable({}, { __index = Table })

--[=[
    @tag override
    Returns the index and value of the first element in the array that returns `true` when passed to the given filter function.
]=]
function Array.first<T>(array: { T }, filter: (index: number, value: T) -> boolean): (number, T)
    for index, value in ipairs(array) do
        if filter(index, value) then
            return index, value
        end
    end
end

--[=[
    @tag override

    Returns a new array consisting only of elements that return `true` when passed to the provided filter function.

    :::caution
    Valid values will be added to the end of the new array to preserve the consecutive integer keys. This means that the values are not guarantee to have the same keys after filtering. If you need to preserve the keys but not the array structure, use [Table.filter].
    :::
]=]
function Array.filter<T>(array: { T }, filter: (index: number, value: T) -> boolean): { T }
    local filteredArray: { T } = {}

    for index, value in ipairs(array) do
        if filter(index, value) then
            table.insert(filteredArray, value)
        end
    end

    return filteredArray
end

--[=[
    @param fromIndex number? -- defaults to 1
    Returns a new array consisting of `numElements` values from the given array, starting at `fromIndex`.
]=]
function Array.range<T>(array: { T }, numElements: number, fromIndex: number?): { T }
    fromIndex = if fromIndex then fromIndex else 1

    local rangeArray: { T } = {}
    table.move(array, fromIndex, fromIndex + numElements - 1, 1, rangeArray)

    return rangeArray
end

--[=[
    @param fromIndex number? -- defaults to 1

    Removes `numElements` values from the given array, starting at `fromIndex`, and returns them.

    :::caution
    Unlike other methods, [Array.slice] will mutate the given array.
    :::
]=]
function Array.slice<T>(array: { T }, numElements: number, fromIndex: number?): { T }
    fromIndex = if fromIndex then fromIndex else 1
    local slicedArray: { T } = {}

    for index = fromIndex, fromIndex + numElements - 1 do
        table.insert(slicedArray, table.remove(array, index))
    end

    return slicedArray
end

--[=[
    Short for "fold right", performs the same function as [Table.reduce] but begins at index 1 and counts upwards to `#array`.
]=]
function Array.foldr<T>(
    array: { T },
    initialValue: any,
    reduce: (accumulator: any, index: number, value: T) -> any
): any
    local accumulator = initialValue

    for index, value in ipairs(array) do
        accumulator = reduce(accumulator, index, value)
    end

    return accumulator
end

--[=[
    Short for "fold left", performs the same function as [Table.reduce] but begins at index `#array` and counts down to 1.
]=]
function Array.foldl<T>(
    array: { T },
    initialValue: any,
    reduce: (accumulator: any, index: number, value: T) -> any
): any
    local accumulator = initialValue

    for index = #array, 1, -1 do
        accumulator = reduce(accumulator, index, array[index])
    end

    return accumulator
end

--[=[
    Returns a new array consisting of the values of the given array, in reverse order.
]=]
function Array.reverse<T>(array: { T }): { T }
    local reversedArray: { T } = {}

    for index = #array, 1, -1 do
        table.insert(reversedArray, array[index])
    end

    return reversedArray
end

--[=[
    @tag override
    Selects a random element from the given array and returns it's index and value.
]=]
function Array.random<T>(array: { T }): (number, T)
    local randomIndex = RNG:NextInteger(1, #array)
    return randomIndex, array[randomIndex]
end

--[=[
    @tag override
    @param weight function(index: number, value: T) -> integer >= 1

    Calls the given `weight` function on each element to determine it's weight, and then selects a random element based on the weights and returns it's index and value.

    :::tip
    It is recommended that the weight function's return be the number of "standard" elements that element is "worth".
    :::
]=]
function Array.randomWeighted<T>(array: { T }, weight: (index: number, value: any) -> number): (number, T)
    local totalWeights = 0
    local weights = {}

    for index, value in ipairs(array) do
        local weight = weight(index, value)
        totalWeights += weight
        table.insert(weights, totalWeights)
    end

    local randomWeight = RNG:NextInteger(1, totalWeights)
    totalWeights = 0

    for index, weight in ipairs(weights) do
        totalWeights += weight
        if totalWeights >= randomWeight then
            return index, array[index]
        end
    end
end

--[=[
    Shuffles the given array into a new array.
]=]
function Array.shuffle<T>(array: { T }): { T }
    local indices: { number } = Array.keys(array)
    local shuffledArray: { T } = {}

    while #indices > 0 do
        local randomIndex = RNG:NextInteger(1, #indices)
        table.insert(array[indices[randomIndex]], table.remove(indices, randomIndex))
    end

    return shuffledArray
end

--[=[
    @param deep boolean? -- defaults to `false`, will recursively flatten sub-arrays if `true`

    Flattens an array of tables into a single array.

    ```lua
    local matrix = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
    }

    local flattenedArray = Array.flatten(matrix)
    print(flattenedArray) --> {1, 2, 3, 4, 5, 6, 7, 8, 9}
    ```
]=]
function Array.flatten(array: { any }, deep: boolean?): { any }
    return Array.foldr(array, {}, function(accumulator, value)
        if deep and typeof(value) == "table" then
            for _, subValue in ipairs(Array.flatten(value, deep)) do
                table.insert(accumulator, subValue)
            end
        else
            table.insert(accumulator, value)
        end

        return accumulator
    end)
end

table.freeze(Array)
return Array
