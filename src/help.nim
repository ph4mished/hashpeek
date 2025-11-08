import terminal, tables, re, strutils
import cli_flag, hashpeek/hash_database
import spectra

#UNSUPPORTED FLAGS (WITHOUT FUNCTIONALITIES) ARE COMMENTED OUT
colorToggle = not flags.noColor and stdout.isatty()

#flags to add
#filters out low entropy tokens. helps drop simple repetitive data
#encoding handling = this is to decode hashes or find those encoded hashes = -enc <encoding format> or --encoding <encoding format>. eg -enc base64. this extracts only base64 encoded hashes
#-bs <number> or --batch-size <number> = hashes processed per batch (memory control)
#-ml <number> or --memory-limit <number> = stops if memory exceeds the given number (this flags exists to control -bs)

#output filtering
#-cf <number> or --confidence-filtering <number> = only shows identification with >80% confidence
#-gs or -group-similar = group similar hashes using fuzzy hashing
#-ft <names> or --filter-types <names> = only show specific hashtypes (md5,sha1,ntlm)
#-u or --unique = this flag accepts bool on whether to show duplicates or deduplicate results
# if -u is false. keep duplicates


#analysis mode options
#-fm or --fast-mode = prioritize speed over comprehensive identification
#-dm or --deep-mode = more thorough and slower identification
#-st or --statistics = show extraction statistics and confidence metrics
#divide into chunks of command that needs file argument, rulefile, hash
#some flags look stupid and redundant so they should be removed.
#hashpeek is bent on extraction hashes and identification(can be toggled)

