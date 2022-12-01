
@with_kw struct Firm
    ID::String
    q_obs::Number 
    X::Vector  #nT,K
    D::AbstractArray  #nT,K
end


@with_kw struct Tract
    ID::Int
    M::Real
    inds::Vector{Int} 
    firms::Vector{Firm} 
    D::AbstractArray  #n_firms, K
    n_firms::Int 
    utils::AbstractArray # n_firms, nI
    expu::AbstractArray  # n_firms, nI
    denom::AbstractArray  #(1, nI)
    share_i::AbstractArray #(n_firms, nI)
    shares::AbstractArray #(n_firms, 1)
    abδ::AbstractArray #n_firms, nI
    q::AbstractArray
end


@with_kw mutable struct EconomyPars
    K::Int
    nI::Int
    v::AbstractArray #K, nI
    δs::AbstractArray #n_firms_ec, 1
end

# σ #K

@with_kw struct Economy
    firms::Vector{Firm}
    tracts::Vector{Tract}
    q_obs::Vector #nJ
end
