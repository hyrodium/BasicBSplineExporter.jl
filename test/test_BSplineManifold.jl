DIR = joinpath("tmp","BSplineManifold")
rm(DIR, force=true, recursive=true)
mkpath(DIR)

@testset "BSplineManifold" begin
    Random.seed!(42)

    @testset "parabola" begin
        path = joinpath(DIR, "parabola.png")

        # Draw a parabola with BasicBSplineExporter.jl
        p = 2
        k = KnotVector([0,0,0,1,1,1])
        P = BSplineSpace{p}(k)
        a = [
            SVector( -2, 4),
            SVector( 0, -4),
            SVector( 2, 4),
        ]
        M = BSplineManifold(a,P)
        save_png(path, M;
                 xlims=(-2,2),
                 ylims=(-2,2),
                 thickness=20,
                 points=false,
                 unitlength=100,
                 maincolor=RGB(0,1,1),
        )

        # Draw a parabola with Images.jl
        function draw_parabola()
            img = fill(RGB(1),400,400)
            d = 0.2
            for i in 1:400, j in 1:400
                x = (j - 200.5)/100
                y = -(i - 200.5)/100
                a = [(x+d*cospi(t))^2 < y+d*sinpi(t) for t in 0:(1/6):2]
                if any(a) ≠ all(a)
                    img[i,j] = RGB(0,1,1)
                end
            end
            return img
        end

        # Check these are almost same images.
        diff = draw_parabola() .≈ load(path)
        @test count(diff)/prod(size(diff)) > 0.99
    end

    @testset "1d2d" begin
        p = 3 # degree of polynomial
        k = KnotVector(1:12) # knot vector
        P = BSplineSpace{p}(k) # B-spline space
        rand_a = [randn(2) for i in 1:dim(P)] / 2
        a = [SVector(2i-6, 0) for i in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(a, (P,)) # Define B-spline manifold

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
        a = [SVector(2i-6, 2j-6) for i in 1:dim(P), j in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(a, (P, P)) # Define B-spline manifold

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
        a = [SVector(2i-6, 2i-6, 0) for i in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(a, (P,)) # Define B-spline manifold

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
        a = [SVector(2i-6, 2j-6, 0) for i in 1:dim(P), j in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(a, (P, P)) # Define B-spline manifold

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
        a = [SVector(2i-6, 2j-6, 2k-6) for i in 1:dim(P), j in 1:dim(P), k in 1:dim(P)] + rand_a # random generated control points
        M = BSplineManifold(a, (P, P, P)) # Define B-spline manifold

        @testset "povray" begin
            path = joinpath(DIR, "3d3d.inc")
            save_pov(path, M, maincolor=RGBA(0.5,0.1,1,0.8))
            @test isfile(path)
        end
    end
end
