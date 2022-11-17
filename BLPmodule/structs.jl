# TODO: look at Core.Ref (pointers)

@with_kw struct Firm
    markets::Vector{Int}
    loc::Vector{Number}
    # X::Vector{Float64}
    agg_q::Number
end

@with_kw struct Market
    pop::Number
    loc::Vector{Number}
    firms::Vector{Int}
end

@with_kw struct Economy
    n_markets::Int
    # function Economy(n_markets)
    #     return Market(pop = pop, loc = loc, firms = firms)
    # end
end