#!/bin/bash

script_dir="$(cd "$(dirname "$0")" && pwd)"
AWK_SCRIPT="$script_dir/convert.awk"

# Function to sanitize the input file
sanitize_input() {
  local input_file="$1"
  local sanitized_file

  sanitized_file=$(mktemp)

  # Remove comments and empty lines
  grep -vE '^\s*#|^\s*$' "$input_file" |

    #Replace Windows break line for Linux break line
    sed 's/\r$//' |

    # Remove leading and trailing whitespace
    sed 's/^[ \t]*//;s/[ \t]*$//' |

    # Remove keys without values (lines ending with "=")
    grep -vE '^[^=]+=?$' |

    # Replace backslashes with forward slashes \->/\
    sed 's#\\#\\/#g' >"$sanitized_file"

  echo "$sanitized_file"
}

# Function to convert sanitized key-value pairs to JSON
convert_to_json() {
  local sanitized_file="$1"
  local output_file="$2"

  awk -f "$AWK_SCRIPT" "$sanitized_file" | sed '$s/,$//' >"$output_file"
}

# Main function
cfg_to_json() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
  fi

  local input_file="$1"
  local output_file="$2"

  if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file not found: $input_file"
    exit 1
  fi

  if [[ ! -f "$AWK_SCRIPT" ]]; then
    echo "Error: AWK script not found: $AWK_SCRIPT"
    exit 1
  fi

  # Sanitize input
  local sanitized_file
  sanitized_file=$(sanitize_input "$input_file")

  # Convert to JSON
  convert_to_json "$sanitized_file" "$output_file"

  # Clean up
  rm -f "$sanitized_file"

  echo "JSON has been saved to: $output_file"
}

# Call the main
cfg_to_json "$@"
