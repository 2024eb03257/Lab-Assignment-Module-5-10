#!/bin/bash

# Log analyzer script for Question 2
# Usage: log_analyzer.sh logfile

# Validate argument count
if [ $# -ne 1 ]; then
  echo "Usage: $0 <logfile>"
  exit 1
fi

logfile="$1"

# Validate file exists and is readable
if [ ! -e "$logfile" ]; then
  echo "Error: File '$logfile' does not exist."
  exit 1
fi

if [ ! -r "$logfile" ]; then
  echo "Error: File '$logfile' is not readable."
  exit 1
fi

# Regex pattern for valid log entries (YYYY-MM-DD HH:MM:SS )
pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} '

# Count total log entries (lines matching the timestamp pattern)
total=$(grep -E "$pattern" "$logfile" | wc -l)

# Count levels (using awk to check third field)
info=$(awk '$3=="INFO"{count++} END{print (count+0)}' "$logfile")
warning=$(awk '$3=="WARNING"{count++} END{print (count+0)}' "$logfile")
error=$(awk '$3=="ERROR"{count++} END{print (count+0)}' "$logfile")

# Find most recent ERROR message (combine date+time as sort key)
most_recent_error=$(awk '$3=="ERROR"{print $1" "$2" "substr($0, index($0,$4))}' "$logfile" \
  | sort -k1,1 -k2,2 | tail -n 1)

if [ -z "$most_recent_error" ]; then
  most_recent_error="No ERROR entries found."
fi

# Generate report file
report_file="logsummary_$(date +%F).txt"
{
  echo "Log Summary Report - $(date +%F)"
  echo "Source file: $logfile"
  echo ""
  echo "Total log entries: $total"
  echo "INFO: $info"
  echo "WARNING: $warning"
  echo "ERROR: $error"
  echo ""
  echo "Most recent ERROR:"
  echo "$most_recent_error"
} > "$report_file"

# Display the summary to stdout and indicate report file
cat "$report_file"

echo ""
echo "Report saved to: $report_file"

exit 0
