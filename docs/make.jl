push!(LOAD_PATH, "../src/")

using Documenter, CEDICT

makedocs(
    sitename="CEDICT.jl Documentation",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true"
    ),
    modules=[CEDICT],
    pages=[
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/tmthyln/CEDICT.jl.git",
    devbranch = "main",
    devurl="latest"
    )
