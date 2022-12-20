
using DataFrames, Optim, Revise, Serialization, DebuggingUtilities

const datadir = "/export/storage_adgandhi/MiscLi/factract";
string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

testmodes = ["full", "fl", "fl17"]
testmode = testmodes[1]################# EDIT THIS ##################

pars = deserialize("$datadir/analysis/pars.jls");
ec = deserialize("$datadir/analysis/ec$testmode.jls");
# linear characteristics (staffing variables):
X1 = vcat(transpose.([ec.firms[i].X for i in eachindex(ec.firms)])...);
Z = vcat(transpose.([ec.firms[i].Z for i in eachindex(ec.firms)])...);
# closure 
function closure_gmm(θ2)
    return m.gmm_lm(θ2, ec, pars, X1, hcat(Z,X1))
end

res = optimize(closure_gmm, -1., 1., show_trace= true, abs_tol= 1e-4)

initial_θ2 = [0.]
# res = optimize(closure_gmm, initial_θ2, LBFGS(), Optim.Options(show_trace = true))

serialize("/mnt/staff/zhli/blp-quantities/jls/res.jls", res)
# res = deserialize("/mnt/staff/zhli/blp-quantities/jls/res.jls")
θ2res = Optim.minimizer(res)
δ, _ = m.compute_deltas(ec, pars, θ2res, verbose = true)
θ1res = X1 \ δ
serialize("/mnt/staff/zhli/blp-quantities/jls/theta1res.jls", θ1res)

n_firms = length(ec.firms)
j_indexer, t_indexer, positionin = m.create_indices(ec.tracts, n_firms);
share = cat([tt.shares for tt in ec.tracts]..., dims=1)
mktq = cat([tt.q for tt in ec.tracts]..., dims=1)
X_dc = [t.X[:,[1]] for t in tracts];
X_rn = [t.X[:,[2]] for t in tracts];

η_dc = m.compute_elasticity(X_dc, [θ1res[1]], share, mktq, t_indexer, positionin, n_firms);
η_rn = m.compute_elasticity(X_rn, [θ1res[2]], share, mktq, t_indexer, positionin, n_firms);

println(mean(η_dc))
println(mean(η_rn))

