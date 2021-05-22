using LazyArtifacts

struct DictionaryEntry
    trad::String
    simp::String
    pinyin::String
    senses::Vector{String}
end

function Base.print(io::IO, entry::DictionaryEntry)
    char_str = entry.trad == entry.simp ? entry.trad : "$(entry.trad) ($(entry.simp))"
    print(io, "$char_str: [$(entry.pinyin)]\n")
    print(io, join(map(w -> "\t" * w, entry.senses), "\n"))
    return nothing
end

struct ChineseDictionary
    entries::Dict{String, Vector{DictionaryEntry}}

    """
        ChineseDictionary([filename])

    Load a text-based dictionary either from the default dictionary file or from the provided
    filename. The format of the text file must be the same as
    [that used by the CC-CEDICT project](https://cc-cedict.org/wiki/format:syntax) for
    compatibility reasons.

    For general use, it's the easiest to just use the default dictionary (from the CC-CEDICT project).
    This is loaded if you don't specify a filename.
    """
    function ChineseDictionary(filename=joinpath(artifact"cedict", "cedict_ts.u8"))
        dict = Dict{String, Vector{DictionaryEntry}}()
        pattern = r"^([^#\s]+) ([^\s]+) \[(.*)\] /(.+)/$"

        for line in eachline(filename)
            m = match(pattern, line)
            m === nothing && continue

            trad, simp, pinyin, defns = String.(m.captures)
            entry = DictionaryEntry(trad, simp, pinyin, split(defns, "/"))

            dict[trad] = push!(get(dict, trad, []), entry)
            simp != trad && (dict[simp] = push!(get(dict, simp, []), entry))
        end

        new(dict)
    end
end


# iteration
Base.iterate(dict::ChineseDictionary) = iterate(dict.entries)
Base.IteratorSize(::Type{ChineseDictionary}) = HasLength()
Base.IteratorEltype(::Type{ChineseDictionary}) = HasEltype()
Base.length(dict::ChineseDictionary) = length(dict.entries)
Base.eltype(::Type{ChineseDictionary}) = Pair{String, Vector{DictionaryEntry}}

# indexing
Base.getindex(dict::ChineseDictionary, i) = getindex(dict.entries, i)
Base.setindex!(dict::ChineseDictionary, v, i) = setindex!(dict.entries, v, i)

# dictionaries
Base.keys(dict::ChineseDictionary) = keys(dict.entries)
Base.values(dict::ChineseDictionary) = values(dict.entries)
Base.haskey(dict::ChineseDictionary, key) = haskey(dict.entries, key)
