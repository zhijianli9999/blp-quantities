

function shares(δ, D, ζ, β)
    δ0 = zeros(1, size(ζ, 2))
    # println("size(δ0) = ", size(δ0))
    # println("size(δj) = ", size(δj))
    # println("size(Dj) = ", size(Dj))  #n_tracts, 2
    # println("size(ζ) = ", size(ζ))
    # println("size((ζ .* β)) = ", size((ζ .* β)))
    # println("size(Dj * (ζ .* β)) = ", size(Dj * (ζ .* β)))
    u = [δ .+ (D * (ζ .* β)); δ0]
    e = exp.(u)
    s = mean(e ./ sum(e, dims=1), dims=2)

    return s[1:end-1]
    # println("size(e)", size(e))
    # println("size(s)", size(s))
end

function q(δ, D, M, ζ, β, J, J_set, T, T_set)
    # J_set is a vector of facility IDs (unique)
    # J is the column with facility IDs in the fac-tract dataframe 

    s = zeros(length(M))
    for i in eachindex(T_set)
        t = T_set[i] # market ID
        t_ind = T.==t # boolean. which rows of the dataframe is in this market 
        Jset_in_t = unique(J[t_ind]) #IDs of the facilities in this market
        Jset_selector = [(jj in Jset_in_t) for jj in J_set] #boolean to select this market's facilities in J_set
        δt = δ[Jset_selector]
        Dt = D[t_ind, :]
        # println("length(δt) = ", length(δt))
        # println("length(Dt) = ", length(Dt))
        s[t_ind] = shares(δt, Dt, ζ, β)
    end


    q = zeros(length(J_set))
    for i in eachindex(J_set)
        j = J_set[i]
        j_ind_indf = J.==j
        sj = s[j_ind_indf]
        Mj = M[j_ind_indf]
        q[i] = dot(sj, Mj)
    end
    return q
end


function compute_deltas(q_obs, D, M, ζ, β, J, J_set, T, T_set)::Vector
    # q: observed quantity of the facility associated with that row of the big (fac-tract) dataframe
    # ..._set: vector with one element per facility
    
    tol = 1e-12
    max_iter = 1000

    dist = 1
    counter = 0
    
    δ_  = ones(length(J_set))
    δ2_ = ones(length(J_set))

    while (dist > tol && counter <= max_iter)
        q_ = q(δ_, D, M, ζ, β, J, J_set, T, T_set)
        # println("size(q) = ", size(q_))
        δ2_ = δ_ + log.(q_obs) - log.(q_)
        # println("δ_: ", δ_, "\ns: ", s, "\nδ2_: ", δ2_)
        dist = maximum(abs.(δ2_ - δ_))
        # println("dist: ", dist)
        # println("counter: ", counter)
        δ_ = δ2_
        # print(δ_[1:6])
        # println("\n")
        counter+=1
    end
    println("iterations: ", counter)
    println("dist: ", dist)
    return δ_
end;
