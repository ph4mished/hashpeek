import tables

type
  HashAlgo* = object
    name*: string
    description*: string
    characteristics*: string
    commonSources*: seq[string]
    contexts*: seq[string] #context will be used to control confidence level. every hash will have its context. eg. where it was extracted from
    #baseConfidence*: float
    notes*: seq[string]
    limitations*: seq[string]
    hashcat*: string
    john*: string
    alternativeFormats*: seq[string]
    extended*: bool

    #this is why contexts exists
    #[
    Hash: e10adc3949ba59abbe56e057f20f883e

Without extraction (clean hash):
- MD5: 80%
- NTLM: 75% 
- MD4: 70%
- MySQL323: 40%
# Low confidence, multiple candidates

With extraction (context-aware):
Case 1: Found in web app code:
- MD5: 95% (web apps commonly use MD5)
- NTLM: 25% (rare in web contexts)

Case 2: Found in Windows memory:
- NTLM: 90% (common in Windows auth)
- MD5: 45% (less likely in this context)]#
#more research will be made on 
#where each hash is used
#the file extension and binary formats
#its characteristics, popularity (popularity will be used for its base confidence)


# Hash database - using Nim's case-insensitive regex
let HASH_DATABASE* = {
  r"(?i)\b[a-f0-9]{4}\b": @[
    HashAlgo(name: "CRC-16", description: "Cyclic Redundancy Check 16-bit", characteristics: "4 hexadecimal chars, basic checksum", contexts: @["checksum", "networking"], commonSources: @["file verification", "network protocols", "embedded systems"], notes: @["Error detection in data transmission", "Data storage integrity checks"], limitations: @["Not cryptographic", "Low collision resistance"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "CRC-16-CCITT", description: "Cyclic Redundancy Check 16-bit Consultative Commitee for International Telegraph and Telephone", characteristics: "4 hexadecimal chars, telecommunications standard", contexts: @["checksum", "telecom"], commonSources: @["V.41", "X.25", "HDLC", "Bluetooth"], notes: @["Used for error detection in communication and storage systems", "Data Integrity and verification", "Memory checks integrity"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FCS-16", description: "Frame Check Sequence 6-bit", characteristics: "4 hexadecimal chars, data link layer", contexts: @["checksum", "networking"], commonSources: @["Ethernet frames", "PPP"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{6}\b": @[
    HashAlgo(name: "CRC-24", description: "Cyclic Redundancy Check 24-bits", characteristics: "6 hexadecimal chars, OpenPGP standard", contexts: @["checksum"], commonSources: @["OpenPGP", "RFID", "some file formats"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false)
  ],

  r"(?i)\b[a-f0-9]{8}\b": @[
    HashAlgo(name: "Adler-32", description: "Adler-32 checksum", characteristics: "8 hex chars, zlib compression", commonSources: @["zlib", "PNG files", "RSYNC"], contexts: @["checksum", "compression"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "CRC-32",  description: "Cyclic Redundancy Check 32-bit", characteristics: "8 hex chars, most common checksum", commonSources: @["ZIP files", "Ethernet", "SATA", "PNG"], contexts: @["checksum", "filesystems"], hashcat: "--", john: "crc32", extended: false),
    HashAlgo(name: "CRC-32B", description: "CRC-32 IEEE 802.3 variant", characteristics: "8 hex chars, Ethernet standard", commonSources: @["Ethernet", "MPEG-2", "PKZIP"], contexts: @["checksum", "networking"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1-32", description: "Fowler-Noll-Vo hash 32-bit", characteristics: "8 hex chars, fast non-crypto hash", commonSources: @["DNS", "database indexing", "hash tables"], contexts: @["checksum", "programming"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1a-32", description: "Fowler-Noll-Vo alternative 32-bit", characteristics: "8 hex chars, FNV variant", commonSources: @["programming languages", "database systems"], contexts: @["checksum", "programming"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Murmur3-32", description: "MurmurHash3 32-bit", characteristics: "8 hex chars, fast general-purpose hash", commonSources: @["Redis", "libstdc++", "various frameworks"], contexts: @["programming", "caching"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FCS-32", description: "Frame Check Sequence 32-bit", characteristics: "8 hex chars, advanced networking", commonSources: @["advanced networking protocols"], contexts: @["checksum", "networking"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "GHash-32-3", description: "G-Hash 32-bit 3-round", characteristics: "8 hex chars, experimental hash", commonSources: @["research", "academic"], contexts: @["experimental"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "GHash-32-5", description: "G-Hash 32-bit 5-round", characteristics: "8 hex chars, experimental hash", commonSources: @["research", "academic"], contexts: @["experimental"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Fletcher-32", description: "Fletcher's checksum 32-bit", characteristics: "8 hex chars, error detection", commonSources: @["OSTA UDF", "ISO/IEC 8473-1"], contexts: @["checksum", "storage"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Joaat", description: "Jenkins one-at-a-time hash", characteristics: "8 hex chars, simple string hash", commonSources: @["Perl", "Apache", "various applications"], contexts: @["programming", "hashing"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "ELF-32", description: "ELF-32 hash for object files", characteristics: "8 hex chars, Unix/Linux object files", commonSources: @["ELF binaries", "Unix/Linux systems"], contexts: @["executable", "system"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "XOR-32", description: "Simple XOR-based 32-bit hash", characteristics: "8 hex chars, basic XOR operation", commonSources: @["simple applications", "embedded systems"], contexts: @["basic", "embedded"], limitations: @["Very weak", "not cryptographic"], hashcat: "--", john: "--", extended: false)
  ],
  
  r"\b[a-zA-Z0-9./]{13}\b": @[
    HashAlgo(name: "DES (Unix)", description: "DES-based Unix crypt", characteristics: "13 chars, traditional Unix passwords", commonSources: @["/etc/passwd", "old Unix systems"], contexts: @["unix", "legacy"], limitations: @["Only 8 char passwords", "weak salt"], hashcat: "1500", john: "descrypt", extended: false),
    HashAlgo(name: "DEScrypt", description: "DES crypt implementation", characteristics: "13 chars, [a-zA-Z0-9./] charset", commonSources: @["old Unix/Linux"], contexts: @["unix", "legacy"], notes: @["Traditional Unix password hashing"], hashcat: "1500", john: "descrypt", extended: false),
    HashAlgo(name: "BigCrypt", description: "Extended DES crypt", characteristics: "13+ chars, extended length", commonSources: @["some Unix variants"], contexts: @["unix", "extended"], limitations: @["Rarely used"], hashcat: "--", john: "bigcrypt", extended: true)
  ],
  
  r"\b[a-f0-9]{40}:[a-f0-9]{16}\b": @[
    HashAlgo(name: "Android PIN", description: "Android PIN/Password hash", characteristics: "40 chars hash + 16 chars salt, SHA1 + MD5", commonSources: @["Android lockscreen", "gesture.key files"], contexts: @["mobile", "android"], hashcat: "5800", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{16}\b": @[
    HashAlgo(name: "DES(Oracle)", description: "Oracle DES-based hash", characteristics: "16 hex chars, Oracle specific", commonSources: @["Oracle databases", "Oracle applications"], contexts: @["database", "oracle"], hashcat: "3100", john: "--", extended: false),
    HashAlgo(name: "LM", description: "LAN Manager hash", characteristics: "16 hex chars, all uppercase, split password", commonSources: @["Windows SAM", "legacy Windows"], contexts: @["windows", "legacy"], limitations: @["Very weak", "no lowercase", "split passwords"], hashcat: "3000", john: "lm", extended: false),
    HashAlgo(name: "MySQL323", description: "MySQL 3.23 password hash", characteristics:  "16 chars typical, but can be padded to 32 (hexadecimals)", commonSources: @["old MySQL databases", "legacy systems"], contexts: @["database", "mysql"], limitations: @["Can be broken in seconds", "Susceptible to rainbow tables", "Limited to 8 character passwords", "Deprecated since MySQL 4.1"], hashcat: "200", john: "mysql", extended: false),
    HashAlgo(name: "CRC-64", description: "Cyclic Redundancy Check 64-bit", characteristics: "16 hex chars, ISO 3309", commonSources: @["ISO standards", "some storage systems"], contexts: @["checksum"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1-64", description: "Fowler-Noll-Vo hash 64-bit", characteristics: "16 hex chars, 64-bit version", commonSources: @["64-bit systems", "large datasets"], contexts: @["programming", "hashing"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "FNV-1a-64", description: "Fowler-Noll-Vo alternative 64-bit", characteristics: "16 hex chars, FNV-1a variant", commonSources: @["modern applications", "databases"], contexts: @["programming", "hashing"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Half-MD5", description: "First half of MD5 hash", characteristics: "16 hex chars, MD5 truncated", commonSources: @["some legacy systems", "custom implementations"], contexts: @["legacy", "custom"], limitations: @["Weaker than full MD5"], hashcat: "5100", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-z0-9./]{16}\b": @[
    HashAlgo(name: "Cisco-PIX(MD5)", description: "Cisco PIX MD5 hash", characteristics: "16 alphanumeric + (./) chars", commonSources: @["Cisco PIX firewalls", "Cisco ASA"], contexts: @["networking", "cisco"], hashcat: "2400", john: "pix-md5", extended: false)
  ],

  r"\b[a-zA-Z0-9./]{24}\b": @[
    HashAlgo(name: "Crypt16", description: "Extended crypt16 implementation", characteristics: "24 chars, extended DES crypt", commonSources: @["some Unix variants", "Tru64"], contexts: @["unix", "extended"], notes: @["Rarely used"], hashcat: "--", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{24}\b": @[
    HashAlgo(name: "CRC-96-ZIP", description: "CRC-96 used in some ZIP variants", characteristics: "24 hex chars, extended CRC", commonSources: @["some archive formats", "specialized applications"], contexts: @["checksum", "archives"], limitations: @["Not cryptographic"], hashcat: "--", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{32}\b": @[
    HashAlgo(name: "MD5", description: "MD5 cryptographic hash function",
    characteristics: "32 chars, hexadecimal, unsalted", commonSources: @["web applications", "file integrity checks", "checksums", "legacy systems"], contexts: @["web", "checksum", "legacy"], notes: @["Used as checksum to verify data or file integrity", "MD5 is cryptographically broken as it is vulnerable to collision attacks"], hashcat: "0", john: "raw-md5", extended: false),
    HashAlgo(name: "NTLM", description: "Windows NTLM authentication hash",
    characteristics: "32 chars, Windows authentication, based on MD4", commonSources: @["Windows SAM", "Active Directory", "LSASS memory"], contexts: @["windows", "SAM", "LSASS"], notes: @["Use if source is Windows system"], hashcat: "1000", john: "nt", alternativeFormats: @["Hashcat Mode: 5600 (NetNTLMv2) - if network captured", "Hashcat Mode: 5500 (NetNTLMv1) - legacy versions", "John Format: netntlm (for network hashes)", "John Format: netntlmv2 (v2 hashes)"], extended: false),
    HashAlgo(name: "LM", description: "Windows LAN Manager hash", characteristics: "32 chars, all uppercase, no lowercase", commonSources: @["Windows SAM", "legacy Windows systems"], contexts: @["windows", "SAM"], notes: @["Use if source is Windows system"], hashcat: "3000", john: "lm", extended: false),
    HashAlgo(name: "MD4", characteristics: "32 chars, legacy Microsoft systems", commonSources: @["Old Windows systems", "legacy applications"],hashcat: "900", john: "raw-md4", extended: false),
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
  
  r"(?i)\b[a-f0-9]{34}\b": @[
    HashAlgo(name: "CryptoCurrency(Adress)", hashcat: "--", john: "--", extended: false)
  ],

  r"\b\$1\$[a-zA-Z0-9./]{0,8}\$[a-zA-Z0-9./]{22}\b": @[
    HashAlgo(name: "MD5 Crypt", characteristics: "$1$ prefix, includes salt, 34-60 chars", commonSources: @["/etc/shadow", "web applications", "Linux systems"], hashcat: "500", john: "md5crypt")
  ], 

  
  r"(?i)\b[a-f0-9]{40}\b": @[
    HashAlgo(name: "SHA-1", description: "SHA-1 cryptographic hash function", 
    characteristics: "40 chars, hexadecimal, unsalted", commonSources: @["Git commits", "file verification", "legacy certificates"], contexts: @["token", "API", "authentication"], hashcat: "100", john: "raw-sha1", extended: false),
    HashAlgo(name: "MySQL SHA1", description: "MySQL double SHA1 implementation", characteristics: "40 chars, double SHA1 with salt", commonSources: @["MySQL user tables", "database dumps", "phpMyAdmin"], notes: @["Use if source is database export"], hashcat: "300", john: "mysql-sha1"),
    HashAlgo(name: "RIPEMD-160", characteristics: "40 chars, Bitcoin addresses, digital signatures", commonSources: @["Blockchain", "PGP", "TLS"], notes: @["Rarely used for passwords"], hashcat: "6000", john: "ripemd-160", extended: false),
    HashAlgo(name: "Haval-160", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Double-SHA-1", hashcat: "4500", john: "--", extended: false),
    HashAlgo(name: "Tiger-160", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Tiger-160,3", hashcat: "--", john: "--", extended: false)
  ],
  
  r"\b[a-z0-9]{43}\b": @[
    HashAlgo(name: "Cisco-IOS(SHA-256)", hashcat: "5700", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{48}\b": @[
    HashAlgo(name: "Haval-192", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Tiger-192", hashcat: "--", john: "tiger", extended: false),
    HashAlgo(name: "Tiger-192-3", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "SHA-1(Oracle)", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "OSX v10.4", hashcat: "122", john: "xsha", extended: false),
    HashAlgo(name: "OSX v10.5", hashcat: "122", john: "xsha", extended: false),
    HashAlgo(name: "OSX v10.6", hashcat: "122", john: "xsha", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{49}\b": @[
    HashAlgo(name: "Citrix Netscaler", hashcat: "8100", john: "citrix_ns10", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{51}\b": @[
    HashAlgo(name: "Palshop CMS", hashcat: "--", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-z0-9]{51}\b": @[
    HashAlgo(name: "CryptoCurrency(PrivateKey)", hashcat: "--", john: "--", extended: false)
  ],

  r"^$2[abxy]\$[0-9]{2}\$[./A-Za-z0-9]{53}$": @[
    HashAlgo(name: "bcrypt", description: "bcrypt password hashing", characteristics: "$2a$/2b$/2x$/2y$ prefix, 60 chars", commonSources: @["/etc/shadow", "modern web applications", "databases"], contexts: @["modern", "secure"], hashcat: "3200", john: "bcrypt", extended: false),
    HashAlgo(name: "Woltlab Burning Board 4.x", hashcat: "--", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{56}\b": @[
    HashAlgo(name: "SHA-224", hashcat: "--", john: "raw-sha224", extended: false),
    HashAlgo(name: "SHA3-224", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Haval-224", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein-256(224)", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein-512(224)", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Whirlpool-224", hashcat: "--", john: "--", extended: false)
  ],
  
  r"\bsnefru\$[a-fA-F0-9]{64}\b": @[
    HashAlgo(name: "Snefru-256", hashcat: "--", john: "snefru-256", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{64}\b": @[
    HashAlgo(name: "SHA-256", description: "SHA-256 cryptographic hash function", characteristics: "64 chars, hexadecimal, unsalted", commonSources: @["Bitcoin", "SSL certificates", "modern applications", "file verification"], hashcat: "1400", john: "raw-sha256", extended: false),
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
  
  r"(?i)\b[a-f0-9]{80}\b": @[
    HashAlgo(name: "RIPEMD-320", hashcat: "--", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{96}\b": @[
    HashAlgo(name: "SHA-384", hashcat: "10800", john: "raw-sha384", extended: false),
    HashAlgo(name: "SHA3-384", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein512-384", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein1024-384", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Whirlpool-384", hashcat: "--", john: "--", extended: false)
  ],


  r"\$5\$[a-zA-Z0-9./]{0,16}\$[a-zA-Z0-9./]{43}": @[
    HashAlgo(name: "SHA256 Crypt", description: "SHA-256 based crypt", characteristics: "$5$ prefix, 55-75 chars", commonSources: @["/etc/shadow", "Linux systems"], contexts: @["unix", "modern"], hashcat: "7400", john: "sha256crypt", extended: false)
  ],

  r"^\$6\$[a-zA-Z0-9./]{0,16}\$[a-zA-Z0-9./]{86}$": @[
    HashAlgo(name: "SHA512 Crypt", characteristics: "$6$ prefix, includes salt, 96-106 chars", commonSources: @["/etc/shadow (modern Linux systems)", "Unix/Linux password authentication", "security focused applications"], contexts: @["unix", "secure"], notes: @["Industry standard for modern Linux systems"],hashcat: "1800", john: "sha512crypt")
  ], 


  r"^\$argon2i\$v=[0-9]+\$m=[0-9]+,t=[0-9]+,p=[0-9]+\$[a-zA-Z0-9+/]+\$[a-zA-Z0-9+/]+$": @[
    HashAlgo(name: "Argon2i", description: "Argon2 memory-hard function", characteristics: "Argon2i variant, memory intensive", commonSources: @["modern applications", "password managers"], contexts: @["modern", "secure"], hashcat: "argon2", john: "argon2", extended: false)
  ],
  
  r"^\$pbkdf2-sha256\$[0-9]+\$[a-zA-Z0-9+/]+\$[a-zA-Z0-9+/]+$": @[
    HashAlgo(name: "PBKDF2-SHA256", description: "PBKDF2 with SHA-256", characteristics: "iterations count, salt, hash", commonSources: @["Django", "macOS", "various apps"], contexts: @["modern", "kdf"], hashcat: "10000", john: "pbkdf2-hmac-sha256", extended: false)
  ],
  
  r"^\$scrypt\$[a-zA-Z0-9]+\$[a-zA-Z0-9+/]+\$[a-zA-Z0-9+/]+$": @[
    HashAlgo(name: "scrypt", description: "scrypt key derivation function", characteristics: "memory-hard KDF", commonSources: @["cryptocurrencies", "some password managers"], contexts: @["modern", "secure"], hashcat: "scrypt", john: "scrypt", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{102}\b": @[
    HashAlgo(name: "Skein1024-408", hashcat: "--", john: "--", extended: false)
  ],
  
  r"(?i)\b[a-f0-9]{128}\b": @[
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
  
  r"(?i)\b[a-f0-9]{256}\b": @[
    HashAlgo(name: "Skein512-1024", hashcat: "--", john: "--", extended: false),
    HashAlgo(name: "Skein1024-1024", hashcat: "--", john: "--", extended: false)
  ]
}.toTable

