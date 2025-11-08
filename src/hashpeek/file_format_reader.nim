import os, strutils, strformat, tables, times
#this function will be used for file_type detection
type
  FileType* = enum
    ftUnknown = "Unknown"
    ftText = "Text"
    ftPDF = "PDF"
    ftZIP = "ZIP"
    ftPNG = "PNG"
    ftJPEG = "JPEG"
    ftGIF = "GIF"
    ftBMP = "BMP"
    ftMP3 = "MP3"
    ftMP4 = "MP4"
    ftAVI = "AVI"
    ftEXE = "Windows Executable"
    ftELF = "ELF Binary"
    ftDOC = "Microsoft Word"
    ftXLS = "Microsoft Excel"
    ftPPT = "Microsoft PowerPoint"
    ftHTML = "HTML"
    ftXML = "XML"
    ftJSON = "JSON"
    ftCSV = "CSV"
    ftRAR = "RAR"
    ftTAR = "TAR"
    ftGZIP = "GZIP"
    ftISO = "ISO Image"
    # Windows Registry/Security files
    ftRegistryHive = "Windows Registry Hive"
    ftSAM = "SAM Database"
    ftSYSTEM = "SYSTEM Registry Hive"
    ftSECURITY = "SECURITY Registry Hive"
    ftSOFTWARE = "SOFTWARE Registry Hive"
    ftNTUSER = "NTUSER.DAT Registry"
    ftUSRCLASS = "USRCLASS.DAT Registry"
    ftAmCache = "AmCache.hve"
    ftSHADOW = "Volume Shadow Copy"
    ftEVT = "Windows Event Log"
    ftEVTX = "Windows Event Log (XML)"
    ftPREFETCH = "Windows Prefetch"
    ftPAGE_FILE = "Page File"
    ftHIBER_FILE = "Hibernation File"
    ftMEMORY_DUMP = "Memory Dump"
    ftLNK = "Windows Shortcut"
    ftJUNCTION = "Directory Junction"

  FileInfo* = object
    fileType*: FileType
    mimeType*: string
    description*: string
    confidence*: float
    isWindowsArtifact*: bool
    isSensitive*: bool

