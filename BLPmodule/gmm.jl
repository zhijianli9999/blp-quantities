

function gmm_lm(
    θ2::Vector{Float64}, 
    ec::Economy,
    pars::EconomyPars,
    X1::Matrix{Float64}, #df.x1, df.x2
    tol=1e-8
    )::Float64
    @showln θ2
    pars = @set pars.σ = θ2
    # @unpack nlcoefs, nI, K, β, δs, σ, v = pars

    δ, _ = compute_deltas(ec, pars, initial_δ=pars.δs, tol = tol, verbose = false)

    θ1::Matrix{Float64} = inv(X1' * X1) * X1' * δ
    @showln θ1
    ω::Matrix{Float64} = δ .- (X1 * θ1)
    obj = reduce(+, (ω .^ 2)) #SSR

    return obj
end

# TODO: cleanup an efficiency
function compute_Dδ(ec::Economy, pars::EconomyPars)
    
    @unpack tracts, firms = ec
    @unpack nI, K, v = pars
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
                    dsdδ[tt][j,m] = mean([-t.share_i[j,i] * t.share_i[m,i] for i in 1:nI])
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
                dsdθ[tt][j,k] = mean([v[k,i]*t.share_i[j,i]*(t.D[j,k] - reduce(+, [t.D[m,k]*t.share_i[m,i] for m in 1:t.n_firms])) for i in 1:nI])
            end
        end
    end
    dqdθ = [M[tt] .* dsdθ[tt] for tt in eachindex(tracts)]

    Dδₜ = [inv(dqdδ[tt]) * dqdθ[tt] for tt in eachindex(tracts)]
    
    Dδ = zeros(length(firms), K)
    for tt in eachindex(tracts)
        Dδ[tracts[tt].inds,:] .+= Dδₜ[tt]
    end
    return Dδ
end

function gmm_grad(
    θ2::Vector{Float64},
    ec::Economy,
    pars::EconomyPars,
    X1::Matrix{Float64} #df.x1, df.x2
    )
    #δ: Jx1
    #Dδ: Jx2
    #X1: Jx2
    #θ1: 2x1
    
    pars = @set pars.σ = θ2
    δ, _ = compute_deltas(ec, pars, initial_δ=pars.δs, verbose = false)

    Dδ = compute_Dδ(ec, pars)
    θ1::Matrix{Float64} = inv(X1' * X1) * X1' * δ
    return 2 .* (Dδ' * δ - (Dδ' * (X1 * θ1)))

end

