
function implied_shares(Xt_::Matrix, ζt_::Matrix, δt_::Vector, δ0::Matrix)::Vector
    """Compute shares implied by deltas and shocks"""
    u = [δt_ .+ (Xt_ * ζt_); δ0]                  # Utility
    e = exp.(u)                                 # Take exponential
    s = mean(e ./ sum(e, dims=1), dims=2)       # Compute demand
    return s[1:end-1]
end;

#i guess the implied shares along with populations must imply a set of firm-level quantities.
function implied_quantities(st_::Vector,  B::Number)::Vector

end;

function inner_loop(st_::Vector, Xt_::Matrix, ζt_::Matrix)::Vector
    """Solve the inner loop: compute delta, given the shares"""
    δt_ = ones(size(st_))
    δ0 = zeros(1, size(ζt_, 2))
    dist = 1

    # Iterate until convergence
    while (dist > 1e-11)
        s = implied_shares(Xt_, ζt_, δt_, δ0)
        δt2_ = δt_ + log.(st_) - log.(s)
        dist = max(abs.(δt2_ - δt_)...)
        δt_ = δt2_
    end
    return δt_
end;

function compute_delta(s_::Vector, X_::Matrix, ζ_::Matrix, T::Vector)::Vector
    """Compute residuals"""
    δ_ = zeros(size(T))

    # Loop over each market
    for t in unique(T)
        st_ = s_[T.==t]                             # Share in market t
        Xt_ = X_[T.==t,:]                           # Characteristics in mkt t
        δ_[T.==t] = inner_loop(st_, Xt_, ζ_)        # Solve inner loop
    end
    return δ_
end;

function compute_xi(X_::Matrix, IV_::Matrix, δ_::Vector)::Tuple
    """Compute residual, given delta (IV)"""
    β_ = inv(IV_' * X_) * (IV_' * δ_)           # Compute coefficients (IV)
    ξ_ = δ_ - X_ * β_                           # Compute errors
    return ξ_, β_
end;

function GMM(s_::Vector, X_::Matrix, Z_::Matrix, ζ_::Matrix, T::Vector, IV_::Matrix,  varζ_::Number)::Tuple
    """Compute GMM objective function"""
    δ_ = compute_delta(s_, X_, ζ_ * varζ_, T)   # Compute deltas
    ξ_, β_ = compute_xi(X_, IV_, δ_)            # Compute residuals
    gmm = ξ_' * Z_ * Z_' * ξ_ / length(ξ_)^2    # Compute ortogonality condition
    return gmm, β_
end;