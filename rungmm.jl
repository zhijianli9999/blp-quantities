xvars = [:labor_expense,
    :labor_expense_lag,
    :loglabor_expense,
    :loglabor_expense_lag
]


logged_inds = [3, 4] # for the modified elasticity computation
qvars = [:nres_mcare, :nres_nonmcaid]

using DataFrames, Optim, Revise, Serialization, DebuggingUtilities, CSV, Statistics, FixedEffectModels

const datadir = "/export/storage_adgandhi/MiscLi/factract";
string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;


################# EDIT ,,, ##################

d_ind = [3] #which distance variable. 1=d, 2=d2, 3=log(d)

testmodes = ["_FL17",2 ""]
testmode = testmodes[2] #1 is testing, 2 is full

suble = false #select only a subset facilities based on (log)labor_expense(_lag)

fe_ind = [1, 2]
x_ind = [3]
q_ind = 1

for x_ind in [[1], [3], [2], [4]] # x_ind: which x variable 

for q_ind in [1] #which q variable. 1=nres_mcare, 2=nres_nonmcaid

################# EDIT ^^^ ##################

println("*** Starting GMM with new configuration ***")
println("X variable: ", xvars[x_ind])
println("Q variable: ", qvars[q_ind])
x_tag = join(string.(x_ind))
d_tag = join(string.(d_ind))
configtag = "$(q_ind)_$(x_tag)_$(d_tag)$testmode"

ec = deserialize("$datadir/analysis/ec$q_ind$testmode.jls");

# linear characteristics (staffing variables):
X1 = vcat(transpose.([ec.firms[ii].X[x_ind] for ii in eachindex(ec.firms)])...);

# fixed effects
FE = vcat(transpose.([ec.firms[ii].FE[fe_ind] for ii in eachindex(ec.firms)])...);

# instruments
Z = vcat(transpose.([ec.firms[ii].Z for ii in eachindex(ec.firms)])...);

xnames = ["x$ii" for ii in 1:size(X1)[2]]
fenames = ["fe$ii" for ii in 1:size(FE)[2]]
znames = ["z$ii" for ii in 1:size(Z)[2]]
colnames = cat(xnames, fenames, znames, dims =1)
fac_df = DataFrame(hcat(X1, FE, Z), colnames)

pars = m.set_Pars(K = length(d_ind), nJ=length(ec.firms));
function closure_gmm(θ2)
    return m.gmm_lm(θ2, ec, pars, fac_df; d_ind)
end

res = optimize(closure_gmm, -2., 8., show_trace = false, abs_tol= 1e-4)

serialize("$datadir/temp/res$configtag.jls", res)
share = [tt.shares for tt in ec.tracts];
mktq = [tt.q for tt in ec.tracts];
serialize("$datadir/temp/share$configtag.jls", share)
serialize("$datadir/temp/mktq$configtag.jls", mktq)
serialize("$datadir/temp/pars$configtag.jls", pars)

δ = pars.δs;


# ### testing
# q_obs = ec.q_obs;
# x_sub = [ff.X[x_ind][1] for ff in ec.firms];
# x_subind = x_sub .< quantile(x_sub, 0.95);
# δ_ = δ[x_subind];
# X1_ = X1[x_subind, :];
# q_obs_subset = ec.q_obs[x_subind];

# cor(δ, q_obs)
# cor(δ, X1)
# cor(q_obs, X1)

# cor(δ_, q_obs_subset)
# cor(δ_, X1_)
# cor(q_obs_subset, X1_)
# ###

# subset labor expense 
if suble
    x_sub = [ff.X[x_ind][1] for ff in ec.firms]; 
    x_subind = x_sub .< quantile(x_sub, 0.95); 
    δ_ = δ[x_subind]; 
    X1_ = X1[x_subind, :]; 
    Z_ = Z[x_subind, :]; 
else
    δ_ = δ;
    X1_ = X1;
    Z_ = Z;
end


θ1res = m.compute_θ1(δ_, fac_df)

println("θ1: ", θ1res)
# println("θ1 without subsetting: ", m.compute_θ1(δ, X1, Z))

serialize("$datadir/temp/theta1res$configtag.jls", θ1res)
serialize("$datadir/temp/delta$configtag.jls", δ_)

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
    xislogged = x_ind[ii] in logged_inds #these are the logged hrppd variables
    η = m.compute_elasticity(X_vecs[ii], θ1res[ii], share, mktq, t_indexer, JpositioninT, n_firms, xislogged);
    println("Mean elasticity = ", mean(η))
    if testmode==""
        CSV.write(datadir*"/analysis/elasticities$(configtag)_$strii.csv", DataFrame((id = [ff.ID for ff in ec.firms], elast = η)))
    end
    describe(η)
end


end
end