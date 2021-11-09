--!strict

local root = script.Parent.Parent

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(rgb1: {number}, rgb2: {number}, t: number, _: string?): (number, number, number)
    return
        lerp(rgb1[1], rgb2[1], t),
        lerp(rgb1[2], rgb2[2], t),
        lerp(rgb1[3], rgb2[3], t)
end