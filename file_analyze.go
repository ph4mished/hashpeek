package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func percentage(num, total int) float64 {
	return (float64(num) / float64(total)) * 100
}

func Group_Hash(hashFile string) {
	hash_counts := make(map[string]int)
	total_hashes := 0

	file, err := os.Open(hashFile)
	if err != nil {
		fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		hashLine := strings.TrimSpace(scanner.Text())

		if len(hashLine) > 0 {
			total_hashes++
			hashtype := HashAnalyze(hashLine)
			if hashtype == "" {
				hashtype = "Unknown"
			}
			hash_counts[hashtype]++
		}
	}

	fmt.Print(ifColor(bgrn, "\n[~] Found ", rst) + ifColor(borng, total_hashes, rst) + ifColor(bgrn, " hashes in ", rst) + ifColor(borng, hashFile, rst))
	for hashtype, count := range hash_counts {
		pct := percentage(count, total_hashes)
		fmt.Printf(ifColor(bgrn, "\n\n{", rst)+ifColor(bylw, "%.2f%%", rst)+ifColor(bgrn, "} ", rst)+ifColor(bcyn, "%d/%d", rst)+ifColor(bcyn, " Of The Hashes Are:\n", rst)+"\n%s", pct, count, total_hashes, hashtype)
	}
}

func VerboseAnalyze(hashFile string) {
	totalNum := 0
	var hashtype string

	file, err := os.Open(hashFile)
	if err != nil {
		fmt.Printf("Error: %s\n", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		hashLine := strings.TrimSpace(scanner.Text())
		totalNum++
		if len(hashLine) > 0 {
			fmt.Print("\n\n" + hashLine)
			fmt.Println(ifColor(bcyn, "\nPOSSIBLE HASH TYPES", rst))
			hashtype = HashAnalyze(hashLine)
			fmt.Println(hashtype)
		}
	}
	fmt.Print(ifColor(bgrn, "\n[~] Found ", rst) + ifColor(borng, totalNum, rst) + ifColor(bgrn, " hashes in ", rst) + ifColor(borng, hashFile, rst) + "\n")
}
