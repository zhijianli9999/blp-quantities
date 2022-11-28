
@with_kw struct Firm
    ID::String
    q_obs::Number 
    X::Matrix{Float64}  #nT,K
    D::Matrix{Float64}  #nT,K
end


@with_kw struct Tract
    ID::Int
    M::Float64 
    inds::Vector{Int} 
    firms::Vector{Firm} 
    D::Matrix{Float64}  #n_firms, K
    n_firms::Int 
    utils::Matrix{Float64} # n_firms, nI
    expu::Matrix{Float64}  # n_firms, nI
    denom::Matrix{Float64}  #(1, nI)
    share_i::Matrix{Float64} #(n_firms, nI)
    shares::Matrix{Float64} #(n_firms, 1)
    abδ::Matrix{Float64} 
    q::Matrix{Float64}
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
