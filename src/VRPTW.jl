module VRPTW

using Revise, JLD2

# Write your package code here.
include("func.jl")
include("load_data.jl")
include("solution.jl")

# export function that clould be used
export load_solomon_data, dir, dir_data, Solution, Problem, swap!, add!

end
