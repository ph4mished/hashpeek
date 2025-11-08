import strformat, terminal, os, strutils
import hashpeek/file_analyze
import spectra
import help, cli_flag, helper_func

#hashpeek expected input at the moment is that of a single hash and file, streams (of hashes and files) are handled explicitly
#hashpeek will dropp its library api because it has made it complex to manage hashpeek

import hashpeek/[analyze, outfmt, file_analyze, extract, hash_database]
export analyze, outfmt, file_analyze, extract, hash_database
# [INFO] = CYAN
# [ERROR] = RED
# [SKIP] = yellow

colorToggle = not flags.noColor and stdout.isatty()

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
    #fileIdentifyGroup(flags.file)
    let file = open(flags.file, fmRead)
    defer: file.close()
    let totalHashes = fileCountLine(flags.file)
    #paint fmt "[bold fg=cyan][INFO] [fg=green]Found [fg=cyan]{totalHashes} [fg=green]hashes in [fg=yellow]{flags.file} [reset]"
    echo fmt "\n[FILE: {flags.file}]"
    for line in file.lines:
      let input = line.strip()
      streamIdentify(input)
    flushHashGroup()
    paint fmt "[bold fg=cyan][[[[fg=green] End Of File of [fg=yellow]{flags.file} [fg=cyan]]]][reset]\n\n"
    let footer = "SUMMARY"
    echo "=".repeat(footer.len+8)
    echo " ".repeat(4) & footer
    echo "=".repeat(footer.len+8)
    echo fmt "Total files processed: 1"
    echo fmt "Total hashes found: "
    echo fmt "Scan duration: "
    echo ""
    let eof = "END OF IDENTIFICATION REPORTA"
    echo "=".repeat(eof.len+8)
    echo " ".repeat(4) & footer
    echo "=".repeat(eof.len+8)

    return

  if flags.hash.len > 0:
    if flags.hash == "-":
      #maybe streams will do
      for line in stdin.lines():
        let input = line.strip
        identifyHash(input, flags.trunc, flags.probe, flags.ignore, format)
    elif flags.hash != "-" and flags.hash != "":
      identifyHash(flags.hash, flags.trunc, flags.probe, flags.ignore, format)
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
    paint "[bold fg=green]hashpeek v0.3.1 by ph4mished (https://github.com/ph4mished/hashpeek)[reset]"

#ignore flag should be a bool instead of accepting strings. this is to silence all errors
when isMainModule:
  main()
