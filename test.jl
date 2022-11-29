println(Threads.nthreads())
using Serialization, Revise
using BenchmarkTools
string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;
ec = deserialize("jls/ec.jls");
it = 1000;
@benchmark m.compute_deltas(ec,max_iter=it, verbose=true)


