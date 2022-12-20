
function update_q!(t::Tract, δ_vec::Vector{Float64}, prevent_overflow = true)::Matrix{Float64}
    @unpack utils, abδ, inds, M, expu, denom, share_i, shares, q = t
    
    @views utils .= abδ .+ δ_vec[inds]
    if prevent_overflow 
        util_reduction = max(maximum(utils), 0.)
        utils .-= util_reduction
        scale = exp(-util_reduction)
    else
        scale = 1.
    end
    expu .= exp.(utils)
    denom .=  sum(expu, dims=1) .+ scale
    share_i .= expu ./ denom
    shares .= mean(share_i, dims=2)
    q .= shares .* M
    
    # if debug
        # @showln maximum(expu) minimum(expu)
        # if any(isnan.(utils)) error("nan utils") end
        # if any(isinf.(expu)) error("inf expu") end
        # if any(isnan.(expu)) error("nan expu") end
        # if any(isnan.(denom)) error("nan denom") end
        # if isapprox(denom[1],0.) 
        #     # @showln maximum(t.D) 
        #     println(util_reduction)
        #     println(maximum(abδ))
        #     @showln util_reduction
        #     @showln maximum(abδ)
        #     error("denom zero")
        # end
        # if any(isnan.(share_i)) error("nan share_i") end
        # if any(isnan.(shares)) error("nan shares") end
    # end
    return q
end


function update_market!(
    tracts::Vector{Tract},
    δ_vec::Vector{Float64},
    q_mat::Matrix{Float64}
)
Threads.@threads for tt in eachindex(tracts)
# for tt in eachindex(tracts)
    @views q_mat[tt, tracts[tt].inds] = update_q!(tracts[tt], δ_vec)
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
)::Tuple{Vector{Float64}, Vector{Float64}}
    ec_init = deepcopy(ec)
    pars_init = deepcopy(pars)
    
    @unpack tracts, firms, q_obs = ec 
    
    # q_mat is the container matrix for iterated quantities
    q_mat = zeros(length(tracts), length(firms)) # nT by nJ matrix to store iterated quantities
    
    @unpack K, nI, v, δs = pars
    
    # set the part of the utilities unrelated to δ, i.e. [D] * [(v .* σ)]
    nlcoefs = v .* σ #K, nI

    Threads.@threads for t in tracts
        t.abδ .= t.D * nlcoefs
    end

    dist = 1
    counter = 0
    δ_ = deepcopy(δs) #initial
    q_iter = zeros(length(δs))
    while (dist > tol && counter <= max_iter)
        update_market!(tracts, δ_, q_mat)
        q_iter = sum(q_mat, dims=1)[1,:] # Sum across markets to aggregate quantities
        δs .= δ_ .+ log.(q_obs ./ q_iter)
        dist = maximum(abs.(δs - δ_))
        δ_ .= δs
        counter += 1
    end
    δs .= δ_
    if verbose println("dist = $dist, iterations = $counter") end
    ec = ec_init
    pars = pars_init
    pars.δs = δs

    return δs, q_iter
end;
