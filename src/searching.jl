using Pipe

function searchfiltered(filter_func, dict::LookupDictionary)
    word_entries = Set{DictionaryEntry}()

    for entry_list in values(dict)
        for entry in entry_list
            filter_func(entry) && push!(word_entries, entry)
        end
    end

    word_entries
end

searchheadwords(dict::LookupDictionary, keyword) =
    searchfiltered(dict) do entry
        occursin(keyword, entry.trad) || occursin(keyword, entry.simp)
    end

searchsenses(dict::LookupDictionary, keyword) =
    searchfiltered(dict) do entry
        any(occursin.(keyword, entry.senses))
    end

"""
    searchpinyin(dict, keyword)

Search the dictionary for terms that fuzzy match the pinyin search key provided.
The language that is understood for the search key is described below.

# Examples
```julia-repl
julia> searchpinyin(dict, "yi2 han4") .|> println;
遺憾 (遗憾): [yi2 han4]
        regret
        to regret
        to be sorry that
```

# Fuzzy Matching
The search key need not be exact. For example, tone numbers are not required.

In addition, when used on their own,
- "*" will match any additional characters,
- "?" will match up to one additional character, and
- "+" will match one or more additional characters.

For example,
```julia-repl
julia> searchpinyin(dict, "si ma dang huo ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation
julia> searchpinyin(dict, "si ma dang ? ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation
julia> searchpinyin(dict, "si + ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation
julia> searchpinyin(dict, "si ma dang * huo ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation
```
"""
function searchpinyin(dict::LookupDictionary, pinyin_searchkey)
    search_regex = _convert_pinyin_regex(pinyin_searchkey)
    searchfiltered(dict) do entry
        match(search_regex, entry.pinyin) != nothing
    end
end

function _convert_pinyin_regex(searchkey)
    re = @pipe split(searchkey, " ") |>
            map(w -> (w == "*" ? raw"(\w+\d)*" : w), _) |> # TODO: doesn't handle spaces correctly'
            map(w -> (w == "+" ? raw"(\w+\d)+" : w), _) |>
            map(w -> (w == "?" ? raw"(\w+\d)?" : w), _) |>
            map(w -> w * raw"\d?", _)|>
            join(_, raw"\s")
    Regex("^$(re)\$")
end
