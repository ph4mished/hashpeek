package main

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type ErrorOut struct {
	Status  string `json:"status"`
	Error   string `json:"error"`
	Line    int    `json:"line"`
	Content string `json:"content"`
}

func CleanHashLine(hashLine string, truncLine string, ignoreStr string, countLine int, format string) string {
	var splitWord []string
	var intIndex int
	var trimDelim string
	if hashLine != "" {
		if ignoreStr != "" {
			ShouldIgnore := false
			ignoreSlice := IgnoreParse(ignoreStr)
			for _, ignoreChar := range ignoreSlice {
				if strings.HasPrefix(hashLine, ignoreChar) {
					ShouldIgnore = true
				}
			}
			if ShouldIgnore {
				return ""
			}
		}
		if truncLine != "" {
			intIndex, trimDelim = ParseTrunc(truncLine)

			splitWord = strings.Split(hashLine, trimDelim)
			if intIndex < 0 {
				fmt.Println(ifColor(bred, "\n\n[!] Invalid truncation index", rst), ifColor(bylw, intIndex, rst), ifColor(bred, ": Negative indices not supported\n", rst))

				return ""

			}
		}
		if intIndex < len(splitWord) {
			hashLine = splitWord[intIndex]
		} else {
			errDescript := fmt.Sprintf("not enough fields for truncation {%d} with delimiter '%s'", intIndex, trimDelim)

			if format == "default" {
				fmt.Println(ifColor(bred, "\n[!] Skipped line ", rst), ifColor(bcyn, strconv.Itoa(countLine), rst), ifColor(bred, ": Expected at least "+strconv.Itoa(intIndex)+" fields (got "+strconv.Itoa(len(splitWord)-1)+") after splitting by '"+trimDelim+"'.", rst))
				fmt.Println(ifColor(bgrn, "Content: ", rst), ifColor(bylw, hashLine, rst))
				return ""
			} else if format == "csv" {
				w := csv.NewWriter(os.Stdout)
				_ = w.Write([]string{"status", "error", "line", "content"})
				_ = w.Write([]string{"error", errDescript, strconv.Itoa(countLine), hashLine})
				w.Flush()
				return ""
			} else if format == "json" {
				errDescript := fmt.Sprintf("Not enough fields for truncation {%d} with delimiter '%s'", intIndex, trimDelim)
				var allJsonErr []string

				errObj := ErrorOut{
					Status:  "error",
					Error:   errDescript,
					Line:    countLine,
					Content: hashLine,
				}
				jsonErr, err := json.MarshalIndent(errObj, "", "  ")
				if err != nil {
					fmt.Printf("[!] JSON Encoding Error: %v\n", err)
					return ""
				}
				allJsonErr = append(allJsonErr, string(jsonErr))
				fmt.Println(strings.Join(allJsonErr, "\n"))
				return ""
			}
		}
	}
	return hashLine
}

func IgnoreParse(ignoreStr string) []string {
	if ignoreStr == "" {
		return nil
	}
	return strings.Split(ignoreStr, ",")
}

func ParseTrunc(truncInput string) (int, string) {
	truncSplit := strings.Split(truncInput, " ")
	trimIndex := strings.Trim(truncSplit[0], "{}")
	trimDelim := strings.Trim(truncSplit[1], "''``")
	intIndex, _ := strconv.Atoi(trimIndex)
	return intIndex, trimDelim
}

func IsFile(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return !info.IsDir()
}
