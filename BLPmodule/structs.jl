
@with_kw struct Firm
    ID::String
    q_obs::Number
    X::Vector{Float64}  #nT,KX
    Z::Vector{Float64}  #nT,KZ
    D::Matrix{Float64}  #nT,KD
end


@with_kw struct Tract
    ID::Int
    M::Float64
    inds::Vector{Int} 
    # firms::Vector{Firm} 
    D::Matrix{Float64}  #n_firms, KD
    X::Matrix{Float64}  #n_firms, KX
    Z::Matrix{Float64}  #n_firms, KZ
    n_firms::Int 
    utils::Matrix{Float64} # n_firms, nI
    expu::Matrix{Float64}  # n_firms, nI
    denom::Matrix{Float64}  #(1, nI)
    share_i::Matrix{Float64} #(n_firms, nI)
    shares::Matrix{Float64} #(n_firms, 1)
    abδ::Matrix{Float64} #n_firms, nI
    q::Matrix{Float64}
end


@with_kw mutable struct EconomyPars
    K::Int
    nI::Int
    v::Matrix{Float64} #K, nI
    δs::Matrix{Float64} #n_firms_ec, 1
end

# σ #K

@with_kw struct Economy
    firms::Vector{Firm}
    tracts::Vector{Tract}
    q_obs::Vector{Float64} #nJ
end
