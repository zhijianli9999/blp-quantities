
function make_Economy(
    firm_IDs_long,
    tract_IDs_long::Vector,
    X::VecOrMat{Float64},
    D::VecOrMat{Float64},
    Q::Vector,
    M::Vector,
    pars::EconomyPars
    )
    """Outer constructor that takes in data to create Firm and Tract objects"""
    # initialize vectors of firms and tracts
    firm_IDs = String.(unique(firm_IDs_long))
    firms = [Firm(ID = j) for j in firm_IDs]
    tract_IDs = unique(tract_IDs_long)
    tracts = [Tract(ID = t) for t in tract_IDs]

    # create firms 
    for i in eachindex(firm_IDs)
        j = firm_IDs[i]
        j_selector = j .== firm_IDs_long

        firms[i].q_obs = Q[j_selector][1]
        firms[i].tracts = tract_IDs_long[j_selector]
        firms[i].X = X[j_selector, :]
        firms[i].D = D[j_selector, :]
        firms[i].q_iter = 0
        firms[i].δ = 0
    end

    # create tracts 
    for i in eachindex(tract_IDs)
        t = tract_IDs[i]
        t_selector = t .== tract_IDs_long
        firms_in_t = firm_IDs_long[t_selector]
        nfirms = length(t_selector)

        tracts[i].M = M[t_selector][1]
        tracts[i].firms = [j for j in firms if (j.ID in firms_in_t)]
        tracts[i].D = D[t_selector, :]
        tracts[i].shares = ones(nfirms)
        tracts[i].quantities = ones(nfirms)
        tracts[i].n_firms = nfirms
        tracts[i].exp_utils = ones(pars.nI, (nfirms+1))
    end
    
    println("Economy with ", length(firms), " firms and ", length(tracts), " tracts.")

    return Economy(
            firms = firms,
            tracts = tracts,
            pars = pars
        )

end


function set_Pars(K::Int, nI::Int)
    # K: number of non-linear characteristics, 
    # nI: number of draws
    return EconomyPars(
            K = K,
            nI = nI,
            v = rand(Normal(0,1), K, nI),
            β = zeros(K),
            σ = zeros(K),
            δ0 = zeros(1, nI)
        )
end