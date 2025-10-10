import strutils, sets, strformat, terminal
import ../cli_flag

type
  Extractor* = object
    lengths*: seq[int]
    contexts*: seq[string]

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
proc incrementLine*(fp: FieldParser) = 
  echo fp.currentLine+1
  #inc(fp.currentLine)

proc parseField*(fp: FieldParser, hashLine, delim: string, index: int): (string, ErrorOut) =
  #tuple[value: string, error: ErrorOut] = 
  var splitWord: seq[string]
  splitWord = hashLine.split(delim)
  
  if index < 0:
     stderr.writeLine(ifColor(fgRed, "[ERROR] Invalid truncation index: ") & ifColor(fgGreen, "Negative indices not supported"))
     stderr.flushFile()
     return ("", ErrorOut())

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

proc isHex(ch: char): bool =
  return ch >= 'a' and ch <= 'f' or ch >= 'A' and ch <= 'F' or ch >= '0' and ch <= '9'



proc parseExtractToSeq*(extHexVal: string): seq[int] =
  var allNum: seq[int]
  if extHexVal.contains(','):
    let extNum = extHexVal.split(',')
    for num in extNum:
      allNum.add(parseInt(num))
    return allNum
  elif extHexVal.contains('-'):
    let hexVal = extHexVal.split('-')
    let startRange = parseInt(hexVal[0])
    let endRange = parseInt(hexVal[1])
    for num in startRange..endRange:
      allNum.add(num)
    return allNum
  else:
    return @[parseInt(extHexVal)]



proc parseContextToSeq*(context: string): seq[string] =
  if context.contains(','):
    return context.split(',')
  return @[context]





#this function will be deprecated if ignore flag uses bool
proc parseIgnore*(ignorableChar: string): seq[string] =
  if ignorableChar.contains(','):
    return ignorableChar.split(',')
  return @[ignorableChar]

#ignore flag wont accept a string any longer. 
#it will only need to mute every error or skip.
#hence all output to sterr will be muted if ignore is true
#ignore flag will be a bool
#this function will be deprecated
proc isIgnore*(hashLine, ignorableChar: string): bool = 
  for ignore in parseIgnore(ignorableChar):
    if hashLine.startsWith(ignore):
      return true
  return false
    

proc parseTruncate*(truncInput: string): (int, string) =
  let valSplit = truncInput.split()
  let index = parseInt(valSplit[0].strip(chars={'{','}'}))
  let delim = valSplit[1].strip(chars={'`'})
  return (index-1, delim)



proc generateCaseVariants*(input: string): seq[string] =
  var allCase: seq[string]
  allCase.add(input.toUpperAscii)
  allCase.add(input.toLowerAscii)
  allCase.add(input.capitalizeAscii)
  return allCase 

proc deDuplicate(allInputs: seq[string]): seq[string] = 
  var seen = initHashSet[string]()
  var list: seq[string]
  for input in allInputs:
    if input notin seen:
      seen.incl(input)
      list.add(input)
  return list


#if it sees ':' or '=' before extraction begins. it should look behind it to see what key it holds
#because its probably "key:value". this will help boost the confidence level during identification
#eg. "md5:aaa5b..." it peekback tells it, its an md5 hash. it then goes on to identify it
#if md5 is found among the results, it boosts md5 confidence level up.
#this logic should give the hex extractor some context awareness

#in place of -e 16 which is a hungry hex extraction type. -e-hex 6.. will be used -e-hex 6
#well i think range is enough to solve it.
proc extractHex*(input: string, numLen: int): seq[string] = 
  var 
    hashes: seq[string]
    currentHash: string
   #to avoid confusion. minimum value, will be supported no more
  
  var inHexSequence = false
  for ch in input:
    #start appending immediately ch is a valid hex
    if isHex(ch) and not inHexSequence:
      inHexSequence = true
      currentHash.add(ch)
    #continuation if still a hex value
    elif isHex(ch) and inHexSequence:
      currentHash.add(ch)
    #abrupt stop if value is not valid hex but appending is still in process
    elif not isHex(ch) and inHexSequence:
      #cross check per given minimum length
      if currentHash.len == numLen:
       #add to hashes
       hashes.add(currentHash)
      inHexSequence = false
      currentHash.reset() #set it to nil
  
  if inHexSequence and currentHash.len == numLen:
    hashes.add(currentHash)

  return hashes


#fix for this function 
#sometimes a user could meet "hash: {This is md5}aa5cdf..."
#currently the tool breaks after "{,("
#it needs to check if a value comes after "{,(" that is if no value was extracted before those break-causing chars.
proc extractByContext*(input: string,  context: seq[string]): seq[string] = 
  var allValues: seq[string]
  var allDelim = @[":", "="]
  
  for conString in context:
    for delim in allDelim:
      let target = conString & delim
      let pos = input.find(target)
      if pos != -1:
        var remaining = input[pos + target.len..^1].strip()

        var extractedValue: string
        for ch in remaining:
          #if ch.isWhiteSpace() or 
          if isEmptyOrWhiteSpace($ch) or ch == '(' or ch == '{':
            break
          extractedValue.add(ch)

        allValues.add(extractedValue)
  return allValues
  

proc extract*(e: Extractor, input: string): seq[string] =
  var allResults: seq[string]

  if e.contexts.len > 0:
    for context in e.contexts:
      let allVariants = generateCaseVariants(context)
      let contextMatch = extractByContext(input, allVariants)
      allResults.add(contextMatch)

  if e.lengths != @[] :
    for minLen in e.lengths:
      let minLengthMatch = extractHex(input, minLen)
      allResults.add(minLengthMatch)
  result = deDuplicate(allResults)