proc help*() =
  #uncomment flags when added functionality is added
  #paint "[bold fg=green]\n=======================================================================[reset]"
  let title = "Hashpeek 0.3.1 - Hash Extraction, Identification & Triage Tool"
  echo "=".repeat(title.len+8)
  echo " ".repeat(4) & title
  echo "=".repeat(title.len+8)
  #paint "[bold fg=cyan]   Hashpeek 0.3.1 - Hash Extraction, Identification & Triage Tool[reset]"
  #paint "[bold fg=green]=======================================================================[reset]"
  paint "[bold fg=magenta] Extract and identify hashes from any input: files, stdin, or text.[reset]"
  paint "[bold fg=magenta] Supports structured analysis, entropy filtering, and multithreaded scanning.[reset]"
  paint "[bold fg=cyan]\nUsage:  [fg=white]hashpeek [OPTIONS] [input][reset]"
  paint "[bold fg=green] Input may be hash string, a file, path or '-' for stdin"
  #general options
  paint "\n[bold fg=blue][[fg=cyan]GENERAL OPTIONS[fg=blue]][reset]"
  paint "\t[bold fg=#FF6600]-h[fg=green], [fg=#FF6600]--help [fg=green]: Show this help.[reset]"
  paint "\t[bold fg=#FF6600]-v[fg=green], [fg=#FF6600]--version [fg=green]: Show version information.[reset]"
  #paint "\t[bold fg=#FF6600]-q[fg=green], [fg=#FF6600]--quiet [fg=green]: Suppress non-critical output.[reset]"


  #input options
  paint "\n[bold fg=blue][[fg=cyan]INPUT OPTIONS[fg=blue]][reset]"
  paint "\t[bold fg=#FF6600]-t[fg=green], [fg=#FF6600]--text HASH [fg=green]: Analyze a single hash.[reset]"
  paint "\t[bold fg=#FF6600]-f[fg=green], [fg=#FF6600]--file FILE [fg=green]: Analyze file.[reset]"

  #extraction  options
  #-fd and -pb can be used together in one command
  #-pb should directly extract hashes hence it doesnt need -ovh
  #-pb should check if given file is binary, and convert to strings to extract hashes
  paint "\n[bold fg=blue][[fg=cyan]EXTRACTION OPTIONS[fg=blue]][reset]"
  paint "\t[bold fg=#FF6600]-fd[fg=green], [fg=#FF6600]--field '{N} X'[fg=green]: Capture segment at 1-based index N after splitting by delimiter X.[reset]"
  paint "\t[bold fg=#FF6600]-pb[fg=green], [fg=#FF6600]--probe[fg=green]: Probe data for embedded hashes(aggressive).[reset]"
  #paint "\t[bold fg=#FF6600]-ni[fg=green], [fg=#FF6600]--no-identify[fg=green]: Only extract, skip identification.[reset]"
  #hex encoded words vs hex-hashes. when decoding, hex-hashes gives encoded binary characters instead of utf-8 readable char. hex encoded words gives out chars
  #paint "\t[bold fg=#FF6600]-enc[fg=green], [fg=#FF6600]--encode <type> [fg=green]: Extracts encoded data.\n Supported types: base64, hex[reset]"

  #filtering extraction
  #[paint "\n[bold blue][[cyan]FILTERING OPTIONS[blue]][reset]"
  paint "\t[bold fg=#FF6600]-me[fg=green], [fg=#FF6600]--min-entropy <float>[fg=green]: Minimum entropy to accept candidate.[reset]"
  paint "\t[bold fg=#FF6600]-mr[fg=green], [fg=#FF6600]--max-results N[fg=green]: Limit to top N results.[reset]"
  #paint "\t[bold fg=#FF6600]-k[fg=green], [fg=#FF6600]--keep-duplicates[fg=green]: Maintains duplicate extracted hashes.[reset]"
  paint "\t[bold fg=#FF6600]-cf[fg=green], [fg=#FF6600]--confidence-threshold N[fg=green]: Only show confidence >= N%.[reset]"]#

  #performance
  #[paint "\n[bold blue][[cyan]PERFORMANCE OPTIONS[blue]][reset]"
  paint "\t[bold fg=#FF6600]-t[fg=green], [fg=#FF6600]--threads <N>[fg=green]: Number of worker threads.[reset]"
  #without memory limit, hashpeek should be smart enough to use 60%-80% of RAM. remember to keep it to sensible default to avoid crashes
  paint "\t[bold fg=#FF6600]-ml[fg=green], [fg=#FF6600]--memory-limit MB[fg=green]: Maximum RAM usage.[reset]"]#


  paint "\n[bold fg=blue][[fg=cyan]OUTPUT & FORMATTING OPTIONS[fg=blue]][reset]"
  paint "\t[bold fg=#FF6600]--json[fg=green]: Outputs results in JSON format.[reset]"
  paint "\t[bold fg=#FF6600]--csv[fg=green]: Outputs results in CSV format.[reset]"
  paint "\t[bold fg=#FF6600]-nc[fg=green], [fg=#FF6600]--no-color [fg=green]: Disable coloured output.[reset]"
  #paint "\t[bold fg=#FF6600]-vb[fg=green], [fg=#FF6600]--verbose [fg=green]: Show detailed results per hash (verbose).\n[reset]"

  #[paint "\n[bold fg=blue][[cyan]EXTENDED HASH SUPPORT[fg=blue]][reset]"
  paint "\t[bold fg=#FF6600]-db[fg=green], [fg=#FF6600]--database <file>[fg=green]: Load custom hash database (JSON).[reset]"]#

  #examples
  #paint "\n\t\t\t\t[bold fg=blue][[cyan]EXAMPLES[fg=blue]][reset]"
  #paint "\t[bold fg=#2882BE]#Single hash identification[reset]"
  #paint "\t[bold fg=yellow]hashpeek [fg=green]-t '87c8cdddb2b4ea61c2d2752c24eb2e1f1ff05500173f504c4cda5291'[reset]"

  #paint "\n\t[bold fg=#2882BE]#Extract from log with context[reset]"
  #paint "\t[bold fg=yellow]hashpeek [fg=green]-f dump.txt -e-ctext 'password,token' -me 3.4[reset]"

  #paint "\n\t[bold fg=#2882BE]#Field extraction from structured data[reset]"
  #paint "\t[bold fg=yellow]hashpeek [fg=green]-f /etc/passwd -fd '{2} :' -j[reset]"
  #paint "\t[bold fg=yellow]hashpeek [fg=green]-f data.csv -fd '{3} ,' -hc[reset]"

  #paint "\n\t[bold fg=#2882BE]#Probe for embedded hashes in binary data[reset]"
  #paint "\t[bold fg=yellow]hashpeek [fg=green]-f memory.dmp -pb  -me 3.8[reset]"
  #paint "\t[bold fg=yellow]hashpeek [fg=green]-f binary_file -pb [reset]"

  #paint "\n\t[bold fg=#2882BE]#Large file processing[reset]"
  #paint "\t[bold fg=yellow]hashpeek [fg=green]-f huge_dump.txt -mr 500 --thread 4 --json [fg=yellow]> findings.json[reset]"
  

  #notes
  paint "\n[bold fg=cyan]\t\t\t\t\tNOTES[reset]"
  paint "\t[bold  fg=blue]-[fg=green] Probing extracts all hash sequences - use with [fg=yellow]--min-entropy[fg=green] to reduce false positives[reset]"
  #paint "\t[bold fg=blue]-[fg=green] Hashpeek removes duplicate hashes by default: use [fg=yellow]-k[fg=green] to keep duplicates"
  #paint "\t[bold  fg=blue]-[fg=green] Use --probe for binary files, memory dumps and forensic analysis[reset]"
  paint "\t[bold  fg=blue]-[fg=green] Use --file for structured data like config files and databases[reset]"
  paint "\t[bold fg=blue]-[fg=green] Custom hash databases must be JSON format[reset]"
  paint "\t[bold fg=blue]-[fg=green] Threading (-t) significantly speeds up --probe operations on large files[reset]\n"
