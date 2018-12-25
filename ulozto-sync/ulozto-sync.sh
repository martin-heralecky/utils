# Copyright (c) 2018 Martin Heralecký <heralecky.martin@gmail.com>
# License: MIT
# Usage: ulozto-sync

#!/bin/bash

ARGS=("$@")

# The program's entry point.
function main {
    loadOptions
    checkDependencies

    rm "$FILE_ORIGINAL" 2> /dev/null
    log "Downloading. URL: $ULOZTO_URL"
    ulozto-download "$ULOZTO_URL" "$FILE_ORIGINAL" "$ULOZTO_USERNAME" "$ULOZTO_PASSWORD" || die "Downloading"
    log "Download complete."

    rm "$FILE_ENCRYPTED" 2> /dev/null
    log "Encrypting."
    gpg -e -r "$GPG_RECIPIENT" -o "$FILE_ENCRYPTED" "$FILE_ORIGINAL" || die "Encrypting"
    log "Encryption complete."
    rm "$FILE_ORIGINAL" 2> /dev/null

    FILE_UPLOAD_NAME="`randString 8`"

    log "Uploading. File name: $FILE_UPLOAD_NAME"
    gdrive upload -p "$REMOTE_DIRECTORY" --name "$FILE_UPLOAD_NAME" "$FILE_ENCRYPTED" --timeout 0 || die "Uploading"
    log "Upload complete."
    rm "$FILE_ENCRYPTED" 2> /dev/null

    echo "$FILE_UPLOAD_NAME  $ULOZTO_URL" >> "$SIGNATURES_FILE"

    log "Synchronization complete."
}

# Loads options, including those from the configuration file. If program arguments are invalid or some required options
# are unavailable, prints error message or help and exits the program.
function loadOptions {
    CONFIG_FILE=~/.config/ulozto-sync
    FILE_ORIGINAL="/tmp/ulozto-sync.orig"
    FILE_ENCRYPTED="/tmp/ulozto-sync.enc"

    if [[ $1 == "-c" ]]; then
        CONFIG_FILE="${ARGS[1]}"
        ULOZTO_URL="${ARGS[2]}"
    else
        ULOZTO_URL="${ARGS[0]}"
    fi

    if isEmpty "$CONFIG_FILE" || isEmpty "$ULOZTO_URL"; then
        showHelp
        exit 1
    fi

    if [[ ! -f $CONFIG_FILE ]]; then
        echo "Configuration file ($CONFIG_FILE) does not exist."
        exit 1
    fi

    . "$CONFIG_FILE"

    if isEmpty "$ULOZTO_USERNAME" \
        || isEmpty "$ULOZTO_PASSWORD" \
        || isEmpty "$FILE_ORIGINAL" \
        || isEmpty "$GPG_RECIPIENT" \
        || isEmpty "$FILE_ENCRYPTED" \
        || isEmpty "$REMOTE_DIRECTORY" \
        || isEmpty "$SIGNATURES_FILE"; then
        echo "Invalid configuration file. Some variables are empty."
        exit 1
    fi
}

# Checks, whether all the required dependencies are available. If some are missing, prints error message and exists the
# program.
function checkDependencies {
    type ulozto-download &> /dev/null || die "Dependency ulozto-download not found."
    type gpg             &> /dev/null || die "Dependency gpg not found."
    type gdrive          &> /dev/null || die "Dependency gdrive not found."
}

# Returns 0, if $1's length is zero or consists of whitespace only. Otherwise returns 1.
# Params:
#   $1  Value to be tested.
function isEmpty {
    ! echo "$1" | grep -qP '\S'
}

# Generates a random string consisting of a-zA-Z0-9.
# Params:
#   $1  Length.
function randString {
    (cat /dev/urandom | base64 | tr -dc a-zA-Z0-9 | head -c "$1") 2> /dev/null
}

# Prints given message preceded by current time.
# Params:
#   $1  Message.
function log {
    local MESSAGE="`date +'[%d-%m-%Y %H:%M:%S]'` $1"
    echo "$MESSAGE"

    if ! isEmpty "$LOG_FILE"; then
        echo "$MESSAGE" >> "$LOG_FILE"
    fi
}

# Prints given error message and exits the program.
# Params:
#   $1  Message - reason for dying.
function die {
    log "ERROR: $1"
    exit
}

# Prints help to stdout.
function showHelp {
    echo -en "\e[0m" # reset
    echo -e "\e[1mUSAGE\e[0m"
    echo -e "    \e[1mulozto-sync\e[0m [options] \e[4murl\e[0m"
    echo -e
    echo -e "    Downloads a file from uloz.to, encrypts it and uploads to Google Drive under randomly generated name."
    echo -e
    echo -e "    \e[4mFILE_ORIGINAL\e[0m and \e[4mFILE_ENCRYPTED\e[0m are removed before and after the synchronization."
    echo -e
    echo -e "    If the synchronization was successful, appends the signature of the synced file to \e[4mFILE_ORIGINAL\e[0m."
    echo -e
    echo -e "\e[1mOPTIONS\e[0m"
    echo -e "    \e[1m-c\e[0m \e[4mfile\e[0m    Specifies the configuration file."
    echo -e "               optional, default: ~/.config/ulozto-sync"
    echo -e
    echo -e "\e[1mCONFIGURATION FILE\e[0m"
    echo -e "    Contains declaration of configuration variables. Is loaded via \`. <config-file>\`."
    echo -e
    echo -e "    \e[1mULOZTO_USERNAME\e[0m     Username for the uloz.to account."
    echo -e "                        required"
    echo -e "    \e[1mULOZTO_PASSWORD\e[0m     Password for the uloz.to account."
    echo -e "                        required"
    echo -e "    \e[1mFILE_ORIGINAL\e[0m       Location, where the original file will be stored."
    echo -e "                        optional, default: /tmp/ulozto-sync.orig"
    echo -e "    \e[1mFILE_ENCRYPTED\e[0m      Location, where the encrypted file will be stored."
    echo -e "                        optional, default: /tmp/ulozto-sync.enc"
    echo -e "    \e[1mGPG_RECIPIENT\e[0m       Recipient in context of the GnuPG encryption."
    echo -e "                        required"
    echo -e "    \e[1mREMOTE_DIRECTORY\e[0m    ID of the Google Drive directory where the encrypted file should be uploaded."
    echo -e "                        required"
    echo -e "    \e[1mSIGNATURES_FILE\e[0m     File containing signatures of the synced files."
    echo -e "                        required"
    echo -e "    \e[1mLOG_FILE\e[0m            File for logging."
    echo -e
    echo -e "\e[1mDEPENDENCIES\e[0m"
    echo -e "    \e[1mulozto-download\e[0m, \e[1mgpg\e[0m, \e[1mgdrive\e[0m"
    echo -e
    echo -e "    Enough disk space for both \e[4mFILE_ORIGINAL\e[0m and \e[4mFILE_ENCRYPTED\e[0m to be stored."
}

main
