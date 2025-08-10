package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
    "encoding/csv"
    "encoding/json"
)

type ErrorOut struct {
    Status     string `json:"status"`
    Error      string `json:"error"`
    Line       int    `json:"line"`
    Content    string `json:"content"`
    //Suggestion string `json:"suggestion"`
}

type NegErrorOutput struct {
        Status     string `json:"status"`
        Error      string `json:"error"`
        Description    string `json:"description"`
       //Suggestion string `json:"suggestion"`
    }
// I think instead of doing it this way, a function should be created that support []string parameters,ignore, hashline and truncLine, this will make use of it for hashes that aren't from files too
// I think ignore and trunc will be handled here
func FileLaunch(hashFile string) ([]string, error) {
	var allLines []string
	file, err := os.Open(hashFile)
	if err != nil {
		//err = fmt.Sprintf(ifColor(bred, 
		//"[!] Error: %s\n", rst), err)
        //allErr = append(allErr, err)
		return []string{""}, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		hashLine := strings.TrimSpace(scanner.Text())
		allLines = append(allLines, hashLine)
	}
	return allLines, nil
}

func CleanHashLine(allLines []string, truncLine string, ignoreStr string, format string) []string {
    var pureHashes, splitWord [] string
    var intIndex int
    var trimDelim string
    countLine := 0
    for _, hashLine := range allLines{
            		countLine += 1
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
					continue
				}
			}
			if truncLine != "" {
				intIndex, trimDelim = ParseTrunc(truncLine)

				splitWord = strings.Split(hashLine, trimDelim)
				if intIndex < 0 {
                    //errors for json and csv about this will be handled so that machines can parse such.
                    //or these will be split to three for Json, csv, and default
                    //or the error will be returned so that it can be handled.
                    //I think the best option is splitting the function because there are so many errors to handle and returning them will be too much
					if format == "default" {
                        fmt.Println(ifColor(bred, "[!] Invalid truncation index", rst), ifColor(bylw, intIndex, rst), ifColor(bred, ": Negative indices not supported\n", rst))
                    
					return []string{""}
                    } else if format == "csv" {
                    w := csv.NewWriter(os.Stdout)
                        	_ = w.Write([]string{"status", "error", "description"})
		 _ = w.Write([]string{"error", "invalid truncation index", "negative indices not supported"})
		w.Flush()
        return []string{""}
        } else if format == "json" {
	/*	errObj := map[string]string{
			"error": "Invalid truncation index",
			"description": 
			"Negative indices not supported",
		}*/
		errObj := NegErrorOutput {
			Status: "error",
			Error: "Invalid truncation index",
			Description : "Negative indices not supported",
		}
		jsonErr, err := json.MarshalIndent(errObj, "", "  ")
		if err != nil {
			fmt.Printf("[!] JSON Encoding Error: %v\n", err)
return []string{""}
		}
		fmt.Println(string(jsonErr))
		return []string{""}
            }
                    }
                }
				if intIndex < len(splitWord) {
					hashLine = splitWord[intIndex]
				} else {
                       // var errDescript string
errDescript := fmt.Sprintf("not enough fields for truncation {%d} with delimiter '%s'", intIndex, trimDelim)
 // errSuggest := fmt.Sprintf("try -trunc '{%d} `%s`", (intIndex+1), trimDelim)
                    if format == "default" {
fmt.Println(ifColor(bred, "\n[!] Skipped line ", rst), ifColor(bcyn, strconv.Itoa(countLine), rst), ifColor(bred, ": Expected at least "+strconv.Itoa(intIndex)+" fields (got "+strconv.Itoa(len(splitWord)-1)+") after splitting by '"+trimDelim+"'.", rst))
					fmt.Println(ifColor(bgrn, "Line: ", rst), ifColor(bylw, hashLine, rst))
					continue
                    } else if format == "csv"{
//errDescript = fmt.Sprintf("not enough fields' for truncation {%d} with delimiter '%s'", intIndex, trimDelim)
w := csv.NewWriter(os.Stdout)
                        	_ = w.Write([]string{"status", "error", "line", "content"})
		_ = w.Write([]string{"error", errDescript, strconv.Itoa(countLine), hashLine})
		w.Flush()
        continue 
        } else if format == "json" {
            errDescript := fmt.Sprintf("Not enough fields for truncation {%d} with delimiter '%s'", intIndex, trimDelim)
         //   errSuggest := fmt.Sprintf("Try -trunc '{%d} `%s`", (intIndex+1), trimDelim)
            var allJsonErr []string
	/*	errObj := map[string]interface{} {
		"status": "error",
			"error": errDescript,
            "line": countLine,
            "content": hashLine,
           // "suggestion": errSuggest,
		}*/
		errObj := ErrorOut{
		    Status:     "error",
		    Error:      errDescript,
		    Line:       countLine,
		    Content:    hashLine,
		    //Suggestion: errSuggest,
		}
		jsonErr, err := json.MarshalIndent(errObj, "", "  ")
		if err != nil {
			fmt.Printf("[!] JSON Encoding Error: %v\n", err)
			return []string{""}
		}
        allJsonErr = append(allJsonErr, string(jsonErr))
        jsonResult := strings.Join(allJsonErr, "\n")
        //return jsonResult
        fmt.Println(jsonResult)
        continue 
        
		//return string(jsonErr)*

            }
				}
			}
            pureHashes = append(pureHashes, hashLine)
            }
            return pureHashes
            }


func IgnoreParse(ignoreStr string) []string {
	var ignoreSlice []string
	if strings.Contains(ignoreStr, ",") {

		splitIgnore := strings.Split(ignoreStr, ",")
		for _, ignoreChar := range splitIgnore {
			ignoreSlice = append(ignoreSlice, ignoreChar)
		}
		return ignoreSlice
	} else {
		ignoreSlice = append(ignoreSlice, ignoreStr)
	}
	return ignoreSlice
}


func ParseTrunc(truncInput string) (int, string) {
	truncSplit := strings.Split(truncInput, " ")
	trimIndex := strings.Trim(truncSplit[0], "{}")
	trimDelim := strings.Trim(truncSplit[1], "''``")
	intIndex, _ := strconv.Atoi(trimIndex)
	return intIndex, trimDelim
}
