using Pipe

"""
    search_filtered(func, dict)

Produce a set of entries for which `func(entry)` returns `true`. This is considered
an internal function and not part of the public API for this package; use at your own risk!
"""
function search_filtered(filter_func, dict::ChineseDictionary)
    word_entries = Set{DictionaryEntry}()

    for entry_list in values(dict)
        for entry in entry_list
            filter_func(entry) && push!(word_entries, entry)
        end
    end

    word_entries
end

"""
    search_headwords(dict, keyword)

Search for the given `keyword` in the dictionary as a headword, in either traditional or
simplified characters (will only return results where the headword is an exact match for
`keyword`; this behavior may change in future releases).

## Examples
```julia-repl
julia> search_headwords(dict, "2019冠狀病毒病") .|> println;
2019冠狀病毒病 (2019冠状病毒病): [er4 ling2 yi1 jiu3 guan1 zhuang4 bing4 du2 bing4]
        COVID-19, the coronavirus disease identified in 2019
```
"""
search_headwords(dict::ChineseDictionary, keyword) =
    search_filtered(dict) do entry
        occursin(keyword, entry.trad) || occursin(keyword, entry.simp)
    end

"""
    search_senses(dict, keyword)

Search for the given `keyword` in the dictionary among the meanings/senses (the `keyword` must
appear exactly in one or more of the definition senses; this behavior may change in future
releases).

## Examples
```julia-repl
julia> search_senses(dict, "fishnet") .|> println;
漁網 (渔网): [yu2 wang3]
        fishing net
        fishnet
扳罾: [ban1 zeng1]
        to lift the fishnet
網襪 (网袜): [wang3 wa4]
        fishnet stockings
```
"""
search_senses(dict::ChineseDictionary, keyword) =
    search_filtered(dict) do entry
        any(occursin.(keyword, entry.senses))
    end

"""
    search_pinyin(dict, keyword)

Search the dictionary for terms that fuzzy match the pinyin search key provided.
The language that is understood for the search key is described below.

# Examples
```julia-repl
julia> search_pinyin(dict, "yi2 han4") .|> println;
遺憾 (遗憾): [yi2 han4]
        regret
        to regret
        to be sorry that

julia> search_pinyin(dict, "bang shou") .|> println;
榜首: [bang3 shou3]
        top of the list
幫手 (帮手): [bang1 shou3]
        helper
        assistant
```
"""
function search_pinyin(dict::ChineseDictionary, pinyin_searchkey)
    search_regex = _prepare_pinyin_regex(pinyin_searchkey)
    search_filtered(dict) do entry
        match(search_regex, entry.pinyin) != nothing
    end
end

function _prepare_pinyin_regex(searchkey)
    re = @pipe split(searchkey, " ") |>
            map(w -> (w == "*" ? raw"(\w+\d\s*)*" : w), _) |> # TODO: doesn't handle spaces correctly'
            map(w -> (w == "+" ? raw"\w+\d(\s+\w+\d)*" : w), _) |>
            map(w -> (w == "?" ? raw"(\w+\d)?" : w), _) |>
            map(w -> (endswith(w, r"\d") ? w : w * raw"\d?"), _) |>
            join(_, raw"\s+")
    Regex("^$(re)\$")
end
