push!(LOAD_PATH,"../src/")

using Documenter
using LocalOperators
import LocalOperators: LocalOperator

makedocs(sitename="LocalOperators.jl")

deploydocs(
    repo = "github.com/jack-dunham/LocalOperators.jl.git",
)
