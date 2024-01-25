# BasicBSplineExporter

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://hyrodium.github.io/BasicBSpline.jl/stable/basicbsplineexporter/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://hyrodium.github.io/BasicBSpline.jl/dev/basicbsplineexporter/)
[![Build Status](https://github.com/hyrodium/BasicBSplineExporter.jl/workflows/CI/badge.svg)](https://github.com/hyrodium/BasicBSplineExporter.jl/actions)
[![Coverage](https://codecov.io/gh/hyrodium/BasicBSplineExporter.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/hyrodium/BasicBSplineExporter.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


This package supports export `BasicBSpline.BSplineManifold{Dim,Deg,<:StaticVector}` to:
* PNG image (`.png`)
* SVG image (`.png`)
* POV-Ray mesh (`.inc`)

## Installation
```julia
] add BasicBSpline
] add https://github.com/hyrodium/BasicBSplineExporter.jl
```

## First example
```julia
using BasicBSpline
using BasicBSplineExporter
using StaticArrays

p = 2
k = KnotVector(1:8)
P = BSplineSpace{p}(k)
rand_a = [rand(2) for i in 1:dim(P), j in 1:dim(P)]
a = [SVector(2*i-6.5, 2*j-6.5) for i in 1:dim(P), j in 1:dim(P)] + rand_a
M = BSplineManifold(a, (P,P))
k₊=(KnotVector(3.3,4.2),KnotVector(3.8,3.2,5.3))
M′ = refinement(M, k₊)
save_png("2dim.png", M)
save_png("2dim_refinement.png", M′)
```

![](img/2dim.png)
![](img/2dim_refinement.png)

## Other examples
Here are some images rendared with POV-Ray.

![](img/pov_1d3d.png)
![](img/pov_2d3d.png)
![](img/pov_3d3d.png)

See `test/runtests.jl` for more examples.
