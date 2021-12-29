DIR = joinpath("temporary","BSplineManifold")
rm(DIR, force=true, recursive=true)
mkpath(DIR)

@testset "BSplineManifold" begin
    Random.seed!(42)

    @testset "1d2d" begin
        p = 3 # degree of polynomial
        k = KnotVector(1:12) # knot vector
        P = BSplineSpace{p}(k) # B-spline space
        rand_a = [randn(2) for i in 1:dim(P)] / 2
        a = [[2 * i - 6, 0] for i in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(_arrayofvector2array(a), (P,)) # Define B-spline manifold

        @testset "luxor-svg" begin
            path = joinpath(DIR, "1d2d.svg")
            save_svg(path,M)
            @test isfile(path)
        end
        @testset "luxor-png" begin
            path = joinpath(DIR, "1d2d.png")
            save_png(path,M)
            @test isfile(path)
        end
    end

    @testset "2d2d" begin
        p = 3 # degree of polynomial
        k = KnotVector(1:12) # knot vector
        P = BSplineSpace{p}(k) # B-spline space
        rand_a = [randn(2) for i in 1:dim(P), j in 1:dim(P)] / 2
        a = [[2 * i - 6, 2 * j - 6] for i in 1:dim(P), j in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(_arrayofvector2array(a), (P, P)) # Define B-spline manifold

        @testset "luxor-svg" begin
            path = joinpath(DIR, "2d2d.svg")
            save_svg(path,M)
            @test isfile(path)
        end
        @testset "luxor-png" begin
            path = joinpath(DIR, "2d2d.png")
            save_png(path,M)
            @test isfile(path)
        end
        @testset "luxor-color-a-png" begin
            color(u1,u2) = rand(RGB)
            path = joinpath(DIR, "2d2d_color-a.png")
            save_png(path, M, color)
            @test isfile(path)
        end
        @testset "luxor-color-b-png" begin
            n1, n2 = dim.(bsplinespaces(M))
            colors = rand(RGB,n1,n2)
            path = joinpath(DIR, "2d2d_color-b.png")
            save_png(path, M, colors)
            @test isfile(path)
        end
    end

    @testset "1d3d" begin
        p = 4 # degree of polynomial
        k = KnotVector(rand(12)) # knot vector
        P = BSplineSpace{p}(k) # B-spline space
        rand_a = [randn(3) for i in 1:dim(P)]
        a = [[2 * i - 6, 2 * i - 6, 0] for i in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(_arrayofvector2array(a), (P,)) # Define B-spline manifold

        @testset "povray" begin
            path = joinpath(DIR, "1d3d.inc")
            save_pov(path,M)
            @test isfile(path)
        end
    end

    @testset "2d3d" begin
        p = 3 # degree of polynomial
        k = KnotVector(1:12) # knot vector
        P = BSplineSpace{p}(k) # B-spline space
        rand_a = [randn(3) for i in 1:dim(P), j in 1:dim(P)] / 2
        a = [[2 * i - 6, 2 * j - 6, 0] for i in 1:dim(P), j in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(_arrayofvector2array(a), (P, P)) # Define B-spline manifold

        @testset "povray" begin
            path = joinpath(DIR, "2d3d.inc")
            save_pov(path, M , maincolor=RGBA(0,1,1,0.95))
            @test isfile(path)
        end
    end

    @testset "3d3d" begin
        p = 3 # degree of polynomial
        k = KnotVector(1:12) # knot vector
        P = BSplineSpace{p}(k) # B-spline space
        rand_a = [randn(3) for i in 1:dim(P), j in 1:dim(P), k in 1:dim(P)] / 4
        a = [[2 * i - 6, 2 * j - 6, 2 * k - 6] for i in 1:dim(P), j in 1:dim(P), k in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(_arrayofvector2array(a), (P, P, P)) # Define B-spline manifold

        @testset "povray" begin
            path = joinpath(DIR, "3d3d.inc")
            save_pov(path, M, maincolor=RGBA(0.5,0.1,1,0.8))
            @test isfile(path)
        end
    end
end
