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

func main() {
	hash := flag.String("x", "", "Analyze a single hash string")
	file := flag.String("f", "", "Analyze hashes from a file")
	version := flag.Bool("v", false, "Show the version of hashpeek")
	help := flag.Bool("h", false, "Show this help message")
	verbose := flag.Bool("vb", false, "Show detailed results per hash (verbose)")

	flag.Parse()
	if len(os.Args) == 1 || *help {
		Help()
		return
	}
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
			fmt.Println(HashAnalyze(*hash))
		}
		return
	} else if *hash != "" && *hash != "-" {
		fmt.Println(ifColor(bgrn, "\n Hash: ", rst), ifColor(bylw, *hash, rst))
		fmt.Println(ifColor(bcyn, "POSSIBLE HASHTYPES", rst))
		fmt.Println(HashAnalyze(*hash))
		return
	}

	if *verbose && *file != "" {
		VerboseAnalyze(*file)
		return
	} else if *file == "-" {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			input := scanner.Text()
			*file = strings.TrimSpace(string(input))
			if *file == "" {
				continue
			}
			Group_Hash(*file)
		}
		return
	} else if *file != "" {
		Group_Hash(*file)
		return
	}

	if *version {
		fmt.Println(ifColor(bgrn, "hashpeek v.0.1.1", rst))
		return
	}

	if *color {
	}
}
