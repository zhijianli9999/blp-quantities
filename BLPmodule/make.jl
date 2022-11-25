
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
    # initialize vectors of firms and tracts
    firm_IDs = String.(unique(firm_IDs_long))
    n_firms_ec = length(firm_IDs)
    firms = Array{Firm}(undef, n_firms_ec)
    # # make a vector (firm) of vector (tract) of string to contain tract IDs
    # firms_tractIDs = Vector{Vector{typeof(tract_IDs_long[1])}}(undef, n_firms_ec)
    
    # create firms 
    for i in 1:n_firms_ec
        j = firm_IDs[i]
        j_selector = j .== firm_IDs_long
        # firms_tractIDs[i] = tract_IDs_long[j_selector]
        firms[i] = Firm(
            ID = j, 
            q_obs = Q[j_selector][1], 
            X = X[j_selector, :],
            D = D[j_selector, :]
        )
    end

    # create tracts (and fill in their firms)
    tract_IDs = unique(tract_IDs_long)
    tracts = Array{Tract}(undef, length(tract_IDs))
    for i in eachindex(tract_IDs)
        t = tract_IDs[i] #ID of the tract
        t_selector = t .== tract_IDs_long #bitvector - which rows in df belong to this tract
        firms_in_t = firm_IDs_long[t_selector] # IDs of firms in tract
        n_firms = sum(t_selector) # number of firms in tract 
        tracts[i] = Tract(
            ID = t, 
            M = M[t_selector][1], #market size. can just take the first one since all the same in df.
            firms = [j for j in firms if in(j.ID, firms_in_t)],
            inds = [i for i in 1:n_firms_ec if in(firms[i].ID, firms_in_t)], # indices of this tract's firms among all firms
            D = D[t_selector, :],
            shares = ones(n_firms)./n_firms,
            n_firms = n_firms,
            utils = zeros(pars.nI, (n_firms+1)),
            exp_utils = ones(pars.nI, (n_firms+1))
        )
    end


    println("Economy with ", length(firms), " firms and ", length(tracts), " tracts.")

    q_mat = zeros(n_firms_ec, length(tract_IDs))  # nJ by nT matrix to store iterated quantities

    return Economy(
            firms = firms,
            tracts = tracts,
            pars = pars,
            δs = zeros(n_firms_ec, 1),
            q_mat = q_mat
        )
end


function set_Pars(;K::Int, nI::Int, β::Vector{Float64})
    # K: number of non-linear characteristics, 
    # nI: number of draws
    v = rand(Normal(0,1), K, nI)
    σ = ones(K)
    return EconomyPars(
            K = K,
            nI = nI,
            v = v,
            β = β,
            σ = σ,
            nlcoefs = (v .* σ) .+ β #K by nI
        )
end