
function grad(X, Z, Φ, δ)
    return inv(X' * Z * inv(Φ) * Z' * X) *( X' * Z * inv(Φ) * Z' * δ)
end


function gmm(β, q, X1, X2, Z, M, ζ, J, T, Φ)
    # X1 are linear characteristics, X2 are non-linear, Z are instruments
    
    δ = compute_deltas(q, X2, M, ζ, β, J, T)
    δ_long = zeros(length(M)) # fill in a long fac-tract-level vector with δⱼs
    J_set = unique(J)
    for i in eachindex(J_set)
        j = J_set[i]
        j_ind_inlong = J.==j
        δ_long[j_ind_inlong] .= δ[i]
    end

    θ1 = grad(X1, Z, Φ, δ_long)
    ξ = δ_long - X1 * θ1
    obj = ξ' * Z * Φ * Z' * ξ
    if isnan(obj)
        obj = 10^10
    end
    return obj
end;
