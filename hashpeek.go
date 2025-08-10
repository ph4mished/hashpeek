package main

import (
	"bufio"
	"flag"
	"fmt"
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

var color = flag.Bool("c", false, "Enable Coloured Output")

func ifColor(frontCol string, word interface{}, backCol string) string {
	if *color {
		colouredWord := fmt.Sprintf("%s%v%s", frontCol, word, backCol)
		return colouredWord
	}
	return fmt.Sprint(word)
}
//trunc and ignore will be handled because of stdin mode. but the current way of handling trunc and ignore will make this redundant
func main() {
	hash := flag.String("x", "", "Analyze a single hash string")
	file := flag.String("f", "", "Analyze hashes from a file")
	ignore := flag.String("i", "", "Ignore lines that begins with  character/string '<string>'")
	truncLine := flag.String("trunc", "", "Capture segment at index N (0-indexed) after splitting by delimiter X  (e.g. -trunc '{1} `:::`' gets 'hash' from 'user:::hash:::salt')")
	version := flag.Bool("v", false, "Show the version of hashpeek")
	help := flag.Bool("h", false, "Show this help message")
	Json := flag.Bool("json", false, "Formats outputs in json")
	CSV := flag.Bool("csv", false, "Formats outputs in csv")
	verbose := flag.Bool("vb", false, "Show detailed results per hash (verbose)")

	flag.Parse()
	if len(os.Args) == 1 || *help {
		*help = true
		Help()
		return
	}
if *CSV {
	if *hash == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			input := scanner.Text()
			*hash = strings.TrimSpace(string(input))
			if *hash == "" {
				continue
			}
            CSVFormat(*hash)
		}
		return
	} else if *hash != "-" && *hash != "" {
		CSVFormat(*hash)
		return
	}
    
    	if *file == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		//for standard input mode
		for scanner.Scan() {
			input := scanner.Text()
			*file = strings.TrimSpace(string(input))
			if *file == "" {
				continue
			}
			VerboseAnalyze(*file, *truncLine, *ignore, "csv")
			fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
		}
		return
	} else if *file != "-" && *file != "" {
		VerboseAnalyze(*file, *truncLine, *ignore, "csv")
		return
	}
    }

if *Json{
    	if *hash == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			input := scanner.Text()
			*hash = strings.TrimSpace(string(input))
			if *hash == "" {
				continue
			}
        fmt.Println(JSONFormat(*hash))
		}
		return
	} else if *hash != "-" && *hash != "" {
		fmt.Println(JSONFormat(*hash))
		return
	} 	
	if *file == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		//for standard input mode
		for scanner.Scan() {
			input := scanner.Text()
			*file = strings.TrimSpace(string(input))
			if *file == "" {
				continue
			}
        VerboseAnalyze(*file, *truncLine, *ignore, "json")
			fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
		}
		return
	}else if *file != "-" && *file != "" {
		VerboseAnalyze(*file, *truncLine, *ignore, "json")
		return
	}
    }

	if !*CSV || !*Json{
        if *hash == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			input := scanner.Text()
			*hash = strings.TrimSpace(string(input))
			if *hash == "" {
				continue
			}
			fmt.Println(ifColor(bgrn, "\n\nHash: ", rst), ifColor(bylw, *hash, rst))
			fmt.Println(ifColor(bcyn, "POSSIBLE HASHTYPES", rst))
			fmt.Println(DefaultFormat(*hash))
		}
		return
	} else if *hash != "" && *hash != "-" {
		fmt.Println(ifColor(bgrn, "\n Hash: ", rst), ifColor(bylw, *hash, rst))
		fmt.Println(ifColor(bcyn, "POSSIBLE HASHTYPES", rst))
		fmt.Println(DefaultFormat(*hash))
		return
	}

	if *verbose && *file != "" {
		VerboseAnalyze(*file, *truncLine, *ignore, "default")
		return
	}
	if *file == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		//for standard input mode
		for scanner.Scan() {
			input := scanner.Text()
			*file = strings.TrimSpace(string(input))
			if *file == "" {
				continue
			}
			GroupHash(*file, *truncLine, *ignore)
			fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
		}
		return
	} else if *file != "" {
		GroupHash(*file, *truncLine, *ignore)
		fmt.Println(ifColor(bblu, "\n[[[", rst), ifColor(bcyn, "End Of File of", rst), ifColor(bgrn, *file, rst), ifColor(bblu, "]]]\n", rst))
		return
	}
    }

	if *version {
		*version = true
		fmt.Println(ifColor(bgrn, "hashpeek v.0.1.2 (built on July 2025 by ph4mished)", rst))
		return
	}

	if *color {
		*color = true
	}
}
