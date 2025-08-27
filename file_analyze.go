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


func GroupHash(hashFile string, truncLine string, ignoreStr string, extractInt int) {
	var hashtype string
	var err error
	hash_counts := make(map[string]int)
	total_hashes := 0
	countLine := 0

	file, err := os.Open(hashFile)
	defer file.Close()
	if err != nil {
		fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
		return
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		input := strings.TrimSpace(scanner.Text())
		countLine++

		if input != "" {
			cleanLine := input

			if truncLine != "" || ignoreStr != ""{    
					cleanLine = CleanHashLine(cleanLine, truncLine, ignoreStr, countLine, "default")
					if len(cleanLine) > 0 {
					                  total_hashes++
					                //  fmt.Println("Test: ", cleanLine)
					 
					                  hashtype = DefaultFormat(cleanLine)
					 
					                  hash_counts[hashtype]++
				}
				} 
					

				if extractInt > 0 {
					extractedHashes := ExtractHexHashes(cleanLine, extractInt)

					for _, extractedHash := range extractedHashes {
						if len(extractedHash) > 0 {
							fmt.Println(ifColor(bgrn, "\n Extracted Hash: ", rst), ifColor(bylw, extractedHash, rst))
							if len(extractedHash) > 0 {
								total_hashes++

								hashtype = DefaultFormat(extractedHash)

								hash_counts[hashtype]++
							}
						}
					}
					continue

				}

			if len(cleanLine) > 0 {
				total_hashes++
			//	fmt.Println("Test: ", cleanLine)

				hashtype = DefaultFormat(cleanLine)

				hash_counts[hashtype]++
			}
		}
	}

	if total_hashes > 0 {
		fmt.Print(ifColor(bgrn, "\n[~] Found ", rst) + ifColor(borng, total_hashes, rst) + ifColor(bgrn, " hashes in ", rst) + ifColor(borng, hashFile, rst))
	}
	for hashtype, count := range hash_counts {
		pct := percentage(count, total_hashes)
		fmt.Printf(ifColor(bgrn, "\n\n{", rst)+ifColor(bylw, "%.2f%%", rst)+ifColor(bgrn, "} ", rst)+ifColor(bcyn, "%d/%d", rst)+ifColor(bcyn, " Of The Hashes Are:\n", rst)+"\n%s", pct, count, total_hashes, hashtype)
	}
	if err := scanner.Err(); err != nil {
		fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
	}
}


func VerboseAnalyze(hashLine, truncLine, ignoreStr, format string) {
	var hashtype string

	if hashLine != "" {

		if truncLine != "" || ignoreStr != "" {

			if truncLine != "" || ignoreStr != "" {
				hashLine = CleanHashLine(hashLine, truncLine, ignoreStr, /*countLine*/ 0, format)
			}
		}

		if len(hashLine) > 0 {
			if format == "csv" {
				CSVFormat(hashLine)
			} else if format == "json" {
				hashtype = JSONFormat(hashLine)
				fmt.Println(hashtype)
			} else if format == "default" {
				fmt.Println(ifColor(bcyn, "\nPOSSIBLE HASH TYPES", rst))
				hashtype = DefaultFormat(hashLine)
				fmt.Println(hashtype)
			}
		}
	}
}

func FileVerboseAnalyze(hashFile, truncLine, ignoreStr, format string) {
	countLine := 0
	file, err := os.Open(hashFile)
	defer file.Close()
	if err != nil {
		fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
		return
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		hashLine := strings.TrimSpace(scanner.Text())
		countLine++
		if truncLine != "" || ignoreStr != "" {
			hashLine = CleanHashLine(hashLine, truncLine, ignoreStr, countLine, format)
		}
		if format == "default"{
		fmt.Print(ifColor(bgrn, "\nHash: ", rst), ifColor(bylw, hashLine, rst))
		}
		VerboseAnalyze(hashLine, "", "", format)
	}
	if err := scanner.Err(); err != nil {
		fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
	}
}
