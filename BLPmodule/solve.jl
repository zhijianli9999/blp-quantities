
# BLP
# implied_shares with random coefficients
function shares(δ_, X, ζ, β)
    # Utility
    δ0 = zeros(1, size(ζ, 2))
    u = [δ_ .+ (X * (ζ .* β)); δ0]
    # println(mean(u))
    e = exp.(u)
    s = mean(e ./ sum(e, dims=1), dims=2)
    # s = mean(e, dims=2)
    
    # println("size(e)", size(e))
    # println("size(s)", size(s))
    return s[1:end-1]
end
# compute deltas, with RCs
function loop(s::Vector, X, ζ, β; verbose = false)::Vector
    """Compute delta given shares"""
    dist = 1
    counter = 0
    δ_ = ones(size(s))
    s_ = []
    while (dist > 1e-12 && counter <= 1000)
        s_ = shares(δ_, X, ζ, β)
        δ2_ = δ_ + log.(s) - log.(s_)
        # println("δ_: ", δ_, "\ns: ", s, "\nδ2_: ", δ2_)
        dist = maximum(abs.(δ2_ - δ_))
        # println("dist: ", dist)
        # println("counter: ", counter)
        δ_ = δ2_
        # print(δ_[1:6])
        # println("\n")
        counter+=1
    end
    if verbose
        println("iterations: ", counter)
        println("dist: ", dist)
        println("deltas:", δ_[1:5])
        println("s_:    ", s_[1:5])
    end
    return δ_
end;


function grad(X, Z, Φ, δ)
    return inv(X' * Z * inv(Φ) * Z' * X) *( X' * Z * inv(Φ) * Z' * δ)
end


function gmm(β, s, X, Z, ζ, Φ)
    """X is distances, Z is the staffing measures"""
    δ = loop(s, X, ζ, β)
    # weighting matrix 
        # Φ = Z' * ξ * ξ' * Z
        # Φ = Z' * Z
    b = grad(X, Z, Φ, δ)
    # y2 is delta; theta_2 is 
    ξ = δ - X * b 
    obj = ξ' * Z * Φ * Z' * ξ

    # println("β: ", β)
    # println("b: ", b)
    return obj
end;    



