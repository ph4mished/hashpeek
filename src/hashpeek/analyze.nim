import strutils, hash_database, tables, re, terminal, os
import ../cli_flag
import spectra, strformat, json





type
  AnalysisResult* = object
    hash*: string
    algorithms*: seq[HashAlgo]
    found*: bool

  GroupedResult* = object
    identifiedResult*: AnalysisResult
    algorithm*: string
    count*: int
    percent*: float
    #output*: string  # the formatted output line
    hashes*: seq[string]

  StreamGroupResults* = object
    groups*: seq[GroupedResult]
    totalHashes*: int






  
#[proc percentage(num, total: int): float = 
    return float(num/total)*100.0]#


proc coreIdentify*(hash: string, database=HASH_DATABASE): (seq[HashAlgo], bool) = 
  if database == HASH_DATABASE:
    for patternStr, algos in database.pairs:
      let pattern = re(patternStr)
      if hash.match(pattern):
        return (algos, true)
  else:
    echo "External Database isn't supported yet"
    quit(1)
    return (@[], false)


#since hashpeek is built to be scalable
#still on the point of getting to know how to make this great for concurrency without giving pressure to one function if a huge file/ list of hash is given
#many chefs in the kitchen is better than one chef in the kitchen doing all the work
#many functions for identification?? or many identifcation instances????
proc identify*(hash: string): AnalysisResult = 
  let (algorithms, found) = coreIdentify(hash.strip())
  return AnalysisResult(
    hash: hash,
    algorithms: algorithms,
    found: found
  )


#this will be the supported formats for external databases
# --database file must be JSON format containing hash definitions:
# {
#     {
#       "name": "CustomAppHash",
#       "pattern": "^[A-Z0-9]{32}$",
#       "description": "Our custom format"
#     }
# }


proc defaultFormat(identResult: AnalysisResult): string =
  if not identResult.found:
    result.add(paint("\n[bold fg=red][ERROR] Unknown hash format[reset]", toStdout=false))

  for hashalgo in identResult.algorithms:
    result.add(paint(fmt "\n[bold fg=blue]  {hashalgo.name} [reset]", toStdout=false))
    result.add(paint(fmt "\n  [bold fg=magenta]  Hashcat Mode: [fg=yellow]{hashalgo.hashcat}[reset]", toStdout=false))
    result.add(paint(fmt "\n  [bold fg=green]  John Format: [fg=yellow]{hashalgo.john}[reset]\n", toStdout=false))



#this variables are defined outside the streamIdentify function to avoid re-initialization of the table anytime the function is called
var 
    #hashtype: string
    streamHashCounts = initTable[string, int]()
    streamIdentResults = initTable[string, AnalysisResult]()
    streamHashLists = initTable[string, seq[string]]()
    streamTotalHashes = 0
    #streamCurrentFormat: proc(identResult: AnalysisResult): string = defaultFormat


proc streamIdentify*(hash: string#[, database=HASH_DATABASE]#) =  
  if hash != "":
    streamTotalHashes.inc()
    let identResult = identify(hash)
    #streamCurrentFormat = format

    if identResult.algorithms.len > 0:
      let algorithmName = identResult.algorithms[0].name
      if algorithmName in streamHashCounts:
        inc(streamHashCounts[algorithmName])
        streamHashLists[algorithmName].add(hash)
      else:
        streamHashCounts[algorithmName] = 1
        streamIdentResults[algorithmName] = identResult
        streamHashLists[algorithmName] = @[hash]
#[
# Demo command 2: Binary probing with memory limit  
hashpeek -f memory_dump.img -pb 32-64 -e 3.8 --analyze --all-candidates --memory-limit 1024 --threads 4

# Output:
==================================================
HASHPEEK - PROFESSIONAL HASH ANALYSIS
==================================================

📊 PROBING SUMMARY
├─ Source: memory_dump.img (8.5 GB)
├─ Probe: Lengths 32-64, Min Entropy: 3.8
├─ Memory Limit: 1024 MB, Threads: 4
├─ Hashes Identified: 347
├─ Unique Hashes: 228
├─ Processing Time: 42.7s
└─ Memory Used: 978 MB
]#

#outputting results makes it look static to me
#[proc flushHashGroup*() =
  if total_hashes > 0:
    #let hashname = algo.name
    for hashname, count in hash_counts:
      if currentFormat == defaultFormat:
        let pct = percentage(count, totalHashes)
        paint fmt "\n\n[bold fg=green]GROUP 1: NTLM - {count} HASHES ({pct:.2f}%) [reset]"
        echo hashtype
      else:
        echo hashname
    #reset for next group
    hash_counts.clear()
    totalHashes = 0]#
      

proc resetStream*() = 
  #reset for next group
  streamHashCounts.clear()
  streamTotalHashes = 0
  streamIdentResults.clear()
  streamHashLists.clear

proc getStreamResults*(): StreamGroupResults = 
  var groups: seq[GroupedResult]

  if streamTotalHashes > 0:
    for algorithmName, count in streamHashCounts:
      let percent = (count.float / streamTotalHashes.float) * 100
      #var formattedOutput: string

      let identResult = streamIdentResults[algorithmName]
      #let formattedOutput = streamCurrentFormat(identResult)
      #if streamCurrentFormat == defaultFormat:
        #formattedOutput = fmt "GROUP 1: {algorithm} - {count} HASHES ({percent:.2f}%)\n {algorithm"
      #else:
      #formattedOutput = algorithm
      #algorithms should accept seq[HASHALGO]
      groups.add(GroupedResult(identifiedResult: identResult, algorithm: algorithmName, count: count, percent: percent, hashes: streamHashLists[algorithmName]))
  resetStream()
  return StreamGroupResults(groups: groups, totalHashes: streamTotalHashes)




#[proc streamGroupIdentify*(hashes: varargs[string], format: proc(identResult: AnalysisResult): string = defaultFormat) = 
  for hash in hashes:
    if hash != "":
      streamIdentify(hash, format)
    flushHashGroup()]#



proc fileCountLine*(filename: string): int = 
  var lineCount: int = 0
  if not fileExists(filename):
    paint fmt "[bold red][ERROR] [green]{filename} does not exist[reset]"
    quit(0)

  try:
    for line in lines(filename):
      if line != "":
        let cleanLine = line.strip()
        inc(lineCount)

  except IOError:
    paint fmt "[bold red][ERROR] Cannot open or read {filename}[reset]"
  result =  lineCount