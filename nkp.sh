#!/bin/bash

OUTPUT_DIR="nkp_help_output"
mkdir -p "$OUTPUT_DIR"

# Log file for any errors
ERROR_LOG="$OUTPUT_DIR/error.log"
: > "$ERROR_LOG"

# Function to crawl nkp commands recursively
crawl_help() {
    local CMD_PATH=("$@")   # full path of commands as array
    local CMD_STR="nkp ${CMD_PATH[*]}"
    local DIR_PATH="$OUTPUT_DIR/$(IFS=/; echo "${CMD_PATH[*]}")"
    mkdir -p "$DIR_PATH"

    local HELP_FILE="$DIR_PATH/help.txt"
    echo "📄 Saving help for: $CMD_STR"

    # Run help and save output
    $CMD_STR --help > "$HELP_FILE" 2>>"$ERROR_LOG"
    if [ $? -ne 0 ]; then
        echo "⚠️ Failed: $CMD_STR --help" >> "$ERROR_LOG"
        return
    fi

    # Extract subcommands from the "Available Commands:" section
    local SUBCOMMANDS=$(awk '/Available Commands:/{flag=1;next}/^$/{flag=0}flag' "$HELP_FILE" | awk '{print $1}')

    # Recurse for each subcommand
    for SUB in $SUBCOMMANDS; do
        # Skip empty or help
        if [[ -n "$SUB" && "$SUB" != "help" ]]; then
            crawl_help "${CMD_PATH[@]}" "$SUB"
        fi
    done
}

# Start from top-level
echo "Saving top-level help..."
nkp --help > "$OUTPUT_DIR/nkp_help.txt" 2>>"$ERROR_LOG"

# Get initial top-level commands
TOP_COMMANDS=$(awk '/Available Commands:/{flag=1;next}/^$/{flag=0}flag' "$OUTPUT_DIR/nkp_help.txt" | awk '{print $1}')

# Crawl each top-level command
for CMD in $TOP_COMMANDS; do
    crawl_help "$CMD"
done

echo "✅ Done. All help saved under: $OUTPUT_DIR"
echo "⚠️ Errors (if any) logged in: $ERROR_LOG"

