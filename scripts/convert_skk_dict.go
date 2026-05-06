// Converts SKK dictionary to JSON format
// Usage: go run convert_skk_dict.go SKK-JISYO.L dict.json
//
// SKK dictionaries can be downloaded from:
//   https://skk-dev.github.io/dict/
package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"regexp"
	"strings"

	"golang.org/x/text/encoding/japanese"
	"golang.org/x/text/transform"
)

var (
	linePattern      = regexp.MustCompile(`^([^ ]+) /(.+)/$`)
	hiraganaPattern  = regexp.MustCompile(`^[ぁ-ゔー]+$`)
	okuriganaPattern = regexp.MustCompile(`^([ぁ-ゔー]+)[a-z]$`)
	annotationRe     = regexp.MustCompile(`;.*$`)
)

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: go run convert_skk_dict.go <input_skk_dict> <output_json_file>")
		fmt.Println("Example: go run convert_skk_dict.go SKK-JISYO.L dict.json")
		os.Exit(1)
	}

	inputFile := os.Args[1]
	outputFile := os.Args[2]

	entries, err := convertSKKToJSON(inputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	if err := writeJSON(outputFile, entries); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing JSON: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Converted %d entries to %s\n", len(entries), outputFile)
}

func convertSKKToJSON(inputFile string) (map[string][]string, error) {
	file, err := os.Open(inputFile)
	if err != nil {
		return nil, fmt.Errorf("failed to open input file: %w", err)
	}
	defer file.Close()

	// Decode EUC-JP to UTF-8
	reader := transform.NewReader(file, japanese.EUCJP.NewDecoder())
	scanner := bufio.NewScanner(reader)

	entries := make(map[string][]string)

	for scanner.Scan() {
		line := scanner.Text()

		// Skip comments and empty lines
		if strings.HasPrefix(line, ";;") || strings.TrimSpace(line) == "" {
			continue
		}

		// Parse SKK format: reading /candidate1/candidate2/.../
		match := linePattern.FindStringSubmatch(line)
		if match == nil {
			continue
		}

		reading := match[1]
		candidatesStr := match[2]

		// Process pure hiragana readings and okurigana entries
		// Okurigana entries (e.g., "つくr") have a trailing alphabet character
		// marking the okurigana boundary — strip it to get the hiragana stem
		if !hiraganaPattern.MatchString(reading) {
			if m := okuriganaPattern.FindStringSubmatch(reading); m != nil {
				reading = m[1]
			} else {
				continue
			}
		}

		candidates := strings.Split(candidatesStr, "/")
		var cleanCandidates []string

		for _, c := range candidates {
			// Remove annotations
			c = annotationRe.ReplaceAllString(c, "")
			// Skip empty or same as reading
			if c != "" && c != reading {
				cleanCandidates = append(cleanCandidates, c)
			}
		}

		if len(cleanCandidates) > 0 {
			if existing, ok := entries[reading]; ok {
				// Merge with existing entry, avoiding duplicates
				seen := make(map[string]bool, len(existing))
				for _, c := range existing {
					seen[c] = true
				}
				for _, c := range cleanCandidates {
					if !seen[c] {
						existing = append(existing, c)
					}
				}
				entries[reading] = existing
			} else {
				entries[reading] = cleanCandidates
			}
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error reading file: %w", err)
	}

	return entries, nil
}

func writeJSON(outputFile string, entries map[string][]string) error {
	file, err := os.Create(outputFile)
	if err != nil {
		return fmt.Errorf("failed to create output file: %w", err)
	}
	defer file.Close()

	encoder := json.NewEncoder(file)
	encoder.SetEscapeHTML(false)
	// Compact output (no indentation)
	return encoder.Encode(entries)
}
