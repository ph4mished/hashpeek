package main

import "regexp"

type HASHALGO struct {
	Name    string
	HashCat string
	John    string
}

var HASH_DATABASE = map[*regexp.Regexp][]HASHALGO{

	regexp.MustCompile(`^(?i)[a-f0-9]{4}$`): {
		{Name: "CRC-16", HashCat: "--", John: "--"},
		{Name: "CRC-16-CCITT", HashCat: "--", John: "--"},
		{Name: "FCS-16", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{6}$`): {
		{Name: "CRC-24", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{8}$`): {
		{Name: "Adler-32", HashCat: "--", John: "--"},
		{Name: "CRC-32", HashCat: "--", John: "crc32"},
		{Name: "CRC-32B", HashCat: "--", John: "--"},
		{Name: "FNV-1-32", HashCat: "--", John: "--"},
		{Name: "FNV-1a-32", HashCat: "--", John: "--"},
		{Name: "Murmur3-32", HashCat: "--", John: "--"},
		{Name: "FCS-32", HashCat: "--", John: "--"},
		{Name: "GHash-32-3", HashCat: "--", John: "--"},
		{Name: "GHash-32-5", HashCat: "--", John: "--"},
		{Name: "Fletcher-32", HashCat: "--", John: "--"},
		{Name: "Joaat", HashCat: "--", John: "--"},
		{Name: "ELF-32", HashCat: "--", John: "--"},
		{Name: "XOR-32", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{16}$`): {
		{Name: "DES(Oracle)", HashCat: "3100", John: "--"},
		{Name: "LM", HashCat: "3000", John: "lm"},
		{Name: "MySQL323", HashCat: "200", John: "mysql"},
		{Name: "CRC-64", HashCat: "--", John: "--"},
		{Name: "FNV-1-64", HashCat: "--", John: "--"},
		{Name: "FNV-1a-64", HashCat: "--", John: "--"},
		{Name: "Half-MD5", HashCat: "5100", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{32}$`): {
		{Name: "MD5", HashCat: "0", John: "raw-md5"},
		{Name: "NTLM", HashCat: "1000", John: "nt"},
		{Name: "LM", HashCat: "3000", John: "lm"},
		{Name: "MD4", HashCat: "900", John: "raw-md4"},
		{Name: "Double MD5", HashCat: "2600", John: "--"},
		{Name: "MD2", HashCat: "--", John: "md2"},
		{Name: "RIPEMD-128", HashCat: "--", John: "ripemd-128"},
		{Name: "BLAKE3-128", HashCat: "--", John: "--"},
		{Name: "FNV-1-128", HashCat: "--", John: "--"},
		{Name: "Murmur3-128", HashCat: "--", John: "--"},
		{Name: "SNEFRU-128", HashCat: "--", John: "snefru-128"},
		{Name: "Skein256-128", HashCat: "--", John: "--"},
		{Name: "Skein512-128", HashCat: "--", John: "--"},
		{Name: "Tiger-128", HashCat: "--", John: "--"},
		{Name: "Tiger128-3", HashCat: "--", John: "--"},
		{Name: "Haval-128", HashCat: "--", John: "haval-128-4"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{34}$`): {
		{Name: "CryptoCurrency(Adress)", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{40}$`): {
		{Name: "SHA-1", HashCat: "100", John: "raw-sha1"},
		{Name: "RIPEMD-160", HashCat: "6000", John: "ripemd-160"},
		{Name: "Haval-160", HashCat: "", John: ""},
		{Name: "Double-SHA-1", HashCat: "4500", John: "--"},
		{Name: "Tiger-160", HashCat: "--", John: "--"},
		{Name: "Tiger-160,3", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{48}$`): {
		{Name: "Haval-192", HashCat: "--", John: "--"},
		{Name: "Tiger-192", HashCat: "--", John: "tiger"},
		{Name: "Tiger-192-3", HashCat: "--", John: "--"},
		{Name: "SHA-1(Oracle)", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{49}$`): {
		{Name: "Citrix Netscaler", HashCat: "8100", John: "citrix_ns10"},
	},

	regexp.MustCompile(`^\$2[abxy]\$\d{2}\$[./A-Za-z0-9]{53}$`): {
		{Name: "bcrypt", HashCat: "3200", John: "bcrypt"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{56}$`): {
		{Name: "SHA-224", HashCat: "--", John: "raw-sha224"},
		{Name: "SHA3-224", HashCat: "--", John: "--"},
		{Name: "Haval-224", HashCat: "--", John: "--"},
		{Name: "Skein-256(224)", HashCat: "--", John: "--"},
		{Name: "Skein-512(224)", HashCat: "--", John: "--"},
		{Name: "Whirlpool-224", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{64}$`): {
		{Name: "SHA-256", HashCat: "1400", John: "raw-sha256"},
		{Name: "SHA3-256", HashCat: "5000", John: "raw-keccak-256"},
		{Name: "BLAKE2s", HashCat: "--", John: "--"},
		{Name: "BLAKE3-256", HashCat: "--", John: "--"},
		{Name: "RIPEMD-256", HashCat: "--", John: "--"},
		{Name: "Haval-256", HashCat: "--", John: "haval-256-3"},
		{Name: "Gost", HashCat: "--", John: "--"},
		{Name: "GOST R 34.11-94", HashCat: "6900", John: "gost"},
		{Name: "Gost-CryptoPro S-Box", HashCat: "--", John: "--"},
		{Name: "SNEFRU-256", HashCat: "--", John: "snefru-256"},
		{Name: "EDON-R-256", HashCat: "--", John: "--"},
		{Name: "Skein256-256", HashCat: "--", John: "skein-256"},
		{Name: "Skein512-256", HashCat: "--", John: "--"},
		{Name: "Whirlpool-256", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{80}$`): {
		{Name: "RIPEMD-320", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{96}$`): {
		{Name: "SHA-384", HashCat: "10800", John: "raw-sha384"},
		{Name: "SHA3-384", HashCat: "--", John: "--"},
		{Name: "Skein512-384", HashCat: "--", John: "--"},
		{Name: "Skein1024-384", HashCat: "--", John: "--"},
		{Name: "Whirlpool-384", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{192}$`): {
		{Name: "Skein1024-408", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{128}$`): {
		{Name: "SHA-512", HashCat: "1700", John: "raw-sha512"},
		{Name: "SHA3-512", HashCat: "--", John: "raw-keccak"},
		{Name: "BLAKE2b", HashCat: "--", John: "--"},
		{Name: "BLAKE3-512", HashCat: "--", John: "--"},
		{Name: "Salsa10", HashCat: "--", John: "--"},
		{Name: "Salsa20", HashCat: "--", John: "--"},
		{Name: "Skein512-512", HashCat: "--", John: "skein-512"},
		{Name: "Whirlpool", HashCat: "6100", John: "whirlpool"},
		{Name: "EDON-R-512", HashCat: "--", John: "--"},
		{Name: "Whirlpool-1", HashCat: "--", John: "--"},
		{Name: "Whirlpool-2", HashCat: "--", John: "--"},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{256}$`): {
		{Name: "Skein512-1024", HashCat: "--", John: "--"},
		{Name: "Skein1024-1024", HashCat: "--", John: ""},
	},
}
