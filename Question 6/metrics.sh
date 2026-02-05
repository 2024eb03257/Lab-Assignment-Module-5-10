#!/bin/bash

# Compact version using efficient pipelines

[ $# -ne 1 ] && echo "Usage: $0 <file>" && exit 1
[ ! -f "$1" ] && echo "File not found: $1" && exit 1
[ ! -s "$1" ] && echo "File is empty: $1" && exit 1

echo "Analyzing: $1"
echo "------------------------"

# Process file once and reuse
WORDS=$(tr '[:upper:]' '[:lower:]' < "$1" | tr -s '[:space:][:punct:]' '\n' | grep -v '^$')

# All calculations in one awk pass
echo "$WORDS" | awk '
    {
        words[NR] = $0
        len = length($0)
        sum += len
        if (NR == 1 || len > max_len) max_len = len
        if (NR == 1 || len < min_len) min_len = len
    }
    END {
        if (NR == 0) exit 1
        
        # Count unique words
        for (i in words) seen[words[i]]++
        unique_count = length(seen)
        
        # Find all longest words
        printf "Unique words: %d\n\n", unique_count
        printf "Longest words (%d chars):\n", max_len
        for (w in seen) if (length(w) == max_len) printf "  %s\n", w
        
        printf "\nShortest words (%d chars):\n", min_len
        for (w in seen) if (length(w) == min_len) printf "  %s\n", w
        
        printf "\nAverage length: %.2f chars\n", sum/NR
        printf "Total words: %d\n", NR
    }'

echo "------------------------"
