
@with_kw struct Firm
    ID::String
    q_obs::Number 
    X::Matrix{Float64}  #nT,K
    D::Matrix{Float64}  #nT,K
end


@with_kw struct Tract
    ID::Int
    M::Number 
    inds::Vector{Int} 
    firms::Vector{Firm} 
    D::Matrix{Float64}  #n_firms, K
    q::Vector{Float64}
    n_firms::Int 
    utils::Matrix{Float64} # n_firms, nI
    exputils::Matrix{Float64}  # n_firms, nI
    abδ::Matrix{Float64} 
end


# @unpack 


@with_kw struct EconomyPars
    K::Int 
    nI::Int
    v::Matrix{Float64}
    β::Vector{Float64}
    σ::Vector{Float64}
    nlcoefs::Matrix{Float64} #K,nI
end


@with_kw struct Economy
    firms::Vector{Firm}
    tracts::Vector{Tract}
    pars::EconomyPars
    δs::Matrix{Float64}
    q_mat::Matrix{Float64} #nJ, nT
end
