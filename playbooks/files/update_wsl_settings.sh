#!/bin/sh

# Check if all arguments are present
if [ $# -ne 5 ]; then
  echo "Usage: $0 distro_name font_name use_acrylic opacity wsl_settings_file"
  exit 1
fi

# Extract arguments
distro_name="$1"
font_name="$2"
use_acrylic="$3"
opacity="$4"
wsl_settings_file="$5"

distro_name="\"${distro_name}\""
font_name="\"${font_name}\""

# Build jq query
query='.profiles.list[] |= if .name == $distro_name then . + {font: {face: $font_name}, useAcrylic: $use_acrylic, opacity: $opacity } else . end'
# Execute jq and save output to file
jq --arg distro_name "$distro_name" --arg font_name "$font_name" --argjson use_acrylic "$use_acrylic" --argjson opacity "$opacity" "$query" "$wsl_settings_file" > output

# Print success message
echo "Settings updated and written to output file."