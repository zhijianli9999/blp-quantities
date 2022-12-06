
function compute_elasticity(X, θ, share, mktq, t_indexer, positionin, n_firms)
    η = Float64[]
    order = length(θ)
    if order==1
        θ1 = θ
        η = [sum([mktq[tt,jj]*(1-share[tt,jj])*θ1*X[tt][positionin[jj,tt]] for tt in t_indexer[jj]]) / sum(mktq[t_indexer[jj],jj]) for jj in 1:n_firms];
    elseif order==2
        θ1 = θ[1]
        θ2 = θ[2]
        η = [sum([mktq[tt,jj]*(1-share[tt,jj])*(θ2*X[tt][positionin[jj,tt],1] + θ1)*X[tt][positionin[jj,tt],1] for tt in t_indexer[jj]]) / sum(mktq[t_indexer[jj],jj]) for jj in 1:n_firms];
    else
        error("θ has too many elements. Only order==1 or order==2 supported.")
    end
    return η
end