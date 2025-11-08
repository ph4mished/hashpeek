import strformat, strutils, json, terminal, analyze, extract, hash_database
import spectra
import ../cli_flag



colorToggle = not flags.noColor and stdout.isatty()  


proc defaultFormat*(identResult: AnalysisResult): string =
  if not identResult.found:
    result.add(paint("\n[bold fg=red][ERROR] Unknown hash format[reset]", toStdout=false))
  
  for hashalgo in identResult.algorithms:
    result.add(paint(fmt "\n[bold fg=blue]  {hashalgo.name} [reset]", toStdout=false))
    if hashalgo.characteristics != "":
      result.add("Characteristics: " & hashalgo.characteristics)
    result.add(paint(fmt "\n  [bold fg=magenta]  Hashcat Mode: [fg=yellow]{hashalgo.hashcat}[reset]", toStdout=false))
    result.add(paint(fmt "\n  [bold fg=green]  John Format: [fg=yellow]{hashalgo.john}[reset]\n", toStdout=false))



proc treeLine*(level: int, isLast: bool = false, text: string = "", parentContinue=false): string =
  case level
  of 0:
    result = text
  of 1:
    if isLast: 
      result = "└─ " & text
    else: 
      result = "├─ " & text
  of 2:
    if parentContinue:
      if isLast: 
        result = "│  └─ " & text
      else: 
        result = "│  ├─ " & text
    else:
      if isLast: 
        result = "   └─ " & text
      else: 
        result = "   ├─ " & text
  else:
    if parentContinue:
      if isLast: 
        result = "│" & " ".repeat(level * 2) &   "└─ " & text
      else: 
        result = "│" & " ".repeat(level * 2) &   "├─ " & text
    else:
      if isLast: 
        result = " ".repeat(level * 2) &   "└─ " & text
      else: 
        result = " ".repeat(level * 2) &   "├─ " & text



proc treeFormat*(identResult: AnalysisResult): string =
  if not identResult.found:
  
    #expected output for known results
    #[
    🏷️ GROUP 3: SHA1 - 5 HASHS (17.9%)
├─ Primary Type: SHA1 (90% confidence)
│  ├─ Hashcat: Mode 100
│  └─ John: Format raw-sha1
├─ Alternative Types:
│  └─ MySQL SHA1 (85% confidence)
│     ├─ Hashcat: Mode 300
│     └─ John: Format mysql-sha1]#
   #[ echo "[CANDIDATE 1: MD5 - 95% CONFIDENCE]"
  echo treeLine(1, false, "Characteristics: 32 chars, hexadecimal, unsalted")
  echo treeLine(1, false, "Common Sources: Web apps, file verification, legacy systems")
  echo treeLine(1, false, "Hashcat Mode: 0")
  echo treeLine(2, false, "Command: hashcat -m 0 '5f4dcc3b5aa765d61d8327deb882cf99' rockyou.txt")
  echo treeLine(1, false, "John the Ripper: raw-md5")
  echo treeLine(2, true, "Command: john --format=raw-md5 hash.txt")]#
  #echo ""
  #[🏷️ GROUP 4: UNIDENTIFIED - 1 HASH (12.5%)
├─ Hash: xyz123abc456def789ghi012jkl345mno678pqr
├─ Characteristics: Mixed charset, unusual pattern
├─ Possible: Custom hash, session token, or false positive
└─ Recommendation: Manual investigation required]#

    result.add("UNKNOWN FORMAT - 1 HASH (12.76%)\n")
    result.add(treeLine(1, false, "Characteristics: Mixed charset, unusual pattern\n"))
    result.add(treeLine(1, false, "Possible: Custom hash, session token or false positive\n"))
    result.add(treeLine(1, true, "Hash:\n", false))
    result.add(treeLine(2, true, fmt "{identResult.hash}\n"))
  
  else:
    #result.add("GROUP 1 - 45 HASHES (87.76%)\n")
    var number = 0
    for hashalgo in identResult.algorithms:
      inc(number)
      result.add(fmt "\n[CANDIDATE {number}: {hashalgo.name} - 70% CONFIDENCE]\n")
      result.add(treeLine(1, false, fmt "Characteristics: {hashalgo.characteristics}\n"))
      result.add(treeLine(1, false, fmt "Common Sources: {hashalgo.commonSources}\n"))
      result.add(treeLine(1, false, fmt "Hashcat Mode: {hashalgo.hashcat}\n"))
      if hashalgo.notes != @[] or hashalgo.limitations != @[]:
        result.add(treeLine(1, false, fmt "John Format: {hashalgo.john}\n"))
      else:
        result.add(treeLine(1, true, fmt "John Format: {hashalgo.john}\n"))
      if hashalgo.notes != @[]:
        if hashalgo.limitations != @[]:
          result.add(treeLine(1, false, "Notes\n"))
        else:
          result.add(treeLine(1, true, "Notes\n"))
        for i, note in hashalgo.notes:
          if i == hashalgo.notes.len - 1:
            result.add(treeLine(2, true, fmt "{note}\n", true))
          else:
            result.add(treeLine(2, false, fmt "{note}\n", true))

      if hashalgo.limitations != @[]:
        result.add(treeLine(1, true, "Limitations\n"))
        #result.add(fmt "  LIMITATIONS OF {hashalgo.name}\n")
        for i, limits in hashalgo.limitations:
          if i == hashalgo.limitations.len-1:
            result.add(treeLine(2, true, fmt "{limits}\n\n"))
          else:
            result.add(treeLine(2, false, fmt "{limits}\n"))







proc jsonFormat*(identResult: AnalysisResult): string = 
  if not identResult.found:
    let jsonErr = %*{
      "status": "unknown",
      "value": identResult.hash,
      "description": "Unknown hash format"
    }
    return jsonErr.pretty()

  var processedAlgos = newJArray()
  for algo in identResult.algorithms:
    var algoObj = %algo #convert to json

    if algo.hashcat == "--":
      algoObj["hashcat"] = newJNull()
    else:
      algoObj["hashcat"] = %parseInt(algo.hashcat)
    
    if algo.john == "--":
      algoObj["john"] = newJNull()

    
    processedAlgos.add(algoObj)
  let jsonOut = %*{
      identResult.hash: processedAlgos
  }
  return jsonOut.pretty()



proc csvFormat*(identResult: AnalysisResult): string =
  var csvLine: seq[string] = @["hash,hashtype,hashcat_mode,john_format"]
  if not identResult.found:
    var csvErr: seq[string] = @[]
    csvErr.add("status,value,description")
    csvErr.add("unknown," & identResult.hash & ",unknown hash format")
    return csvErr.join("\n")

  for algo in identResult.algorithms:
     let hashcatMode = if algo.hashcat == "--": "" else: algo.hashcat
     let johnFmt = if algo.john == "--": "" else: algo.john
     csvLine.add(identResult.hash & "," & algo.name & "," & hashcatMode & "," & johnFmt)

  return csvLine.join("\n")

#proc defaultErrFormat*(): string =


proc jsonErrOut*(errOut: ErrorOut): string = 

  let jsonErr = %*{
    "status": errOut.status,
    "message": errOut.message,
    "line": errOut.line,
    "content": errOut.content
  }
  return jsonErr.pretty()


#proc
    