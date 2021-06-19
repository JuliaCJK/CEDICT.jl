push!(LOAD_PATH, "../src/")

using Documenter, CEDICT

makedocs(
    sitename="CEDICT.jl Documentation",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true"
    ),
    modules=[CEDICT],
    pages=[
        "Home" => "index.md",
        "API Reference" => [
            "Loading Dictionaries" => "api_dictionaries.md",
            "Searching in Dictionaries" => "api_searching.md",
            "Convenience Functions" => "api_convenience.md"
        ]
    ]
)

deploydocs(
    repo="github.com/tmthyln/CEDICT.jl.git",
    devbranch="main",
    devurl="latest"
    )
