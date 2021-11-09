--!strict

local root = script.Parent.Parent

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(cmyk1: {number}, cmyk2: {number}, t: number, _: string?): (number, number, number, number)
    return
        lerp(cmyk1[1], cmyk2[1], t),
        lerp(cmyk1[2], cmyk2[2], t),
        lerp(cmyk1[3], cmyk2[3], t),
        lerp(cmyk1[4], cmyk2[4], t)
end