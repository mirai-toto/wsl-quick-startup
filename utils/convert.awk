BEGIN {
    print "{"
}

{
    split($0, arr, "=")
    key = arr[1]
    value = arr[2]

    # Skip lines with empty values
    if (value == "") {
        next
    }

    # Determine if value is a number or boolean
    if (value ~ /^[0-9]+$/ || value ~ /^(true|false)$/) {
        data[NR] = "  \"" key "\": " value
    } else {
        # Escape double quotes in string values
        gsub(/"/, "\\\"", value)
        data[NR] = "  \"" key "\": \"" value "\""
    }
}

END {
    for (i = 1; i <= length(data); i++) {
        if (i == length(data)) {
            print data[i]  # No comma for the last item
        } else {
            print data[i] ","
        }
    }
    print "}"
}
