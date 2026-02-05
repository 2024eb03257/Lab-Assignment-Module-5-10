#!/bin/bash

# Usage: ./emailcleaner.sh [emails_file]
file="${1:-emails.txt}"

if [ $# -gt 1 ]; then
  echo "Usage: $0 [emails_file]"
  exit 1
fi

if [ ! -e "$file" ]; then
  echo "Error: File '$file' does not exist."
  exit 1
fi

if [ ! -r "$file" ]; then
  echo "Error: File '$file' is not readable."
  exit 1
fi

# Temporary files
valid_tmp=".valid_tmp.txt"
invalid_tmp=".invalid_tmp.txt"

# Valid email regex: letters/digits before @ and letters for domain, ending with .com
valid_regex='\b[a-z0-9]+@[a-z]+\.com\b'

# Extract tokens containing '@' (potential emails)
# Use -o to get only the matches; use perl-compatible boundaries via grep -E
grep -E -o '[^[:space:]]+@[^[:space:]]+' "$file" > "$invalid_tmp" || true

# From the potential list, pick ones that match the valid form (case-insensitive)
grep -i -E "$valid_regex" "$invalid_tmp" | tr '[:upper:]' '[:lower:]' | sort | uniq > "$valid_tmp"

# Invalid are those potential tokens that are not valid
if [ -e "$valid_tmp" ]; then
  grep -i -F -v -f "$valid_tmp" "$invalid_tmp" | sort | uniq > invalid.txt
else
  sort -u "$invalid_tmp" > invalid.txt
fi

# Move valid_tmp to valid.txt (already deduped)
mv "$valid_tmp" valid.txt 2>/dev/null || :

# Cleanup temporary file
rm -f "$invalid_tmp"

echo "Valid emails written to: valid.txt"
echo "Invalid emails written to: invalid.txt"

exit 0
