
function make_Economy(
    firm_IDs_long,
    tract_IDs_long::Vector,
    X::Matrix{Float64},
    Z::Matrix{Float64},
    D::Matrix{Float64},
    Q::Vector,
    M::Vector,
    nI::Int
    )
    """Outer constructor that takes in data to create Firm and Tract objects"""
    # initialize vectors of firms 
    firm_IDs = String.(unique(firm_IDs_long))
    n_firms_ec = length(firm_IDs)
    firms = Array{Firm}(undef, n_firms_ec)

    # @unpack K, nI, v, β, σ = pars
    # create firms 
    Threads.@threads for i in 1:n_firms_ec
        j = firm_IDs[i]
        j_selector = j .== firm_IDs_long
        nt = length(j_selector) #number of tracts served by this firm
        firms[i] = Firm(
            ID = j, 
            q_obs = Q[j_selector][1], 
            X = (X[j_selector, :])[1,:],
            Z = (Z[j_selector, :])[1,:],
            D = D[j_selector, :]
        )
    end

    # initialize vectors of tracts 
    tract_IDs = unique(tract_IDs_long)
    n_tracts_ec = length(tract_IDs)
    tracts = Array{Tract}(undef, length(tract_IDs))
    Threads.@threads for i in eachindex(tract_IDs)
        t = tract_IDs[i] #ID of the tract
        t_selector = t .== tract_IDs_long #bitvector - which rows in df belong to this tract
        firms_in_t = firm_IDs_long[t_selector] # IDs of firms in tract
        n_firms = sum(t_selector) # number of firms in tract 
        tracts[i] = Tract(
            ID = t, 
            M = M[t_selector][1], #market size. can just take the first one since all the same in df.
            inds = [i for i in 1:n_firms_ec if in(firms[i].ID, firms_in_t)], # indices of this tract's firms among all firms
            # firms = [j for j in firms if in(j.ID, firms_in_t)],
            D = D[t_selector, :],
            X = X[t_selector, :],
            Z = Z[t_selector, :],
            q = ones(n_firms, 1), #quantity from this tract to the firms in this tract
            n_firms = n_firms,
            utils = zeros(n_firms, nI),
            expu = ones(n_firms, nI),
            denom = ones(1, nI),
            share_i = ones(n_firms, nI),
            shares = ones(n_firms, 1),
            abδ = zeros(n_firms, nI)
        )
    end

    println("Economy with ", length(firms), " firms and ", length(tracts), " tracts.")
    
    return Economy(
            firms = firms,
            tracts = tracts,
            q_obs = [j.q_obs for j in firms]
        )
end


function set_Pars(;K::Int, nI::Int, δs::Matrix{Float64})
    # K: number of non-linear characteristics
    # nI: number of draws
    v = randn(K, nI) #standard normal
    return EconomyPars(
            K,
            nI,
            v,
            δs
        )
end

function create_indices(tracts, n_firms)
    # create some indices 
    j_indexer = [t.inds for t in tracts]

    # t_indexer[jj] is the vector of markets (i.e. their indices) served by facility jj
    t_indexer = [Int[] for _ in 1:n_firms]
    for tt in eachindex(tracts), ind in tracts[tt].inds
            push!(t_indexer[ind], tt)
    end

    # positionin[jj,tt] is firm jj's position in tract tt's vectors (e.g. the vector of market shares in tt)
    positionin = Matrix{Int}(undef, n_firms, length(tracts))
    for jj in 1:n_firms, tt in t_indexer[jj]
            positionin[jj,tt] = findall(x->x == jj, j_indexer[tt])[1]
    end

    return j_indexer, t_indexer, positionin
end