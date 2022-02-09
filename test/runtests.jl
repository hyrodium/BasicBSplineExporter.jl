using BasicBSplineExporter
using Test
using Random
using BasicBSpline
using Colors
using StaticArrays
import BasicBSplineExporter._arrayofvector2array
import BasicBSplineExporter._array2arrayofvector

@testset "BasicBSplineExporter.jl" begin
    Random.seed!(42)
    include("test_BSplineManifold.jl")
end
