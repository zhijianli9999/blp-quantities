
function compute_θ1(X, Z, Φ, δ)
    return inv(X' * Z * inv(Φ) * Z' * X) *( X' * Z * inv(Φ) * Z' * δ)
end

function compute_gradient(Dδ, Z, Φ, ω)
    return Nothing
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

    θ1 = compute_θ1(X1, Z, Φ, δ_long)
    ω = δ_long - X1 * θ1
    obj = ω' * Z * Φ * Z' * ω

    if isnan(obj) #if obj not defined - Nevo appendix pp 5-6
        obj = 10^10
    end
    
    return obj
end;