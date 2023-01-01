xvars = [:dchrppd,
    :dchrppd_lag,
    :logdchrppd,
    :logdchrppd_lag,
    :rnhrppd,
    :rnhrppd_lag,
    :logrnhrppd,
    :logrnhrppd_lag,
    :lpnhrppd,
    :lpnhrppd_lag,
    :loglpnhrppd,
    :loglpnhrppd_lag,
    :cnahrppd,
    :cnahrppd_lag,
    :logcnahrppd,
    :logcnahrppd_lag,
    :labor_expense,
    :labor_expense_lag,
    :loglabor_expense,
    :loglabor_expense_lag,
    :rn_frac
]


logged_inds = [3, 4, 7, 8, 11, 12, 15, 16, 19, 20] # for the modified elasticity computation
qvars = [:restot, :nres_mcare, :nres_nonmcaid]

using DataFrames, Optim, Revise, Serialization, DebuggingUtilities, CSV, Statistics

const datadir = "/export/storage_adgandhi/MiscLi/factract";
string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;


################# EDIT ,,, ##################



d_ind = [3] #which distance variable. 1=d, 2=d2, 3=log(d)

testmodes = ["_FL17", ""]
testmode = testmodes[2]

suble = true #select only a subset facilities based on (log)labor_expense(_lag)

for x_ind in [[20], [19], [18], [17]] # x_ind: which x variable 
# for x_ind in [[20]] # x_ind: which x variable 
# x_ind = [20]
for q_ind in [2, 3] #which q variable. 1=restot, 2=nres_mcare, 3=nres_nonmcaid
# for q_ind in [2] #which q variable. 1=restot, 2=nres_mcare, 3=nres_nonmcaid
# q_ind = 2

logit = false

################# EDIT ^^^ ##################

println("X variable: ", xvars[x_ind])
println("Q variable: ", qvars[q_ind])
x_tag = join(string.(x_ind))
d_tag = join(string.(d_ind))
configtag = "$(q_ind)_$(x_tag)_$(d_tag)$testmode"

ec = deserialize("$datadir/analysis/ec$q_ind$testmode.jls");

# linear characteristics (staffing variables):
X1 = vcat(transpose.([ec.firms[ii].X[x_ind] for ii in eachindex(ec.firms)])...);
Z = vcat(transpose.([ec.firms[ii].Z for ii in eachindex(ec.firms)])...);



if !logit
    pars = m.set_Pars(K = length(d_ind), nJ=length(ec.firms));
    function closure_gmm(θ2)
        return m.gmm_lm(θ2, ec, pars, X1, Z; d_ind)
    end
    
    res = optimize(closure_gmm, -2., 8., show_trace = false, abs_tol= 1e-4)
else
    pars = m.set_Pars(K = length(d_ind), nJ=length(ec.firms), nI = 1);
    res = m.gmm_lm(0., ec, pars, X1, Z; d_ind)
end

serialize("$datadir/temp/res$configtag.jls", res)
share = [tt.shares for tt in ec.tracts];
mktq = [tt.q for tt in ec.tracts];
serialize("$datadir/temp/share$configtag.jls", share)
serialize("$datadir/temp/mktq$configtag.jls", mktq)

δ = pars.δs;


# subset labor expense 
if suble
    x_sub = [ff.X[x_ind][1] for ff in ec.firms]
    x_subind = x_sub .< quantile(x_sub, 0.95)
    δ_ = δ[x_subind]
    X1_ = X1[x_subind, :]
    Z_ = Z[x_subind, :]
else
    δ_ = δ
    X1_ = X1
    Z_ = Z
end


θ1res = m.compute_θ1(δ_, X1_, Z_)

println("θ1: ", θ1res)
println("θ1 without subsetting: ", m.compute_θ1(δ, X1, Z))

serialize("$datadir/temp/theta1res$configtag.jls", θ1res)

# θ1res = deserialize("$datadir/temp/theta1res$configtag.jls") #use when testing

# inputs for compute_elasticity()
n_firms = length(ec.firms)
j_indexer, t_indexer, JpositioninT = m.create_indices(ec.tracts, n_firms);

# share = deserialize("$datadir/temp/share$configtag.jls")
# mktq = deserialize("$datadir/temp/mktq$configtag.jls")

# loop over each X variable 
X_vecs = Vector{Vector{Float64}}(undef, length(θ1res));
for ii in eachindex(θ1res)
    X_vecs[ii] = X1[:,ii]
end

for ii in eachindex(θ1res)
    strii = string(ii)
    xislogged = x_ind[ii] in logged_inds #these are the logged hrpd variables
    η = m.compute_elasticity(X_vecs[ii], θ1res[ii], share, mktq, t_indexer, JpositioninT, n_firms, xislogged);
    println("Mean elasticity = ", mean(η))
    if testmode==""
        CSV.write(datadir*"/analysis/elasticities$(configtag)_$strii.csv", DataFrame((elast = η)))
    end
end


end
end