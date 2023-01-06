
@with_kw struct Firm
    ID::Int
    q_obs::Number
    X::Vector{Float64}
    FE::Vector{Int64}
    Z::Vector{Float64}
end


@with_kw struct Tract
    ID::Int
    M::Float64
    inds::Vector{Int} 
    D::Matrix{Float64}  #n_firms, KD
    n_firms::Int 
    utils_pa::Matrix{Float64} # n_firms, nI #pre-allocated utilities/exp(utilities)/shares of individuals
    denom::Matrix{Float64}  #(1, nI)
    shares::Matrix{Float64} #(n_firms, 1)
    abδ::Matrix{Float64} #n_firms, nI
    q::Matrix{Float64}
end


@with_kw mutable struct EconomyPars
    K::Int
    nI::Int
    v::Matrix{Float64} #K, nI
    δs::Vector{Float64} #n_firms_ec
end


@with_kw struct Economy
    firms::Vector{Firm}
    tracts::Vector{Tract}
    q_obs::Vector{Float64} #nJ
end
