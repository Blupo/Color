--!strict

return function(n: number, e: number?): number
    e = e or 0

    return math.floor((n / 10^e) + 0.5) * 10^e
end