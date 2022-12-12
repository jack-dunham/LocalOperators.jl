using LocalOperators
using Test
using TestSetExtensions

@testset ExtendedTestSet "All tests" begin
    Z = [1 0 ; 0 -1]
    M_r = [1 0 0; 0 0 1]
    S = [1 0 0 ; 0 0 0; 0 0 -1]
    A = [1 0 0 1; 0 1 0 0; 0 0 1 0; 1 0 0 1]
    @testset "Constructors" begin
        @test_throws "not square" LocalOperator(M_r, 0:0) 
        @test_throws "local dimension" LocalOperator(S, 0:1) 
        @test LocalOperator(Z, -1) == LocalOperator(Z, -1:-1)
        @test LocalOperator(Z) == LocalOperator(Z, 0:0)
    end
    @testset "`AbstractMatrix`" begin
        @test eltype(LocalOperator(Z)) == eltype(Z)
        # setindex!
        Z_l = LocalOperator(Z)
        @test (Z_l[2,2] = 1) == 1
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
end
