using DataFrames, DataFramesMeta, LinearAlgebra, Distributions, Revise, Serialization, DebuggingUtilities, CSV, FixedEffectModels, Optim, Parameters

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

##
const datadir = "/export/storage_adgandhi/MiscLi/factract";

testtag = "";
testtag = "_FL17";
# testtag = "_FL";

vars_toload = m.Vars(
    tvar = :tractyear,
    jvar = :facyr,
    xvars = [:labor_expense, :loglabor_expense],
    zvars = [:nbr_dchrppd, :nbr_rnhrppd, :nbr_lpnhrppd, :nbr_cnahrppd, :dist_nbrfac, :competitors_in5, :competitors_in20],
    fevars = [:statecounty, :year],
    qvar = :nres_mcare,
    mvar = :mktpop,
    dvars = [:logd]
);

ec, fac_df = m.load_economy(
    datadir*"/analysis/factract"*testtag*".csv",
    datadir*"/analysis/fac"*testtag*".csv",
    vars_toload
);

pars = m.set_Pars(K = 1, nJ=length(ec.q_obs));

vars_toreg = deepcopy(vars_toload);
vars_toreg.xvars = [:labor_expense];

function closure_gmm(θ2)
    return m.gmm_lm(θ2, ec, pars, fac_df, vars_toreg)
end;

res = optimize(closure_gmm, -2., 8., show_trace = false, abs_tol= 1e-4)

share = [tt.shares for tt in ec.tracts];
mktq = [tt.q for tt in ec.tracts];
δ = pars.δs;
θ1res = m.compute_θ1(δ, fac_df)
n_firms = length(ec.q_obs);
j_indexer, t_indexer, JpositioninT = m.create_indices(ec.tracts, n_firms);


for ii in eachindex(vars_toreg.xvars)
    x_vals = fac_df[!, xvars]
    strii = string(ii)
    xislogged = (minimum(x_vals) < 0.)
    η = m.compute_elasticity(x_vals, θ1res[ii], share, mktq, t_indexer, JpositioninT, n_firms, xislogged);
    println("Mean elasticity = ", mean(η))
    if testtag==""
        CSV.write(datadir*"/analysis/elasticities_$strii.csv", DataFrame((facyr = fac_df.j, elast = η)))
    end
    describe(η)
end
# 

######


# 



#TODO: save things

# fevars = [:statecounty, :year]
# for ii in eachindex(fevars)
#     rename!(fac_df, fevars[ii] => "fe$ii")
# end


# fac_path = datadir*"/analysis/fac"*testtag*".csv"
# fac = DataFrame(CSV.File(fac_path));
# names(fac)

# xvars = [:labor_expense, :loglabor_expense]
# dropmissing!(fac, cat(xvars, qvar, dims = 1));
