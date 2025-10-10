import strformat, strutils, json, terminal, analyze, extract
import ../cli_flag
#the user after identf

type
  FormatOut = object
    hashtype: string
    hashcat: string
    john: string

    

proc defaultFormat*(identResult: AnalysisResult): string =
  if not identResult.found:
    result.add(ifColor(fgRed, "\n[ERROR] ") & ifColor(fgGreen, "Unknown hash format\n"))

  for hashalgo in identResult.algorithms:
    result.add(ifColor(fgBlue, fmt "\n  {hashalgo.name}") & ifColor(fgMagenta, "\n    Hashcat Mode: ") & ifColor(fgYellow, hashalgo.hashcat) & ifColor(fgGreen, "\n    John Format: ") & ifColor(fgYellow, fmt "{hashalgo.john}\n"))


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
  var csvLine: seq[string] = @[]
  if not identResult.found:
    var csvErr: seq[string] = @[]
    csvErr.add("status,value,description")
    csvErr.add("unknown," & identResult.hash & ",unknown hash format")
    return csvErr.join("\n")

  for algo in identResult.algorithms:
     let hashcatMode = if algo.hashcat == "--": "" else: algo.hashcat
     let johnFmt = if algo.john == "--": "" else: algo.john
     csvLine.add("hash,hashtype,hashcat_mode,john_format")
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

    