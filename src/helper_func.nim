import strformat, terminal, strutils, os
import spectra
import hashpeek/[outfmt, analyze, extract], cli_flag


colorToggle = not flags.noColor and stdout.isatty()

#output expected when field parsing is used
#[
📊 EXTRACTION SUMMARY
├─ Source: database_export.csv
├─ Extraction: Field 3 using ',' delimiter  
├─ Memory Limit: 512 MB (streaming mode)
├─ Hashes Identified: 1,247
├─ Unique Hashes: 892
├─ Processing Time: 3.8s
└─ Memory Used: 487 MB]#

#truncation, extHex, extCtext and ignore will be handled here
#ignore flag will be a bool
#extract hex hashes will be deprecated for extract flag which will use the database regex for finding hashes
proc probeHashes*(messyInput: string) = 
  let foundHashes = extractHashes(messyInput)
  let title = fmt "HASHES FOUND {foundHashes.len}"
  echo "=".repeat(title.len)
  echo " ".repeat(4) & title
  echo "=".repeat(title.len)
  for hash in foundHashes:
    echo "Match: ", hash

#use this for file analysis output
#[
# Command:
hashpeek -f hashes.txt --all-candidates --cracking-formats --analyze

# Output:
==================================================
HASHPEEK - FILE HASH ANALYSIS
==================================================

📊 FILE ANALYSIS REPORT
├─ Source: hashes.txt
├─ Total Hashes Processed: 8
├─ Unique Hashes: 7
├─ Hash Types Identified: 4
├─ Processing Time: 0.8s
└─ Analysis: Multi-hash correlation


🏷️ GROUP 4: UNIDENTIFIED - 1 HASH (12.5%)
├─ Hash: xyz123abc456def789ghi012jkl345mno678pqr
├─ Characteristics: Mixed charset, unusual pattern
├─ Possible: Custom hash, session token, or false positive
└─ Recommendation: Manual investigation required

==================================================
8 HASHES ANALYZED - READY FOR TRIAGED ATTACK
==================================================


]#

proc fileIdentify*(filename#[, truncLine: string, probe, ignore: bool, format]#: string) =
  if filename.fileExists():
    #[case format:
    of "json": 
      let form = jsonFormat
    else: 
     let form = defaultFormat]#
    #var lineCount, groupCount = 0
    for line in lines(filename):
      #inc(lineCount)
      streamIdentify(line)
    let res = treeGroupFormat(getStreamResults())
    #drop paint until range defect error is fixed
    echo res
    echo "END OF FILE"
    #echo res
    #[echo fmt "Found {lineCount} HASHES IN {filename}"
    for group in res.groups:
      inc(groupCount)
      paint fmt "\n\n[bold fg=white]HASH CLUSTER {groupCount}[fg=reset]: [fg=#FF6600]   {group.count} OF {lineCount} HASHES ARE[reset]\n{group.output}[na]"
      for hash in group.hashes:
        echo fmt "[EXTRACTED HASHES]: {hash}"]#
  else:
    echo fmt "File: {filename} does not exists"


proc identifyHash*(hash, truncLine: string, probe, ignore: bool, format: string) =
  #let contexts = @["hash", "password", "pwd"]
  var extValue: seq[string]
  let title = "HASH IDENTIFICATION REPORT"
  echo "=".repeat(title.len+8)
  echo " ".repeat(4) & title
  echo "=".repeat(title.len+8)

 
  if hash.len > 0:    
    #if extCtext != "" or extHex != "":
    if probe:
      let extHashes = extractHashes(hash)
      #extValue.add(myExtractor.extract(hash))
      if extHashes == @[]:
        paint fmt "[bold red][ERROR] Extraction Failed: [green]No hash found[reset]"
        echo extHashes
        return
      else:
        echo fmt "PROBING SUMMARY"
        #echo treeLine(1, false, "Source: memory_dump.img")
        #echo treeLine(1, false, "Min Entropy: 3.8")
        #echo treeLine(1, false, "Memory Limit: 1024 MB")
        #echo treeLine(1, false, "Threads: 4")
        echo treeLine(1, false, fmt "Hashes Found: {extHashes.len}")
        #echo treeLine(1, false, "Processing Time: 42.7s")
        #echo treeLine(1, false, "Memory Used: 987 MB")
        echo treeLine(1, true, "Extracted Hashes: ")
        for i, hash in extHashes:
          if i == extHashes.len-1:
            echo treeLine(2, true, fmt "{hash}\n")
          else:
            echo treeLine(2, false, hash)
        
        
        for extHash in extHashes:
          if format == "json":
            echo jsonFormat(identify(extHash))
          else:
            #echo "hi"
            #echo extHash
            #paint fmt "\n  [bold green]Extracted Hash: [yellow]{extHash}[reset]"
            #paint "[bold cyan]MOST LIKELY HASHES[reset]"
            echo fmt "{treeFormat(identify(extHash))}\n"
        return

    #for truncation part
    if truncLine != "":  
      let (truncIndex, truncDelim) = parseTruncate(truncLine)  
      #echo truncIndex, truncDelim
      var fp = newFieldParser()
      fp.incrementLine()
      let (truncRes, error) = fp.parseField(hash, truncDelim, truncIndex)
      if truncRes != "" or error.status == "error":
        if format == "json":
          #handle error for json
          if error.status == "error":
            echo jsonErrOut(error)
            return
          echo jsonFormat(identify(truncRes))
        else:
          if error.status == "error":
            if not ignore:
              paint fmt "[bold fg=yellow][WARN] Skipped Line {error.line}: Expected at least {truncIndex+1} fields [fg=cyan](got {error.field}) [fg=yellow]after splitting by delimiter '{truncDelim}'.[reset] "
              paint fmt "[bold fg=green]Content: {error.content}[reset]"
              quit(1)
          else:
            paint fmt "\n  [bold fg=green] Extracted Hash: [fg=yellow]{truncRes}[reset]"
            echo fmt "{defaultFormat(identify(truncRes))}\n"
        return
    
    #for normal
    else:
      if format == "json":
        echo jsonFormat(identify(hash))
        return
      else:
        #paint fmt "\n  [bold fg=green]Hash: [fg=yellow]{hash}[reset]"
        #echo fmt "{defaultFormat(identify(hash))}\n"
        echo fmt "{treeFormat(identify(hash))}\n"
      return

