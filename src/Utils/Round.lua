--!strict

return function(n: number, optionalE: number?): number
    local e: number = optionalE or 0

    return math.floor((n / 10^e) + 0.5) * 10^e
end