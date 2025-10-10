import tables

type
  HashAlgo* = object
    name*: string
    hashcat*: string
    john*: string
    extended*: bool


# Hash database - using Nim's case-insensitive regex
let HASH_DATABASE* = {
  "^(?i)[a-f0-9]{4}$": @[
    HashAlgo(name: "CRC-16", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "CRC-16-CCITT", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FCS-16", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{6}$": @[
    HashAlgo(name: "CRC-24", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{8}$": @[
    HashAlgo(name: "Adler-32", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "CRC-32", hashcat: "--", john: "crc32", extended: false),
    HashAlgo(name: "CRC-32B", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1-32", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1a-32", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Murmur3-32", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FCS-32", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "GHash-32-3", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "GHash-32-5", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Fletcher-32", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Joaat", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "ELF-32", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "XOR-32", hashcat: "--", john: "--", extended: false)
  ],
  
  "^[a-zA-Z0-9./]{13}$": @[
    HashAlgo(name: "DES (Unix)", hashcat: "1500", john: "descrypt", extended: false),
    HashAlgo(name: "DEScrypt", hashcat: "1500", john: "descrypt", extended: false),
    HashAlgo(name: "BigCrypt", hashcat: "--", john: "bigcrypt", extended: true)
  ],
  
  "^[a-f0-9]{40}:[a-f0-9]{16}$": @[
    HashAlgo(name: "Android PIN", hashcat: "5800", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{16}$": @[
    HashAlgo(name: "DES(Oracle)", hashcat: "3100", john: "--", extended: false),
    HashAlgo(name: "LM", hashcat: "3000", john: "lm", extended: false),
    HashAlgo(name: "MySQL323", hashcat: "200", john: "mysql", extended: false),
    HashAlgo(name: "CRC-64", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1-64", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1a-64", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Half-MD5", hashcat: "5100", john: "--", extended: false)
  ],
  
  "^(?i)[a-z0-9./]{16}$": @[
    HashAlgo(name: "Cisco-PIX(MD5)", hashcat: "2400", john: "pix-md5", extended: false)
  ],
  
  "^[a-zA-Z0-9./]{24}$": @[
    HashAlgo(name: "Crypt16", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{24}$": @[
    HashAlgo(name: "CRC-96-ZIP", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{32}$": @[
    HashAlgo(name: "MD5", hashcat: "0", john: "raw-md5", extended: false),
    HashAlgo(name: "NTLM", hashcat: "1000", john: "nt", extended: false),
    HashAlgo(name: "LM", hashcat: "3000", john: "lm", extended: false),
    HashAlgo(name: "MD4", hashcat: "900", john: "raw-md4", extended: false),
    HashAlgo(name: "Double MD5", hashcat: "2600", john: "--", extended: false),
    HashAlgo(name: "MD2", hashcat: "--", john: "md2", extended: false),
    HashAlgo(name: "RIPEMD-128", hashcat: "--", john: "ripemd-128", extended: false),
    HashAlgo(name: "BLAKE3-128", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1-128", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Murmur3-128", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Haval-128", hashcat: "--", john: "haval-128-4", extended: false),
    HashAlgo(name: "SNEFRU-128", hashcat: "--", john: "snefru-128", extended: false),
    HashAlgo(name: "Skein256-128", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein512-128", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Tiger-128", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Tiger128-3", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{34}$": @[
    HashAlgo(name: "CryptoCurrency(Adress)", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{40}$": @[
    HashAlgo(name: "SHA-1", hashcat: "100", john: "raw-sha1", extended: false),
    HashAlgo(name: "RIPEMD-160", hashcat: "6000", john: "ripemd-160", extended: false),
    HashAlgo(name: "Haval-160", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Double-SHA-1", hashcat: "4500", john: "--", extended: false),
    HashAlgo(name: "Tiger-160", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Tiger-160,3", hashcat: "--", john: "--", extended: false)
  ],
  
  "^[a-z0-9]{43}$": @[
    HashAlgo(name: "Cisco-IOS(SHA-256)", hashcat: "5700", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{48}$": @[
    HashAlgo(name: "Haval-192", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Tiger-192", hashcat: "--", john: "tiger", extended: false),
    HashAlgo(name: "Tiger-192-3", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "SHA-1(Oracle)", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "OSX v10.4", hashcat: "122", john: "xsha", extended: false),
    HashAlgo(name: "OSX v10.5", hashcat: "122", john: "xsha", extended: false),
    HashAlgo(name: "OSX v10.6", hashcat: "122", john: "xsha", extended: false)
  ],
  
  "^(?i)[a-f0-9]{49}$": @[
    HashAlgo(name: "Citrix Netscaler", hashcat: "8100", john: "citrix_ns10", extended: false)
  ],
  
  "^(?i)[a-f0-9]{51}$": @[
    HashAlgo(name: "Palshop CMS", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-z0-9]{51}$": @[
    HashAlgo(name: "CryptoCurrency(PrivateKey)", hashcat: "--", john: "--", extended: false)
  ],
  
  "^\\$2[abxy]\\$\\d{2}\\$[./A-Za-z0-9]{53}$": @[
    HashAlgo(name: "bcrypt", hashcat: "3200", john: "bcrypt", extended: false),
    HashAlgo(name: "Blowfish(OpenBSD)", hashcat: "3200", john: "bcrypt", extended: false),
    HashAlgo(name: "Woltlab Burning Board 4.x", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{56}$": @[
    HashAlgo(name: "SHA-224", hashcat: "--", john: "raw-sha224", extended: false),
    HashAlgo(name: "SHA3-224", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Haval-224", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein-256(224)", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein-512(224)", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Whirlpool-224", hashcat: "--", john: "--", extended: false)
  ],
  
  "^\\$snefru\\$(?i)[a-f0-9]{64}$": @[
    HashAlgo(name: "Snefru-256", hashcat: "--", john: "snefru-256", extended: false)
  ],
  
  "^(?i)[a-f0-9]{64}$": @[
    HashAlgo(name: "SHA-256", hashcat: "1400", john: "raw-sha256", extended: false),
    HashAlgo(name: "SHA3-256", hashcat: "5000", john: "raw-keccak-256", extended: false),
    HashAlgo(name: "BLAKE2s", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "BLAKE3-256", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "RIPEMD-256", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Haval-256", hashcat: "--", john: "haval-256-3", extended: false),
    HashAlgo(name: "Gost", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "GOST R 34.11-94", hashcat: "6900", john: "gost", extended: false),
    HashAlgo(name: "Gost-CryptoPro S-Box", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "SNEFRU-256", hashcat: "--", john: "snefru-256", extended: false),
    HashAlgo(name: "EDON-R-256", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein256-256", hashcat: "--", john: "skein-256", extended: false),
    HashAlgo(name: "Skein512-256", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Whirlpool-256", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{80}$": @[
    HashAlgo(name: "RIPEMD-320", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{96}$": @[
    HashAlgo(name: "SHA-384", hashcat: "10800", john: "raw-sha384", extended: false),
    HashAlgo(name: "SHA3-384", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein512-384", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein1024-384", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Whirlpool-384", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{102}$": @[
    HashAlgo(name: "Skein1024-408", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{128}$": @[
    HashAlgo(name: "SHA-512", hashcat: "1700", john: "raw-sha512", extended: false),
    HashAlgo(name: "SHA3-512", hashcat: "--", john: "raw-keccak", extended: false),
    HashAlgo(name: "BLAKE2b", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "BLAKE3-512", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Salsa10", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Salsa20", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein512-512", hashcat: "--", john: "skein-512", extended: false),
    HashAlgo(name: "Whirlpool", hashcat: "6100", john: "whirlpool", extended: false),
    HashAlgo(name: "EDON-R-512", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Whirlpool-1", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Whirlpool-2", hashcat: "--", john: "--", extended: false)
  ],
  
  "^(?i)[a-f0-9]{256}$": @[
    HashAlgo(name: "Skein512-1024", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein1024-1024", hashcat: "--", john: "--", extended: false)
  ]
}.toTable

