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
