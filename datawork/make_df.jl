using DataFrames, DataFramesMeta, Revise, CSV, Serialization

const datadir = "/export/storage_adgandhi/MiscLi/factract";


# test mode
test1state = false
if test1state 
    data = DataFrame(CSV.File("$datadir/analysis/factract_FL.csv"));
    dirpath = "/export/storage_adgandhi/MiscLi/factract/analysis"
else
    data = DataFrame(CSV.File("$datadir/analysis/factract.csv"));
    dirpath = "jls"
end;

# Get dataframe made in make_df.jl
savepath = ("$dirpath/df.jls");


# This is the dataframe with every fac-tract combination within some dist threshold
# println(names(data))
df = @select(data, 
    :t = :tractid, 
    :j = :facid, 
    :q = :restot,
    # :q = :avg_dailycensus,
    :M = :mktpop,
    :d = :dist ./ 100, 
    :d2 = (:dist ./ 100) .^ 2,
    :x1 = :dchrppd,
    :x2 = :rnhrppd,
    :z1 = :nbr_dchrppd,
    :z2 = :nbr_rnhrppd,
);

sort!(df, :j);
serialize(savepath, df);


