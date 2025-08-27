package main

import (
	"fmt"
	"os"
)

func Help() {
	fmt.Println(ifColor(bcyn, "\nUsage of "+os.Args[0]+":\n", rst))
	fmt.Println(ifColor(orng, "-x <hashstring>", rst), " :\t", ifColor(grn, "Analyze a single hash string", rst))
	fmt.Println(ifColor(orng, "-f </path/to/file>", rst), " :\t", ifColor(grn, "Analyze hashes from a file", rst))
	fmt.Println(ifColor(orng, "-i <ignorableChar>", rst), " :\t", ifColor(grn, "Ignore lines that begins with character/string '<ignorableChar>'", rst), ifColor(ylw, "eg. -i '#,//,$' ignores chars that begins with '#' or '//' or '$' this is to ensure clean results", rst))
	fmt.Println(ifColor(orng, "-e <min-length>", rst), " :\t", ifColor(grn, "Extract hashes from messy text/logs using the given minimum length", rst), ifColor(ylw, "e.g. '-e 16' this means it scans the file for hashes that have a length 16 upwards.", rst))
	fmt.Println(ifColor(orng, "-json", rst), " :\t", ifColor(grn, "Outputs results in JSON format", rst))
	fmt.Println(ifColor(orng, "-csv", rst), " :\t", ifColor(grn, "Outputs results in CSV format", rst))
	fmt.Println(ifColor(orng, "-nc", rst), " :\t", ifColor(grn, "Disable coloured output (no-color)", rst))
	fmt.Println(ifColor(orng, "-vb", rst), " :\t", ifColor(grn, "Show detailed results per hash (verbose)", rst))
	fmt.Println(ifColor(orng, "-h", rst), " :\t", ifColor(grn, "Show this help message", rst))
	fmt.Println(ifColor(orng, "-x - ", rst), " :\t", ifColor(grn, "Analyze hashes directly from stdin", rst))
	fmt.Println(ifColor(orng, "-f -", rst), " :\t", ifColor(grn, "Analyze hashes from filenames via stdin", rst))
	fmt.Println(ifColor(orng, "-v", rst), " :\t", ifColor(grn, fmt.Sprintf("Show the version of %s", os.Args[0]), rst))
	fmt.Println(ifColor(orng, "-trunc '{N} `X`'", rst), " :", ifColor(grn, "    Capture segment at 0-based index N after splitting by delimiter X", rst), ifColor(ylw, "  (e.g. -trunc '{1} `:::`' extracts 'hash' from 'user:::hash:::salt' where ':::' is the delimiter)\n", rst))
}
