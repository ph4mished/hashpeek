import strutils, hash_database, tables, re, terminal, os
import ../cli_flag
import spectra, strformat





type
  AnalysisResult* = object
    hash*: string
    algorithms*: seq[HashAlgo]
    found*: bool




proc percentage(num, total: int): float = 
    return float(num/total)*100.0


proc coreIdentify*(hash: string): (seq[HashAlgo], bool) = 
  for patternStr, algos in HASH_DATABASE.pairs:
    let pattern = re(patternStr)
    if hash.match(pattern):
      return (algos, true)

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



proc defaultFormat(identResult: AnalysisResult): string =
  if not identResult.found:
    result.add(paint("\n[bold fg=red][ERROR] Unknown hash format[reset]", toStdout=false))

  for hashalgo in identResult.algorithms:
    result.add(paint(fmt "\n[bold fg=blue]  {hashalgo.name} [reset]", toStdout=false))
    result.add(paint(fmt "\n  [bold fg=magenta]  Hashcat Mode: [fg=yellow]{hashalgo.hashcat}[reset]", toStdout=false))
    result.add(paint(fmt "\n  [bold fg=green]  John Format: [fg=yellow]{hashalgo.john}[reset]\n", toStdout=false))



#this variables are defined outside the streamIdentify function to avoid re-initialization of the table anytime the function is called
var 
    hashtype: string
    hash_counts = initTable[string, int]()
    totalHashes = 0
    currentFormat: proc(identResult: AnalysisResult): string = defaultFormat

proc streamIdentify*(hash: string, format: proc(identResult: AnalysisResult): string = defaultFormat) =  
  if hash != "":
    totalHashes.inc()
    hashtype = format(identify(hash))
    currentFormat = format
    if hashtype in hash_counts:
      inc(hash_counts[hashtype])
    else:
      hash_counts[hashtype] = 1
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

🏷️ GROUP 1: NTLM - 187 HASHS (53.9%)
├─ Primary Type: NTLM (88% confidence)
│  ├─ Hashcat: Mode 1000
│  └─ John: Format nt
├─ Alternative Types:
│  ├─ MD5 (85% confidence)
│  │  ├─ Hashcat: Mode 0
│  │  └─ John: Format raw-md5
│  └─ MD4 (82% confidence)
│     ├─ Hashcat: Mode 900
│     └─ John: Format raw-md4]#

proc flushHashGroup*() =
  if total_hashes > 0:
    for hashtype, count in hash_counts:
      if currentFormat == defaultFormat:
        let pct = percentage(count, totalHashes)
        paint fmt "\n\n[bold fg=green]GROUP 1: NTLM - {count} HASHES ({pct:.2f}%) [reset]"
        echo hashtype
      else:
        echo hashtype
    #reset for next group
    hash_counts.clear()
    totalHashes = 0
      


proc streamGroupIdentify*(hashes: varargs[string], format: proc(identResult: AnalysisResult): string = defaultFormat) = 
  for hash in hashes:
    if hash != "":
      streamIdentify(hash, format)
    flushHashGroup()



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