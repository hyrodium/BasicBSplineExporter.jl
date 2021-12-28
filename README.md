# ExportNURBS

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://hyrodium.github.io/ExportNURBS.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://hyrodium.github.io/ExportNURBS.jl/dev)
[![Build Status](https://travis-ci.com/hyrodium/ExportNURBS.jl.svg?branch=master)](https://travis-ci.com/hyrodium/ExportNURBS.jl)

This package supports export NURBS to png, svg image. (and also supports vtk, pov, etc. in the future.)

## Example
```julia
(pkg) > add https://github.com/hyrodium/BasicBSpline.jl
(pkg) > add https://github.com/hyrodium/ExportNURBS.jl
```

```julia
using BasicBSpline
using ExportNURBS
p = 2
k = Knots(1:8)
P = BSplineSpace(p,k)
rand_a = [rand(2) for i in 1:dim(P), j in 1:dim(P)]
a = [[2*i-6.5,2*j-6.5] for i in 1:dim(P), j in 1:dim(P)] + rand_a
M = BSplineManifold([P,P],a)
k₊=[Knots(3.3,4.2),Knots(3.8,3.2,5.3)]
M′ = refinement(M,k₊=k₊)
save_png("2dim.png", M)
save_png("2dim_refinement.png", M′)
```

![](docs/src/img/2dim.png) ![](docs/src/img/2dim_refinement.png)
