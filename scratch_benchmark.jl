



julia --track-allocation=user
# using DataFrames, Serialization, LinearAlgebra, Parameters
using Serialization, Profile, Revise;

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

ec = deserialize("ec.jls"); 
m.compute_deltas(ec,max_iter=1)

Profile.clear_malloc_data()

ec = deserialize("ec.jls"); 
m.compute_deltas(ec,max_iter=10)

exit()




--



julia 
using Coverage
analyze_malloc(".")

exit()





---



ec = deserialize("ec.jls"); 
@time m.compute_deltas(ec,max_iter=1000)



# m.compute_deltas(ec,max_iter=100)
