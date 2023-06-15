using Random

function select_combination(elements, k)
    n = length(elements)
    combination = elements[randperm(n)][1:k]
    return combination
end

function randomize_connections(adjlist, radjlist)
    N, dv = size(adjlist)
    for v in 1:N
        available_cnodes = findall(radjlist[:, end] .== 0)
        neighbors = select_combination(available_cnodes, dv)

        # update adjlist
        adjlist[v, :] = neighbors

        # update radjlist
        for c in neighbors
            first_zero = findfirst(radjlist[c, :] .== 0)
            radjlist[c, first_zero] = v
        end
        # display(radjlist)
    end

    return adjlist, radjlist
end

function build_graph(dv, dc, N)
    # N v-nodes, each with dv edges
    # M c-nodes, each with dc edges

    ne = N * dv # = M * dc = number of edges
    @assert ne % dc == 0 "ne must be a multiple of dc"
    M = ne ÷ dc

    println("N = $N, M = $M, dv = $dv, dc = $dc")

    # declare a matrix with undefs
    adjlist = Matrix{Int}(undef, N, dv)
    radjlist = Matrix{Int}(undef, M, dc)

    while true
        try
            adjlist .= 0
            radjlist .= 0

            adjlist, radjlist = randomize_connections(adjlist, radjlist)
            break
        catch e
        end
    end

    return adjlist, radjlist
end

function build_parity_check_matrix(adjlist, radjlist)
    N, dv = size(adjlist)
    M, dc = size(radjlist)

    H = zeros(Int, M, N)

    for v in 1:N
        for c in adjlist[v, :]
            H[c, v] = 1
        end
    end

    return H
end

function bit_flipping(adj, radj, received, max_iter)
    N, dv = size(adj)
    M, dc = size(radj)
    @assert length(received) == N "received must have length N"

    r = copy(received)

    # initialize
    x = zeros(Int, N)
    y = zeros(Int, M)
    for i in 1:max_iter
        for c in 1:M
            y[c] = mod(sum(r[radj[c, :]]), 2) # red numbers
        end
        for v in 1:N
            x[v] = sum(y[adj[v, :]]) # green numbers
        end

        value, index = findmax(x)

        if value == 0
            break
        end

        r[index] = 1 - r[index]
    end
    return r
end

function decode(adj, radj, received, max_iter)
    N, dv = size(adj)
    M, dc = size(radj)
    K = N - M
    r = bit_flipping(adj, radj, received, max_iter)
    return r[1:K]
end