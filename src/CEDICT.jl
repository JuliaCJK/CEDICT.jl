module CEDICT

export load_dictionary, DictionaryEntry, LookupDictionary,

search_headwords, search_senses, search_pinyin


include("dictionary.jl")
include("searching.jl")

end