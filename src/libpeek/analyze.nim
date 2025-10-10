import strutils, hash_database, tables, re

type
  AnalysisResult* = object
    hash*: string
    algorithms*: seq[HashAlgo]
    found*: bool

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


#group identify for files