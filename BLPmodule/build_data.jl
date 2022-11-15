# https://github.com/matteocourthoud/Phd-Industrial-Organization/blob/main/code/blp.jl

# function demand(p::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Tuple{Vector, Number}
#     """Compute demand"""
#     δ = [X p] * (β .+ ζ)                    # Mean value
#     δ0 = zeros(1, size(ζ, 2))               # Mean value of the outside option
#     u = [δ; δ0] + ξ                         # Utility
#     e = exp.(u)                             # Take exponential
#     s = mean(e ./ sum(e, dims=1), dims=2)   # Compute demand
#     return s[1:end-1], s[end]
# end;

# function profits(p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Vector
#     """Compute profits"""
#     s, _ = demand(p, X, β, ξ, ζ)            # Compute demand
#     pr = (p - c) .* s                       # Compute profits
#     return pr
# end;

# function profits_j(pj::Number, j::Int, p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Number
#     """Compute profits of firm j"""
#     p[j] = pj                               # Insert price of firm j
#     pr = profits(p, c, X, β, ξ, ζ)          # Compute profits
#     return pr[j]
# end;

# function equilibrium(c::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Vector
#     """Compute equilibrium prices and profits"""
#     p = 2 .* c;
#     dist = 1;
#     iter = 0;

#     # Iterate until convergence
#     while (dist > 1e-8) && (iter<1000)

#         # Compute best reply for each firm
#         p_old = copy(p);
#         for j=1:length(p)
#             obj_fun(pj) = - profits_j(pj[1], j, p, c, X, β, ξ, ζ);
#             optimize(x -> obj_fun(x), [1.0], LBFGS());
#         end

#         # Update distance
#         dist = max(abs.(p - p_old)...);
#         iter += 1;
#     end
#     return p
# end;

# function draw_data(I::Int, J::Int, K::Int, rangeJ::Vector, varζ::Number, varX::Number, varξ::Number)::Tuple
#     """Draw data for one market"""
#     J_ = rand(rangeJ[1]:rangeJ[2])              # Number of firms (products)
#     X_ = rand(Exponential(varX), J_, K)         # Product characteristics
#     ξ_ = rand(Normal(0, varξ), J_+1, I)         # Product-level utility shocks
#     # Consumer-product-level preference shocks
#     ζ_ = [rand(Normal(0,1), 1, I) * varζ; zeros(K,I)]
#     w_ = rand(Uniform(0, 1), J_)                # Cost shifters
#     ω_ = rand(Uniform(0, 1), J_)                # Cost shocks
#     c_ = w_ + ω_                                # Cost
#     j_ = sort(sample(1:J, J_, replace=false))   # Subset of firms
#     return X_, ξ_, ζ_, w_, c_, j_
# end;

# function compute_mkt_eq(I::Int, J::Int, β::Vector, rangeJ::Vector, rangeB, varζ::Number, varX::Number, varξ::Number)::DataFrame
#     """Compute equilibrium one market"""

#     # Initialize variables
#     K = size(β, 1) - 1
#     X_, ξ_, ζ_, w_, c_, j_ = draw_data(I, J, K, rangeJ, varζ, varX, varξ)

#     # Compute equilibrium
#     p_ = equilibrium(c_, X_, β, ξ_, ζ_)    # Equilibrium prices
#     s_, s0_ = demand(p_, X_, β, ξ_, ζ_)     # Demand with shocks
#     pr_ = (p_ - c_) .* s_                       # Profits
    
#     if rangeB isa Number
#         B = rangeB
#     else
#         B = rand(rangeB[1]:rangeB[2], 1) # market size
#     end
#     q_, q0_ = B .* (s_, s0_)

#     # Save to data
#     s0_ = ones(length(j_)) .* s0_
#     B_ = ones(length(j_)) .* B
#     df = DataFrame(j=j_, w=w_, p=p_, s=s_, s0=s0_, pr=pr_, q = q_, q0 = q0_, B = B_)
#     for k=1:K
#       df[!,"x$k"] = X_[:,k]
#       df[!,"z$k"] = sum(X_[:,k]) .- X_[:,k] #other firms' X 
#     end
#     return df
# end;

# function simulate_data(I::Int, J::Int, β::Vector, nT::Int, rangeJ::Vector, rangeB, varζ::Number, varX::Number, varξ::Number)
#     """Simulate full dataset"""
#     df = compute_mkt_eq(I, J, β, rangeJ, rangeB, varζ, varX, varξ)
#     df[!, "t"] = ones(nrow(df)) * 1
#     for t=2:nT
#         df_temp = compute_mkt_eq(I, J, β, rangeJ, rangeB, varζ, varX, varξ)
#         df_temp[!, "t"] = ones(nrow(df_temp)) * t
#         append!(df, df_temp)
#     end
#     df = groupby(df, :j) # group by firm
#     @transform!(df, :q_j = sum(:q)); # compute firm-level quantities
#     df = transform!(df)
#     # CSV.write("blp.csv", df)
#     return df
# end;


function build_dist_mkt(β::Number, rangeB::Vector, varζ::Number, varξ::Number, dist_thresh::Number, dists::Vector)
    j_ = findall(dists .< dist_thresh) #firms in the market 
    J_ = length(j_) #number of firms in market
    B = rand(rangeB[1]:rangeB[2]) # market size
    ξ = rand(Normal(0, varξ), J_+1, B)         # Product-level utility shocks
    ζ = rand(Normal(0,1), 1, B) * varζ  # Consumer-product-level preference shocks
    #Compute demand
    X = dists[j_]
    δ = X * (β .+ ζ)                    # Mean value
    δ0 = zeros(1, size(ζ, 2))               # Mean value of the outside option
    u = [δ; δ0] + ξ                         # Utility
    e = exp.(u)                             # Take exponential
    s = mean(e ./ sum(e, dims=1), dims=2)   # Compute demand
    s0 = repeat([s[end]], J_) #outside shares
    s = s[1:end-1] #shares
    q0 = s0 .* B
    q = s .* B

    df = DataFrame(s = s, s0 = s0, q = q, q0 = q0, j = j_, dist = X, B = repeat([B], J_))
    return df
end

function build_dist_data(J::Int, β::Number, nT::Int, rangeB::Vector, varζ::Number, varξ::Number, dist_thresh::Number)
    fac_locs = rand(Uniform(0, 1), J)
    mkt_locs = rand(Uniform(0, 1), nT)
    dists = [[abs(locj - locm) for locj in fac_locs] for locm in mkt_locs]
    df = build_dist_mkt(β, rangeB, varζ, varξ, dist_thresh, dists[1])
    df[!, "t"] = Int.(ones(nrow(df)) )
    for t=2:nT
        df_t = build_dist_mkt(β, rangeB, varζ, varξ, dist_thresh, dists[t])
        df_t[!, "t"] = Int.(ones(nrow(df_t)) * t)
        append!(df, df_t)
    end
    df = groupby(df, :j) # group by firm
    df = @transform(df, :q_j = sum(:q), :agg_q0 = sum(:q0), :total_B = sum(:B), :agg_s = sum(:q) ./ sum(:B), :agg_s0 = sum(:q0) ./ sum(:B))
    # df = @transform(df, )
    # df.agg_q0 .= sum(unique(df.q0))
    # df.total_B .= sum(unique(df.q_j)), df.agg_q0[1]
    # df.agg_shares .= df.q_j ./ df.total_B
    # df.agg_s0 .= df.agg_q0 ./ df.total_B
    # TODO: check, use meta
    return df
end;