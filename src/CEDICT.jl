module CEDICT

export DictionaryEntry, ChineseDictionary,

search_headwords, search_senses, search_pinyin,

idioms


include("dictionary.jl")
include("searching.jl")

"""
    idioms([dict])

Retrieves the set of idioms in the provided dictionary (by looking for a label of "(idiom)" in any
of the senses) or in the default dictionary if none provided.
"""
function idioms end
idioms(dict) = search_senses(dict, "(idiom)")
idioms() = idioms(ChineseDictionary())

end
