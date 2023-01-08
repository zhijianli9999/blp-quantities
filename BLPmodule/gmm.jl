

function build_formula(vars::Vars)
    # helper function to write a formula for GMM from variables
    @unpack xvars, zvars, fevars = vars
    @assert length(xvars)==1 "One x variable in the regression please."
    formula = Term(:deltas) ~ (Term(xvars[1]) ~ sum(Term.(zvars))) + sum(fe.(Term.(fevars)))

    return formula
end


function gmm_lm(
    θ2, 
    ec::Economy,
    pars::EconomyPars,
    fac_df::DataFrame,
    vars::Vars;
    Φ::Matrix{Float64}=Matrix{Float64}(undef,(0,0)), #weights
    tol=1e-5
)::Float64

    @unpack zvars, xvars = vars
    Z = Matrix{Float64}(fac_df[:, zvars])
    X = Matrix{Float64}(fac_df[:, xvars])
    if length(Φ)==0
        Φ = Z' * Z
    end

    δ, _ = compute_deltas(ec, pars, θ2, tol=tol, verbose = false)
    pars.δs = δ
    ZinvΦZ = Z * (Φ \ Z')
    θ1 = compute_θ1(δ, fac_df, vars)
    ω = δ .- (X * θ1)
    obj = ω' * ZinvΦZ * ω
    println("Objective function value: ", obj[1])
    return obj[1]
end


function compute_θ1(
    δ::Vector{Float64},
    fac_df::DataFrame,
    vars::Vars
)
    fac_df[:, "deltas"] = δ
    regresult = reg(fac_df, build_formula(vars))
    @showln regresult
    flush(stdout)
    θ1 = coef(regresult)[1]
    return θ1
end
