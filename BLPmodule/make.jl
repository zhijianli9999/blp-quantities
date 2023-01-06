
function make_Economy(
    firm_IDs_long,
    tract_IDs_long::Vector,
    X::Matrix{Float64},
    FE::Matrix{Int64},
    Z::Matrix{Float64},
    D::Matrix{Float64},
    Q::Vector,
    M::Vector,
    nI::Int
    )
    """Outer constructor that takes in data to create Firm and Tract objects"""
    # initialize vectors of firms 
    firm_IDs = unique(firm_IDs_long)
    n_firms_ec = length(firm_IDs)
    firms = Array{Firm}(undef, n_firms_ec)

    # @unpack K, nI, v, β, σ = pars
    # create firms 
    Threads.@threads for i in 1:n_firms_ec
        j = firm_IDs[i]
        j_selector = j .== firm_IDs_long
        firms[i] = Firm(
            ID = j, 
            q_obs = Q[j_selector][1], 
            X = (X[j_selector, :])[1,:],
            FE = (FE[j_selector, :])[1,:],
            Z = (Z[j_selector, :])[1,:]
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
            D = D[t_selector, :],
            q = ones(n_firms, 1), #quantity from this tract to the firms in this tract
            n_firms = n_firms,
            utils_pa = zeros(n_firms, nI),
            denom = ones(1, nI),
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


function set_Pars(;K::Int, nJ::Int, nI::Int=100)
    # K: number of non-linear characteristics
    # nI: number of draws
    v = randn(K, nI) #standard normal
    δs = ones(nJ)
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

    # JpositioninT[jj,tt] is firm jj's position in tract tt's vectors (e.g. the vector of market shares in tt)
    JpositioninT = Matrix{Int}(undef, n_firms, length(tracts))
    for jj in 1:n_firms, tt in t_indexer[jj]
        JpositioninT[jj,tt] = findall(x->x == jj, j_indexer[tt])[1]
    end

    TpositioninJ = Matrix{Int}(undef, length(tracts), n_firms)
    for tt in 1:length(tracts), jj in j_indexer[tt]
        TpositioninJ[tt,jj] = findall(x->x == tt, t_indexer[jj])[1]
    end

    return j_indexer, t_indexer, JpositioninT
end


function mean_inside_share(ec::Economy)
    # do this with the ec after compute_deltas()
    return mean([reduce(+,tt.shares) for tt in ec.tracts])
end