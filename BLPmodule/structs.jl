
@with_kw mutable struct Firm
    ID::String
    q_obs::Number = 0
    tracts::Vector{Int} = [0]
    X::Matrix{Float64} = zeros(1,1)
    D::VecOrMat{Float64} = [0.]
    q_iter::Number = 0
    δ::Float64 = 0.
end


@with_kw mutable struct Tract
    ID::Int
    M::Number = 0
    firms::Vector{Firm} = []
    D::VecOrMat{Float64} = [0.]
    shares::Vector{Float64} = [0.]
    quantities::Vector{Float64} = [0.]
    n_firms::Int = 0 
    exp_utils::Matrix{Float64} = ones(1,1) #will be nI by nfirms

    # exp_u::Vector{Float64}
    # TODO: check lengths
end


# function market_shares!(s, params...)
    # m.distances ... 
    # m.pre-allocated-shares .= exp.(delta .+ m.d .* θγ₁ .+ m.d2 .* θγ₂)
    
    # look into whether @unpack works with dot equals-allocated stuff. 

@with_kw struct EconomyPars
    K::Int = 0
    nI::Int = 0
    v::Matrix{Float64} = zeros(1,1)
    β::Vector{Float64} = [0.]
    σ::Vector{Float64} = [0.]
    δ0::VecOrMat{Float64} = [0.]
end


@with_kw mutable struct Economy
    firms::Vector{Firm}
    tracts::Vector{Tract}
    pars::EconomyPars
end

