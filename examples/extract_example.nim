
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


#from messy data
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