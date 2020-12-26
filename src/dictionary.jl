using Pkg.Artifacts

struct DictionaryEntry
    trad
    simp
    pinyin
    senses
end

function Base.print(io::IO, entry::DictionaryEntry)
    char_str = entry.trad == entry.simp ? entry.trad : "$(entry.trad) ($(entry.simp))"
    print(io, "$char_str: [$(entry.pinyin)]\n")
    print(io, join(map(w -> "\t" * w, entry.senses), "\n"))
    return nothing
end

const LookupDictionary = Dict{SubString, Vector{DictionaryEntry}}

"""
    load_dictionary([filename])

Load a text-based dictionary either from the default dictionary file or from the provided
filename. The format of the text file must be the same as
[that used by the CC-CEDICT project](https://cc-cedict.org/wiki/format:syntax) for
compatibility reasons.

For general use, it's the easiest to just use the default dictionary (from the CC-CEDICT project).
This is loaded if you don't specify a filename.
"""
function load_dictionary(filename = joinpath(artifact"CE-Dict", "cedict_ts.u8"))
    dict = LookupDictionary()
    pattern = r"^([^#\s]+) ([^\s]+) \[(.*)\] /(.+)/$"
    for line in eachline(filename)
        m = match(pattern, line)
        m === nothing && continue

        trad, simp, pinyin, defns = String.(m.captures)
        entry = DictionaryEntry(trad, simp, pinyin, split(defns, "/"))

        if haskey(dict, trad)
            push!(dict[trad], entry)
        else
            dict[trad] = [entry]
        end

        if simp != trad
             if haskey(dict, simp)
                 push!(dict[simp], entry)
             else
                 dict[simp] = [entry]
             end
         end
    end

    dict
end
