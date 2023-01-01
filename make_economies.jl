using DataFrames, DataFramesMeta, LinearAlgebra, Distributions, Revise, Serialization, DebuggingUtilities, CSV

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;
const datadir = "/export/storage_adgandhi/MiscLi/factract";

# testmodes = [""]
testmodes = ["_FL17", ""]
for testmode in testmodes
################# EDIT THIS ##################

data = DataFrame(CSV.File("$datadir/analysis/factract"*testmode*".csv"));

dropmissing!(data);

df_with0s = @select(data, 
    :t = :tractyear, 
    :tract = :tractid, 
    :year, 
    :state, 
    :j = :facid, 
    :restot,
    :avg_dailycensus,
    :nres_mcare,
    :nres_nonmcaid,
    :nres_mcaid,
    :M = :mktpop,
    :d = :dist, 
    :d2 = :dist .^ 2,
    :logd = [dd < 0.5 ? log(0.5) : log(dd) for dd in :dist], #winsorize at 0.5km, then take log
    :dchrppd,
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
    :rn_frac,
    :nbr_dchrppd,
    :nbr_rnhrppd,
    :dist_nbrfac,
    :competitors_in5,
    :competitors_in20
);


dropmissing!(df_with0s); #will drop first year
sort!(df_with0s, :j);

xvars = [
    :dchrppd,
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

zvars = [:nbr_dchrppd, :nbr_rnhrppd, :dist_nbrfac, :competitors_in5, :competitors_in20]
qvars = [:restot, :nres_mcare, :nres_nonmcaid]
dvars = [:d, :d2, :logd]

for qii in eachindex(qvars)
    qvar = qvars[qii]
    df = @subset(df_with0s, df_with0s[!,qvar] .> 0.)

    firm_IDs_long = df.j;
    tract_IDs_long = df.t;

    
    M = df.M;
    nJ = length(unique(firm_IDs_long));
    nI = 100;
    
    X = Matrix(df[!, xvars])
    Z = Matrix(df[!, zvars])
    D = Matrix(df[!, dvars])
    Q = df[!, qvar]

    ec = m.make_Economy(
        firm_IDs_long,
        tract_IDs_long,
        X, Z, D, Q, M, nI
    )

    serialize("$datadir/analysis/ec$qii$testmode.jls", ec)
end
end