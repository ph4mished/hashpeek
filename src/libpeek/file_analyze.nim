import strformat, strutils, tables, os, terminal
import outfmt, analyze, ../cli_flag

proc percentage(num, total: int): float = 
    return float(num/total)*100.0


#[proc fileIdentifyGroupWithExtract*(hash_file, extCtext: string, extHex: int) = 
  var 
    hashtype: string
    hash_counts = initTable[string, int]()
    totalHashes = 0
    extValue: seq[string]

  if not hash_file.fileExists():
    stderr.write(ifColor(fgRed, "[ERROR] ") & ifColor(fgGreen, fmt "{hashfile} not found\n"))
    stderr.flushFile()
    return

  #should check if its a directory

  let file = open(hashfile, fmRead)
  defer: file.close()

  for line in file.lines:
    let input = line.strip()

    if input != "":
      totalHashes.inc()  
      if extCtext != "" or extHex > 0:
        extValue.add(myExtractor.extract(input))
        for extStr in extValue:
        #if format == "" or format == "default":
          stdout.write(ifColor(fgGreen, "\nExtracted Hash: ") & ifColor(fgYellow, fmt "{extStr}"))
          stdout.flushFile()
      hashtype = defaultFormat(identify(extStr))
      #[elif format == "json":
        echo jsonFormat(identify(input))
        return
      elif format == "csv":
        echo csvFormat(identify(input))]#
      #check existence of key before incrementing
      if hashtype in hash_counts:
        inc(hash_counts[hashtype])
      else:
        hash_counts[hashtype] = 1
  if total_hashes > 0:
    stdout.write(ifColor(fgCyan, "\n[INFO]") & ifColor(fgGreen, " Found ") & ifColor(fgCyan, totalHashes) & ifColor(fgGreen, " hashes in ") & ifColor(fgYellow, fmt "{hash_file}\n"))
    stdout.flushFile()
    for hashtype, count in hash_counts:
      let pct = percentage(count, totalHashes)
      stdout.write(ifColor(fgGreen, "\n{") & ifColor(fgYellow, fmt "{pct:.2f}%") & ifColor(fgGreen, "}") & ifColor(fgCyan, fmt " {count}/{totalHashes} Of The Hashes Are:\n") & fmt "{hashtype}\n")
      stdout.flushFile()

]#


proc fileIdentifyGroup*(hash_file: string) = 
  var 
    hashtype: string
    hash_counts = initTable[string, int]()
    totalHashes = 0
  if not hash_file.fileExists():
    stderr.write(ifColor(fgRed, "[ERROR] ") & ifColor(fgGreen, fmt "{hashfile} not found\n"))
    stderr.flushFile()
    return

  #should check if its a directory

  let file = open(hashfile, fmRead)
  defer: file.close()

  for line in file.lines:
    let input = line.strip()

    if input != "":
      totalHashes.inc()
      #if format == "" or format == "default":
      hashtype = defaultFormat(identify(input))
      #[elif format == "json":
        echo jsonFormat(identify(input))
        return
      elif format == "csv":
        echo csvFormat(identify(input))]#
      #check existence of key before incrementing
      if hashtype in hash_counts:
        inc(hash_counts[hashtype])
      else:
        hash_counts[hashtype] = 1
  if total_hashes > 0:
    stdout.write(ifColor(fgCyan, "\n[INFO]") & ifColor(fgGreen, " Found ") & ifColor(fgCyan, totalHashes) & ifColor(fgGreen, " hashes in ") & ifColor(fgYellow, fmt "{hash_file}\n"))
    stdout.flushFile()
    for hashtype, count in hash_counts:
      let pct = percentage(count, totalHashes)
      stdout.write(ifColor(fgGreen, "\n{") & ifColor(fgYellow, fmt "{pct:.2f}%") & ifColor(fgGreen, "}") & ifColor(fgCyan, fmt " {count}/{totalHashes} Of The Hashes Are:\n") & fmt "{hashtype}\n")
      stdout.flushFile()


proc fileIdentify*(hashFile, format: string) = 
  if not hashFile.fileExists():
    stderr.write(ifColor(fgRed, "[ERROR] ") & ifColor(fgGreen, fmt "{hashfile} not found\n"))
    stderr.flushFile()
    return

  let file = open(hashFile, fmRead)
  defer: file.close()

  for line in file.lines():
    if line.strip() != "":
      if format == "" or format == "default":
        stdout.write(fgCyan, "POSSIBLE HASHTYPES")
        stdout.flushFile()
        echo defaultFormat(identify(line.strip()))
      elif format == "json":
        echo jsonFormat(identify(line.strip()))
        return
      elif format == "csv":
        echo csvFormat(identify(line.strip()))
      