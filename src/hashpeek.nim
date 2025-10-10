import strformat, terminal, os, strutils
import libpeek/file_analyze
import help, cli_flag, helper_func

import libpeek/[analyze, outfmt, file_analyze, extract]
export analyze, outfmt, file_analyze, extract
# [INFO] = CYAN
# [ERROR] = RED
# [SKIP] = yellow

proc main() =
  var format: string
  if flags.csv:
    format = "csv"
  elif flags.json:
    format = "json"
  elif flags.verbose:
    format = "default"
  else:
    format = "default"


  if flags.file.len > 0:
    fileIdentifyGroup(flags.file)
    stdout.write(ifColor(fgCyan, "[[[") & ifColor(fgGreen, " End Of File of ") & ifColor(fgYellow, flags.file) & ifColor(fgCyan, " ]]]\n\n"))
    stdout.flushFile()
    return
    #[if flags.extHex != "" or flags.extCtext != "":
      fileIdentifyGroupWithExtract(flags.file, flags.extCtext, flags.extHex)
      stdout.write(ifColor(fgCyan, "[[[") & ifColor(fgGreen, " End Of File of ") & ifColor(fgYellow, flags.file) & ifColor(fgCyan, " ]]]\n\n"))
      stdout.flushFile()]#

  if flags.hash.len > 0:
    if flags.hash == "-":
      #maybe streams will do
      for line in stdin.lines():
        let input = line.strip
        identifyHash(input, flags.extCtext, flags.extHex, flags.trunc,  flags.ignore, format)
    elif flags.hash != "-" and flags.hash != "":
      identifyHash(flags.hash, flags.extCtext, flags.extHex, flags.trunc, flags.ignore, format)
    #[if flags.json:
      echo jsonFormat(identify(flags.hash))
      return
    elif flags.csv:
      echo csvFormat(identify(flags.hash))
      return
    else:
      stdout.write(ifColor(fgGreen, "\nHash: ") & ifColor(fgYellow, fmt "{flags.hash}\n"))
      stdout.flushFile()
      echo fmt "{defaultFormat(identify(flags.hash))}\n"
      return
    ]#
    
  if flags.help:
    help()
    return

  if flags.version:
    echo ifColor(fgGreen,"hashpeek v0.3.0 by ph4mished (https://github.com/ph4mished/hashpeek)")

#ignore flag should be a bool instead of accepting strings. this is to silence all errors
when isMainModule:
  main()
