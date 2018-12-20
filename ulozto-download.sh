# Copyright (c) 2018 Martin Heralecký <heralecky.martin@gmail.com>
# License: MIT
# Usage: ulozto-download

#!/bin/bash

ARGS=("$@")

# The program's entry point.
function main {
    loadOptions

    function curl-auth {
        curl -L --basic -u "$ULOZTO_USERNAME:$ULOZTO_PASSWORD" "$@"
    }

    FILE_SIZE=`\
        curl-auth -sI "$URL" | \
        grep -iP 'content-length:\s*\d+' | \
        sed -r 's/^[^0-9]*([0-9]+).*$/\1/' | \
        tail -n 1`

    echo "File size: ${FILE_SIZE}B"

    touch "$OUTPUT_FILE"

    while [[ `stat -c %s "$OUTPUT_FILE"` < $(($FILE_SIZE - 1)) ]]; do
        curl-auth \
            --header "Range: Bytes=`stat -c %s "$OUTPUT_FILE"`-`echo $(($FILE_SIZE - 2))`" \
            "$URL" \
        >> "$OUTPUT_FILE"

        if [[ ! $? -eq 0 ]]; then
            echo "curl failed. Trying again in 5 seconds."
            sleep 5
        fi
    done

    echo "Download done."
}

# Loads options. If some required options are unavailable, prints help and exits the program.
function loadOptions {
    URL="${ARGS[0]}"
    OUTPUT_FILE="${ARGS[1]}"
    ULOZTO_USERNAME="${ARGS[2]}"
    ULOZTO_PASSWORD="${ARGS[3]}"

    if isEmpty "$URL" \
        || isEmpty "$OUTPUT_FILE" \
        || isEmpty "$ULOZTO_USERNAME" \
        || isEmpty "$ULOZTO_PASSWORD"; then
        showHelp
        exit 1
    fi
}

# Returns 0, if $1's length is zero or consists of whitespace only. Otherwise returns 1.
# Params:
#   $1  Value to be tested.
function isEmpty {
    ! echo "$1" | grep -qE '\S'
}

# Prints help to stdout.
function showHelp {
    echo -en "\e[0m" # reset
    echo -e "\e[1mUSAGE\e[0m"
    echo -e "    \e[1mulozto-download\e[0m \e[4murl\e[0m \e[4moutput-file\e[0m \e[4musername\e[0m \e[4mpassword\e[0m"
    echo -e
    echo -e "    Synchronously downloads a file from uloz.to. Exits only when the entire file has been downloaded" \
        "(if some problem"
    echo -e "    occurs, keeps trying again indefinitely). If the \e[4moutput-file\e[0m already exists, the program" \
        "automatically continues"
    echo -e "    the download (or exits immediately, if the file size is >= the remote file size)."
}

main
