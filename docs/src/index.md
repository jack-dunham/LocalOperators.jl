```@meta
DocTestSetup = quote
    using LocalOperators
end
```

# LocalOperators.jl

LocalOperators.jl is a simple package that exports a single `struct` type, `LocalOperator` representing an operator acting on a local Hilbert space. When adding, subtracting or multiplying two `LocalOperator` types together,the appropriate number of identity matrices are padded to each on the left and right such that they are compatible. 

## Usage

LocalOperators.jl exports only a single `struct` type:

```@docs
LocalOperator
```

A `LocalOperator` can be constructed like so:

```jldoctest ztimesz
julia> d = 2;                               # Local dimension 

julia> Z = Matrix{ComplexF64}([1 0; 0 -1]); # Pauli Z matrix

julia> r = 0:0;                             # Support on site 0 only

julia> a = LocalOperator(Z, r, d)
2×2 1-local LocalOperator{ComplexF64} on sites 0 to 0:
 1.0+0.0im   0.0+0.0im
 0.0+0.0im  -1.0+0.0im
```
If the last argument to `LocalOperator` is ommited, then local dimension `d=2` is assumed.
```jldoctest ztimesz
julia> b = LocalOperator(Z, 1:1)
2×2 1-local LocalOperator{ComplexF64} on sites 1 to 1:
 1.0+0.0im   0.0+0.0im
 0.0+0.0im  -1.0+0.0im
```
We can now multiply `a` and `b` together to perform $(a \otimes 1) * (1 \otimes b)$:
```jldoctest ztimesz
julia> a * b 
4×4 2-local LocalOperator{ComplexF64} on sites 0 to 1:
 1.0+0.0im   0.0+0.0im   0.0+0.0im  0.0+0.0im
 0.0+0.0im  -1.0+0.0im   0.0+0.0im  0.0+0.0im
 0.0+0.0im   0.0+0.0im  -1.0+0.0im  0.0+0.0im
 0.0+0.0im   0.0+0.0im   0.0+0.0im  1.0+0.0im
```
We can also do addition and subtraction
```jldoctest ztimesz
julia> a + b 
4×4 2-local LocalOperator{ComplexF64} on sites 0 to 1:
 2.0+0.0im  0.0+0.0im  0.0+0.0im   0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im   0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im   0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im  -2.0+0.0im

julia> b - a 
4×4 2-local LocalOperator{ComplexF64} on sites 0 to 1:
 0.0+0.0im   0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  -2.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im   0.0+0.0im  2.0+0.0im  0.0+0.0im
 0.0+0.0im   0.0+0.0im  0.0+0.0im  0.0+0.0im
```
If two `LocalOperator` types have support on the identical sites, then we fall back to the regular operations:
```jldoctest ztimesz
julia> a - a
2×2 1-local LocalOperator{ComplexF64} on sites 0 to 0:
 0.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im
```
Operations between `LocalOperator` types with differing local dimension are not supported:
```jldoctest
julia> a = LocalOperator([1 0; 0 -1], 0:0, 2);

julia> b = LocalOperator([1 0 0; 0 0 0 ; 0 0 -1], 1:1, 3);

julia> a * b
ERROR: LocalDimensionMismatch: local dimensions must match: a has local dim 2, b has local dim 3
[...]
```

```@meta
DocTestSetup = nothing
```