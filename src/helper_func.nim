import strformat, terminal, strutils
import libpeek/[outfmt, file_analyze, analyze, extract], cli_flag

#truncation, extHex, extCtext and ignore will be handled here
#ignore flag will be a bool
proc identifyHash*(hash, extCtext, extHex, truncLine: string, ignore: bool, format: string) =
  var extValue: seq[string]
  var extHexVal: seq[string]


 
  if hash.len > 0:    
    if extCtext != "" or extHex != "":
      var myExtractor = Extractor(
      lengths: parseExtractToSeq(extHex),
      contexts: parseContextToSeq(extCtext),
      )
      extValue.add(myExtractor.extract(hash))
      if extValue == @[]:
        stderr.write(ifColor(fgRed,"[ERROR] Extraction Failed: "))
        stderr.writeLine(ifColor(fgGreen, fmt "No hash found with length(s) {extHex}"))
        stderr.flushFile()
        return
      else:
        for extStr in extValue:
          if format == "csv":
            echo csvFormat(identify(extStr))
          elif format == "json":
            echo jsonFormat(identify(extStr))
          else:
            echo extStr
            stdout.write(ifColor(fgGreen, "\n  Extracted Hash: ") & ifColor(fgYellow, fmt "{extStr}"))
            stdout.flushFile()
            echo fmt "{defaultFormat(identify(extStr))}\n"
        return

    #for truncation part
    elif truncLine != "":  
      let (truncIndex, truncDelim) = parseTruncate(truncLine)  
      #echo truncIndex, truncDelim
      var fp = newFieldParser()
      fp.incrementLine()
      echo num
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
              stderr.writeLine(ifColor(fgYellow, "[WARN] ") & ifColor(fgYellow, "Skipped Line ") & ifColor(fgCyan, fmt "{error.line}") & ifColor(fgYellow, fmt ": Expected at least {truncIndex+1} fields (got {error.field}) after splitting by delimiter '{truncDelim}'"))
              stderr.writeLine(ifColor(fgGreen, "Content: ") & ifColor(fgGreen, fmt "{error.content}"))
              stderr.flushFile()
              quit(1)
          else:
            stdout.write(ifColor(fgGreen, "\n  Extracted Hash: ") & ifColor(fgYellow, fmt "{truncRes}"))
            stdout.flushFile()
          #echo truncRes
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
        stdout.write(ifColor(fgGreen, "\n  Hash: ") & ifColor(fgYellow, fmt "{hash}"))
        stdout.flushFile()
        echo fmt "{defaultFormat(identify(hash))}\n"
      return
