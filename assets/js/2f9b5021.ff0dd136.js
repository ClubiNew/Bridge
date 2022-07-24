"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[806],{57160:e=>{e.exports=JSON.parse('{"functions":[{"name":"first","desc":"Returns the index and value of the first element in the array that returns `true` when passed to the given filter function.","params":[{"name":"array","desc":"","lua_type":"{ T }"},{"name":"filter","desc":"","lua_type":"(index: number, value: T) -> boolean"}],"returns":[{"desc":"","lua_type":"number"},{"desc":"","lua_type":"T"}],"function_type":"static","tags":["override"],"source":{"line":40,"path":"packages/table/Array.lua"}},{"name":"filter","desc":"Returns a new array consisting only of elements that return `true` when passed to the provided filter function.\\n\\n:::caution\\nValid values will be added to the end of the new array to preserve the consecutive integer keys. This means that the values are not guarantee to have the same keys after filtering. If you need to preserve the keys but not the array structure, use [Table.filter].\\n:::","params":[{"name":"array","desc":"","lua_type":"{ T }"},{"name":"filter","desc":"","lua_type":"(index: number, value: T) -> boolean"}],"returns":[{"desc":"","lua_type":"{ T }\\n"}],"function_type":"static","tags":["override"],"source":{"line":57,"path":"packages/table/Array.lua"}},{"name":"range","desc":"Returns a new array consisting of `numElements` values from the given array, starting at `fromIndex`.","params":[{"name":"array","desc":"","lua_type":"{ T }"},{"name":"numElements","desc":"","lua_type":"number"},{"name":"fromIndex","desc":"defaults to 1","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"{ T }\\n"}],"function_type":"static","source":{"line":73,"path":"packages/table/Array.lua"}},{"name":"slice","desc":"Removes `numElements` values from the given array, starting at `fromIndex`, and returns them.\\n\\n:::caution\\nUnlike other methods, [Array.slice] will mutate the given array.\\n:::","params":[{"name":"array","desc":"","lua_type":"{ T }"},{"name":"numElements","desc":"","lua_type":"number"},{"name":"fromIndex","desc":"defaults to 1","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"{ T }\\n"}],"function_type":"static","source":{"line":91,"path":"packages/table/Array.lua"}},{"name":"foldr","desc":"Short for \\"fold right\\", performs the same function as [Table.reduce] but begins at index 1 and counts upwards to `#array`.","params":[{"name":"array","desc":"","lua_type":"{ T }"},{"name":"initialValue","desc":"","lua_type":"any"},{"name":"reduce","desc":"","lua_type":"(accumulator: any, index: number, value: T) -> any\\n"}],"returns":[{"desc":"","lua_type":"any\\n"}],"function_type":"static","source":{"line":105,"path":"packages/table/Array.lua"}},{"name":"foldl","desc":"Short for \\"fold left\\", performs the same function as [Table.reduce] but begins at index `#array` and counts down to 1.","params":[{"name":"array","desc":"","lua_type":"{ T }"},{"name":"initialValue","desc":"","lua_type":"any"},{"name":"reduce","desc":"","lua_type":"(accumulator: any, index: number, value: T) -> any\\n"}],"returns":[{"desc":"","lua_type":"any\\n"}],"function_type":"static","source":{"line":122,"path":"packages/table/Array.lua"}},{"name":"reverse","desc":"Returns a new array consisting of the values of the given array, in reverse order.","params":[{"name":"array","desc":"","lua_type":"{ T }"}],"returns":[{"desc":"","lua_type":"{ T }\\n"}],"function_type":"static","source":{"line":139,"path":"packages/table/Array.lua"}},{"name":"random","desc":"Selects a random element from the given array and returns it\'s index and value.","params":[{"name":"array","desc":"","lua_type":"{ T }"}],"returns":[{"desc":"","lua_type":"number"},{"desc":"","lua_type":"T"}],"function_type":"static","tags":["override"],"source":{"line":153,"path":"packages/table/Array.lua"}},{"name":"randomWeighted","desc":"Calls the given `weight` function on each element to determine it\'s weight, and then selects a random element based on the weights and returns it\'s index and value.\\n\\n:::tip\\nIt is recommended that the weight function\'s return be the number of \\"standard\\" elements that element is \\"worth\\".\\n:::","params":[{"name":"array","desc":"","lua_type":"{ T }"},{"name":"weight","desc":"","lua_type":"function(index: number, value: T) -> integer >= 1"}],"returns":[{"desc":"","lua_type":"number"},{"desc":"","lua_type":"T"}],"function_type":"static","tags":["override"],"source":{"line":168,"path":"packages/table/Array.lua"}},{"name":"shuffle","desc":"Shuffles the given array into a new array.","params":[{"name":"array","desc":"","lua_type":"{ T }"}],"returns":[{"desc":"","lua_type":"{ T }\\n"}],"function_type":"static","source":{"line":192,"path":"packages/table/Array.lua"}},{"name":"flatten","desc":"Flattens an array of tables into a single array.\\n\\n```lua\\nlocal matrix = {\\n    {1, 2, 3},\\n    {4, 5, 6},\\n    {7, 8, 9},\\n}\\n\\nlocal flattenedArray = Array.flatten(matrix)\\nprint(flattenedArray) --\x3e {1, 2, 3, 4, 5, 6, 7, 8, 9}\\n```","params":[{"name":"array","desc":"","lua_type":"{ any }"},{"name":"deep","desc":"defaults to `false`, will recursively flatten sub-arrays if `true`","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"{ any }\\n"}],"function_type":"static","source":{"line":220,"path":"packages/table/Array.lua"}}],"properties":[],"types":[],"name":"Array","desc":"A collection of functions specifically for array tables, accessed via [Table.Array].\\n\\n:::note\\n[Array] also inherits all of the functions available in [Table]. Functions marked with the override tag will override the functions in [Table].\\n:::\\n\\n:::tip\\nAn array table is a table whose keys are consecutive integers beginning at 1.\\n```lua\\n-- this is an array!\\nlocal fruitArray = {\\"apples\\", \\"oranges\\", \\"bananas\\"}\\n\\n-- this is an array!\\nlocal colorArray = {\\n    [1] = \\"red\\",\\n    [2] = \\"green\\",\\n    [3] = \\"blue\\",\\n}\\n\\n-- this is not an array!\\nlocal notAnArray = {\\n    [2] = \\"Tuesday\\",\\n    [4] = \\"Thursday\\",\\n    [6] = \\"Saturday\\",\\n}\\n```\\n:::","source":{"line":32,"path":"packages/table/Array.lua"}}')}}]);