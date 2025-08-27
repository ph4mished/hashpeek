package main

import (
	"bufio"
	"unicode"
	"fmt"
	"os"
	"strings"
)

func ExtractHexHashes(input string, minLength int) []string {
	var hashes []string
	var currentHash []rune
	inHexSequence := false

	for _, char := range input {
		isHex := unicode.Is(unicode.ASCII_Hex_Digit, char)

		if isHex && !inHexSequence {
			inHexSequence = true
			currentHash = []rune{char}
		} else if isHex && inHexSequence {
			currentHash = append(currentHash, char)
		} else if !isHex && inHexSequence {
			if len(currentHash) >= minLength {
				hashes = append(hashes, string(currentHash))
			}
			inHexSequence = false
			currentHash = nil
		}
	}

	// Check if we ended while in a hex sequence
	if inHexSequence && len(currentHash) >= minLength {
		hashes = append(hashes, string(currentHash))
	}

	return hashes
}

// this function extract the hashes from messy logs and send them to the function for hash identification
func PrintExtractedHashes(hashFile string, truncLine string, ignoreStr string, minLength int, format string) {
	countLine := 0
	if !IsFile(hashFile) {
		hashLine := hashFile
		extractedHashes := ExtractHexHashes(hashLine, minLength)
		for _, extractedHash := range extractedHashes {
			fmt.Println(ifColor(bgrn, "\n Extracted Hash: ", rst), ifColor(bylw, extractedHash, rst))
			countLine++
			if len(extractedHash) > 0 {
				VerboseAnalyze(extractedHash, truncLine, ignoreStr, /*countLine,*/ format)
			}
		}
	} else {
		file, err := os.Open(hashFile)
		defer file.Close()
		if err != nil {
			fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
			return
		}

		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			hashLine := strings.TrimSpace(scanner.Text())
			extractedHashes := ExtractHexHashes(hashLine, minLength)
			for _, extractedHash := range extractedHashes {
				if len(extractedHash) > 0 {
					fmt.Println(ifColor(bgrn, "\n Extracted Hash: ", rst), ifColor(bylw, extractedHash, rst))
					VerboseAnalyze(extractedHash, truncLine, ignoreStr, format)
				}
			}
		  continue

		}
		if err := scanner.Err(); err != nil {
			fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
		}
	}
}
