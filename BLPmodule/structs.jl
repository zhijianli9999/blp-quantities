

Base.@kwdef mutable struct Firm
    ID::String
    quantity::Number
    tracts::Vector{Int} 
    X::VecOrMat{Float64}
    D::VecOrMat{Float64}
    δ::Float64 
end


Base.@kwdef mutable struct Tract
    ID::Int
    M::Number
    firms::Vector{Firm}
    D::VecOrMat{Float64}
    shares::Vector{Float64}
    # exp_u::Vector{Float64}
end


# function market_shares!(s, params...)
    # m.distances ... 
    # m.pre-allocated-shares .= exp.(delta .+ m.d .* θγ₁ .+ m.d2 .* θγ₂)
    
    # look into whether @unpack works with dot equals-allocated stuff. 


Base.@kwdef mutable struct Economy
    J_set::Vector{Firm}
    T_set::Vector{Tract}
end


function make_Economy(
    J_IDs::Vector,
    T_IDs::Vector,
    X::VecOrMat{Float64},
    D::VecOrMat{Float64},
    Q::Vector,
    M::Vector
    )
    """Outer constructor that takes in data to create Firm and Tract objects"""

    # # check lengths
    # l = [
    #     length(J_IDs),
    #     length(T_IDs),
    #     size(X)[1],
    #     size(D)[1],
    #     length(Q),
    # ]
    # if !all(y->y==l[1], l)
    #     error("wrong lengths!")
    # end

    J_set_IDs = unique(J_IDs)
    J_set = []
    T_set_IDs = unique(T_IDs)
    T_set = []

    # create firms 
    for i in eachindex(J_set_IDs)
        j = J_set_IDs[i]
        j_selector = j .== J_IDs
        push!(J_set, Firm(
            ID = j,
            quantity = Q[j_selector][1],
            tracts = T_IDs[j_selector],
            X = X[j_selector, :],
            D = D[j_selector, :],
            δ = 0
        ))
    end

    # create tracts 
    for i in eachindex(T_set_IDs)
        t = T_set_IDs[i]
        t_selector = t .== T_IDs
        j_in_t = J_IDs[t_selector]
        push!(T_set, Tract(
            ID = t,
            M = M[t_selector][1],
            firms = [j for j in J_set if (j.ID in j_in_t)],
            D = D[t_selector, :],
            shares = ones(length(t_selector))
        ))
    end
    
    println("Economy with ", length(J_set), " firms and ", length(T_set), " tracts.")

    return Economy(
            J_set = J_set,
            T_set = T_set
        )

end
