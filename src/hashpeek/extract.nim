import strutils, sets, strformat, terminal, re, tables
import ../cli_flag, hash_database
import spectra


colorToggle = not flags.noColor and stdout.isatty()

type
  FieldParser* = object
    currentLine*: int

  ErrorOut* = object
    status*: string
    message*: string
    field*: int
    line*: int
    content*: string

proc newFieldParser*(): FieldParser = 
  return FieldParser(currentLine: 0)


#this function is for line counting. 
#it should be manually called so that it can get the right line number before empty lines are excluded
#[
   let delim = ":"
   let index = 2
   var fp = newFieldParser()
   fp.incrmentLine()
   #note that the line gets counted before empty lines are blocked from getting to parseField
   if line != "":
     fp.parseField(line,delim, index)
    ]#
proc incrementLine*(fp: var FieldParser) = 
  inc(fp.currentLine)

#this function exists to keep track of line number for correct error report
proc parseField*(fp: FieldParser, hashLine, delim: string, index: int): (string, ErrorOut) =
  #tuple[value: string, error: ErrorOut] = 
  var splitWord: seq[string]
  splitWord = hashLine.split(delim)
  
  if index < 0:
    paint "[bold fg=red][ERROR] Invalid truncation index: [fg=green]Negative indices not supported[reset]"
    quit(0)

  if index < splitWord.len:
    return (splitWord[index], ErrorOut()) #equivalent of nil. empty or default object
  else:
    let errDescript = fmt "Not enough fields for truncation {{{index+1}}} with delimiter '{delim}'"
    return ("", ErrorOut(
    status: "error",
    message: errDescript,
    field: splitWord.len,
    line: fp.currentLine,
    content: hashLine
    ))







proc parseIgnore*(ignorableChar: string): seq[string] =
  if ignorableChar.contains(','):
    return ignorableChar.split(',')
  return @[ignorableChar]

#ignore flag wont accept a string any longer. 
#it will only need to mute every error or skip.
#ignore flag will be a bool
#this function will be deprecated
proc isIgnore*(hashLine, ignorableChar: string): bool = 
  for ignore in parseIgnore(ignorableChar):
    if hashLine.startsWith(ignore):
      return true
  return false
    
#This function is meant for the tool only
#manual splitting is too brittle. 
#it should accommodate -trunc '3 :' without needed curly braces.
#well extract hex logic can be used
 # curly braces should be removed and should accomodate for --trunc '2 :' or --trunc '2:' or --trunc ':2' or --trunc ': 2'
 #the above is just a suggestion
proc parseTruncate*(truncInput: string): (int, string) =
  let valSplit = truncInput.split()
  let index = parseInt(valSplit[0].strip(chars={'{','}'}))
  let delim = valSplit[1].strip(chars={'`'})
  return (index-1, delim)



proc deduplicate(allInputs: seq[string]): seq[string] = 
  var seen = initHashSet[string]()
  var list: seq[string]
  for input in allInputs:
    if input notin seen:
      seen.incl(input)
      list.add(input)
  return list


proc extractHashes*(input: string): seq[string] =
  var foundHashes: seq[string] = @[]
  for patternStr, _ in HASH_DATABASE.pairs:
    let pattern = re(patternStr)
    let matches = input.findAll(pattern)
    foundHashes.add(matches)
  return foundHashes



when isMainModule:
  proc realTimeHashScanner() =
    echo "\nReal-time Hash Scanner Simulation:"
    echo "=".repeat(40)
  
    let input = """# User login attempts
[INFO] 2025-08-25T10:00:01Z New user 'alice' created. Temp pass: welcome123
[DEBUG] 2025-08-25T10:01:12Z Session token: ####5f4dcc3b5aa765d61d8327deb882cf99###
[ERROR] 2025-08-25T10:02:15Z Password reset failed for 'svc_user'. Hash: d6e0d2c1a5e89c5c7b6b9bccb8b8b8b8b8b8b8b8
Random note: nothing to see here 12345
[WARN] 2025-08-25T10:03:33Z User 'bob' failed login. Token: ####e99a18c428cb38d5f260853678922e03###
Some debug info: 0x4f2a1b
alright this is descript G8n0KRCTGO8SY
[INFO] Miscellaneous logs ####c3fcd3d76192e4007dfb496cca67e13b###
# End of log#
"""
  
  #echo "Input: ", input
  #let hashes = extractHashes(input)
    echo "SCAN INPUT CHAR BY CHAR"
    echo extractHashes(input)
    #[if hashes.len > 0:
      for hashInfo in hashes:
        echo "  → Found: $1 ($2)" % [hashInfo.hash, $hashInfo.hashType]
    else:
      echo "  → No valid hashes found"
    echo ""]#

# Run real-time scanner
  realTimeHashScanner()
