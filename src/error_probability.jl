using Random, DataFrames, CSV

include("./utils.jl")
include("./channel.jl")
include("./hamming.jl")
include("./bit_flipping.jl")

function estimate_error_probability(encoder, channel, decoder, data_bits_count, data_length)
    data_bits_count = round_to_multiple(data_bits_count, data_length, false)
    word_count = data_bits_count ÷ data_length
    wrong_bits_count = 0
    for _ in 1:word_count
        data = falses(data_length) # leverage the simmetry of the channel
        transmitted = encoder(data)
        received = channel(transmitted)
        decoded = decoder(received)
        wrong_bits_count += sum(data .⊻ decoded)
    end
    return wrong_bits_count / data_bits_count
end

function compute_data()
    Random.seed!(0)

    probs = collect(logrange(0.00001, 0.1, 15))
    channels = [BinarySymmetricChannel(p) for p in probs]

    ## Hamming
    hamming_encoder, hamming_decoder, hamming_data_length = Hamming.encode, Hamming.decode, 4
    hamming_data_bits_count(p) = 100_000 # FIXME: use Chebyshev's inequality to estimate this
    get_hamm_error_prob(channel) = estimate_error_probability(hamming_encoder, channel, hamming_decoder, hamming_data_bits_count(channel.dist.p), hamming_data_length)
    hamming_bit_error_probs = get_hamm_error_prob.(channels)

    ## LDPC
    dv = 3
    dc = 7
    N = 1000
    max_iter = 100

    ldpc_encoder, ldpc_decoder, ldpc_data_length = regular_ldpc(dv, dc, N, max_iter)
    ldpc_data_bits_count(p) = 10_000_000 # FIXME: use Chebyshev's inequality to estimate this
    get_ldpc_error_prob(channel) = estimate_error_probability(ldpc_encoder, channel, ldpc_decoder, ldpc_data_bits_count(channel.dist.p), ldpc_data_length)
    ldpc_bit_error_probs = get_ldpc_error_prob.(channels)

    df = DataFrame(channel_prob=probs, hamming_bit_error_probs=hamming_bit_error_probs, ldpc_bit_error_probs=ldpc_bit_error_probs)

    # save to csv
    CSV.write("data/error_probability.csv", df)
end

function get_data()
    df = CSV.read("data/error_probability.csv", DataFrame)
    return df
end