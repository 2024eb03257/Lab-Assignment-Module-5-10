#!/bin/bash
# Alternative implementation using grep patterns

[ $# -ne 1 ] && echo "Usage: $0 <file>" && exit 1
[ ! -f "$1" ] && echo "Error: File '$1' not found" && exit 1

echo "Processing: $1"

# Clean output files
> vowels.txt > consonants.txt > mixed.txt

# Get words (lowercase, alphabetic only)
WORDS=$(tr '[:upper:]' '[:lower:]' < "$1" | 
         grep -oE '\b[a-z]+\b')

# 1. Words with only vowels
echo "$WORDS" | grep -E '^[aeiou]+$' | sort -u > vowels.txt

# 2. Words with only consonants
echo "$WORDS" | grep -E '^[bcdfghjklmnpqrstvwxyz]+$' | sort -u > consonants.txt

# 3. Mixed words (start with consonant, contain both)
echo "$WORDS" | grep -E '^[bcdfghjklmnpqrstvwxyz].*[aeiou].*' | 
                grep '[bcdfghjklmnpqrstvwxyz]$' | 
                sort -u > mixed.txt

echo "Done! Check the output files."
