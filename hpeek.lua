require ("./hash_analyze")
require("./grp_hash")
require("./help")
require("./file_analyzer")

orng = "\27[38;5;208m"
borng = "\27[1;38;5;208m"
bcyn = "\27[1;36m"
rst = "\27[0m"
bred = "\27[1;31m"
	grn  = "\27[32m"
vol  = "\27[35m"
bvol  = "\27[1;35m"
bgrn  = "\27[1;32m"
	blu  = "\27[34m"
bblu  = "\27[1;34m"
	ylw  = "\27[33m"
bylw  = "\27[1;33m"
	red  = "\27[31m"


 local flags = {}

function ifColor(front_color, word, back_color)
  if flags.color == true then
return (front_color.. word.. back_color)
  end
  return word
end

local i = 1
while i <= #arg do
  local a = arg[i]
  if a == "-f" or a == "--file" then
    if arg[i + 1] == nil then
      print("[!] Error: Missing file name after "..a)
      return
    end
    flags.file = arg[i + 1]
    i = i + 1
  elseif a == "--verbose" then
    flags.verbose = true
    elseif a == "--color" or a == "-c" then
    flags.color = true
  elseif a == "--hash" then
    if arg[i + 1] == nil then
      print("[!] Error: Missing hash string after "..a)
      return
    end
    flags.hash = arg[i + 1]
    i = i + 1
    
    elseif a == "--help" or a == "-h" then
    flags.help = true
      
      elseif a == "--version" or a == "-v" then
  print("hashpeek v0.1.0")
  return
        
  else
    print(ifColor(red, "[!] Unknown argument:  "..a , rst))
  end
  i = i + 1
end

if flags.color then
end

if flags.file then
  if flags.verbose == true then
  
  print(file_analyze(flags.file))
  print(ifColor(bblu, "[[[  ", rst)..ifColor( bcyn, "End Of File Of ", rst)..ifColor(bgrn, flags.file, rst)..ifColor(bblu, "  ]]]", rst))
  return
  end
  
  print(group_hash(flags.file))
  print(ifColor(bblu, "[[[  ", rst)..ifColor( bcyn, "End Of File Of ", rst)..ifColor(bgrn, flags.file, rst)..ifColor(bblu, "  ]]]", rst))
  return
end


  if flags.verbose then
  end

if flags.help then
  help()
  return
end

if flags.hash then
 local result = hash_identify(flags.hash)
  if result:find("\n") then
  print(ifColor(bcyn, "\nPOSSIBLE HASHTYPES", rst))
  print(ifColor(orng, result, rst))
  return
  end
  print(ifColor(bcyn, "\nHASHTYPE: ", rst ), ifColor(orng, "[+] "..result, rst))
  
else
  help()
  return
end
