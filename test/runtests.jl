using LocalOperators
using Test
using TestSetExtensions

@testset ExtendedTestSet "All tests" begin
    Z = [1 0; 0 -1]
    X = [0 1; 1 0]
    idd = [1 0; 0 1]
    M_r = [1 0 0; 0 0 1]
    S = [1 0 0; 0 0 0; 0 0 -1]
    A = [1 0 0 1; 0 1 0 0; 0 0 1 0; 1 0 0 1]
    @testset "Constructors" begin
        @test_throws ArgumentError LocalOperator(M_r, 0:0)
        @test_throws ArgumentError LocalOperator(S, 0:1)
        @test LocalOperator(Z, -1) == LocalOperator(Z, -1:-1)
        @test LocalOperator(Z) == LocalOperator(Z, 0:0)
    end
    @testset "`AbstractMatrix`" begin
        @test eltype(LocalOperator(Z)) == eltype(Z)
        # setindex!
        Z_l = LocalOperator(Z)
        @test (Z_l[2, 2] = 1) == 1
        @test Z_l == one(Z_l)
    end
    @testset "Functions" begin
        Z_l = LocalOperator(Z)
        A_l = LocalOperator(A, 0:1)
        S_l = LocalOperator(S, 2:2)
        @test size(Z) == size(Z_l)
        @testset "`support`, `minsupport`, `maxsupport`" begin
            @test typeof(support(LocalOperator(Z, 3))) == UnitRange{Int}
            @test typeof(support(Z_l)) == UnitRange{Int}
            @test support(LocalOperator(Z, -1)) == -1:-1
            @test support(Z_l) == 0:0
            @test minsupport(Z_l) == maxsupport(Z_l) == 0
            @test minsupport(A_l) == 0
            @test maxsupport(A_l) == 1
        end
        @testset "`locality`, `localdim`, `dim`" begin
            @test locality(Z_l) == 1
            @test locality(S_l) == 1
            @test locality(A_l) == 2
            @test localdim(Z_l) == localdim(A_l) == 2
            @test localdim(S_l) == 3
            @test dim(Z_l) == localdim(Z_l) == 2
            @test dim(A_l) == 4
        end
    end
    @testset "Operations" begin
        Z_1 = LocalOperator(Z, 1)
        X_2 = LocalOperator(X, 2)
        idd_3 = LocalOperator(idd, 3)
        A_23 = LocalOperator(A, 2:3)
        @testset "Addition" begin
            @test (Z_1 + Z_1).data == Z + Z
            @test (Z_1 + Z_1 + Z_1).data == 3 * Z
            @test (Z_1 + X_2 + idd_3).data ==
                kron(Z, one(Z), one(Z)) +
                kron(one(X), X, one(X)) +
                kron(one(idd), one(idd), idd)
        end
        @testset "Subtraction" begin
            @test (A_23 - A_23).data == zero(A)
        end
        @testset "Multiplication" begin
            @test (Z_1 * X_2).data == kron(Z, one(Z)) * kron(one(X), X)
            @test (X_2 * Z_1).data == kron(one(X), X) * kron(Z, one(Z))
            @test (Z_1 * A_23).data == kron(Z, one(Z), one(Z)) * kron(one(Z), A)
            @test (Z_1 * X_2 * idd_3).data ==
                kron(Z, one(Z), one(Z)) *
                kron(one(X), X, one(X)) *
                kron(one(idd), one(idd), idd)
        end
    end
end
