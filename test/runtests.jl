using ExportNURBS
using Test
using Random
using BasicBSpline
using Colors

@testset "ExportNURBS.jl" begin
    Random.seed!(42)

    @testset "1d2d" begin
        p = 3 # degree of polynomial
        k = Knots(1:12) # knot vector
        P = FastBSplineSpace(p, k) # B-spline space
        rand_a = [randn(2) for i in 1:dim(P)] / 2
        a = [[2 * i - 6, 0] for i in 1:dim(P)] + rand_a # random generated control points
        M = BSplineCurve([P], a) # Define B-spline manifold

        @testset "luxor-svg" begin
            save_svg("1d2d.svg",M)
            @test isfile("1d2d.svg")
        end
        @testset "luxor-png" begin
            save_png("1d2d.png",M)
            @test isfile("1d2d.png")
        end
    end

    @testset "2d2d" begin
        p = 3 # degree of polynomial
        k = Knots(1:12) # knot vector
        P = FastBSplineSpace(p, k) # B-spline space
        rand_a = [randn(2) for i in 1:dim(P), j in 1:dim(P)] / 2
        a = [[2 * i - 6, 2 * j - 6] for i in 1:dim(P), j in 1:dim(P)] + rand_a # random generated control points
        M = BSplineSurface([P, P], a) # Define B-spline manifold

        @testset "luxor-svg" begin
            save_svg("2d2d.svg",M)
            @test isfile("2d2d.svg")
        end
        @testset "luxor-png" begin
            save_png("2d2d.png",M)
            @test isfile("2d2d.png")
        end
        @testset "luxor-color-png" begin
            color(u) = rand(RGB)
            save_png("2d2d_color.png", M, color)
            @test isfile("2d2d_color.png")
        end
    end

    @testset "1d3d" begin
        p = 4 # degree of polynomial
        k = Knots(rand(12)) # knot vector
        P = FastBSplineSpace(p, k) # B-spline space
        rand_a = [randn(3) for i in 1:dim(P)]
        a = [[2 * i - 6, 2 * i - 6, 0] for i in 1:dim(P)] + rand_a # random generated control points
        M = BSplineCurve([P], a) # Define B-spline manifold

        @testset "povray" begin
            save_pov("1d3d.inc",M)
            @test isfile("1d3d.inc")
        end
    end

    @testset "2d3d" begin
        p = 3 # degree of polynomial
        k = Knots(1:12) # knot vector
        P = FastBSplineSpace(p, k) # B-spline space
        rand_a = [randn(3) for i in 1:dim(P), j in 1:dim(P)] / 2
        a = [[2 * i - 6, 2 * j - 6, 0] for i in 1:dim(P), j in 1:dim(P)] + rand_a # random generated control points
        M = BSplineSurface([P, P], a) # Define B-spline manifold

        @testset "povray" begin
            save_pov("2d3d.inc", M , maincolor=RGBA(0,1,1,0.95))
            @test isfile("2d3d.inc")
        end
    end

    @testset "3d3d" begin
        p = 3 # degree of polynomial
        k = Knots(1:12) # knot vector
        P = FastBSplineSpace(p, k) # B-spline space
        rand_a = [randn(3) for i in 1:dim(P), j in 1:dim(P), k in 1:dim(P)] / 4
        a = [[2 * i - 6, 2 * j - 6, 2 * k - 6] for i in 1:dim(P), j in 1:dim(P), k in 1:dim(P)] + rand_a # random generated control points
        M = BSplineSolid([P, P, P], a) # Define B-spline manifold

        @testset "povray" begin
            save_pov("3d3d.inc", M, maincolor=RGBA(0.5,0.1,1,0.8))
            @test isfile("3d3d.inc")
        end
    end
end
