
@with_kw mutable struct Firm
    ID::String
    q_obs::Number = 0
    X::Matrix{Float64} = zeros(1,1)
    D::Matrix{Float64} = zeros(1,1)
end


@with_kw mutable struct Tract
    ID::Int
    M::Number = 0
    firmIDs::Vector = [0]
    inds::Vector{Int} = []
    firms::Vector{Firm} = []
    D::Matrix{Float64} = zeros(1,1)
    shares::Vector{Float64} = [0.]
    n_firms::Int = 0 
    utils::Matrix{Float64} = zeros(1,1) #will be nI by n_firms
    exp_utils::Matrix{Float64} = ones(1,1) #will be nI by n_firms
end


# @unpack 


@with_kw mutable struct EconomyPars
    K::Int = 0
    nI::Int = 0
    v::Matrix{Float64} = zeros(1,1)
    β::Vector{Float64} = [0.]
    σ::Vector{Float64} = [0.]
    nlcoefs::Matrix{Float64} = zeros(1,1)
end


@with_kw mutable struct Economy
    firms::Vector{Firm}
    tracts::Vector{Tract}
    pars::EconomyPars
    δs::Matrix{Float64}
    q_mat::Matrix{Float64}
end

