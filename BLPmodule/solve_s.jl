
function update_shares!(t, pars)
    δ0 = pars.δ0

    old_quantities = deepcopy(t.quantities)
    
    for jj in 1:t.nfirms
        j = t.firms[jj]
        δj = j.δ
        D_tj = t.D[1, :] # 1 by 2
        coef = (pars.v .* pars.σ) .+ pars.β #K by nI
        u_j = [dot(D_tj, coef[:, i]) .+ δj for i in 1:nI] #nI-element Vector 
        t.exp_utils[:, jj] = u_j
    end

    t.exp_utils[:,(nfirms+1)] = δ0
    t.exp_utils = exp.(t.exp_utils)
    t.shares = mean(t.exp_utils ./ sum(t.exp_utils, dims=2), dims=1)[1:end-1]
    t.quantities = t.shares .* M
    for jj in 1:t.nfirms
        t.firms[jj].q_iter = t.firms[jj].q_iter - old_quantities[jj] + t.quantities[jj]
    end
end


function update_market!(
        tracts::Vector{Tract},
        firms::Vector{Firm},
        pars::EconomyPars
    )

    for t in tracts
        update_shares!(t, pars)
    end

    return q_out
end


function compute_deltas(
    ec::Economy;
    initial_δ = [], 
    max_iter = 10000, 
    tol = 1e-9 # note that the magnitudes of δ are much larger than usual
)
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
if length(initial_δ)==0
    initial_δ = ones(length(ec.firms))
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

dist = 1
counter = 0
δ_  = initial_δ
δ2_ = ones(length(δ_))
q_iter = zeros(length(δ_))
q_obs = [j.q_obs for j in ec.firms]

while (dist > tol && counter <= max_iter)
    update_market!(ec.tracts, ec.firms, pars)
    q_iter = [j.q_iter for j in ec.firms]
    δ2_ .= δ_ .+ log.(q_obs ./ q_iter)
    dist = maximum(abs.(δ2_ - δ_))
    δ_ .= δ2_
    counter += 1
end

# report stats for the actual BLP with RCs (and not the logit initialization)
if any(v .!= 0.)
    println("iterations: ", counter)
    println("dist: ", dist)
end
return δ_
end;
