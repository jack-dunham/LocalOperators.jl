module LocalOperators

using LinearAlgebra

export LocalOperator
export support, minsupport, maxsupport, locality, localdim, dim

@doc raw"""
    LocalOperator{T<:Number} <: AbstractMatrix{T}

Concrete type corresponding to a matrix operator acting on a tensor product of local vector 
spaces. The operator acts as the matrix stored in the field `data` on the local
vector spaces defined by the field `support`, and as the identity elsewhere. 

# Fields
- `data::Matrix{T}`: stores the matrix represention of the operator
- `support::UnitRange{Int}`: stores the sites that the operator has support on
"""
struct LocalOperator{T<:Number} <: AbstractMatrix{T}
    data::Matrix{T}
    support::UnitRange{Int}
    function LocalOperator(
        data::AbstractMatrix{T}, support::UnitRange
    ) where {T}
        D = localdim
        n, m = size(data)
        if !(n == m)
            throw(ArgumentError("matrix size $(size(data)) is not square"))
        else 
            l = length(support)
            D = n^(1/l)
            if !(isinteger(D))
                throw(
                    ArgumentError(
                    "matrix size $(size(data)) and support $(support) results in non-integer local dimension $D"
                    ),
                )
            else
                return new{T}(data, support)
            end
        end
    end
end

const LocalOp = LocalOperator

struct LocalDimensionMismatch <: Exception
    a::LocalOp
    b::LocalOp
end

function Base.showerror(io::IO, e::LocalDimensionMismatch)
    return print(
        io,
        "LocalDimensionMismatch: local dimensions must match: a has local dim $(localdim(e.a)), b has local dim $(localdim(e.b))",
    )
end

@doc raw"""
    LocalOperator(A::AbstractMatrix, support::UnitRange{Int})
    LocalOperator(A::AbstractMatrix, i::Int=0)

Contructs a `LocalOperator` corresponding to the matrix `A` with support on the indices 
defined by the range `support`, or the single index `i` defaulting to `0`.
"""
LocalOperator(a::AbstractMatrix, i::Int=0) = LocalOperator(a, i:i)

Base.size(A::LocalOp) = size(A.data)

@doc raw"""
    support(A::LocalOperator)
Returns the support of `A` as a `UnitRange` type. That is, returns the range of indices that
the local operator `A` is defined on. Equivalent to `A.support` or `getfield(A, :support)`.
See also [`maxsupport`](@ref) and [`minsupport`](@ref).
"""
support(A::LocalOp) = A.support

@doc raw"""
    minsupport(A::LocalOperator)
Returns the lowest site index that `A` has support on. See also [`support`](@ref) and
[`maxsupport`](@ref).
"""
minsupport(A::LocalOp) = support(A)[begin]

@doc raw"""
    maxsupport(A::LocalOperator)
Returns the highest site index that `A` has support on. See also [`support`](@ref) and [`minsupport`](@ref)
"""
maxsupport(A::LocalOp) = support(A)[end]

@doc raw"""
    locality(A::LocalOperator)
Returns the locality of `A`. That is, returns the number of sites that `A` has support on.
"""
locality(A::LocalOp) = length(support(A))

@doc raw"""
    localdim(A::LocalOperator)

Returns the dimension of the *local* vector spaces that form the tensor product space that
`A` has support on.
"""
localdim(A::LocalOp) = Int( (size(A)[1])^(1 / locality(A)))

@doc raw"""
    dim(A::LocalOperator)

Returns the dimension of the tensor product space corresponding to the support of `A`. 
"""
dim(A::LocalOp) = localdim(A)^locality(A)

function Base.showarg(io::IO, A::LocalOp, toplevel)
    return print(
        io,
        "$(length(support(A)))-local ",
        typeof(A),
        " on sites ",
        minsupport(A),
        " to ",
        maxsupport(A),
    )
end

Base.getindex(A::LocalOp, i::Int) = getindex(A.data, i)
Base.setindex!(A::LocalOp, v, i::Int) = setindex!(A.data, v, i)

Base.IndexStyle(::Type{<:LocalOp}) = IndexStyle(Matrix{ComplexF64})

Base.similar(A::LocalOp) = LocalOp(similar(A.data), support(A))
function Base.similar(A::LocalOp, ::Type{<:Number}, dims::Dims)
    D = localdim(A)
    size_change = Int(log(D, dims[1]) - log(D, size(A)[1]))
    r = support(A) .+ size_change
    return LocalOp(similar(A.data, ComplexF64, dims), r)
end

# Fallback 
Base.similar(A::LocalOp, dims::Tuple{Base.OneTo{Int64}}) = similar(A.data, dims)

function promote_support(a::LocalOp, b::LocalOp)
    localdim(a) == localdim(b) || throw(LocalDimensionMismatch(a, b))
    l = min(minsupport(a), minsupport(b))
    u = max(maxsupport(a), maxsupport(b))
    return l:u
end

function promote_support(a::LocalOp, b::LocalOp, c::LocalOp, args::Vararg{<:LocalOp})
    return promote_support(promote_support(a, b), c, args...)
end

# Pad `a` on the left and right with `kl` and `kr` 2x2 identity matrices respectively.
function pad(a::LocalOp, kl::Int, kr::Int)
    return kron(1, fill(one(a), kl)..., a, fill(one(a), kr)...)
end

function fit(a::LocalOp, r::UnitRange{Int})
    kl = minsupport(a) - r[begin]
    kr = r[end] - maxsupport(a)
    return LocalOp(pad(a, kl, kr), r)
end

# Basic operations

Base.:*(x::Number, a::LocalOp) = mul!(similar(a), x, a)
Base.:*(a::LocalOp, x::Number) = mul!(similar(a), a, x)

function Base.:*(a::LocalOp, b::LocalOp)
    r = promote_support(a, b)
    aa = fit(a, r)
    bb = fit(b, r)

    cc = similar(aa)

    mul!(cc, aa, bb)

    return cc
end

function Base.:+(a::LocalOp, b::LocalOp)
    r = promote_support(a, b)
    aa = fit(a, r)
    bb = fit(b, r)

    axpy!(1, aa, bb)

    return bb
end

Base.:-(a::LocalOp, b::LocalOp) = +(a, -1 * b)

function LinearAlgebra.mul!(a::LocalOp, b::LocalOp, x::Number)
    localdim(a) == localdim(b) || throw(LocalDimensionMismatch(a, b))
    mul!(a.data, b.data, x)
    return a
end
function LinearAlgebra.mul!(a::LocalOp, x::Number, b::LocalOp)
    localdim(a) == localdim(b) || throw(LocalDimensionMismatch(a, b))
    mul!(a.data, x, b.data)
    return a
end
function LinearAlgebra.axpy!(x::Number, a::LocalOp, b::LocalOp)
    localdim(a) == localdim(b) || throw(LocalDimensionMismatch(a, b))
    axpy!(x, a.data, b.data)
    return b
end
function LinearAlgebra.axpby!(x::Number, a::LocalOp, y::Number, b::LocalOp)
    localdim(a) == localdim(b) || throw(LocalDimensionMismatch(a, b))
    axpby!(x, a.data, y, b.data)
    return b
end

function LinearAlgebra.mul!(c::LocalOp, a::LocalOp, b::LocalOp, x::Number, y::Number)
    mul!(c.data, a.data, b.data, x, y)
    return c
end

end # module LocalOperators
