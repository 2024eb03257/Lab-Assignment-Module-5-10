
#!/bin/bash

# sync_compact.sh - Compact directory comparison

[ $# -ne 2 ] && echo "Usage: $0 dir1 dir2" && exit 1
[ ! -d "$1" ] && echo "Error: $1 not a directory" && exit 1
[ ! -d "$2" ] && echo "Error: $2 not a directory" && exit 1

echo "=== Files only in $1 ==="
comm -23 <(find "$1" -type f -printf "%P\n" | sort) <(find "$2" -type f -printf "%P\n" | sort)

echo -e "\n=== Files only in $2 ==="
comm -13 <(find "$1" -type f -printf "%P\n" | sort) <(find "$2" -type f -printf "%P\n" | sort)

echo -e "\n=== Common files (showing differences) ==="
comm -12 <(find "$1" -type f -printf "%P\n" | sort) <(find "$2" -type f -printf "%P\n" | sort) | while read file; do
    if ! cmp -s "$1/$file" "$2/$file"; then
        echo "DIFFERENT: $file"
        # Uncomment next line to see diff output
        # diff -u "$1/$file" "$2/$file" | head -20
    else
        echo "SAME: $file"
    fi
done
