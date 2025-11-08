#identify a hash
let ident = identify("73f9aa497ec97105fa5436b4a43e897bd06c2afc7775b366eebeb8e2")

#results in default format (colored terminal output)
echo defaultFormat(ident)
#results in json format
echo jsonFormat(ident)
#results in csv format
echo csvFormat(ident)


#identify a stream of hashes
let file = open("my_hashFile.txt", fmRead)
defer: file.close()
for line in file.lines:
  let input = line.strip()
  #function for stream identification of hashes
  #extraction before identification is the reason this function is preferred to creating a file identification function
  streamIdentify(input, defaultFormat)
  #for jsonFormat
  #streamIdentify(input, jsonFormat)
#flushHashGroup()
  #for csvFormat
  #streamIndentify(input, csvFormat)
#flushHashGroup()
  #immediately output accumulated/ grouped results
  #remember to flush 
flushHashGroup()

