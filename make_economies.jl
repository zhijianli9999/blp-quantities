using DataFrames, DataFramesMeta, LinearAlgebra, Distributions, Revise, Serialization, DebuggingUtilities, CSV

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__)
using BLPmodule; const m = BLPmodule;
const datadir = "/export/storage_adgandhi/MiscLi/factract";

testmodes = ["", "_FL", "_FL17"]
testmode = testmodes[1]################# EDIT THIS ##################

data = DataFrame(CSV.File("$datadir/analysis/factract"*testmode*".csv"));


df_with0s = @select(data, 
    :t = :tractyear, 
    :tract = :tractid, 
    :year, 
    :state, 
    :j = :facid, 
    :restot,
    :avg_dailycensus,
    :nres_mcare,
    :nres_mcaid,
    :M = :mktpop,
    :d = :dist, 
    :d2 = :dist .^ 2,
    :logd = [dd < 0.5 ? log(0.5) : log(dd) for dd in :dist], #winsorize at 0.5km, then take log
    :dchrppd,
    :rnhrppd,
    :lpnhrppd,
    :cnahrppd,
    :nbr_dchrppd,
    :nbr_rnhrppd,
    :dist_nbrfac
);


dropmissing!(df_with0s);
sort!(df_with0s, :j);

xvars = [:dchrppd, :rnhrppd, :lpnhrppd, :cnahrppd]
zvars = [:nbr_dchrppd, :nbr_rnhrppd, :dist_nbrfac]
qvars = [:restot, :nres_mcare]
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
