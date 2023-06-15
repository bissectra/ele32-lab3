function round_to_multiple(x, m, log=true)
    new_value = round(Int, x / m) * m
    !log || new_value == x || println("Warning: rounding $x to $new_value")
    return new_value
end

logrange(x1, x2, n) = (10^y for y in range(log10(x1), log10(x2), length=n))