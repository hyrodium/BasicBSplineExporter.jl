using Documenter, BasicBSplineExporter

makedocs(;
    modules=[BasicBSplineExporter],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/hyrodium/BasicBSplineExporter.jl/blob/{commit}{path}#L{line}",
    sitename="BasicBSplineExporter.jl",
    authors="hyrodium <hyrodium@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/hyrodium/BasicBSplineExporter.jl",
)
