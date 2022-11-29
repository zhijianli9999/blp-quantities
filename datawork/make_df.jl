using DataFrames, DataFramesMeta, Revise, CSV, Serialization

const datadir = "/export/storage_adgandhi/MiscLi/factract";

test1state = true
if test1state 
    data = DataFrame(CSV.File("$datadir/analysis/factract_FL.csv"));
else
    data = DataFrame(CSV.File("$datadir/analysis/factract.csv"));
end;

# This is the dataframe with every fac-tract combination within some dist threshold
# println(names(data))
df = @select(data, 
    :t = :tractid, 
    :j = :facid, 
    :q = :restot,
    :M = :mktpop,
    :d = :dist ./ 100, 
    :d2 = (:dist ./ 100) .^ 2,
    :x1 = :dchrppd,
    :x2 = :rnhrppd
);

sort!(df, :j);
serialize("jls/df.jls", df);

