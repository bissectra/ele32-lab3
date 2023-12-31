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

    tol = 0.05
    conf = 0.05

    function data_bits_count(p)
        ans = round(Int, (1 - p) / p / tol^2 / conf)
        println("data_bits_count($p) = $ans")
        return ans
    end

    probs = collect(logrange(0.00001, 0.1, 20))
    channels = [BinarySymmetricChannel(p) for p in probs]

    ## Hamming
    hamming_encoder, hamming_decoder, hamming_data_length = Hamming.encode, Hamming.decode, 4
    hamming_data_bits_count = data_bits_count
    get_hamm_error_prob(channel) = estimate_error_probability(hamming_encoder, channel, hamming_decoder, hamming_data_bits_count(channel.dist.p), hamming_data_length)
    hamming_bit_error_probs = get_hamm_error_prob.(channels)

    ## LDPC
    dv = 3
    dc = 7
    Ns = [100, 200, 500, 1000]
    max_iter = 100

    ldpc_bit_error_probs_array = []

    for N in Ns

        ldpc_encoder, ldpc_decoder, ldpc_data_length = regular_ldpc(dv, dc, N, max_iter)
        ldpc_data_bits_count = data_bits_count
        get_ldpc_error_prob(channel) = estimate_error_probability(ldpc_encoder, channel, ldpc_decoder, ldpc_data_bits_count(channel.dist.p), ldpc_data_length)
        ldpc_bit_error_probs = get_ldpc_error_prob.(channels)
        push!(ldpc_bit_error_probs_array, ldpc_bit_error_probs)
    end

    df = DataFrame(channel_prob=probs,
        hamming_bit_error_probs=hamming_bit_error_probs,
        ldpc_bit_error_probs_100=ldpc_bit_error_probs_array[1],
        ldpc_bit_error_probs_200=ldpc_bit_error_probs_array[2],
        ldpc_bit_error_probs_500=ldpc_bit_error_probs_array[3],
        ldpc_bit_error_probs_1000=ldpc_bit_error_probs_array[4])

    # save to csv
    CSV.write("assets/error_probability.csv", df)
end

function get_data()
    df = CSV.read("assets/error_probability.csv", DataFrame)
    return df
end