push!(LOAD_PATH, "../src/")

using Documenter
using LocalOperators
import LocalOperators: LocalOperator

makedocs(
    sitename = "LocalOperators.jl",
    authors = "Jack Dunham",
    pages = [
        "Home" => "index.md",
        "Library" => "library.md",
        "Index" => ["index/index.md"]
    ]
)

deploydocs(
    repo = "github.com/jack-dunham/LocalOperators.jl.git",
)
