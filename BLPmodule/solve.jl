
function update_q!(t::Tract, δ_mat::Matrix{Float64})::Matrix{Float64}
    @unpack utils, abδ, inds, M, expu, denom, share_i, shares, q = t
    # @showln size(utils) size(abδ) size(δ_mat[inds, :])
    # error("stop")
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
Threads.@threads for tt in eachindex(tracts)
# for tt in eachindex(tracts)
    @views q_mat[tracts[tt].inds, tt] = update_q!(tracts[tt], δ_mat)
end
return nothing
end

function compute_deltas(
    ec::Economy,
    pars::EconomyPars,
    σ
    ;
    max_iter = 1000, 
    tol = 1e-6,
    verbose = true
)::Tuple{Matrix{Float64}, Matrix{Float64}}

    # set initial deltas to be the logit estimate (still requires iteration)
    @unpack tracts, firms, q_obs = ec 
    #q_mat is the container matrix for iterated quantities
    q_mat = zeros(length(firms), length(tracts)) # nJ by nT matrix to store iterated quantities
    @unpack K, nI, v, δs = pars
    # println("σ = ", σ)
    # set the part of the utilities unrelated to δ, i.e. [D] * [(v .* σ)]
    nlcoefs = v .* σ #K, nI
    Threads.@threads for t in tracts
    # for t in tracts
        t.abδ .= t.D * nlcoefs
    end

    dist = 1
    counter = 0
    δ_ = deepcopy(δs) #initial
    δ_mat = repeat(δ_, outer = [1, nI])
    # δ_vec 
    q_iter = zeros(length(δ_))

    while (dist > tol && counter <= max_iter)
        update_market!(tracts, δ_mat, q_mat)
        q_iter = sum(q_mat, dims=2) #The matrix is nJ by nT. Sum across markets to aggregate quantities
        δs .= δ_ .+ log.(q_obs ./ q_iter)
        dist = maximum(abs.(δs - δ_))
        δ_ .= δs
        δ_mat = repeat(δ_, outer = [1, nI]) 
        #more efficient to pass in δ in matrix form (n_firms_ec, nI)
        counter += 1
    end
    δs .= δ_
    # report stats for the actual BLP with RCs (and not the logit initialization)
    # if any(pars.v .!= 0.)
    if verbose println("dist = $dist, iterations = $counter") end
    return δs, q_iter
end;
