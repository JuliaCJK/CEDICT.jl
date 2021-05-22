# Searching within a Dictionary
There are several ways to search in a dictionary, depending on what part of the dictionary entries are used and what the user is searching for. 

(All the examples are using the default dictionary.)

```@docs
search_headwords
search_senses
search_pinyin
```

## Advanced Pinyin Searching
The `search_pinyin` function also supports a certain flavor of fuzzy matching and searches with missing information. For example, tone numbers are not required. In addition,
- "*" will match any additional characters,
- "?" will match up to one additional character, and
- "+" will match one or more additional characters.

If these characters are separated by spaces (not attached to any other word character), "character" means a Chinese character; if these characters are attached to other word characters, "character" means a pinyin character. 

For example, using these metacharacters on their own (separated by spaces), we can search where we may not know all the characters in the phrase.
```julia-repl
julia> search_pinyin(dict, "si ma dang huo ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation

julia> search_pinyin(dict, "si ma dang ? ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation

julia> search_pinyin(dict, "si + ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation

julia> search_pinyin(dict, "si ma dang * huo ma yi") .|> println;
死馬當活馬醫 (死马当活马医): [si3 ma3 dang4 huo2 ma3 yi1]
        lit. to give medicine to a dead horse (idiom)
        fig. to keep trying everything in a desperate situation
```
The above examples all return the same result.

We could also instead use the metacharacters attached to pinyin letters if we don't know the full sound of a word.


## More Advanced Searching
The un-exported method `search_filtered` can be used if none of the above options are powerful/flexible enough. However, this requires working with the raw `DictionaryEntry` struct and is subject to breakage in future releases (not a part of the public API).

```@docs
CEDICT.search_filtered
```

