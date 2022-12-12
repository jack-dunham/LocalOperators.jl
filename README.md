# LocalOperators.jl

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://jack-dunham.github.io/LocalOperators.jl/dev/

[ci-img]: https://github.com/jack-dunham/LocalOperators.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/jack-dunham/LocalOperators.jl/actions?query=workflow%3ACI

[ci-nightly-img]: https://github.com/jack-dunham/LocalOperators.jl/workflows/CI%20Julia%20nightly/badge.svg
[ci-nightly-url]: https://github.com/jack-dunham/LocalOperators.jl/actions?query=workflow%3A%22CI+Julia+nightly%22

[codecov-img]: https://codecov.io/gh/jack-dunham/LocalOperators.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/jack-dunham/LocalOperators.jl


[![][docs-dev-img]][docs-dev-url] [![CI][ci-img]][ci-url] [![CI (Julia nightly)][ci-nightly-img]][ci-nightly-url] [![][codecov-img]][codecov-url]

LocalOperators.jl is a simple package that exports a single `struct` type, `LocalOperator` representing an operator acting on a local Hilbert space. When adding, subtracting or multiplying two `LocalOperator` types together, the appropriate number of identity matrices are padded to each on theleft and right such that they are compatible. 
