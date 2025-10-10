# HASHPEEK
**Hashpeek** is a hash identification tool as well as a library with extraction and hashtype grouping features.

# Why Hashpeek
One will wonder, **"why a new hash identifier (hashpeek), aren't there enough of this out there?"** 

**You are right to question the existence of this tool**.

There are many hash identifiers out there but they seem to have one limitation or the other.
1. Some don't accept input via stdin making it somehow difficult for scripting.

2. Others too show outputs that are a hassle to grep (you need regex gymnastics to grep).

3. Some too only accept hashes (no files) and those that accept hashfiles are prone to spamming your screen with redundant results.

4. Inability to extract hashes from logs, dumps and structured data (shadow files, etc)

These are the issues or limitations hashpeek is here to solve.
Without much ado, lets pop into some usage examples of hashpeek

# Library Usage
## Identification
``` nim
import hashpeek

let hash = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
let identifiedResults = identify(hash)
#hashpeek allows for different output format

#colored-terminal format output
echo defaultFormat(identifiedResults)

#json format output
echo jsonFormat(identifiedResults)

#csv format output
echo csvFormat(identifiedResults)

#for more flexibility
for hashlago in identifiedResults.algorithms:
  #print hashtype
  echo hashalgo.name

  #print hashcat
  echo hashalgo.hashcat

  #print john format
  echo hashalgo.john
```
## Extraction
### hash extraction from structured data
``` nim
#structured data extraction

let roughData = "Administrator:500:aad3b435b51404eeaad3b435b51404ee:209c6174da490caeb422f3fa5a7ae634:::"
let fieldIndex =  3
let delimiter = ":"
let fp = newFieldParser()
#use incrementLine() only for files (it tracks line number for correct error reporting)
#fp.incrementLine()
let (extractHash, err) = fp.parseField(roughData, delimiter, fieldIndex)
# default format output
if err.status == "error":
  echo err.message
else:
  echo fmt "Extracted Hash: {extractHash}"
  let identResults = identify(extractHash)
  echo fmt "{defaultFormat(identResults)}\n"
```

### extraction from unstructured or messy data
``` nim
# parseExtractToSeq is a function that accepts range of numbers, comma-separated numbers etc. this function makes it easier to increase length values for extraction without manually typing "1,2,3,..44"
var extractedHashes: seq[string]
let rangeExtract = parseExtractToSeq("10-99")
let contextExtract = parseContextToSeq("password, hash, md5,")
#or just directly
#let contextExtract = @["password", "hash", "md5"]
let input = """# User login attempts
[INFO] 2025-08-25T10:00:01Z New user 'alice' created. Temp pass: welcome123
[DEBUG] 2025-08-25T10:01:12Z Session token: ####5f4dcc3b5aa765d61d8327deb882cf99###
[ERROR] 2025-08-25T10:02:15Z Password reset failed for 'svc_user'. Hash: d6e0d2c1a5e89c5c7b6b9bccb8b8b8b8b8b8b8b8
Random note: nothing to see here 12345
[WARN] 2025-08-25T10:03:33Z User 'bob' failed login. Token: ####e99a18c428cb38d5f260853678922e03###
Some debug info: 0x4f2a1b
[INFO] Miscellaneous logs ####c3fcd3d76192e4007dfb496cca67e13b###
# End of log#
"""

var myExtractor = Extractor(
  #lengths is for hex extraction and it needs the required length for the hex value extraction
  lengths: rangeExtract,
  #contexts extracts values of inputs with "key:value" or "key=value" format. but it breaks at "(), {}"
  #eg. "hash: e99a18c428cb38d5f260853678922e03{bob}. it only extracts "e99a18c428cb38d5f260853678922e03" leaving out "{bob}". Case of given contexts  is handled implicitly. 
  # the values of "key:value", "Key:value", "KEY:value" will all be extracted as far as the given context is "key". And no need to worry about duplicates
  contexts: contextExtract,
)
extractedHashes.add(myExtractor.extract(input))
for hash in extractedHashes:
  #for csv format
  echo csvFormat(identify(hash))
  #for json format
  echo jsonFormat(identify(hash))
  #for default format
  echo fmt "Extracted Hash: {hash}"
  echo fmt "{defaultFormat(identify(hash))}\n"
#to get a clear picture of the extracted hashes
echo extractedHashes
```

# CLI Usage
! [Alt Text](https://github.com/ph4mished/hashpeek/Peek 2025-10-10 12-27.gif)

# Installation
```
git clone https://github.com/ph4mished/hashpeek