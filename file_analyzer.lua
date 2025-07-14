require("hash_analyze")

function file_analyze(hashFile)
  local count = 0
  local ok, file = pcall(io.open, hashFile, "r")
  if not ok or not file then
    return ifColor(bred, "[!] Error opening file: " .. tostring(hashFile), rst)
  end

  for line in file:lines() do
    local hashLine = line:match("^%s*(.-)%s*$")

    if #hashLine > 0 then
      local result = hash_identify(hashLine)
      print("\n" .. hashLine)

      if result and #result > 0 then
        count = count + 1
        if result:find("\n") then
          print(ifColor(bcyn, "POSSIBLE HASHTYPES", rst))
        else
          print(ifColor(bcyn, "HASHTYPE: ", rst))
        end
        print(ifColor(orng, result, rst))
      else
        print(ifColor(bred, "[!] Unknown hash format", rst))
      end
    end
  end

  file:close()
end
