# Creating & Loading Dictionaries
The `load_dictionary` function is the primary method for loading a dictionary. Currently, dictionaries can only be loaded from text files, but there may be support for other formats in the future.

```@docs
load_dictionary
```

## File Format for a Text-Based Dictionary
See the [formatting guide for the CC-CEDICT project](https://cc-cedict.org/wiki/format:syntax) for how each line should be formatted (just consider the formatting elements and not necessarily the other notes on translation/dictionary entry creation).Each line of the file should be a single entry; for examples, see the small test dictionaries in the repository. Lines starting with a "#" are treated as comments and ignored.
