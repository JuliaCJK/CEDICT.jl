module CEDICT

export DictionaryEntry, ChineseDictionary,

search_headwords, search_senses, search_pinyin


include("dictionary.jl")
include("searching.jl")

end