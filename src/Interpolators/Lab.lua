--!strict

local root = script.Parent.Parent

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(lab1: {number}, lab2: {number}, t: number, _: string?): (number, number, number)
    return
        lerp(lab1[1], lab2[1], t),
        lerp(lab1[2], lab2[2], t),
        lerp(lab1[3], lab2[3], t)
end