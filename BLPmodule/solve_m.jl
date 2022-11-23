

function shares(δ, D, v, β)
    δ0 = zeros(1, size(v, 2))
    # TODO: don't write this in matrix form
    # [list comprehension .. for j] or for loop

    # u = [δ[j] + ...
    #     for j in eachindex(δ)]
    u = [δ .+ (D * (v .+ β)); δ0]
    e = exp.(u)
    s = mean(e ./ sum(e, dims=1), dims=2)
    return s[1:end-1]
end


function compute_quantities(δ, D, M, v, β, J, T)
    # J is the column with facility IDs in the fac-tract dataframe 
    # TODO: have structs to contain the data and the parameters. maybe also settings like tolerances
    # unique() is slow
    
    J_set = unique(J)
    T_set = unique(T)

    s = zeros(length(M)) # we have a share for each facility for each tract
    # calculate the shares for each tract, store in the big s vector
    for i in eachindex(T_set)
        t = T_set[i] # market ID
        t_ind = T.==t # boolean. which rows of the dataframe is in this market 
        Jset_in_t = unique(J[t_ind]) #IDs of the facilities in this market
        Jset_selector = [(jj in Jset_in_t) for jj in J_set] #boolean to select this market's facilities in J_set
        δt = δ[Jset_selector]
        Dt = D[t_ind, :]
        s[t_ind] = shares(δt, Dt, v, β)
    end

    q_out = zeros(length(J_set))
    # calculate the facility-level quantities implied by the big s vector (and the tract populations)
    for i in eachindex(J_set)
        j = J_set[i]
        j_ind_indf = J.==j
        sj = s[j_ind_indf]
        Mj = M[j_ind_indf]
        q_out[i] = dot(sj, Mj)
    end
    return q_out
end


function compute_deltas(
        q, D, M, v, β, J, T; 
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
        initial_δ = compute_deltas(
            q, D, M, zeros(2,1), β, J, T,
            initial_δ = ones(length(q)),
            max_iter = 1000,
            tol = 1e-8
        )
    end

    dist = 1
    counter = 0
    δ_  = initial_δ
    δ2_ = ones(length(δ_))
    q_ = zeros(length(δ_))
    
    while (dist > tol && counter <= max_iter)
        # TODO: the w thing for computation
        # TODO: update_quantities!(q,...)
        q_ = compute_quantities(δ_, D, M, v, β, J, T)
        # println(q_[1:6])
        δ2_ .= δ_ .+ log.(q ./ q_)
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
