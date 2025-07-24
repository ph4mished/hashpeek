package main

import (
	"fmt"
	"strings"
)

var unknown string

func HashAnalyze(targetHash string) string {

	targetHash = strings.TrimSpace(targetHash)

	var matches []string
	for regex, HashTypes := range HASH_DATABASE {
		for _, hashtype := range HashTypes {
			if regex.MatchString(targetHash) {
				name := fmt.Sprintf(
					ifColor(bblu, " %s", rst)+
						ifColor(bvol, "\n    Hashcat Mode: ", rst)+ifColor(bylw, "%s", rst)+ifColor(borng, "\n    John Format: ", rst)+ifColor(bylw, "%s\n", rst), hashtype.Name, hashtype.HashCat, hashtype.John)
				matches = append(matches, name)
			}
		}
	}
	if len(matches) > 0 {
		return strings.Join(matches, "\n ")
	}
	unknown = fmt.Sprintf(ifColor(bred, "[!] Unknown Hash Format!\n", rst))
	return unknown
}
