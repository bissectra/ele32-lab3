module Hamming

using Memoize
@memoize mask(len, j) = BitVector((i & (1 << j)) != 0 for i in 1:len)
function encode(data::BitVector)
    k = length(data)
    encoded = BitVector()
    index = 1
    included_count = 0
    parity_count = 0
    while included_count < k
        if ispow2(index)
            parity_count += 1
            push!(encoded, 0)
        else
            included_count += 1
            push!(encoded, data[included_count])
        end
        index += 1
    end

    n = length(encoded)

    # println("partially encoded: $encoded")

    for j in 0:parity_count-1
        masked = mask(n, j) .& encoded
        encoded[2^j] = xor(masked...)
    end

    return encoded
end



function error_correction(received::BitVector)
    n = length(received)
    p = prevpow(2, n)
    parity_count = round(Int, log2(p)) + 1
    syndrome = 0
    for j = 0:parity_count-1
        masked = mask(n, j) .& received
        if xor(masked...)
            syndrome += 1 << j
        end
    end
    syndrome == 0 && return received

    corrected = copy(received)
    corrected[syndrome] = !corrected[syndrome]

    return corrected
end

function decode(received::BitVector)
    n = length(received)
    transmitted_estimate = error_correction(received)
    mask = (!ispow2).(1:n)
    return transmitted_estimate[mask]
end
end