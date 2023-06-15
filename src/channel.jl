using Distributions

struct BinarySymmetricChannel
    dist::Distribution
    BinarySymmetricChannel(p::Float64) = new(Bernoulli(p))
end

function (channel::BinarySymmetricChannel)(data::BitVector)
    toggle = rand(channel.dist, length(data))
    return data .⊻ toggle
end
