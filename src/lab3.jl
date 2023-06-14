function transmission_rate(N, dv, dc)
    M = N * dv / dc
    info_length = N
    transmission_length = N + M
    R = info_length / transmission_length
    return R
end

function transmission_rate(dv, dc)
    return dc / (dc + dv)
end

# Queremos taxa = 4 / 7. Logo, queremos dc = 4 e dv = 3.
# N / (N + M) = N / (N + N * dv / dc) = 1 / (1 + dv / dc) = dc / (dc + dv)