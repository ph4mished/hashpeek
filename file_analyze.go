package main

import (
	"fmt"
	"os"
    "encoding/csv"
    "encoding/json"
)

type ErrorOutput struct {
      Status     string `json:"status"`
      Error      string `json:"error"`
      File    string `json:"content"`
      //Suggestion string `json:"suggestion"`
  }
  
 
func percentage(num, total int) float64 {
	return (float64(num) / float64(total)) * 100
}
func GroupHash(hashFile string, truncLine string, ignoreStr string) {
	var hashtype, hashLine string
	//var pureLines []string
	hash_counts := make(map[string]int)
	total_hashes := 0
	allLines, err := FileLaunch(hashFile)
	if err != nil {
		fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
		return
	}
	if truncLine != "" || ignoreStr != ""{
    allLines = CleanHashLine(allLines, truncLine, ignoreStr, "")
}
	for _, hashLine = range allLines {

			if len(hashLine) > 0 {
				total_hashes++

				hashtype = DefaultFormat(hashLine)

				hash_counts[hashtype]++
			}
		}
	fmt.Print(ifColor(bgrn, "\n[~] Found ", rst) + ifColor(borng, total_hashes, rst) + ifColor(bgrn, " hashes in ", rst) + ifColor(borng, hashFile, rst))
	for hashtype, count := range hash_counts {
		pct := percentage(count, total_hashes)
		fmt.Printf(ifColor(bgrn, "\n\n{", rst)+ifColor(bylw, "%.2f%%", rst)+ifColor(bgrn, "} ", rst)+ifColor(bcyn, "%d/%d", rst)+ifColor(bcyn, " Of The Hashes Are:\n", rst)+"\n%s", pct, count, total_hashes, hashtype)
	}
}



func VerboseAnalyze(hashFile string, truncLine string, ignoreStr string, format string) {
	var hashtype string
	//var pureLines []string

	allLines, err := FileLaunch(hashFile)
	if err != nil{
	strErr :=  fmt.Sprint(err)
	if err != nil && format == "json"{
	//,to convert error to string
	//strErr :=  fmt.Sprintf(err)
		/*	errObj := map[string]string{
			"error": strErr,
			"file": hashFile,
		}*/
		errObj := ErrorOutput{
		             Status:     "error",
		             Error:       strErr,
	                 //Line:       countLine,
		             File:    hashFile,
		             //Suggestion: errSuggest,
		         }
		jsonErr, err := json.MarshalIndent(errObj, "", "  ")
		if err != nil {
			fmt.Printf("[!] JSON Encoding Error: %v\n", err)
		}
		fmt.Println(string(jsonErr))
	} else	if err != nil && format == "csv"{
	w := csv.NewWriter(os.Stdout)
		_ = w.Write([]string{"error", "file"})
		_ = w.Write([]string{strErr, hashFile})
		w.Flush()
	  return
	} else	if err != nil && format == "default"{
	//error will be handled in all three formats later
	  fmt.Printf(ifColor(bred, "[!] Error: %s\n", rst), err)
	  return
	}
	}
	if truncLine != "" || ignoreStr != ""{
    allLines = CleanHashLine(allLines, truncLine, ignoreStr, format)
    }
	for _, hashLine := range allLines {
			if len(hashLine) > 0 {

				if format == "csv" {
					CSVFormat(hashLine)
				} else if format == "json" {
					hashtype = JSONFormat(hashLine)
					fmt.Println(hashtype)
				} else if format == "default" {
				fmt.Print(ifColor(bgrn, "Hash: ", rst), ifColor(bylw, hashLine, rst))
					fmt.Println(ifColor(bcyn, "\nPOSSIBLE HASH TYPES", rst))
					hashtype = DefaultFormat(hashLine)
					fmt.Println(hashtype)
				}
			}
		}
	}
