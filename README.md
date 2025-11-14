# HASHPEEK
**Hashpeek** is a hash identification tool with extraction and hashtype grouping features.

# Why Hashpeek
One will wonder, **"why a new hash identifier (hashpeek), aren't there enough of this out there?"** 

**You are right to question the existence of this tool**.

There are many hash identifiers out there but they seem to have one limitation or the other.
1. Some don't accept input via stdin making it somehow difficult for scripting.

2. Others too show outputs that are a hassle to grep (you need regex gymnastics to grep).

3. Some too only accept hashes (no files) and those that accept hashfiles are likely to spam your screen with redundant results(results-per-hash spam).

4. Inability to extract hashes from logs, dumps and structured data (shadow files, etc)

These are the issues or limitations hashpeek is here to solve.


# TODOS
- [ ] Add external database support (only in json).
- [ ] change default format to tree format
- [ ] Drop hex and context Extraction for an efficient one.
- [ ] Add contexts and metadata per hash to the hash database.
- [ ] Make the tool faster
- [ ] Fix bugs
- [ ] Accept generic extraction (not necessarily a hash) through external databases.

# CLI Usage
![Hi](https://s14.gifyu.com/images/bwr2x.gif)

# Installation
```
git clone https://github.com/ph4mished/hashpeek
