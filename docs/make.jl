using Documenter, ExportNURBS

makedocs(;
    modules=[ExportNURBS],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/hyrodium/ExportNURBS.jl/blob/{commit}{path}#L{line}",
    sitename="ExportNURBS.jl",
    authors="hyrodium <hyrodium@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/hyrodium/ExportNURBS.jl",
)
