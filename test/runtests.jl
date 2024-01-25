using BasicBSplineExporter
using Test
using Aqua
using Random
using BasicBSpline
using Colors
using Images
using StaticArrays
import BasicBSplineExporter._arrayofvector2array
import BasicBSplineExporter._array2arrayofvector

Aqua.test_all(BasicBSplineExporter)

@testset "BasicBSplineExporter.jl" begin
    Random.seed!(42)
    include("test_BSplineManifold.jl")
end
