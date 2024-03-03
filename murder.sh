#!/usr/bin/env bash

function print_usage() {
    echo "Usage: $(basename $0) [-p] <PROGRAM_NAME | PORT>"
}

function kill_process() {
    local match="$1"
    local pid=$(echo -n "$match" | awk '{ print $1 }')
    local cmd=$(echo -n "$match" | cut -d ' ' -f 2-)

    echo "Killing process $pid ('$cmd')"
    kill "$pid"
}

program_name="$1"
port="$2"

if [ -z "$program_name" ]; then
    print_usage
    exit 1
fi

# this is not the best way to do this at all, but it works and is far less
# complicated than making use of getopts, which I don't want to do unless
# I need more options in the future
if [ -z "$port" ] && [ "$program_name" = "-p" -o "$program_name" = "--port" ]; then
    print_usage
    exit 1
fi

results=""

if [ -n "$port" ]; then
    # use the lsof command to find a process that is listening on the given port
    results=$(
        lsof -i ":$port" -t |
            xargs -I{} ps -p {} -o 'pid,cmd=' --no-headers
    )

    # this is a bit of a hack to print the proper thing on errors
    program_name="$port"
else
    # get the processes that match for a word, meaning we won't select
    # processes that have the word in their name
    # we also filter out the grep process and this script itself
    results=$(
        ps ax -o 'pid,cmd=' --no-headers |
            grep -e "\\b$program_name\\b" |
            grep -vE '(grep|murder)'
    )
fi

# trim the results of any leading whitespace
matches=$(
    echo -n "$results" |
        sed 's/^ *//'
)

if [ -z "$matches" ]; then
    echo "No matches found for '$program_name'"
    exit 1
fi

match_count=$(echo -ne "$matches" | wc -l)

# we kill the first match because that's the whole point of this script
if [ $match_count -eq 0 ]; then
    kill_process "$matches"
    exit 0
fi

line_formatted=$(
    echo "$matches" | awk '{print "  " NR ". " $0 }'
)

echo -e "\nMultiple matches found for '$program_name':\n$line_formatted" && echo
read -p "Enter the number of the process you want to kill: " choice

if [ -z "$choice" ]; then
    echo "No choice provided, exiting..."
    exit 1
fi

# trim the choice of any whitespace
choice=$(echo -n "$choice" | tr -d '[:space:]')

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid choice provided, exiting..."
    exit 1
fi

# we add 1 to the match count because wc -l doesn't count the first line
# (e.g. "hello\nworld" would return 1)
if [ "$choice" -lt 1 -o "$choice" -gt $(($match_count + 1)) ]; then
    echo "Invalid choice provided, exiting..."
    exit 1
fi

kill_process "$(echo -n "$matches" | awk -v choice=$choice 'NR == choice { print $0 }')"
