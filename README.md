# yourmomsnamewasjulia

yourmomsnamewasjulia

## to run gravsim_vectorized_gpu.jl

- requirements:
  - run julia, then in interpreter
    - using Pkg; Pkg.add("SimpleDirectMediaLayer")
    - using Pkg; Pkg.add("CUDA")
- export JULIA_NUM_THREADS=8
- $ julia --threads=8 gravsim_vectorized_gpu.jl
- slowly crank the number of bodies up

## TRY

- paralelized iterator test?
- matricized operations?
- make vector classes?
- run some shit on the gpu??
