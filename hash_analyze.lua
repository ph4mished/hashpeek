require("./hash_db")


function is_hex(str)
    return str:match("^[a-fA-F0-9]+$") ~= nil
end


function hash_identify(hashstring)
    local hash_len = #hashstring
    if is_hex(hashstring) and hash_database[hash_len] then
        local results = {}
        for _, hash in ipairs(hash_database[hash_len]) do
            table.insert(results, string.format(
                ifColor(bblu, " %s", rst)..ifColor(bvol, "\n   Hashcat Mode: ", rst)..ifColor(bylw, "%s", rst)..ifColor(borng, "\n   John Format: ", rst)..ifColor(bylw, "%s\n", rst),
                hash.name, hash.hashcat, hash.john
            ))
        end
        return table.concat(results, "\n")
    else
        return ifColor(bred, "[!] Unknown Hash Format!", rst)
    end
end
