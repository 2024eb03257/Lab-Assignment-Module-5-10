#!/bin/bash

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Please provide exactly one argument (file or directory path)."
    exit 1
fi

# Check if the path exists
if [ ! -e "$1" ]; then
    echo "Error: Path '$1' does not exist."
    exit 1
fi

# Check if the argument is a file
if [ -f "$1" ]; then
    # Use wc to get statistics (lines, words, characters)
    lines=$(wc -l < "$1" | tr -d ' ')
    words=$(wc -w < "$1" | tr -d ' ')
    chars=$(wc -c < "$1" | tr -d ' ')
    
    echo "File Analysis: $1"
    echo "Number of lines: $lines"
    echo "Number of words: $words"
    echo "Number of characters: $chars"
    
# Check if the argument is a directory
elif [ -d "$1" ]; then
    # Count total files (only in the directory, not subdirectories)
    total_files=$(find "$1" -maxdepth 1 -type f | wc -l)
    
    # Count .txt files
    txt_files=$(find "$1" -maxdepth 1 -name "*.txt" -type f | wc -l)
    
    echo "Directory Analysis: $1"
    echo "Total number of files: $total_files"
    echo "Number of .txt files: $txt_files"
fi
