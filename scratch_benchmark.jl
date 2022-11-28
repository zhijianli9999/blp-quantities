# this is just for pasting into command line. 



find . -name '*.mem' -delete
# julia --track-allocation=user
julia --track-allocation=all
# julia
using Serialization, Profile;

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

ec = deserialize("ec.jls"); 
m.compute_deltas(ec,max_iter=1, verbose=false)

ec = deserialize("ec.jls"); 

Profile.clear_malloc_data()
m.compute_deltas(ec,max_iter=10, verbose=false)


# ec = deserialize("ec.jls"); 
# m.compute_deltas(ec,max_iter=1000, verbose=false)
# ProfileView.@profview m.compute_deltas(ec,max_iter=10);

exit()




# @code_warntype m.compute_deltas(ec, max_iter=1000);
# @code_warntype m.compute_deltas(ec, max_iter=1000);

--


julia 
using Coverage, Profile
analyze_malloc(".")
exit()





