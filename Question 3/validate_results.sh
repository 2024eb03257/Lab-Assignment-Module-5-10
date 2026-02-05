#!/bin/bash

# Usage: ./validate_results.sh [marks_file]
file="${1:-marks.txt}"
pass=33

if [ ! -e "$file" ]; then
  echo "Error: '$file' not found."
  exit 1
fi

if [ ! -r "$file" ]; then
  echo "Error: '$file' is not readable."
  exit 1
fi

one_fail_count=0
all_pass_count=0
one_fail_list=()
all_pass_list=()

while IFS=',' read -r roll name m1 m2 m3 || [ -n "$roll" ]; do
  # skip empty lines or lines missing fields
  # trim whitespace
  roll=$(echo "$roll" | xargs)
  name=$(echo "$name" | xargs)
  m1=$(echo "$m1" | xargs)
  m2=$(echo "$m2" | xargs)
  m3=$(echo "$m3" | xargs)

  [ -z "$roll" ] && continue

  # ensure marks are numeric (treat non-numeric as 0)
  [[ "$m1" =~ ^[0-9]+$ ]] || m1=0
  [[ "$m2" =~ ^[0-9]+$ ]] || m2=0
  [[ "$m3" =~ ^[0-9]+$ ]] || m3=0

  failed=0
  if [ "$m1" -lt "$pass" ]; then failed=$((failed+1)); fi
  if [ "$m2" -lt "$pass" ]; then failed=$((failed+1)); fi
  if [ "$m3" -lt "$pass" ]; then failed=$((failed+1)); fi

  if [ "$failed" -eq 1 ]; then
    one_fail_list+=("$roll, $name")
    one_fail_count=$((one_fail_count+1))
  fi

  if [ "$failed" -eq 0 ]; then
    all_pass_list+=("$roll, $name")
    all_pass_count=$((all_pass_count+1))
  fi

done < "$file"

# Output results
printf "Students who failed in exactly ONE subject:\n"
if [ "$one_fail_count" -eq 0 ]; then
  printf "None\n"
else
  for s in "${one_fail_list[@]}"; do
    printf "%s\n" "$s"
  done
fi

printf "\nStudents who passed ALL subjects:\n"
if [ "$all_pass_count" -eq 0 ]; then
  printf "None\n"
else
  for s in "${all_pass_list[@]}"; do
    printf "%s\n" "$s"
  done
fi

printf "\nCounts:\n"
printf "Passed all: %d\n" "$all_pass_count"
printf "Failed exactly one: %d\n" "$one_fail_count"

exit 0
