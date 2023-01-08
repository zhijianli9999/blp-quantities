
@with_kw struct Tract
    ID::Int
    M::Float64
    inds::Vector{Int} 
    D::Matrix{Float64}  #(n_firms, KD)
    n_firms::Int 
    utils_pa::Matrix{Float64} #(n_firms, nI) pre-allocated utilities/exp(utilities)/shares of individuals
    denom::Matrix{Float64}  #(1, nI)
    shares::Matrix{Float64} #(n_firms, 1)
    abδ::Matrix{Float64} #(n_firms, nI)
    q::Matrix{Float64}
end


@with_kw mutable struct EconomyPars
    K::Int #number of non-linear parameters
    nI::Int
    v::Matrix{Float64} #(K, nI)
    δs::Vector{Float64} #nJ
end


@with_kw struct Year
    tracts::Vector{Tract}
    q_obs::Vector{Float64} #nJ
    q_mat::Matrix{Float64} #(nT, nJ)
end


@with_kw struct Economy
    years::Vector{Year}
end


@with_kw mutable struct Vars
    tvar::Symbol
    jvar::Symbol
    xvars::Vector{Symbol}
    zvars::Vector{Symbol}
    fevars::Vector{Symbol}
    qvar::Symbol
    mvar::Symbol
    dvars::Vector{Symbol}
end