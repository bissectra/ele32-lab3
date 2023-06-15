using Random, DataFrames, CSV

include("./utils.jl")
include("./channel.jl")
include("./bit_flipping.jl")

function estimate_error_probability(encoder, channel, decoder, data_bits_count, data_length)
    data_bits_count = round_to_multiple(data_bits_count, data_length, false)
    word_count = data_bits_count ÷ data_length
    wrong_bits_count = 0
    for _ in 1:word_count
        data = falses(data_length)
        transmitted = encoder(data)
        received = channel(transmitted)
        decoded = decoder(received)
        wrong_bits_count += sum(data .⊻ decoded)
    end
    return wrong_bits_count / data_bits_count
end

function main()
    Random.seed!(0)

    dv = 3
    dc = 7
    N = 1000
    max_iter = 100
    data_bits_count(p) = 100_000 # FIXME: use Chebyshev's inequality to estimate this

    encoder, decoder, data_length = regular_ldpc(dv, dc, N, max_iter)

    probs = collect(logrange(0.00001, 0.1, 15))
    channels = [BinarySymmetricChannel(p) for p in probs]

    get_ldpc_error_prob(channel) = estimate_error_probability(encoder, channel, decoder, data_bits_count(channel.dist.p), data_length)

    ldpc_bit_error_probs = get_ldpc_error_prob.(channels)

    df = DataFrame(channel_prob=probs, ldpc_bit_error_probs=ldpc_bit_error_probs)

    # save to csv
    CSV.write("data/error_probability.csv", df)
end