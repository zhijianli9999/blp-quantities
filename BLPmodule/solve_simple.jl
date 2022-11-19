
# implied_shares, without random coefficients
function simple_shares(δ_)
    # Utility
    u = [δ_; 0.]
    e = exp.(u)
    s = e[1:end-1]
    return s
end
# get deltas without RC
function loop(s_::Vector)::Vector
    """Compute delta given shares"""
    dist = 1
    counter = 0
    δ_ = ones(size(s_))
    while (dist > 1e-12 && counter <= 10000)
        s = simple_shares(δ_)
        δ2_ = δ_ + log.(s_) - log.(s)
        # println("δ_: ", δ_, "\ns: ", s, "\nδ2_: ", δ2_)
        dist = max(abs.(δ2_ - δ_)...)
        δ_ = δ2_
        counter+=1
    end
    # println("s_: ", s_)
    println("iterations:", counter)
    # println("deltas:", δ_)
    return δ_
end;

# implied_shares with random coefficients
function shares(δ_, X, ζ, β)
    # Utility
    δ0 = zeros(1, size(ζ, 2))
    u = [δ_ .+ (X * (ζ .* β)); δ0]
    e = exp.(u)
    s = mean(e, dims=2)
    # s = mean(e ./ sum(e, dims=1), dims=2)
    return s[1:end-1]
end
# compute deltas, with RCs
function loop(s_::Vector, X, ζ, β)::Vector
    """Compute delta given shares"""
    dist = 1
    counter = 0
    δ_ = ones(size(s_))
    while (dist > 1e-12 && counter <= 10000)
        s = shares(δ_, X, ζ, β)
        δ2_ = δ_ + log.(s_) - log.(s)
        # println("δ_: ", δ_, "\ns: ", s, "\nδ2_: ", δ2_)
        dist = maximum(abs.(δ2_ - δ_))
        δ_ = δ2_
        # print(δ_[1:6])
        # println("\n")
        counter+=1
    end
    # println("s_: ", s_)
    println("iterations:", counter)
    # println("deltas:", δ_)
    return δ_
end;


function grad(X, Z, Φ, δ)
    return inv(X' * Z * inv(Φ) * Z' * X) *( X' * Z * inv(Φ) * Z' * δ)
end


function gmm(β, s, X, Z, ζ)
    """X is distances, Z is the staffing measures"""
    δ = loop(s, X, ζ, β)
    # weighting matrix 
    # Φ = Z' * ξ * ξ' * Z
    Φ = Z' * Z
    b = grad(X, Z, Φ, δ)
    # y2 is delta; theta_2 is 
    ξ = δ - X * b 
    obj = ξ' * Z * Φ * Z' * ξ

    println("β: ", β)
    println("b: ", b)
    return obj
end;    



