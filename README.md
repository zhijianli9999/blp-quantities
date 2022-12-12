1) Data work: produce data at the facility-tract level (within distance threshold)

2) `make_economies.jl`: use `make.jl` to create `Economy` and `EconomyPars` (objects defined in `structs.jl`).

3)
   - `nlls.ipynb`: Non-linear least squares
   - `gmm.ipynb`: BLP


`BLPmodule`: 
   - `solve` and `gmm` are for BLP model
   - `nlls` is for non-linear least squares
   - `structs` is for defining structs, `make` has functions to instantiate them.
   - `elasticity` computes elasticities.
