--!strict

local root = script.Parent.Parent

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(luv1: {number}, luv2: {number}, t: number, _: string?): (number, number, number)
    return
        lerp(luv1[1], luv2[1], t),
        lerp(luv1[2], luv2[2], t),
        lerp(luv1[3], luv2[3], t)
end