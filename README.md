# LocalOperators.jl

LocalOperators.jl is a simple package that exports a single `struct` type, `LocalOperator` representing an 
operator acting on a local Hilbert space. When adding, subtracting or multiplying two `LocalOperator` types together,
the appropriate number of identity matrices are padded to each on the left and right such that they are 
compatible. 
