module CEDICT

export DictionaryEntry, ChineseDictionary,

search_headwords, search_senses, search_pinyin,

idioms


include("dictionary.jl")
include("searching.jl")

idioms(dict) = search_senses(dict, "(idiom)")

end