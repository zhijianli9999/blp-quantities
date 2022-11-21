
# implied_shares, without random coefficients
function simple_shares(δ_)
    # Utility
    u = [δ_; 0.]
    e = exp.(u)
    s = e[1:end-1]
    return s
end
# get deltas without RC
function loop(s_::Vector)::Vector
    """Compute delta given shares"""
    dist = 1
    counter = 0
    δ_ = ones(size(s_))
    while (dist > 1e-12 && counter <= 10000)
        s = simple_shares(δ_)
        δ2_ = δ_ + log.(s_) - log.(s)
        # println("δ_: ", δ_, "\ns: ", s, "\nδ2_: ", δ2_)
        dist = max(abs.(δ2_ - δ_)...)
        δ_ = δ2_
        counter+=1
    end
    # println("s_: ", s_)
    println("iterations:", counter)
    # println("deltas:", δ_)
    return δ_
end;
