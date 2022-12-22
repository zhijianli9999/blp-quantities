
using DataFrames, Optim, Revise, Serialization, DebuggingUtilities, CSV, Statistics

const datadir = "/export/storage_adgandhi/MiscLi/factract";
string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

################# EDIT ,,, ##################
q_ind = 2 #which q variable. 1=restot, 2=nres_mcare
d_ind = [3] #which distance variable. 1=d, 2=d2, 3=log(d)
x_ind = [1,2] #which x variable out of  [dchrppd, rnhrppd, lpnhrppd, cnahrppd]
testmodes = ["", "_FL", "_FL17"]
testmode = testmodes[3]
################# EDIT ^^^ ##################

nD = length(d_ind)

ec = deserialize("$datadir/analysis/ec$q_ind$testmode.jls");
pars = m.set_Pars(K = nD, nJ=length(ec.firms));

# linear characteristics (staffing variables):
X1 = vcat(transpose.([ec.firms[i].X[x_ind] for i in eachindex(ec.firms)])...);
Z = vcat(transpose.([ec.firms[i].Z for i in eachindex(ec.firms)])...);

function closure_gmm(θ2)
    return m.gmm_lm(θ2, ec, pars, X1, hcat(Z,X1); d_ind)
end

res = optimize(closure_gmm, -1., 10., show_trace= true, abs_tol= 1e-4)

serialize("$datadir/temp/res$q_ind$testmode.jls", res)

θ2res = Optim.minimizer(res)
δ = pars.δs
θ1res = X1 \ δ

serialize("$datadir/temp/theta1res$q_ind$testmode.jls", θ1res)
θ1res = deserialize("$datadir/temp/theta1res$q_ind$testmode.jls") #use when testing

# input for compute_elasticity()
n_firms = length(ec.firms)
j_indexer, t_indexer, JpositioninT = m.create_indices(ec.tracts, n_firms);


X_vecs = Vector{Vector{Float64}}(undef, length(θ1res))
for ii in eachindex(θ1res)
    X_vecs[ii] = [jj.X[ii] for jj in ec.firms]
end
share = [tt.shares for tt in ec.tracts];
mktq = [tt.q for tt in ec.tracts];

# TODO:add config tag to save path
for ii in eachindex(θ1res)
    strii = string(ii)
    η = m.compute_elasticity(X_vecs[ii], θ1res[ii], share, mktq, t_indexer, JpositioninT, n_firms);
    println(mean(η))
    CSV.write(datadir*"/analysis/elasticities$q_ind$(testmode)_$strii.csv", DataFrame((elast = η)))
end
