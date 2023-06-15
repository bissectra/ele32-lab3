include("./bit_flipping.jl")

function estimate_error_probability(encoder, channel, decoder, data_bits_count, data_length)
    word_count = round(Int, data_bits_count / data_length)
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