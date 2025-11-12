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
      result = paint("[bold fg=blue]└─ [reset]", toStdout=false) & text
    else: 
      result = paint("[bold fg=blue]├─ [reset]", toStdout=false) & text
  of 2:
    if parentContinue:
      if isLast: 
        result = paint("[bold fg=blue]│  └─ [reset]", toStdout=false) & text
      else: 
        result = paint("[bold fg=blue]│  ├─ [reset]", toStdout=false) & text
    else:
      if isLast: 
        result = paint("[bold fg=blue]   └─ [reset]", toStdout=false) & text
      else: 
        result = paint("[bold fg=blue]   ├─ [reset]", toStdout=false) & text
  else:
    if parentContinue:     
      if isLast: 
        result = paint("[bold fg=blue]│[reset]", toStdout=false) & " ".repeat(level * 2) &   paint("[bold fg=blue]└─ [reset]", toStdout=false) & text
      else: 
        result = paint("[bold fg=blue]│[reset]", toStdout=false) & " ".repeat(level * 2) &   paint("[bold fg=blue]├─ [reset]", toStdout=false) & text
    else:
      if isLast: 
        result = " ".repeat(level * 2) &   paint("[bold fg=blue]└─ [reset]", toStdout=false) & text
      else: 
        result = " ".repeat(level * 2) &   paint("[bold fg=blue]├─ [reset]", toStdout=false) & text

#helper funtion 
proc treeArray(level: int, arrayInput: seq[string], parentCont: bool=false): string =
  for i, input in arrayInput:
    if i == arrayInput.len-1:
      result.add(treeLine(level, true, fmt "{input}\n", parentCont))
    else:
      result.add(treeLine(level, false, fmt "{input}\n", parentCont))

proc treeFormat*(identResult: AnalysisResult): string =
  if not identResult.found:
    result.add("UNKNOWN FORMAT - 1 HASH (12.76%)\n")
    result.add(treeLine(1, false, "Characteristics: Mixed charset, unusual pattern\n"))
    result.add(treeLine(1, false, "Possible: Custom hash, session token or false positive\n"))
    result.add(treeLine(1, true, "Hash:\n", false))
    result.add(treeLine(2, true, fmt "{identResult.hash}\n"))
  
  else:
    var number = 0
    for hashalgo in identResult.algorithms:
      #it needs to be have a check to know empty fields so that it can tell the last field
      inc(number)
      result.add(paint(fmt "\n[bold fg=blue][[fg=cyan]CANDIDATE {number}: [fg=green]{hashalgo.name}[fg=reset] - 70% CONFIDENCE[fg=blue]][reset]\n", toStdout=false))
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
        
        result.add(treeArray(2, hashalgo.notes, true))
    
      if hashalgo.limitations != @[]:
        result.add(treeLine(1, true, "Limitations\n"))
        result.add(treeArray(2, hashalgo.limitations))


proc treeGroupFormat*(groupResult: StreamGroupResults): string = 
  var groupCount, clusterCount = 0
  let totalHashes = groupResult.totalHashes
  #until a hash is requested, print only the identification results (lest the results be so much a load to read). 
  #ill add a flag that will only group hashes and wont identify. i think "-ni, --no-identify is better"
  #this part will be cropped out.
  result.add(fmt "GROUPED HASHES\n")
  for i, group in groupResult.groups:
    inc(groupCount)
    result.add(treeLine(1, false, paint(fmt "[bold fg=magenta]HASH CLUSTER {groupCount}[reset]\n", toStdout=false)))
    if groupResult.groups.len == i:
      result.add(treeArray(2, group.hashes, false))
    else:
      echo "LEn: ", groupResult.groups.len
      result.add(treeArray(2, group.hashes, true))
  for group in groupResult.groups:
    inc(clusterCount)
    result.add(paint(fmt "\n\n[bold fg=white]HASH CLUSTER {clusterCount}[fg=reset]: [fg=#FF6600]   {group.count} OF {totalHashes} HASHES ARE[reset]\n", toStdout=false))
    if not group.identifiedResult.found:
      result.add("UNKNOWN FORMAT - 1 HASH (12.76%)\n")
      result.add(treeLine(1, false, "Characteristics: Mixed charset, unusual pattern\n"))
      result.add(treeLine(1, false, "Possible: Custom hash, session token or false positive\n"))
      result.add(treeLine(1, true, "Hash:\n", false))
      result.add(treeLine(2, true, fmt "{group.identifiedResult.hash}\n"))
  
    else:
      #result.add("GROUP 1 - 45 HASHES (87.76%)\n")
      #result.add("GROUP 1 - 45 HASHES (87.76%)\n")
      var number = 0
      for hashalgo in group.identifiedResult.algorithms:
        #it needs to be have a check to know empty fields so that it can tell the last field
        inc(number)
        result.add(paint(fmt "\n[bold fg=blue][[fg=cyan]CANDIDATE {number}: [fg=green]{hashalgo.name}[fg=reset] - 70% CONFIDENCE[fg=blue]][reset]\n", toStdout=false))
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
            result.add(treeArray(2, hashalgo.notes, true))
          else:
            result.add(treeLine(1, true, "Notes\n"))
            result.add(treeArray(2, hashalgo.notes))
    
        if hashalgo.limitations != @[]:
          result.add(treeLine(1, true, "Limitations\n"))
          result.add(treeArray(2, hashalgo.limitations))




proc jsonGroupFormat*(groupResult: StreamGroupResults): string = 
  var groupArray = newJArray()
  var jsonOut = %*{"groups": []}
  for group in groupResult.groups:
    jsonOut["groups"].add(%*{
      "algorithm": group.algorithm,
      "hashes": group.hashes
      })
  groupArray.add(jsonOut)
  return groupArray.pretty()





proc jsonFormat*(identResult: AnalysisResult): string = 
  if not identResult.found:
    let jsonErr = %*{
      "status": "unknown",
      "characteristics": "mixed charset, unusual pattern",
      "description": "custom hash, session token or false positive",
       "hash": identResult.hash,
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
    