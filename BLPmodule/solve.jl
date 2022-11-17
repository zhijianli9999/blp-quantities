
function implied_shares(Xt_::VecOrMat, ζt_::Matrix, δt_::Vector, δ0::Matrix)::Vector
    """Compute shares implied by deltas and shocks"""
    ζt_ .= 0 #testing out without random coefficients
    u = [δt_ .+ (Xt_ * ζt_); δ0]                  # Utility
    # println("u: ", u)
    # println("size(u): ", size(u))

    e = exp.(u)                                 # Take exponential
    s = mean(e ./ sum(e, dims=1), dims=2)       # Compute demand
    # println("size(s): ", size(s))
    return s[1:end-1]
end;


function inner_loop(st_::Vector, s0t_::Vector, Xt_::VecOrMat, ζt_::Matrix)::Vector
    """Solve the inner loop: compute delta, given the shares"""
    δt_ = ones(size(st_))
    # println("δt_ ", δt_)
    δ0 = zeros(1, size(ζt_, 2))
    # println("δ0 ", δ0)
    # println("δ0 size: ", size(δ0))
    dist = 1
    counter = 0
    while (dist > 1e-8 && counter <= 10000)
        s = implied_shares(Xt_, ζt_, δt_, δ0)
        if mod(counter, 2000) == 1
            # println("counter: ", counter)
            # println("s: ", s)
        end
        s *= sum(st_)
        δt2_ = δt_ + log.(st_) - log.(s)
        dist = max(abs.(δt2_ - δt_)...)
        δt_ = δt2_
        counter+=1
    end
    println("final counter: ", counter)
    return δt_
end;


function compute_delta(s_::Vector, s0_::Vector, X_::Vector, ζ_::Matrix, T::Vector)::Vector
    """Compute residuals"""
    δ_ = zeros(size(T))
    # Loop over each market
    for t in unique(T)
        st_ = s_[T.==t]                             # Share in market t
        Xt_ = X_[T.==t]                           # Characteristics in mkt t
        s0t_ = s0_[T.==t]                           # outside share in market t
        δ_[T.==t] = inner_loop(st_, s0t_, Xt_, ζ_)        # Solve inner loop
    end
    println("deltas:", δ_)
    return δ_
end;

function compute_xi(X_::Matrix, IV_::Matrix, δ_::Vector)::Tuple
    """Compute residual, given delta (IV)"""
    β_ = inv(IV_' * X_) * (IV_' * δ_)           # Compute coefficients (IV)
    ξ_ = δ_ - X_ * β_                           # Compute errors
    return ξ_, β_
end;

function GMM(s_::Vector, s0_::Vector, X_::Matrix, Z_::Matrix, ζ_::Matrix, T::Vector, IV_::Matrix,  varζ_::Number)::Tuple
    """Compute GMM objective function"""
    δ_ = compute_delta(s_, s0_, X_, ζ_ * varζ_, T)   # Compute deltas
    ξ_, β_ = compute_xi(X_, IV_, δ_)            # Compute residuals
    gmm = ξ_' * Z_ * Z_' * ξ_ / length(ξ_)^2    # Compute ortogonality condition
    return gmm, β_
end;
