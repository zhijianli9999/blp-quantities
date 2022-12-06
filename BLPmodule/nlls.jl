using JuMP, Ipopt

function run_nlls(
    X::Vector{Matrix{Float64}}, 
    D::Vector{Matrix{Float64}}, 
    tracts::Vector{Tract}, 
    n_firms::Int, 
    q_obs
)

    n_tracts = length(tracts);
    M = [t.M for t in tracts]

    # number of variables
    nX::Int = size(X[1])[2]
    nD::Int = size(D[1])[2]

    model = Model(Ipopt.Optimizer)
    @variables(model, begin
        θx[1:nX]
        θd[1:nD]
    end)

    j_indexer, t_indexer, positionin = create_indices(tracts, n_firms)

    u = @NLexpression(model,
        [tt in 1:n_tracts, jj in j_indexer[tt]],
        sum(θx[ix] * X[tt][positionin[jj,tt],ix] for ix in 1:nX) + sum(θd[id] * D[tt][positionin[jj,tt],id] for id in 1:nD))

    expu = @NLexpression(model,
        [tt in 1:n_tracts, jj in j_indexer[tt]],
        exp(u[tt,jj]))

    denom = @NLexpression(model,
        [tt in 1:n_tracts],
        1+ sum(expu[tt,jj] for jj in j_indexer[tt]))

    share = @NLexpression(model,
        [tt in 1:n_tracts, jj in j_indexer[tt]],
        expu[tt,jj] / denom[tt])

    mktq = @NLexpression(model,
        [tt in 1:n_tracts, jj in j_indexer[tt]],
        M[tt] * share[tt,jj])

    firmq = @NLexpression(model,
        [jj in 1:n_firms],
        sum(mktq[tt, jj] for tt in t_indexer[jj]))

    @NLobjective(model, Min, sum((firmq[jj] - q_obs[jj])^2 for jj in 1:n_firms))
    optimize!(model)
    
    return value.(θx), value.(θd), value.(share), value.(mktq), value.(firmq)
end