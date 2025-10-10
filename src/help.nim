import terminal
import cli_flag


#divide into chunks of command that needs file argument, rulefile, hash
proc help*() =

  stdout.write(ifColor(fgCyan, "\nUsage: ") & ifColor(fgGreen, "hashpeek [OPTIONS]\n"))
  
  
  #general options
  stdout.write(ifColor(fgBlue, "[") & ifColor(fgCyan, "GENERAL OPTIONS") & ifColor(fgBlue, "]\n"))
  stdout.write(ifColor(fgYellow, "\t-h") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--help")  & ifColor(fgGreen, " : Show this help.\n"))
  stdout.write(ifColor(fgYellow, "\t-v") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--version") & ifColor(fgGreen, " : Show version.\n\n"))


  #stdin options
  stdout.write(ifColor(fgBlue, "[") & ifColor(fgCyan, "STDIN MODE OPTIONS") & ifColor(fgBlue, "]\n"))
  stdout.write(ifColor(fgYellow, "\t-x - ") & ifColor(fgGreen, "or ") & ifColor(fgYellow, "--hash -") & ifColor(fgGreen, " : Analyze hashes directly from stdin.\n"))
  stdout.write(ifColor(fgYellow, "\t-f -") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--file - ") & ifColor(fgGreen, " : Analyze hashes from files via stdin.\n\n"))
  
  
  #input options
  stdout.write(ifColor(fgBlue, "[") & ifColor(fgCyan, "INPUT OPTIONS") & ifColor(fgBlue, "]\n"))
  stdout.write(ifColor(fgYellow, "\t-x <hashstring>") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--hash <hashstring>")  & ifColor(fgGreen, " : Analyze a single hash string.\n"))
  stdout.write(ifColor(fgYellow, "\t-f <path/to/file>") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--file <path/to/file>") & ifColor(fgGreen, " : Analyze hashes from a file.\n\n"))

    #extraction and filtering options
  stdout.write(ifColor(fgBlue, "[") & ifColor(fgCyan, "EXTRACTION & FILTERING OPTIONS") & ifColor(fgBlue, "]\n"))
  stdout.write(ifColor(fgYellow, "\t--trunc '{N} X'") & ifColor(fgGreen, " : Capture segment at 1-based index N after splitting by delimiter X.\n") & ifColor(fgGreen, "\t(e.g. --trunc '{2} :::' extracts 'hash' from 'user:::hash:::salt' where ':::' is the delimiter).\n"))
 
  #the ignore flag will be a bool which will mute error messages from appearing on stderr
  #change its help description when this change occurs
  stdout.write(ifColor(fgYellow, "\t-i") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--ignore")  & ifColor(fgGreen, " : Ignore or mute truncation errors to ensure clean results\n"))
  stdout.write(ifColor(fgYellow, "\t-e-hex <length>") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--extract-hex <length>") & ifColor(fgGreen, " : Extract hex hashes from messy text/logs using user-given length or range of lengths.\n"))
  stdout.write(ifColor(fgGreen, "\te.g. '-e-hex 16' this means it scans the file for hashes that have a length 16 only.\n"))
  stdout.write(ifColor(fgBlue, "\tNote: ") & ifColor(fgGreen, "-e-hex flag supports single numbers {-e-hex 8}, range of numbers {-e-hex 32-56} and numbers separated by commas {-e-hex 32,16,56}.\n"))
  stdout.write(ifColor(fgYellow, "\t-e-ctext <contexts/words>") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--extract-context <contexts/words>") & ifColor(fgGreen, " : Extract hashes from messy text/logs using user provided contexts.\n"))
  stdout.write(ifColor(fgGreen, "\te.g. '-e-ctext 'password, hash' ' this means it scans the file for words that corresponds to the given context 'password', 'hash' and returns it value.\n"))
  #to avoid wasting time, the case variant generator will use only "upper, lower and title case toggling" instead of allcase generator
  stdout.write(ifColor(fgBlue, "\tNote: ") & ifColor(fgGreen, "The case of the contexts that will be used by -e-ctext will be handled implicitly. Meaning -e-ctext is case insensitive in its extraction.\n\n"))
  
  
  
  #output and formatting options
  stdout.write(ifColor(fgBlue, "[") & ifColor(fgCyan, "OUTPUT & FORMATTING OPTIONS") & ifColor(fgBlue, "]\n"))
  stdout.write(ifColor(fgYellow, "\t--json")  & ifColor(fgGreen, " : Outputs results in JSON format.\n"))
  stdout.write(ifColor(fgYellow, "\t--csv") & ifColor(fgGreen, " : Outputs results in CSV format.\n"))
  stdout.write(ifColor(fgYellow, "\t-nc") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--no-color") & ifColor(fgGreen, " : Disable coloured output.\n"))
  stdout.write(ifColor(fgYellow, "\t-vb") & ifColor(fgGreen, " or ") & ifColor(fgYellow, "--verbose") & ifColor(fgGreen, " : Show detailed results per hash (verbose).\n\n"))
  stdout.flushFile()


  #examples