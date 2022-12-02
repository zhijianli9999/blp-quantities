
function pred_q(θ::Vector{Float64}, n_firms::Int, tracts::Vector{Tract})
    # θ should have X before D
    KX = size(tracts[1].X)[2] 
    θX = θ[1:KX]
    θD = θ[(KX+1):end]
    q_vec = zeros(n_firms)
    Threads.@threads for tt in eachindex(tracts)
        t = tracts[tt]
        @unpack firms, q, M, utils, inds, X, D, denom, shares = t
        utils .= reduce(+, X * θX) + reduce(+, D * θD)
        utils .= exp.(utils)
        denom .= 1 .+ sum(utils, dims=1)
        shares .= utils ./ denom
        q .= vec(shares .* M)
        view(q_vec, inds) .+= q
    end
    return q_vec
end


function nlls_obj(θ2, n_firms, tracts, q_obs)
    q_pred = pred_q(θ2, n_firms, tracts)
    obj = reduce(+, (q_obs .- q_pred).^2)
    return obj
end