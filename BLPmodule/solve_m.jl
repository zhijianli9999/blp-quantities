

function shares(δ, D, ζ, β)
    δ0 = zeros(1, size(ζ, 2))
    u = [δ .+ (D * (ζ .* β)); δ0]
    e = exp.(u)
    s = mean(e ./ sum(e, dims=1), dims=2)
    return s[1:end-1]
end

function compute_quantities(δ, D, M, ζ, β, J, T)
    # J is the column with facility IDs in the fac-tract dataframe 
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
        s[t_ind] = shares(δt, Dt, ζ, β)
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


function compute_deltas(q, D, M, ζ, β, J, T)
    # Q has one entry per facility
    J_set = unique(J)

    tol = 1e-12
    max_iter = 1000

    dist = 1
    counter = 0
    
    # TODO: starting deltas = logit
    δ_  = ones(length(J_set))
    δ2_ = ones(length(J_set))
    w_ = exp.(δ_)
    while (dist > tol && counter <= max_iter)
        q_ = compute_quantities(δ_, D, M, ζ, β, J, T)
        # TODO: the highlighted thing
        w2_ = w_ * q / q_
        w_ = w2_
        # δ2_ = δ_ + log.(q) - log.(q_)
        # δ_ = δ2_
        dist = maximum(abs.(δ2_ - δ_))
        counter+=1
    end
    println("iterations: ", counter)
    println("dist: ", dist)
    δ_ = log.(w_)
    return δ_
end;
