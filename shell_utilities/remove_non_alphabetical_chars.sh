#!/bin/bash

# Function to remove non-alphabetical characters from the beginning of a string
remove_non_alphabetical() {
  local input="$1"
  echo "$input" | sed 's/^[^a-zA-Z]*//'
}

# Traverse the directory and rename files
traverse_and_rename() {
  local directory="$1"
  shopt -s nullglob
  for file in "$directory"/*; do
    if [ -f "$file" ]; then
      file_name=$(basename "$file")
      new_name=$(remove_non_alphabetical "$file_name")
      if [ "$file_name" != "$new_name" ]; then
        mv "$file" "$directory/$new_name"
        echo "Renamed: $file_name -> $new_name"
      fi
    elif [ -d "$file" ]; then
      traverse_and_rename "$file"
    fi
  done
}

# Main script
if [ $# -eq 0 ]; then
  echo "Usage: $0 directory_path"
  exit 1
fi

directory_path="$1"
if [ ! -d "$directory_path" ]; then
  echo "Directory not found: $directory_path"
  exit 1
fi

traverse_and_rename "$directory_path"

