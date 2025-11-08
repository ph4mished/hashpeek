import strutils, tables, sequtils, os, strformat, terminal, macros

type
  Schema* = object
    cli*: Cli
    flags*: seq[Flag]
    commands*: seq[Command]
    examples*: seq[Example]
  
  Cli* = object
    app*: string
    version*: string
    description*: string

  #support commands, subcommands and args
  Arg* = object
    name*: string
    argType*: string
    help*: string
  
  Flag* = object
    name*:string
    short*:string
    flagType*:string
    default*: string 
    help*: string
    #group*: string
    #required*: bool

  Command* = object
    name*: string
    help*: string

  Example* = object
    name*: string
    command: string
  
  ParseResult* = ref object
    data*: Table[string, string]
    #in able to use generic get() we need to store the types here
    flagType*: Table[string, string]
    #positionalArg*: seq[string]
    #command: Table*[string, string]
    #subcommand*: Table[string, string]

  
  

 #[
  
  ParseResult = ref object
    data: Table[string, Value]
    commands: Table[string, Value]
    subcommands: Table[string, Value]
    positionalArgs: seq[string]  # For any non-flag arguments]#


proc parseSchema*(input: string): Schema =
  var 
    inReadMode = false
    currentTag = ""
    tags: seq[string] = @[]
    cli = Cli()
    flags: seq[Flag] = @[]
    examples: seq[Example] = @[]
    
  
  # Extract tags between [ and ]
  for ch in input:
    if ch == '[' and not inReadMode:
      inReadMode = true
    elif ch == ']' and inReadMode:
      inReadMode = false
      tags.add(currentTag)
      currentTag = ""
    elif inReadMode:
      currentTag.add(ch)
  
  #var 
    
  
  for tag in tags:
    var
      flag = Flag()
      example = Example()
    # Get first word (command type)
    var firstWord = ""
    for ch in tag:
      if ch == ' ': break
      firstWord.add(ch)
  
    var i = firstWord.len
      
    while i < tag.len:
      # Skip spaces
      while i < tag.len and tag[i] == ' ': inc i
      if i >= tag.len: break
        
      # Read key
      var key = ""
      while i < tag.len and tag[i] != '=' and tag[i] != ' ':
        key.add(tag[i])
        inc i
        
      # Skip =
      if i < tag.len and tag[i] == '=': inc i
        
      # Read value
      var value = ""
      if i < tag.len and tag[i] == '"':
        inc i
        while i < tag.len and tag[i] != '"':
          value.add(tag[i])
          inc i
        if i < tag.len and tag[i] == '"': inc i
      else:
        while i < tag.len and tag[i] != ' ':
          value.add(tag[i])
          inc i
        
        
      # Store in flag
      if firstWord == "flag":
        case key 
        of "name": flag.name = value
        of "short": flag.short = value
        of "type": flag.flagType = value
        #of "required": flag.required = value == "true"
        of "default": flag.default = value
        of "help": flag.help = value
      
      #store in cli
      elif firstWord == "cli":
        case key
        of "app": cli.app = value
        of "version": cli.version = value
        of "description": cli.description = value
      
      elif firstWord == "example":
        case key
        of "name": example.name = value
        of "command": example.command = value

    if flag.name != "":
      flags.add(flag)

    if example.name != "":
      examples.add(example)
  
  return Schema(cli: cli #[, groups: groups]#, flags: flags, examples: examples)


#auto generate and define what shows when --version is typed
proc generateHelp(schema: Schema): string =
  var sections: seq[string] 

  #Cli header
  if schema.cli.app != "":
    var 
      title: string = ""
    var header = schema.cli.app
    if schema.cli.version != "":
      title = fmt "{schema.cli.app.toUpperAscii()} v{schema.cli.version}"
    else:
      title = fmt "{schema.cli.app.toUpperAscii()}"
    let padding = " ".repeat((terminalWidth() - title.len) div 2)
    let borderPadding = " ".repeat((terminalWidth() - title.len-16) div 2)
    let border =  "=".repeat(title.len+16)
    header.add(fmt "\n{borderPadding}{border}\n")
    header.add(fmt "{padding}{title}\n")
    header.add(fmt "{borderPadding}{border}\n")
      #header.add(fmt "v{schema.cli.version}")
    if schema.cli.description != "":
      header.add(fmt "\n{schema.cli.description}")
    sections.add(header)

  #usage section
  var usage = "USAGE:\n"
  usage.add(fmt "    {schema.cli.app}")
  if schema.commands.len > 0:
    usage.add(" [COMMAND]")
  usage.add(" [FLAGS]")
  if schema.flags.len > 0:
    usage.add(" [OPTIONS]")
  sections.add(usage)


  #commands section
  if schema.commands.len > 0:
    var commands = "COMMANDS:\n"
    for cmd in schema.commands:
      #left-align in a field of 15 chars wide.
      commands.add(fmt "    {cmd.name:<15} {cmd.help}")
    sections.add(commands)


  #flags section
  if schema.flags.len > 0:
    var flags = "FLAGS:\n"
    for flag in schema.flags:
      var flagLine = ""
      if flag.short != "":
        flagLine.add(fmt "-{flag.short}, --{flag.name}")
      else:
        flagLine.add(fmt "    --{flag.name}")

      if flag.flagType != "bool":
        flagLine.add(fmt " {flag.flagType.toUpperAscii}")
      
      while flagLine.len < 28:
        flagLine.add(" ")
      flagLine.add(fmt "{flag.help}")

      if flag.default != "":
        flagLine.add(fmt "[default: {flag.default}]")
      
      flags.add(fmt "    {flagLine}\n")
    sections.add(flags)
    
  #example section
  if schema.examples.len > 0:
    var examples = "EXAMPLES:\n"
    for example in schema.examples:
      examples.add(fmt "    {example.name}:\n")
      examples.add(fmt "        {example.command}\n\n")
    sections.add(examples)
  
  result = sections.join("\n\n")

# Public API
proc help*(schema: Schema): string =
  generateHelp(schema)






proc parseCommandLine*(schema: Schema, args=commandLineParams()): ParseResult =
  var
    #flagType: initTable[string, string]
    data: Table[string, string]
    i = 0
  

  while i < args.len:
    var flagFound = false
    let arg = args[i]
    #long flag
    if arg.startsWith("--"):
      let flagName = arg[2..^1]
      #find the value in schema
      for flag in schema.flags:
        if flag.name == flagName:
          flagFound = true
          if flag.flagType == "bool":
            #result.flagType[flagName] = flag.flagType
            data[flagName] = "true"
          else:
          #get the value (next argument)
            inc i 
            if i < args.len:
              #result.flagType[flagName] = flag.flagType
              data[flagName] = args[i]
          break
      if not flagFound:
        #raise newException(ValueError, fmt "Unknown flag: {arg}")
        echo fmt "Unknown flag: {arg}"
        quit(1)

    elif arg.startsWith("-"):
      let shortName = arg[1..^1]
      
      for flag in schema.flags:
        if flag.short == shortName:
          flagFound = true
          
          if flag.flagType == "bool":
            #result.flagType[flag.name] = flag.flagType
            #result.
            data[flag.name] = "true"
          else:
            #get the value
            inc i 
            if i < args.len:
              #result.flagType[flag.name] = flag.flagType
              #result.
              data[flag.name] = args[i]
          break
      if not flagFound:
        echo fmt "Unknown flag: {arg}"
        quit(1)
        #raise newException(ValueError, fmt "Unknown flag: {arg}")
  
    #else: else handle positional argument or unknown
    inc i
  return ParseResult(data: data)

  #default for flags that werent provided
  for flag in schema.flags:
    if not result.data.hasKey(flag.name) and flag.default != "":
      #result.
      data[flag.name] = flag.default



proc flagExists*(parseRes: ParseResult, flagName: string): bool =
  # Check if schema has a flag with this name or short
  #echo "Parse Result from flag existence check: ", parseRes.data
  return parseRes.data.hasKey(flagName)

    
proc asInt*(parseRes: ParseResult, flagName: string): int =
  let value = parseRes.data.getOrDefault(flagName)
  try:
    if value != "":
      return parseInt(value)
    else:
      return 0
  except ValueError:
    echo fmt "Error: Expected integer for flag '{flagName}', but got '{value}'"
    echo fmt "Please provide a numeric value"
    quit(1)

proc `[]`*(parseRes: ParseResult, flagName: string): string = 
  let value = parseRes.data.getOrDefault(flagName)
  return value

proc asBool*(parseRes: ParseResult, flagName: string): bool = 
  if parseRes.data.hasKey(flagName):
    return true

proc getAllFlags*(schema: Schema): Table[string, Flag] =
  ## Get all flags as a table
  var parseRes = initTable[string, Flag]()
  for flag in schema.flags:
    parseRes[flag.name] = flag




#[proc get*(parseRes: ParseResult, flagName: string): auto =
  if not parseRes.flagType.hasKey(flagName) or parseRes.data.hasKey(flagName):
    echo fmt "Flag not found: {flagName}"
    quit(1)
   
  let flagType = parseRes.flagType[flagName]
  #let rawValue = parseRes.data[flagName]

  case flagType:
  of "int":
    return getInt(parseRes, flagName)
  of "string":
    return getString(parseRes, flagName)
  of "bool":
    return getBool(parseRes, flagName)
  else:
    echo fmt "Error: Unknown flag type: {flagType}"
    quit(1)]#
    