import os, strformat, terminal, strutils
#this file was created as a result of recursive dependency errors

#[proc identifyDefault*(identResult: AnalysisResult): string =
  if not identResult.found:
    result.add(ifColor(fgRed, "[ERROR] ") & ifColor(fgGreen, "Unknown hash format\n"))
    #result.add ansiStyleCode(styleBright) & ansiForeGroundColorCode(fgRed) & "[ERROR] " & ansiResetCode
    #result.add ansiStyleCode(styleBright) & ansiForeGroundColorCode(fgGreen) & "Unknown hash format\n" & ansiResetCode
  for hashalgo in identResult.algorithms:
    withColors:
      result.add(ifColor(fgBlue, fmt"\n  {hashalgo}") & ifColor(fgMagenta, "\n    Hashcat Mode: ") & ifColor(fgYellow, hashalgo.hashcat) & ifColor(fgGreen, "\n    John Format: ") & ifColor(fgYellow, fmt "{hashalgo.john}\n"))
      #result.add(ansiStyleCode(styleBright) & ansiForeGroundColorCode(fgBlue) & "\n  " & hashalgo.name & ansiResetCode)
      #result.add(ansiStyleCode(styleBright) & ansiForeGroundColorCode(fgMagenta) & "\n    Hashcat Mode: " & ansiResetCode)
      #result.add(ansiStyleCode(styleBright) & ansiForeGroundColorCode(fgYellow) & hashalgo.hashcat & ansiResetCode) 
      #result.add(ansiStyleCode(styleBright) & ansiForeGroundColorCode(fgGreen) & "\n    John Format: " & ansiResetCode)
      #result.add(ansiStyleCode(styleBright) & ansiForeGroundColorCode(fgYellow) & hashalgo.john  & "\n" & ansiResetCode) ]#

type 
  Flags* = object
    file*: string
    help*: bool
    #ignore flag will accept no strings. it needs to be a bool
    ignore*: bool
    version*: bool
    noColor*: bool
    json*: bool
    csv*: bool
    verbose*: bool
    hash*: string
    #extract hex flag will also later  be considered a bool. so that user wouln't need to specify length
    #or extract length with no value means default will be used
    #its considered a string so that it extracts using 6,7,9 or 9-12 or 12
    extHex*: string
    extCtext*: string
    trunc*: string

var flags*: Flags


proc ifColor*(frontColor: ForegroundColor, word: auto): string =
  if not flags.noColor and stdout.isatty():
    result.add(ansiStyleCode(styleBright) & ansiForegroundColorCode(frontColor) & $word & ansiResetCode)
  else:
    return $word
    


var i = 0

while i < paramCount():
  let a = paramStr(i+1)
  case a 
  of "-f", "--file":
    if i+1 >= paramCount():
      stderr.writeLine(ifColor(fgRed, "[ERROR] Missing filename after argument: ") & ifColor(fgGreen, fmt "{a}"))
      stderr.flushFile()
      quit(1)
    flags.file = paramStr(i+2)
    i = i+2
  of "-x", "--hash":
    if i+1 >= paramCount():
      stderr.writeLine(ifColor(fgRed, "[ERROR] Missing hash string after argument: ") & ifColor(fgGreen, fmt "{a}"))
      stderr.flushFile()
      quit(1)
    flags.hash = paramStr(i+2)
    i = i+2
  #[of "-i", "--ignore":
    if i+1 >= paramCount():
      stderr.writeLine(ifColor(fgRed, "[ERROR] Missing value after argument: ") & ifColor(fgGreen, fmt "{a}"))
      stderr.flushFile()
      quit(1)
    flags.ignore = paramStr(i+2)
    i = i+2]#
  of "--trunc":
    if i+1 >= paramCount():
      stderr.writeLine(ifColor(fgRed, "[ERROR] Missing value after argument: ") & ifColor(fgGreen, fmt "{a}"))
      stderr.flushFile()
      quit(1)
    flags.trunc = paramStr(i+2)
    i = i+2
  of "-e-ctext", "--extract-context":
    if i+1 >= paramCount():
      stderr.writeLine(ifColor(fgRed, "[ERROR] Missing value after argument: ") & ifColor(fgGreen, fmt "{a}"))
      stderr.flushFile()
      quit(1)
    flags.extCtext = paramStr(i+2)
    i = i+2
  of "-e-hex", "--extract-hex":
    if i+1 >= paramCount():
      #use this part for default
      #default values are 4-256
      stderr.writeLine(ifColor(fgRed, "[ERROR] Missing value after argument: ") & ifColor(fgGreen, fmt "{a}"))
      stderr.flushFile()
      quit(1)
      #flags.extHex = paramStr(i+1)
      #flags.extHex = "4-256"
      #echo flags.extHex
      #i = i+1
    #else:
    flags.extHex = paramStr(i+2)
    i = i+2
  of "-h", "--help":
    flags.help = true
    inc i
  of "-v", "--version":
    flags.version = true
    inc i
  of "--json":
    flags.json = true
    inc i
  of "--csv":
    flags.csv = true
    inc i
  of "-nc", "--no-color":
    flags.noColor = true
    inc i
  of "-i", "--ignore":
    flags.ignore = true
    inc i
  else:
    stderr.write(ifColor(fgRed, "[ERROR] Unknown argument:") & ifColor(fgGreen,  fmt " {a}\n"))
    stderr.flushFile()
    inc i

  #[
  what to show when flag is not supported
  1
  Usage: nth [OPTIONS]
Try 'nth --help' for help.

Error: No such option: -h

2.
hashid: error: unrecognized arguments: -shit


  ]#