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
);


dropmissing!(df_with0s);
sort!(df_with0s, :j);

X_configs = [
    [:dchrppd],
    [:rnhrppd],
    [:lpnhrppd],
    [:cnahrppd],
    [:rnhrppd, :lpnhrppd, :cnahrppd],
    [:dchrppd, :rnhrppd],
]

Q_configs = [
    :restot,
    :nres_mcare
]

D_configs = [
    [:d],
    [:logd],
    [:d, :d2]
]


configstokeep = ["212"] #EDIT THIS

for xi in eachindex(X_configs), 
    qi in eachindex(Q_configs), 
    di in eachindex(D_configs)

    config_tag = string(xi)*string(qi)*string(di)
    if config_tag in configstokeep

        df = @subset(df_with0s, df_with0s[!, Q_configs[qi]] .> 0)
        
        firm_IDs_long = df.j;
        tract_IDs_long = df.t;

        Z_config = [:nbr_dchrppd, :nbr_rnhrppd]
        Z = Matrix(df[!, Z_config])
        
        M = df.M;
        nJ = length(unique(firm_IDs_long));
        nI = 100;
        
        println(X_configs[xi], Q_configs[qi], D_configs[di], " is ", config_tag)

        X = Matrix(df[!, X_configs[xi]])
        D = Matrix(df[!, D_configs[di]])
        Q = df[!, Q_configs[qi]]

        nD = size(D)[2]
        σ = ones(nD)

        pars = m.set_Pars(K = nD, nI = nI, δs=ones(nJ));
        
        ec = m.make_Economy(
            firm_IDs_long,
            tract_IDs_long,
            X, Z, D, Q, M, nI
        )

        serialize("$datadir/analysis/pars$config_tag$testmode.jls", pars)
        serialize("$datadir/analysis/ec$config_tag$testmode.jls", ec)
    end
end