const
  MagicNumbers = {
    # Images
    "\x89PNG\r\n\x1a\n": (ftPNG, "image/png", "Portable Network Graphics"),
    "\xFF\xD8\xFF": (ftJPEG, "image/jpeg", "JPEG image"),
    "GIF87a": (ftGIF, "image/gif", "GIF image"),
    "GIF89a": (ftGIF, "image/gif", "GIF image"),
    "BM": (ftBMP, "image/bmp", "Bitmap image"),
    
    # Documents
    "%PDF": (ftPDF, "application/pdf", "PDF document"),
    "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1": (ftDOC, "application/msword", "Microsoft Office document"),
    "PK\x03\x04": (ftZIP, "application/zip", "ZIP archive"),
    "Rar!\x1A\x07\x00": (ftRAR, "application/x-rar-compressed", "RAR archive"),
    "ustar": (ftTAR, "application/x-tar", "TAR archive"),
    "\x1F\x8B\x08": (ftGZIP, "application/gzip", "GZIP compressed file"),
    
    # Audio/Video
    "ID3": (ftMP3, "audio/mpeg", "MP3 audio"),
    "\x00\x00\x00 ftyp": (ftMP4, "video/mp4", "MP4 video"),
    "RIFF": (ftAVI, "video/x-msvideo", "AVI video"),
    
    # Executables
    "MZ": (ftEXE, "application/x-msdownload", "Windows executable"),
    "\x7FELF": (ftELF, "application/x-executable", "ELF binary"),
    
    # Disk images
    "CD001": (ftISO, "application/x-iso9660-image", "ISO disk image"),
    
    # Text formats
    "<!DOCTYPE HTML": (ftHTML, "text/html", "HTML document"),
    "<?xml": (ftXML, "application/xml", "XML document"),
    "{": (ftJSON, "application/json", "JSON data"),
    "<html": (ftHTML, "text/html", "HTML document"),

    # Windows Registry Hives (all start with "regf")
    "regf": (ftRegistryHive, "application/x-windows-registry", "Windows Registry Hive"),
    
    # Windows Event Logs
    "ElfFile": (ftEVT, "application/x-windows-event-log", "Windows Event Log"),
    "Elf\x00": (ftEVT, "application/x-windows-event-log", "Windows Event Log"),
    
    # Windows Prefetch
    "\x11\x00\x00\x00\x53\x43\x43\x41": (ftPREFETCH, "application/x-windows-prefetch", "Windows Prefetch File"),
    
    # Memory dumps
    "PAGEDUMP": (ftMEMORY_DUMP, "application/x-memory-dump", "Windows Memory Dump"),
    "DUMP": (ftMEMORY_DUMP, "application/x-memory-dump", "Windows Memory Dump"),
  }.toTable()

  ExtensionMap = {
    # Text files
    "txt": (ftText, "text/plain", "Plain text file"),
    "csv": (ftCSV, "text/csv", "Comma-separated values"),
    "html": (ftHTML, "text/html", "HTML document"),
    "htm": (ftHTML, "text/html", "HTML document"),
    "xml": (ftXML, "application/xml", "XML document"),
    "json": (ftJSON, "application/json", "JSON data"),
    
    # Images
    "png": (ftPNG, "image/png", "Portable Network Graphics"),
    "jpg": (ftJPEG, "image/jpeg", "JPEG image"),
    "jpeg": (ftJPEG, "image/jpeg", "JPEG image"),
    "gif": (ftGIF, "image/gif", "GIF image"),
    "bmp": (ftBMP, "image/bmp", "Bitmap image"),
    
    # Documents
    "pdf": (ftPDF, "application/pdf", "PDF document"),
    "doc": (ftDOC, "application/msword", "Microsoft Word document"),
    "docx": (ftDOC, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "Microsoft Word document"),
    "xls": (ftXLS, "application/vnd.ms-excel", "Microsoft Excel spreadsheet"),
    "xlsx": (ftXLS, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Microsoft Excel spreadsheet"),
    "ppt": (ftPPT, "application/vnd.ms-powerpoint", "Microsoft PowerPoint presentation"),
    "pptx": (ftPPT, "application/vnd.openxmlformats-officedocument.presentationml.presentation", "Microsoft PowerPoint presentation"),
    
    # Archives
    "zip": (ftZIP, "application/zip", "ZIP archive"),
    "rar": (ftRAR, "application/x-rar-compressed", "RAR archive"),
    "tar": (ftTAR, "application/x-tar", "TAR archive"),
    "gz": (ftGZIP, "application/gzip", "GZIP compressed file"),
    
    # Audio/Video
    "mp3": (ftMP3, "audio/mpeg", "MP3 audio"),
    "mp4": (ftMP4, "video/mp4", "MP4 video"),
    "avi": (ftAVI, "video/x-msvideo", "AVI video"),
    
    # Executables
    "exe": (ftEXE, "application/x-msdownload", "Windows executable"),
    "dll": (ftEXE, "application/x-msdownload", "Windows dynamic link library"),
    "so": (ftELF, "application/x-sharedlib", "Shared library"),
    "bin": (ftELF, "application/octet-stream", "Binary file"),
    
    # Disk images
    "iso": (ftISO, "application/x-iso9660-image", "ISO disk image"),

    # Windows specific files
    "lnk": (ftLNK, "application/x-ms-shortcut", "Windows Shortcut"),
    "evt": (ftEVT, "application/x-windows-event-log", "Windows Event Log"),
    "evtx": (ftEVTX, "application/x-windows-event-log", "Windows Event Log (XML)"),
    "pf": (ftPREFETCH, "application/x-windows-prefetch", "Windows Prefetch File"),
    "sys": (ftEXE, "application/x-msdownload", "Windows System File"),
  }.toTable()

  WindowsArtifactFiles = {
    # Registry hives
    "sam": (ftSAM, "application/x-windows-registry", "Security Account Manager database", true),
    "system": (ftSYSTEM, "application/x-windows-registry", "SYSTEM registry hive", true),
    "security": (ftSECURITY, "application/x-windows-registry", "SECURITY registry hive", true),
    "software": (ftSOFTWARE, "application/x-windows-registry", "SOFTWARE registry hive", false),
    "ntuser.dat": (ftNTUSER, "application/x-windows-registry", "User registry hive", true),
    "usrclass.dat": (ftUSRCLASS, "application/x-windows-registry", "User class registry hive", true),
    "amcache.hve": (ftAmCache, "application/x-windows-registry", "Application compatibility cache", false),
    
    # Shadow copies
    "shadow": (ftSHADOW, "application/x-volume-shadow-copy", "Volume Shadow Copy", true),
    
    # System files
    "pagefile.sys": (ftPAGE_FILE, "application/x-pagefile", "Windows Page File", true),
    "hiberfil.sys": (ftHIBER_FILE, "application/x-hibernation", "Windows Hibernation File", true),
    "swapfile.sys": (ftPAGE_FILE, "application/x-pagefile", "Windows Swap File", true),
  }.toTable()

proc readFileHeader(filename: string, maxBytes: int = 16): string =
  var file: File
  if open(file, filename):
    try:
      var buffer = newString(maxBytes)
      let bytesRead = readBuffer(file, addr buffer[0], maxBytes)
      if bytesRead > 0:
        result = buffer[0..<bytesRead]
    except:
      result = ""
    finally:
      close(file)

proc isTextFile(content: string): bool =
  if content.len == 0:
    return false
  
  var controlChars = 0
  let maxCheck = min(content.len, 1024)
  
  for i in 0..<maxCheck:
    let ch = content[i]
    if ch == '\0':
      return false
    elif ch <= '\x08' or (ch >= '\x0E' and ch <= '\x1F') and ch != '\x1B':
      inc controlChars
  
  result = (float(controlChars) / float(maxCheck)) < 0.1

proc detectWindowsArtifact(filename: string): FileInfo =
  let (dir, name, ext) = splitFile(filename)
  let fullName = name & ext
  let lowerName = fullName.toLowerAscii()
  
  # Check for exact Windows artifact filenames
  for artifactName, (fileType, mime, desc, sensitive) in WindowsArtifactFiles.pairs:
    if lowerName == artifactName:
      return FileInfo(
        fileType: fileType,
        mimeType: mime,
        description: desc,
        confidence: 0.95,
        isWindowsArtifact: true,
        isSensitive: sensitive
      )
  
  # Check for registry hive by content (starts with "regf")
  let header = readFileHeader(filename, 4)
  if header.startsWith("regf"):
    var desc = "Windows Registry Hive"
    var sensitive = false
    var specificType = ftRegistryHive
    
    # Try to identify specific hive type by filename
    case lowerName
    of "sam": 
      specificType = ftSAM
      desc = "SAM Database"
      sensitive = true
    of "system": 
      specificType = ftSYSTEM
      desc = "SYSTEM Registry Hive"
      sensitive = true
    of "security": 
      specificType = ftSECURITY
      desc = "SECURITY Registry Hive"
      sensitive = true
    of "software": 
      specificType = ftSOFTWARE
      desc = "SOFTWARE Registry Hive"
    of "ntuser.dat": 
      specificType = ftNTUSER
      desc = "NTUSER.DAT Registry"
      sensitive = true
    of "usrclass.dat": 
      specificType = ftUSRCLASS
      desc = "USRCLASS.DAT Registry"
      sensitive = true
    of "amcache.hve": 
      specificType = ftAmCache
      desc = "AmCache.hve Registry"
    
    return FileInfo(
      fileType: specificType,
      mimeType: "application/x-windows-registry",
      description: desc,
      confidence: 0.98,
      isWindowsArtifact: true,
      isSensitive: sensitive
    )
  
  return FileInfo(fileType: ftUnknown, confidence: 0.0)

proc detectFileType*(filename: string): FileInfo =
  ## Detect the file type including Windows artifacts
  if not fileExists(filename):
    return FileInfo(fileType: ftUnknown, mimeType: "application/octet-stream", 
                   description: "File not found", confidence: 0.0)
  
  # First, check for Windows artifacts (high priority)
  let windowsDetection = detectWindowsArtifact(filename)
  if windowsDetection.confidence > 0.9:
    return windowsDetection
  
  let header = readFileHeader(filename)
  let (dir, name, ext) = splitFile(filename)
  let lowerExt = ext.toLowerAscii().strip(chars = {'.'})
  
  # Magic number detection
  for magic, (fileType, mime, desc) in MagicNumbers.pairs:
    if header.startsWith(magic):
      return FileInfo(
        fileType: fileType,
        mimeType: mime,
        description: desc,
        confidence: 0.9,
        isWindowsArtifact: false,
        isSensitive: false
      )
  
  # Extension-based detection
  if lowerExt.len > 0 and ExtensionMap.hasKey(lowerExt):
    let (fileType, mime, desc) = ExtensionMap[lowerExt]
    return FileInfo(
      fileType: fileType,
      mimeType: mime,
      description: desc,
      confidence: 0.7,
      isWindowsArtifact: false,
      isSensitive: false
    )
  
  # Text file detection
  try:
    let content = readFile(filename)
    if isTextFile(content):
      return FileInfo(
        fileType: ftText,
        mimeType: "text/plain",
        description: "Text file",
        confidence: 0.8,
        isWindowsArtifact: false,
        isSensitive: false
      )
  except:
    discard
  
  return FileInfo(fileType: ftUnknown, confidence: 0.0)

proc getDetailedFileInfo*(filename: string): string =
  let fileInfo = detectFileType(filename)
  let (dir, name, ext) = splitFile(filename)
  
  var sensitivityInfo = ""
  if fileInfo.isWindowsArtifact:
    sensitivityInfo = &"\nWindows Artifact: YES\nSensitive: {fileInfo.isSensitive}"
  
  result = &"""
File Analysis Report:
====================
Filename: {name}{ext}
Directory: {dir}
Size: {getFileSize(filename)} bytes
Type: {fileInfo.fileType}
MIME Type: {fileInfo.mimeType}
Description: {fileInfo.description}
Confidence: {fileInfo.confidence * 100:.1f}%{sensitivityInfo}
"""

# Specialized scanners for forensic artifacts
proc scanRegistryHive*(filename: string): string =
  let info = detectFileType(filename)
  if info.fileType in {ftRegistryHive, ftSAM, ftSYSTEM, ftSECURITY, ftSOFTWARE, ftNTUSER, ftUSRCLASS, ftAmCache}:
    return &"Registry hive detected: {info.description}"
  else:
    return "Not a registry hive file"

proc scanSensitiveFiles*(directory: string): seq[string] =
  ## Scan a directory for sensitive Windows artifacts
  var sensitiveFiles: seq[string] = @[]
  
  for kind, path in walkDir(directory):
    if kind == pcFile:
      let fileInfo = detectFileType(path)
      if fileInfo.isSensitive:
        sensitiveFiles.add(&"{path} - {fileInfo.description}")
  
  return sensitiveFiles

# Example usage
when isMainModule:
  import os
  
  if paramCount() == 0:
    echo "Usage: file_detector <filename> [filename2 ...]"
    echo "Or: file_detector --scan <directory> (to find sensitive files)"
    quit(1)
  
  if paramStr(1) == "--scan" and paramCount() >= 2:
    let directory = paramStr(2)
    echo &"Scanning for sensitive files in: {directory}"
    let sensitiveFiles = scanSensitiveFiles(directory)
    if sensitiveFiles.len > 0:
      echo "Sensitive files found:"
      for file in sensitiveFiles:
        echo "  " & file
    else:
      echo "No sensitive files found."
  else:
    for i in 1..paramCount():
      let filename = paramStr(i)
      if fileExists(filename):
        echo getDetailedFileInfo(filename)
        echo "---"
      else:
        echo &"Error: File '{filename}' not found\n"