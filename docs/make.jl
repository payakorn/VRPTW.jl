using VRPTW
using Documenter

DocMeta.setdocmeta!(VRPTW, :DocTestSetup, :(using VRPTW); recursive=true)

makedocs(;
    modules=[VRPTW],
    authors="Payakorn Saksuriya",
    repo="https://github.com/payakorn/VRPTW.jl/blob/{commit}{path}#{line}",
    sitename="VRPTW.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://payakorn.github.io/VRPTW.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/payakorn/VRPTW.jl",
    devbranch="master",
)
