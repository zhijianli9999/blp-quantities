
function update_q!(t::Tract, δ_mat::Matrix{Float64})::Matrix{Float64}
    @unpack utils, abδ, inds, M, expu, denom, share_i, shares, q = t
    @views utils .= abδ .+ δ_mat[inds, :]
    expu .= exp.(utils)
    denom .= 1 .+ sum(expu, dims=1)
    share_i .= expu ./ denom 
    shares .= mean(share_i, dims=2) 
    q .= shares .* M
    return q
end

function update_market!(
        tracts::Vector{Tract},
        δ_mat::Matrix{Float64},
        q_mat::Matrix{Float64}
)
    for tt in eachindex(tracts)
        @views q_mat[tracts[tt].inds, tt] = update_q!(tracts[tt], δ_mat)
    end
    return nothing
end

function compute_deltas(
    ec::Economy;
    initial_δ = [], 
    max_iter = 1000, 
    tol = 1e-6,
    verbose = true
)::Matrix{Float64}
"""
    Computes mean utilities given:
    q: firm-level quantities 
        (unique vector, 1 entry per firm, sorted by unique(J)),
    D: distances,
    M: Tract populations,
    v: Random coef draws,
    β: non-linear parameters,
    J: Firm IDs (long form),
    T: Tract IDs (long form)
"""
    # set initial deltas to be the logit estimate (still requires iteration)
    @unpack tracts, pars, firms, q_mat, δs = ec
    @unpack nlcoefs, nI = pars
    if length(initial_δ)==0
        initial_δ = ones(size(δs))
            # initial_δ = compute_deltas(
            #     ec; 
            #     initial_δ = [], 
            #     max_iter = 10000, 
            #     tol = 1e-9 # note that the magnitudes of δ are much larger than usual
            # )
            
            # compute_deltas(
            #     q, D, M, zeros(2,1), β, J, T,
            #     initial_δ = ones(length(q)),
            #     max_iter = 1000,
            #     tol = 1e-8
            # )
    end

    # set the part of the utilities unrelated to δ, i.e. [D] * [(v .* σ) .+ β]
    for t in tracts
        t.abδ .= t.D * nlcoefs
    end

    dist = 1
    counter = 0
    q_obs = [j.q_obs for j in firms]
    δ_ = initial_δ
    δ_mat = repeat(δ_, outer = [1, nI])

    q_iter = zeros(length(δ_))
    while (dist > tol && counter <= max_iter)
        update_market!(tracts, δ_mat, q_mat)
        q_iter = sum(q_mat, dims=2) #The matrix is nJ by nT. Sum across markets to aggregate quantities
        δs .= δ_ .+ log.(q_obs ./ q_iter)
        dist = maximum(abs.(δs - δ_))
        δ_ .= δs
        δ_mat  = repeat(δ_, outer = [1, nI]) #more efficient to pass in δ in matrix form (n_firms_ec, nI)
        counter += 1
    end
    δs .= δ_
    # report stats for the actual BLP with RCs (and not the logit initialization)
    # if any(pars.v .!= 0.)
    if verbose println("dist = $dist, iterations = $counter") end
    return δs
end;
