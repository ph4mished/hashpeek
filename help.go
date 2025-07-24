package main

import (
	"fmt"
	"os"
)

func Help() {
	fmt.Println(ifColor(bcyn, "\nUsage of "+os.Args[0]+":\n", rst))
	fmt.Println(ifColor(orng, "-x <hashstring>", rst), " :\t", ifColor(grn, "Analyze a single hash string", rst))
	fmt.Println(ifColor(orng, "-f </path/to/file>", rst), " :\t", ifColor(grn, "Analyze hashes from a file", rst))
	fmt.Println(ifColor(orng, "-c", rst), " :\t", ifColor(grn, "Enable colored output", rst))
	fmt.Println(ifColor(orng, "-vb", rst), " :\t", ifColor(grn, "Show detailed results per hash (verbose)", rst))
	fmt.Println(ifColor(orng, "-h", rst), " :\t", ifColor(grn, "Show this help message", rst))
	fmt.Println(ifColor(orng, "-x - ", rst), " :\t", ifColor(grn, "Analyze hashes directly from stdin", rst))
	fmt.Println(ifColor(orng, "-f -", rst), " :\t", ifColor(grn, "Analyze hashes from filenames via stdin", rst))
	fmt.Println(ifColor(orng, "-v", rst), " :\t", ifColor(grn, "Show the version of "+os.Args[0]+"\n", rst))
}
