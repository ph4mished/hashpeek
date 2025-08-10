package main

import (
	"strings"
)

func HashAnalyze(targetHash string) ([]HASHALGO, bool) {

	targetHash = strings.TrimSpace(targetHash)

	var matches []HASHALGO
	for regex, HashTypes := range HASH_DATABASE {
		if regex.MatchString(targetHash) {

			matches = append(matches, HashTypes...)
		}
	}
	if len(matches) > 0 {
		return matches, true
	}
	return nil, false
}
