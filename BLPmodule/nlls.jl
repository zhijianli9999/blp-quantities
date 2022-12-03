
function pred_q(θ::Vector, n_firms::Int, tracts::Vector{Tract})
    # @showln θ
    # θ should have X before D
    KX = size(tracts[1].X)[2] 
    θX = θ[1:KX]
    θD = θ[(KX+1):end]
    println(θX, θD)
    q_vec = zeros(n_firms)
    for tt in eachindex(tracts)
        t = tracts[tt]
        @unpack firms, n_firms, q, M, utils, inds, X, D, denom, shares = t
        for jj in 1:n_firms
            utils[jj,1] = reduce(+, X[jj,:] .* θX) + reduce(+, D[jj,:] .* θD)
        end
        utils .= exp.(utils)
        # @showln sum(utils, dims=1)
        denom .= 1 .+ sum(utils, dims=1)
        shares .= utils ./ denom
        q .= shares .* M
        q_vec[inds] .+= vec(q)
    end
    # @showln q_vec
    # error()
    return q_vec
end


function nlls_obj(θ2, n_firms, tracts, q_obs)
    q_pred = pred_q(θ2, n_firms, tracts)
    obj = reduce(+, (q_obs .- q_pred).^2)
    return obj
end

function predqt(
    θ, 
    X,
    M
    )
    nJ = size(X)[1]
    utils .= exp.([dot(X[jj,:], θ) for jj in 1:nJ])
    shares .= utils ./ (1 .+ sum(utils, dims=1))
    q .= shares .* M

end


