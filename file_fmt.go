package main

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
)

type ErrOutput struct {
	Status      string `json:"status"`
	Content     string `json:"input"`
	Description string `json:"description"`
}

func DefaultFormat(targetHash string) string {
	var defMatch []string
	rangeHash, found := HashAnalyze(targetHash)
	if !found {
		sht := fmt.Sprint(ifColor(bred, "[!] Unknown Hash Format!\n", rst))
		return sht
	}
	for _, rhash := range rangeHash {
		hashtype := fmt.Sprint(ifColor(bblu, rhash.Name, rst) + ifColor(bvol, "\n    Hashcat Mode: ", rst) + ifColor(bylw, *rhash.HashCat, rst) + ifColor(borng, "\n    John Format: ", rst) + ifColor(bylw, *rhash.John+"\n", rst))
		defMatch = append(defMatch, hashtype)
	}
	allHashtype := strings.Join(defMatch, "\n")
	return allHashtype
}

func CSVFormat(targetHash string) {

	rangeHash, found := HashAnalyze(targetHash)

	w := csv.NewWriter(os.Stdout)

	if !found {
		_ = w.Write([]string{"status", "description", "input"})
		_ = w.Write([]string{"unknown", "unknown hash format", targetHash})
		w.Flush()
		return
	}

	//for file hash analysis. the topic prints per hash. it shouldn't be so
	if err := w.Write([]string{"hash", "hashtype",
		"hashcat_mode", "john_format"}); err != nil {
		log.Fatalln("error writing header to csv:", err)
	}

	for _, hashtype := range rangeHash {
		if *hashtype.HashCat == "--" || *hashtype.John == "--" {
			nullStr := ""
			hashtype.HashCat = &nullStr
			hashtype.John = &nullStr
		}
		record := []string{targetHash, hashtype.Name, *hashtype.HashCat, *hashtype.John}
		if err := w.Write(record); err != nil {
			log.Fatalln("error writing record to csv:", err)
		}
	}
	w.Flush()

	if err := w.Error(); err != nil {
		log.Fatal(err)
	}
}

func JSONFormat(targetHash string) string {
	var jsonMatch []string
	rangeHash, found := HashAnalyze(targetHash)

	if !found {
		errObj := ErrOutput{
			Status:      "unknown",
			Content:     targetHash,
			Description: "Unknown hash format",
		}

		jsonErr, err := json.MarshalIndent(errObj, "", "  ")
		if err != nil {
			return fmt.Sprintf("[!] JSON Encoding Error: %v\n", err)
		}
		return string(jsonErr)
	}

	for i := range rangeHash {
		if rangeHash[i].HashCat != nil && *rangeHash[i].HashCat == "--" {
			rangeHash[i].HashCat = nil
		}
		if rangeHash[i].John != nil && *rangeHash[i].John == "--" {
			rangeHash[i].John = nil
		}
	}

	result := map[string][]HASHALGO{
		targetHash: rangeHash,
	}

	jsonOut, err := json.MarshalIndent(result, "", "  ")
	jsonMatch = append(jsonMatch, string(jsonOut))
	if err != nil {
		return fmt.Sprintf("[!] JSON Encoding Error: %v\n", err)
	}
	jsonResult := strings.Join(jsonMatch, "\n")
	return jsonResult
}
