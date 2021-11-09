--!strict

local root = script.Parent.Parent

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(xyz1: {number}, xyz2: {number}, t: number, _: string?): (number, number, number)
    return
        lerp(xyz1[1], xyz2[1], t),
        lerp(xyz1[2], xyz2[2], t),
        lerp(xyz1[3], xyz2[3], t)
end