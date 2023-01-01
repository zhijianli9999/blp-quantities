

function gmm_lm(
    θ2, 
    ec::Economy,
    pars::EconomyPars,
    X::Matrix{Float64},
    Z::Matrix{Float64};
    d_ind::Vector{Int}=[1],
    Φ::Matrix{Float64}=Matrix{Float64}(undef,(0,0)), #weights
    tol=1e-6
)::Float64

    if length(Φ)==0
        Φ = Z' * Z
    end
    # println("θ2 = ", θ2)
    # flush(stdout)

    δ, _ = compute_deltas(ec, pars, θ2, d_ind=d_ind, tol=tol, verbose = false)
    pars.δs = δ
    ZinvΦZ = Z * (Φ \ Z')
    # θ1 = (X' * ZinvΦZ * X) \ X' * ZinvΦZ * δ
    θ1 = compute_θ1(δ, X, Z, Φ)
    ω = δ .- (X * θ1)
    obj = ω' * ZinvΦZ * ω

    return obj[1]
end


function compute_θ1(
    δ::Vector{Float64},
    X::Matrix{Float64}, 
    Z::Matrix{Float64},
    Φ::Matrix{Float64}=Matrix{Float64}(undef,(0,0)) #weights
)
    if length(Φ)==0
        Φ = Z' * Z
    end
    ZinvΦZ = Z * (Φ \ Z')
    θ1 = (X' * ZinvΦZ * X) \ X' * ZinvΦZ * δ
    return θ1
end



function compute_Dδ(ec::Economy, pars::EconomyPars)
    # TODO: cleanup and efficiency
    
    @showln ec.tracts[1].shares
    @unpack tracts, firms = ec
    @unpack nI, K, v = pars
    # println(tracts[1].shares[1])
    # @showln pars.σ
    M = reshape([t.M for t in ec.tracts], (1,length(tracts)))
    dsdδ = Vector{Matrix{Float64}}(undef, length(tracts))
    for tt in eachindex(tracts)
        t = tracts[tt]
        dsdδ[tt] = Matrix{Float64}(undef, t.n_firms, t.n_firms)
        for j in eachindex(t.firms)
            for m in eachindex(t.firms)
                if j==m 
                    dsdδ[tt][j,m] = mean([t.share_i[j,i] * (1-t.share_i[j,i]) for i in 1:nI])
                else 
                    dsdδ[tt][j,m] = -mean([t.share_i[j,i] * t.share_i[m,i] for i in 1:nI])
                end
            end
        end
    end
    dqdδ = [M[tt] .* dsdδ[tt] for tt in eachindex(tracts)]

    dsdθ = Vector{Matrix{Float64}}(undef, length(tracts))
    for tt in eachindex(tracts)
        t = tracts[tt]
        dsdθ[tt] = Matrix{Float64}(undef, t.n_firms, K)
        for j in eachindex(t.firms)
            for k in 1:K
                dsdθ[tt][j,k] = 
                mean(
                    [v[k,i]*t.share_i[j,i] * (t.D[j,k] - reduce(+, [t.D[m,k]*t.share_i[m,i] for m in eachindex(t.firms)])) for i in 1:nI]
                    )
            end
        end
    end
    dqdθ = [M[tt] .* dsdθ[tt] for tt in eachindex(tracts)]

    Dδₜ = [-inv(dqdδ[tt]) * dqdθ[tt] for tt in eachindex(tracts)]
    Dδ = zeros(length(firms), K)
    for tt in eachindex(tracts)
        Dδ[tracts[tt].inds,:] .+= Dδₜ[tt]
    end
    # @showln Dδ[1,:]
    return Dδ    # Jx2
end


function gmm_grad(
    θ2::Vector{Float64},
    ec::Economy,
    pars::EconomyPars,
    X::Matrix{Float64} #df.x1, df.x2
    )

    #Dδ: Jx2
    #X:  Jx2
    #θ1: 2x1
    
    δ = deepcopy(pars.δs)
    # @showln ec.tracts[1].shares

    Dδ = compute_Dδ(ec, pars)
    θ1 = X \ δ
    dθ1dθ2 = inv(X' * X) * (X' * Dδ) #K, K
    gradj = [Vector{Float64}(undef, 0) for _ in δ]
    for jj in eachindex(δ)
        xj = X[jj,:] #2-element Vector{Float64}
        δj = δ[jj,:] #1-element Vector{Float64}
        Dδj = Dδ[jj,:] #2-element Vector{Float64}
        gradj[jj] =
            (δj .* Dδj) .+
            (xj[1]^2 .* θ1[1] .* dθ1dθ2[1,:]) .+
            (xj[2]^2 .* θ1[2] .* dθ1dθ2[2,:]) .+
            (xj[1] .* xj[2] .* (dθ1dθ2[1,:] .* θ1[2] .+ (θ1[1] .* dθ1dθ2[2,:]))) .-
            (xj[1] .* ((δj .* dθ1dθ2[1,:]) .+ (Dδj .* θ1[1]))) .-
            (xj[2] .* ((δj .* dθ1dθ2[2,:]) .+ (Dδj .* θ1[2]))) 
    end
    grad = 2 .* reduce(.+ , gradj)
    println("grad = ", grad)
    return grad
end


function grad_diff(
    θ2::Vector{Float64},
    ec::Economy,
    pars::EconomyPars,
    X::Matrix{Float64}, #df.x1, df.x2
    eps = 1e-5)

    obj = gmm_lm(θ2, deepcopy(ec), deepcopy(pars), X)
    obj1 = gmm_lm(θ2 .+ [eps,0.], deepcopy(ec), deepcopy(pars), X)
    obj2 = gmm_lm(θ2 .+ [0.,eps], deepcopy(ec), deepcopy(pars), X)
    return [obj1-obj, obj2-obj]./eps
end


