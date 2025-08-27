package main

import (
	"bufio"
	"flag"
	"fmt"
	"golang.org/x/term"
	"os"
	"strings"
)

const (
	bcyn  = "\033[1;36m"
	borng = "\033[1;38;5;208m"
	bgrn  = "\033[1;32m"
	bblu  = "\033[1;34m"
	bred  = "\033[1;31m"
	bylw  = "\033[1;33m"
	vol   = "\033[35m"
	bvol  = "\033[1;35m"
	grn   = "\033[32m"
	blu   = "\033[34m"
	ylw   = "\033[33m"
	red   = "\033[31m"
	orng  = "\033[38;5;208m"
	rst   = "\033[0m"
)


var hashLine, format string
var colorEnabled bool

func ifColor(frontCol string, word interface{}, backCol string) string {
	if colorEnabled {
		colouredWord := fmt.Sprintf("%s%v%s", frontCol, word, backCol)
		return colouredWord
	}
	return fmt.Sprint(word)
}

func main() {

	countLine := 0
		noColor := flag.Bool("nc", false, "Disable coloured output")
	hash := flag.String("x", "", "Analyze a single hash string")
	file := flag.String("f", "", "Analyze hashes from a file")
	ignore := flag.String("i", "", "Ignore lines that begins with  character/string '<string>'")
	extract := flag.Int("e", 0, "Extract hex-like hashes from messy text/logs using the given minimum length (e.g. -e 16) ")
	truncLine := flag.String("trunc", "", "Capture segment at index N (0-indexed) after splitting by delimiter X  (e.g. -trunc '{1} `:::`' gets 'hash' from 'user:::hash:::salt')")
	version := flag.Bool("v", false, "Show the version of hashpeek")
	help := flag.Bool("h", false, "Show this help message")
	Json := flag.Bool("json", false, "Formats outputs in json")
	csv := flag.Bool("csv", false, "Formats outputs in csv")
	verbose := flag.Bool("vb", false, "Show detailed results per hash (verbose)")

	flag.Parse()

if *noColor {
               colorEnabled = false
              } else {
	colorEnabled = term.IsTerminal(int(os.Stdout.Fd()))
	}


	        if len(os.Args) == 1 || *help {
	                  *help = true
	                  Help()
	                  return
	              }

	if *csv {
	*csv = true
		format = "csv"
	} else if *Json {
		format = "json"
	} else if *verbose {
		format = "default"
	} else {
		format = "default"
	}

	
	if *hash == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			input := scanner.Text()
            countLine++
			*hash = strings.TrimSpace(string(input))
			if *hash != "" {
				if *extract > 0 {
					PrintExtractedHashes(*hash, *truncLine, *ignore, *extract,/* countLine,*/ format)
				} else {
				if format == "default"{
				fmt.Print(ifColor(bgrn, "\nHash: ", rst), ifColor(bylw, *hash, rst))
				}
					VerboseAnalyze(*hash, *truncLine, *ignore, format)
				}
			}
		}
	} else if *hash != "-" && *hash != "" {
		if *extract > 0 {
			PrintExtractedHashes(*hash, *truncLine, *ignore, *extract, format)
		} else {
		if format == "default"{
		fmt.Print(ifColor(bgrn, "\nHash: ", rst), ifColor(bylw, *hash, rst))
		}
			VerboseAnalyze(*hash, *truncLine, *ignore, format)
		}
		return
	}

	if *file == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			*file = strings.TrimSpace(scanner.Text())
			countLine++
			if *file != "" {
				if *extract > 0 {
					PrintExtractedHashes(*file, *truncLine, *ignore, *extract, format)
        if format == "default" {
		fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
        }
				} else if *verbose{
					FileVerboseAnalyze(*file, *truncLine, *ignore, format)
        if format == "default" {
		fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
        }
				} else { 
				if format == "csv" || format == "json"{
					FileVerboseAnalyze(*file, *truncLine, *ignore, format)
				}else {
				                GroupHash(*file, *truncLine, *ignore, *extract)
    fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
				        }
				        }
			}
		}

	}

	if *file != "-" && *file != "" {
if *extract > 0 {
if *verbose {
					PrintExtractedHashes(*file, *truncLine, *ignore, *extract, format)
        if format == "default" {
		fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
        }
        return
        }  else { 
        if format == "csv" || format == "json" {
           FileVerboseAnalyze(*file, *truncLine, *ignore, format)
        } else{
        	GroupHash(*file, *truncLine, *ignore, *extract)
            		fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
        }
        }
        return
				} else {
				if *verbose {
					FileVerboseAnalyze(*file, *truncLine, *ignore, format)
        if format == "default" {
		fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
        }
        return
        } else {
        if format == "csv" || format == "json" {
                   FileVerboseAnalyze(*file, *truncLine, *ignore, format)
                 } else{
        	GroupHash(*file, *truncLine, *ignore, *extract)
            		fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
        }
        }
        return
				}
	}

	if *version {
		*version = true
		fmt.Println(ifColor(bgrn, "hashpeek v0.2.0 (built by ph4mished)", rst))
		return
	}
}
