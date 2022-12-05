# LocalOperators.jl

LocalOperators.jl is a simple package that exports a single `struct` type, `LocalOperator` representing an 
operator acting on a local Hilbert space. When adding, subtracting or multiplying two `LocalOperator` types together,
the appropriate number of identity matrices are padded to each on the left and right such that they are 
compatible. 

## Usage

A `LocalOperator` can be constructed wit

```julia
d = 2; # Local dimension 
Z = Matrix{ComplexF64}([1 0; 0 1]); # Pauli Z matrix
r = 0:0 # Support on site 0

a = LocalOperator(Z, r, d)
```
