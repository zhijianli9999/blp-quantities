


function update_q!(t::Tract, δs::Matrix{Float64}, nlcoefs::Matrix{Float64}, nI::Int)::Vector{Float64}
    for jj in 1:t.n_firms
        δt::Float64 = δs[t.inds][jj]
        Dt::Vector{Float64} = t.D[jj, :]
        for ii in 1:nI
            t.utils[ii, jj] = dot(Dt, nlcoefs[:, ii]) .+ δt
        end
    end
    t.exp_utils::Matrix{Float64} .= exp.(t.utils)
    t.shares::Vector{Float64} .= mean(t.exp_utils ./ sum(t.exp_utils, dims=2), dims=1)[1:end-1]
    return t.shares .* t.M
end


function update_market!(
        tracts::Vector{Tract},
        pars::EconomyPars,
        δs::Matrix{Float64},
        q_mat::Matrix{Float64}
    )::Matrix{Float64}
    for tt in 1:length(tracts)
        q_mat[(tracts[tt].inds), tt] .= update_q!(tracts[tt], δs, pars.nlcoefs, pars.nI)
    end
    return q_mat
end


function compute_deltas(
    ec::Economy;
    initial_δ = [], 
    max_iter = 1000, 
    tol = 1e-5 
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
if length(initial_δ)==0
    initial_δ = ones(size(ec.δs))
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
q_obs = [j.q_obs for j in ec.firms]
δ_  = initial_δ

q_iter = zeros(length(δ_))
while (dist > tol && counter <= max_iter)
    update_market!(ec.tracts, ec.pars, δ_, ec.q_mat)

    q_iter = sum(ec.q_mat, dims=2) #The matrix is nJ by nT. Sum across markets to aggregate quantities
    ec.δs = δ_ .+ log.(q_obs ./ q_iter)
    dist = maximum(abs.(ec.δs - δ_))
    δ_ = ec.δs
    counter += 1
end
ec.δs = δ_
# report stats for the actual BLP with RCs (and not the logit initialization)
# if any(ec.pars.v .!= 0.)
@showln dist counter
return ec.δs

# end
# return δ_
end;
