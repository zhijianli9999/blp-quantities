using JuMP 

function compute_elasticity(
    X::Vector{Matrix{Float64}}, 
    θ::Union{Vector{Float64}, Float64},
    share::JuMP.Containers.SparseAxisArray{Float64, 2, Tuple{Int64, Int64}}, 
    mktq::JuMP.Containers.SparseAxisArray{Float64, 2, Tuple{Int64, Int64}}, 
    t_indexer::Vector{Vector{Int64}}, 
    positionin::Matrix{Int64}, 
    n_firms::Int)::Vector{Float64}
    # t_indexer and positionin are made with create_indices(tracts, n_firms) in make.jl
    η = Vector{Float64}(undef,n_firms)
    order = length(θ)
    if order==1
        θ1 = θ[1]
        Threads.@threads for jj in 1:n_firms
            η[jj] = sum([mktq[tt,jj]*(1-share[tt,jj])*θ1*X[tt][positionin[jj,tt]] for tt in t_indexer[jj]]) / sum(mktq[t_indexer[jj],jj])
        end
    elseif order==2
        θ1 = θ[1]
        θ2 = θ[2]
        Threads.@threads for jj in 1:n_firms
            η[jj] = sum([mktq[tt,jj]*(1-share[tt,jj])*(θ2*X[tt][positionin[jj,tt],1] + θ1)*X[tt][positionin[jj,tt],1] for tt in t_indexer[jj]]) / sum(mktq[t_indexer[jj],jj])
        end
    else
        error("θ has too many elements. Only order==1 or order==2 supported.")
    end
    return η
end