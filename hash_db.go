package main

import "regexp"

type HASHALGO struct {
	Name     string  `json:"name"`
	HashCat  *string `json:"hashcat"`
	John     *string `json:"john"`
	Extended bool    `json:"extended"`
}

var hashcatNil = "--"
var johnNil = "--"
var HASH_DATABASE = map[*regexp.Regexp][]HASHALGO{

	regexp.MustCompile(`^(?i)[a-f0-9]{4}$`): {
		{Name: "CRC-16", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "CRC-16-CCITT", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "FCS-16", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{6}$`): {
		{Name: "CRC-24", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{8}$`): {
		{Name: "Adler-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "CRC-32", HashCat: &hashcatNil, John: strptr("crc32")},
		{Name: "CRC-32B", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "FNV-1-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "FNV-1a-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Murmur3-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "FCS-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "GHash-32-3", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "GHash-32-5", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Fletcher-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Joaat", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "ELF-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "XOR-32", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^[a-zA-Z0-9./]{13}$`): {
		{Name: "DES (Unix)", HashCat: strptr("1500"), John: strptr("descrypt"), Extended: false},
		{Name: "DEScrypt", HashCat: strptr("1500"), John: strptr("descrypt"), Extended: false},
		{Name: "BigCrypt", HashCat: &hashcatNil, John: strptr("bigcrypt"), Extended: true},
	},

	regexp.MustCompile(`^[a-f0-9]{40}:[a-f0-9]{16}$`): {
		{Name: "Android PIN", HashCat: strptr("5800"), John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{16}$`): {
		{Name: "DES(Oracle)", HashCat: strptr("3100"), John: &johnNil, Extended: false},
		{Name: "LM", HashCat: strptr("3000"), John: strptr("lm")},
		{Name: "MySQL323", HashCat: strptr("200"), John: strptr("mysql")},
		{Name: "CRC-64", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "FNV-1-64", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "FNV-1a-64", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Half-MD5", HashCat: strptr("5100"), John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-z0-9./]{16}$`): {
		{Name: "Cisco-PIX(MD5)", HashCat: strptr("2400"), John: strptr("pix-md5"), Extended: false},
	},

	regexp.MustCompile(`^[a-zA-Z0-9./]{24}$`): {
		{Name: "Crypt16", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{24}$`): {
		{Name: "CRC-96-ZIP", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{32}$`): {
		{Name: "MD5", HashCat: strptr("0"), John: strptr("raw-md5")},
		{Name: "NTLM", HashCat: strptr("1000"), John: strptr("nt")},
		{Name: "LM", HashCat: strptr("3000"), John: strptr("lm")},
		{Name: "MD4", HashCat: strptr("900"), John: strptr("raw-md4")},
		{Name: "Double MD5", HashCat: strptr("2600"), John: &johnNil, Extended: false},
		{Name: "MD2", HashCat: &hashcatNil, John: strptr("md2")},
		{Name: "RIPEMD-128", HashCat: &hashcatNil, John: strptr("ripemd-128")},
		{Name: "BLAKE3-128", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "FNV-1-128", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Murmur3-128", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Haval-128", HashCat: &hashcatNil, John: strptr("haval-128-4")},
		{Name: "SNEFRU-128", HashCat: &hashcatNil, John: strptr("snefru-128")},
		{Name: "Skein256-128", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein512-128", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Tiger-128", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Tiger128-3", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{34}$`): {
		{Name: "CryptoCurrency(Adress)", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{40}$`): {
		{Name: "SHA-1", HashCat: strptr("100"), John: strptr("raw-sha1")},
		{Name: "RIPEMD-160", HashCat: strptr("6000"), John: strptr("ripemd-160")},
		{Name: "Haval-160", HashCat: &hashcatNil, John: &johnNil},
		{Name: "Double-SHA-1", HashCat: strptr("4500"), John: &johnNil, Extended: false},
		{Name: "Tiger-160", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Tiger-160,3", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^[a-z0-9]{43}$`): {
		{Name: "Cisco-IOS(SHA-256)", HashCat: strptr("5700"), John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{48}$`): {
		{Name: "Haval-192", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Tiger-192", HashCat: &hashcatNil, John: strptr("tiger")},
		{Name: "Tiger-192-3", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "SHA-1(Oracle)", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "OSX v10.4", HashCat: strptr("122"), John: strptr("xsha"), Extended: false},
		{Name: "OSX v10.5", HashCat: strptr("122"), John: strptr("xsha"), Extended: false},
		{Name: "OSX v10.6", HashCat: strptr("122"), John: strptr("xsha"), Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{49}$`): {
		{Name: "Citrix Netscaler", HashCat: strptr("8100"), John: strptr("citrix_ns10")},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{51}$`): {
		{Name: "Palshop CMS", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-z0-9]{51}$`): {
		{Name: "CryptoCurrency(PrivateKey)", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^\$2[abxy]\$\d{2}\$[./A-Za-z0-9]{53}$`): {
		{Name: "bcrypt", HashCat: strptr("3200"), John: strptr("bcrypt"), Extended: false},
		{Name: "Blowfish(OpenBSD)", HashCat: strptr("3200"), John: strptr("bcrypt"), Extended: false},
		{Name: "Woltlab Burning Board 4.x", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{56}$`): {
		{Name: "SHA-224", HashCat: &hashcatNil, John: strptr("raw-sha224")},
		{Name: "SHA3-224", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Haval-224", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein-256(224)", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein-512(224)", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Whirlpool-224", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^\$snefru\$(?i)[a-f0-9]{64}$`): {
		{Name: "Snefru-256", HashCat: &hashcatNil, John: strptr("snefru-256"), Extended: false},
		//  "regex": "^(\\$snefru\\$)?[a-f0-9]{64}$",
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{64}$`): {
		{Name: "SHA-256", HashCat: strptr("1400"), John: strptr("raw-sha256")},
		{Name: "SHA3-256", HashCat: strptr("5000"), John: strptr("raw-keccak-256")},
		{Name: "BLAKE2s", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "BLAKE3-256", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "RIPEMD-256", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Haval-256", HashCat: &hashcatNil, John: strptr("haval-256-3")},
		{Name: "Gost", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "GOST R 34.11-94", HashCat: strptr("6900"), John: strptr("gost")},
		{Name: "Gost-CryptoPro S-Box", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "SNEFRU-256", HashCat: &hashcatNil, John: strptr("snefru-256")},
		{Name: "EDON-R-256", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein256-256", HashCat: &hashcatNil, John: strptr("skein-256")},
		{Name: "Skein512-256", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Whirlpool-256", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{80}$`): {
		{Name: "RIPEMD-320", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{96}$`): {
		{Name: "SHA-384", HashCat: strptr("10800"), John: strptr("raw-sha384")},
		{Name: "SHA3-384", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein512-384", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein1024-384", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Whirlpool-384", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{102}$`): {
		{Name: "Skein1024-408", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{128}$`): {
		{Name: "SHA-512", HashCat: strptr("1700"), John: strptr("raw-sha512"), Extended: false},
		{Name: "SHA3-512", HashCat: &hashcatNil, John: strptr("raw-keccak"), Extended: false},
		{Name: "BLAKE2b", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "BLAKE3-512", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Salsa10", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Salsa20", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein512-512", HashCat: &hashcatNil, John: strptr("skein-512"), Extended: false},
		{Name: "Whirlpool", HashCat: strptr("6100"), John: strptr("whirlpool"), Extended: false},
		{Name: "EDON-R-512", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Whirlpool-1", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Whirlpool-2", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},

	regexp.MustCompile(`^(?i)[a-f0-9]{256}$`): {
		{Name: "Skein512-1024", HashCat: &hashcatNil, John: &johnNil, Extended: false},
		{Name: "Skein1024-1024", HashCat: &hashcatNil, John: &johnNil, Extended: false},
	},
}

func strptr(s string) *string {
	return &s
}
