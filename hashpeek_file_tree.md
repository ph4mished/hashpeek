📁 Hashpeek Nim Repository Structure

```
hashpeek/
├── 📄 README.md                          # Project documentation and usage examples
├── 📄 LICENSE                            # MIT/GPL license file
├── 📄 CHANGELOG.md                       # Version history and changes
├── 📄 hashpeek.nimble                    # Nim package manager configuration
├── 📄 .gitignore                         # Git ignore rules for build files
├── 📁 src/                               # Main source code directory
│   ├── 📄 hashpeek.nim                   # **Main entry point** - orchestrates everything
│   ├── 📄 cli.nim                        # **Command line interface** - argument parsing
│   ├── 📄 types.nim                      # **Type definitions** - data structures used everywhere
│   ├── 📄 config.nim                     # **Configuration handler** - settings and options
│   ├── 📁 engines/                       # **Core processing engines** - the "brains"
│   │   ├── 📄 identifier.nim             # **Hash identification** - figures out hash types
│   │   ├── 📄 scanner.nim                # **File scanner** - finds files and directories
│   │   ├── 📄 extractor.nim              # **Field extractor** - pulls hashes from structured data
│   │   ├── 📄 probe.nim                  # **Binary prober** - finds hashes in binary files
│   │   └── 📄 analyzer.nim               # **Security analyzer** - risk assessment
│   ├── 📁 utils/                         # **Utility functions** - helper code
│   │   ├── 📄 color.nim                  # **Color manager** - ANSI colored output
│   │   ├── 📄 files.nim                  # **File utilities** - reading/writing files
│   │   ├── 📄 memory.nim                 # **Memory manager** - limits RAM usage
│   │   ├── 📄 entropy.nim                # **Entropy calculator** - measures randomness
│   │   ├── 📄 patterns.nim               # **Pattern matcher** - regex and string matching
│   │   └── 📄 hashing.nim                # **Hash utilities** - hash verification tools
│   ├── 📁 output/                        # **Output formatters** - display results
│   │   ├── 📄 formatters.nim             # **Format dispatcher** - chooses output format
│   │   ├── 📄 tree.nim                   # **Tree formatter** - creates tree-style output
│   │   ├── 📄 jsonout.nim                # **JSON output** - machine-readable format
│   │   ├── 📄 csvout.nim                 # **CSV output** - spreadsheet format
│   │   └── 📄 professional.nim           # **Professional reports** - security assessments
│   └── 📁 data/                          # **Data definitions** - hash patterns and mappings
│       ├── 📄 hashpatterns.nim           # **Hash patterns** - definitions of all hash types
│       ├── 📄 hashcat.nim                # **Hashcat mappings** - mode numbers for each hash
│       ├── 📄 john.nim                   # **John mappings** - format names for each hash
│       └── 📄 knownhashes.nim            # **Known hashes** - database of hash:plaintext pairs
├── 📁 tests/                             # **Test suite** - ensures code works correctly
│   ├── 📄 test_all.nim                   # **Test runner** - runs all tests
│   ├── 📄 test_identifier.nim            # **Identification tests** - tests hash ID logic
│   ├── 📄 test_scanner.nim               # **Scanner tests** - tests file scanning
│   ├── 📄 test_extractor.nim             # **Extractor tests** - tests field extraction
│   ├── 📄 test_entropy.nim               # **Entropy tests** - tests randomness detection
│   ├── 📄 test_output.nim                # **Output tests** - tests display formatting
│   └── 📁 fixtures/                      # **Test data** - sample files for testing
│       ├── 📄 sample_hashes.txt          # **Sample hashes** - test hash strings
│       ├── 📄 memory_dump.bin            # **Memory dump** - test binary data
│       ├── 📄 web_logs.txt               # **Web logs** - test log file parsing
│       └── 📄 database_export.csv        # **Database export** - test CSV parsing
├── 📁 examples/                          # **Usage examples** - sample code
│   ├── 📄 basic_usage.nim                # **Basic usage** - simple examples
│   ├── 📄 memory_analysis.nim            # **Memory analysis** - binary file examples
│   ├── 📄 web_app_scan.nim               # **Web app scanning** - directory scan examples
│   └── 📄 custom_patterns.nim            # **Custom patterns** - extending Hashpeek
├── 📁 docs/                              # **Documentation** - user guides
│   ├── 📄 installation.md                # **Installation guide** - how to install
│   ├── 📄 usage.md                       # **Usage guide** - how to use features
│   ├── 📄 api.md                         # **API reference** - developer documentation
│   └── 📄 examples.md                    # **Examples guide** - practical use cases
└── 📁 scripts/                           # **Build and utility scripts**
    ├── 📄 build_release.sh               # **Release builder** - compiles optimized version
    ├── 📄 update_patterns.nim            # **Pattern updater** - updates hash definitions
    ├── 📄 benchmark.nim                  # **Performance tester** - speed benchmarks
    └── 📄 install_deps.sh                # **Dependency installer** - system dependencies
```




# Command to identify a single hash:
hashpeek --identify "5f4dcc3b5aa765d61d8327deb882cf99"

# Output:
==================================================
HASH IDENTIFICATION REPORT
==================================================

Hash: 5f4dcc3b5aa765d61d8327deb882cf99

[IDENTIFICATION]
├─ Type: MD5
├─ Length: 32 characters
├─ Pattern: [a-f0-9]{32}
├─ Confidence: 99.9%
└─ Characteristics: Unsalted cryptographic hash

[PROPERTIES]
├─ Bit Size: 128-bit
├─ Status: Cryptographically broken
├─ Common Use: File verification, weak password storage
└─ Collision Vulnerable: Yes

[SECURITY ASSESSMENT]
├─ Risk Level: CRITICAL
├─ Crack Time Estimate: < 1 second (with modern hardware)
├─ Recommended Action: IMMEDIATE change required
└─ Replacement: bcrypt, argon2, or SHA-256/512 with salt

[KNOWN EXAMPLES]
├─ This specific hash: "password"
├─ Test vectors: d41d8cd98f00b204e9800998ecf8427e (empty string)
└─ Common in: Legacy systems, database dumps

==================================================

