import strformat, terminal, strutils
import spectra
import hashpeek/[outfmt, file_analyze, analyze, extract], cli_flag


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

🔍 HASH TYPE GROUPS

🏷️ GROUP 1: SHA-1 - 3 HASHS (37.5%)
├─ Primary Type: SHA-1 (95% confidence)
├─ Characteristics: 40 chars, hexadecimal, unsalted
├─ Hashcat Mode: 100
├─ John the Ripper: raw-sha1
├─ Security Impact: 🟡 WARNING (Deprecated)
└─ Sample Hashes (2 of 3):
   ├─ a94a8fe5ccb19ba61c4c0873d391e987982fbbd3
   │  ├─ Best: SHA-1 (95%) - "test"
   │  └─ Entropy: 3.85 ✅
   └─ 7c4a8d09ca3762af61e59520943dc26494f8941b
      ├─ Best: SHA-1 (96%) - "123456"  
      └─ Entropy: 3.82 ✅

🏷️ GROUP 2: MD5 - 2 HASHS (25%)
├─ Primary Type: MD5 (95% confidence)
├─ Characteristics: 32 chars, hexadecimal, unsalted
├─ Hashcat Mode: 0
├─ John the Ripper: raw-md5
├─ Security Impact: 🔴 CRITICAL (Weak)
└─ Sample Hashes (2 of 2):
   ├─ 5f4dcc3b5aa765d61d8327deb882cf99
   │  ├─ Best: MD5 (98%) - "password"
   │  └─ Entropy: 3.72 ✅
   └─ e10adc3949ba59abbe56e057f20f883e
      ├─ Best: MD5 (97%) - "123456"
      └─ Entropy: 3.70 ✅

🏷️ GROUP 3: bcrypt - 2 HASHS (25%)
├─ Primary Type: bcrypt (100% confidence)
├─ Characteristics: $2a$ prefix, 60 chars, salted
├─ Hashcat Mode: 3200
├─ John the Ripper: bcrypt
├─ Security Impact: 🟢 SECURE (Modern)
└─ Sample Hashes (2 of 2):
   ├─ $2a$10$N9qo8uLOickgx2ZMRZoMyeIJNRQePd7gJZpbj6BnOdpVq.pPoh6z6
   │  └─ Best: bcrypt (100%) - Strong
   └─ $2a$12$L6qyD8Q1zR2nS9pXwY3vAeB4cD5eF6gH7iJ8kL9mN0oP1qR2sT3u
      └─ Best: bcrypt (100%) - Strong

🏷️ GROUP 4: UNIDENTIFIED - 1 HASH (12.5%)
├─ Hash: xyz123abc456def789ghi012jkl345mno678pqr
├─ Characteristics: Mixed charset, unusual pattern
├─ Possible: Custom hash, session token, or false positive
└─ Recommendation: Manual investigation required

==================================================
8 HASHES ANALYZED - READY FOR TRIAGED ATTACK
==================================================


]#




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
          if format == "csv":
            echo csvFormat(identify(extHash))
          elif format == "json":
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
        if format == "csv":
          if error.status == "error":
            stderr.writeLine("status,error,line,content")
            stderr.writeLine(fmt "{error.status},{error.message},{error.line},{error.content}")
            stderr.flushFile()
            quit(1)
          echo csvFormat(identify(truncRes))
        elif format == "json":
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
      if format == "csv":
        echo hash
        echo csvFormat(identify(hash))
        return
      elif format == "json":
        echo jsonFormat(identify(hash))
        return
      else:
        #paint fmt "\n  [bold fg=green]Hash: [fg=yellow]{hash}[reset]"
        #echo fmt "{defaultFormat(identify(hash))}\n"
        echo fmt "{treeFormat(identify(hash))}\n"
      return



#[proc identifyFile*(hashFile, truncLine: string, extract, ignore: bool, format: string) =
  #this is meant to open a given file and identify it
  echo fmt "[INFO] Analyzing file: {hashFile}"
  #detected file format (a file format parsing function is needed)
  #eg:
  #echo fmt "[INFO] Detected shadow file format"
  echo fmt "[INFO] Analyzing file: {hashFile}"]#