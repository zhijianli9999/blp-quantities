
function make_Economy(
    firm_IDs_long,
    tract_IDs_long::Vector,
    X::Matrix{Float64},
    D::Matrix{Float64},
    Q::Vector,
    M::Vector,
    pars::EconomyPars
    )
    """Outer constructor that takes in data to create Firm and Tract objects"""
    # initialize vectors of firms 
    firm_IDs = String.(unique(firm_IDs_long))
    n_firms_ec = length(firm_IDs)
    firms = Array{Firm}(undef, n_firms_ec)

    @unpack K, nI, v, β, σ, nlcoefs = pars
    # create firms 
    for i in 1:n_firms_ec
        j = firm_IDs[i]
        j_selector = j .== firm_IDs_long
        nt = length(j_selector) #number of tracts served by this firm
        firms[i] = Firm(
            ID = j, 
            q_obs = Q[j_selector][1], 
            X = X[j_selector, :],
            D = D[j_selector, :]
        )
    end

    # initialize vectors of tracts 
    tract_IDs = unique(tract_IDs_long)
    n_tracts_ec = length(tract_IDs)
    tracts = Array{Tract}(undef, length(tract_IDs))
    for i in eachindex(tract_IDs)
        t = tract_IDs[i] #ID of the tract
        t_selector = t .== tract_IDs_long #bitvector - which rows in df belong to this tract
        firms_in_t = firm_IDs_long[t_selector] # IDs of firms in tract
        n_firms = sum(t_selector) # number of firms in tract 
        tracts[i] = Tract(
            ID = t, 
            M = M[t_selector][1], #market size. can just take the first one since all the same in df.
            inds = [i for i in 1:n_firms_ec if in(firms[i].ID, firms_in_t)], # indices of this tract's firms among all firms
            firms = [j for j in firms if in(j.ID, firms_in_t)],
            D = D[t_selector, :],
            q = ones(n_firms), #quantity from this tract to the firms in this tract
            n_firms = n_firms,
            utils = zeros(n_firms, nI),
            exputils = ones(n_firms, nI),
            abδ = zeros(n_firms, nI)
        )
    end

    println("Economy with ", length(firms), " firms and ", length(tracts), " tracts.")

    return Economy(
            firms = firms,
            tracts = tracts,
            pars = pars,
            δs = zeros(n_firms_ec, 1),
            q_mat = zeros(n_firms_ec, n_tracts_ec) # nJ by nT matrix to store iterated quantities
        )
end


function set_Pars(;K::Int, nI::Int, β::Vector{Float64})
    # K: number of non-linear characteristics, 
    # nI: number of draws
    v = randn(K, nI)
    σ = ones(K)
    nlcoefs = (v .* σ) .+ β
    return EconomyPars(
            K,
            nI,
            v,
            β,
            σ,
            nlcoefs #K, nI
        )
end