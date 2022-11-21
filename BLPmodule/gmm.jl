
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



