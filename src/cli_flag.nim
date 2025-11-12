import os, strformat, terminal, strutils
import spectra

type 
  Flags* = object
    enc*: string
    file*: string
    hash*: string
    field*: string
    help*: bool
    ignore*: bool
    version*: bool
    noColor*: bool
    json*: bool
    csv*: bool
    verbose*: bool
    probe*: bool
    minEnt*: float

    

var flags*: Flags

colorToggle = not flags.noColor and stdout.isatty()
    


var i = 0

while i < paramCount():
  let a = paramStr(i+1)
  case a 
  of "-enc", "--encoding":
    if i+1 >= paramCount():
      paint fmt "[bold fg=red][ERROR] Missing encoding type after argument: [fg=green]{a}[reset]"
      quit(1)
    flags.enc = paramStr(i+2)
    i = i+2
  of "-f", "--file":
    if i+1 >= paramCount():
      paint fmt "[bold fg=red][ERROR] Missing filename after argument: [fg=green]{a}[reset]"
      quit(1)
    flags.file = paramStr(i+2)
    i = i+2
  of "-t", "--text":
    if i+1 >= paramCount():
      paint fmt "[bold fg=red][ERROR] Missing hash string after argument: [fg=green]{a}[reset]"
      quit(1)
    flags.hash = paramStr(i+2)
    i = i+2
  #[of "-i", "--ignore":
    if i+1 >= paramCount():
      stderr.writeLine(ifColor(fg=red, "[ERROR] Missing value after argument: ") & ifColor(fgGreen, fmt "{a}"))
      stderr.flushFile()
      quit(1)
    flags.ignore = paramStr(i+2)
    i = i+2]#
  of "-fd", "--field":
    if i+1 >= paramCount():
      paint fmt "[bold fg=red][ERROR] Missing value after argument: [fg=green]{a}[reset]"
      quit(1)
    flags.field = paramStr(i+2)
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
  of "-pb", "--probe":
    flags.probe = true
    inc i
  of "-nc", "--no-color":
    flags.noColor = true
    inc i
  of "-i", "--ignore":
    flags.ignore = true
    inc i
  of "-me", "--min-entropy":
    if i+1 >= paramCount():
      paint fmt "[bold fg=red][ERROR] Missing minimum entropy value after argument: [fg=green]{a}[reset]"
      quit(1)
    flags.minEnt = parseFloat(paramStr(i+2))
    i = i+2
  else:
    paint fmt "[bold fg=red][ERROR] Unknown argument: [fg=green]{a}[reset]"
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