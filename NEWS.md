# NEWS.md - Changes since v0.2.2

## Public API

Four new exported functions for the DictionaryEntry struct:

* traditional_headword
* simplified_headword
* pinyin_pronunciation
* word_senses

These are preferred instead of directly accessing the fields of the struct, as those may change.

* `search_pinyin` function is more capable of using wildcards

## Other Changes (not necessarily public)
* metadata from the dictionary file is also saved (not currently used for anything)

## Behind the Scenes
* more testing of dictionary loading and basic dictionary functionality
