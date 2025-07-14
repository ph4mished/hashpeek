require("./hash_analyze")


local function percentage(num, total)
  return string.format("%.2f", (num / total) * 100)
end

function group_hash(hashFile)
  local hash_counts = {}
  local total_hashes = 0
  
  for line in io.lines(hashFile) do
    local hash = line:match("^%s*(.-)%s*$")
    if #hash > 0 then
      total_hashes = total_hashes + 1
      local hashtype = hash_identify(hash)
      
      if type(hashtype) == "table" then
        hashtype = hashtype[1] or "Unknown"
      end

      hash_counts[hashtype] = (hash_counts[hashtype] or 0) + 1
    end
  end

  print(ifColor(bgrn, "[~] Found ", rst)..ifColor(borng, total_hashes, rst)..ifColor(bgrn, " hashes in ", rst)..ifColor(borng, hashFile, rst))
  
  for hashtype, count in pairs(hash_counts) do
    
    pct = percentage(count, total_hashes)
    print(string.format(ifColor(bylw, "\n%s%% ", rst)..ifColor(bcyn, "(%d/%d)", rst)..ifColor(bcyn, " Of The Hashes Are:\n", rst)..ifColor(orng, "\n%s", rst), pct, count, total_hashes, hashtype))
  end
end

-- Run it
--group_hash("/storage/emulated/0/hashed.txt")
