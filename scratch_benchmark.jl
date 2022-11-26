# this is just for pasting into command line. 



julia --track-allocation=user
using Serialization, Profile;
using ProfileView;

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

ec = deserialize("ec.jls"); 
m.compute_deltas(ec,max_iter=1);

Profile.clear_malloc_data()

ec = deserialize("ec.jls"); 
# m.compute_deltas(ec,max_iter=10);
ProfileView.@profview m.compute_deltas(ec,max_iter=10);

exit()




# @code_warntype m.compute_deltas(ec, max_iter=1000);
# @code_warntype m.compute_deltas(ec, max_iter=1000);

--


julia 
using Coverage
analyze_malloc(".")

exit()






--


find . -name '*.mem' -delete







---

