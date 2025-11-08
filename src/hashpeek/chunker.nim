#this file is made to divide a given file or stream of hashes into chunks
import strutils, strformat, os

#with time, improvements have for it to support stream of hash inputs
proc processInChunks(filename: string, maxLine: int) =
  var
    chunkCount = 0
    totalHashes = 0
    chunk: seq[string] = @[]
    
  if filename.fileExists():
    let file = filename.open(fmRead)
    defer: file.close()

    for line in file.lines():
      inc(totalHashes)
      chunk.add(line)
      if chunk.len >= maxLine:
        chunkCount.inc()
        echo fmt "[INFO] Found {total_hashes} hashes in chunk {chunkCount}"
        echo chunk
        #after using that specific chunk, remember to free memory
        chunk.setLen(0)
        totalHashes = 0
    #reset total Hashes count
    totalHashes = 0
    #process Last chunk
    if chunk.len > 0:
      totalHashes.inc()
      chunkCount.inc()
      echo fmt "[INFO] Found {total_hashes} hashes in Last chunk {chunkCount}"
      echo chunk
  return

    

#[hen isMainModule:
  let filename = "hashed.txt"
  processInChunks(filename, 2)
  let file_size = getFileSize(filename)
  echo file_size
  ]#
      
      
     
