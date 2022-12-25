module CEDICT

export

DictionaryEntry,
traditional_headword, simplified_headword, pinyin_pronunciation, word_senses,

ChineseDictionary,

search_headwords, search_senses, search_pinyin,

idioms


include("dictionary.jl")
include("searching.jl")

"""
    idioms([dict])

Retrieves the set of idioms in the provided dictionary (by looking for a label of "(idiom)" in any
of the senses) or in the default dictionary if none provided.
"""
idioms(dict=ChineseDictionary()) = search_senses(dict, "(idiom)")

end
