#!/bin/bash

function Usage()
{
    printf "\npkill2 | Kill all <process-name> processes"
    printf "\n\nUsage: pkill [OPTION] <process-name>\n"
    printf "\n\t-h Print this message\n"
    printf "\n\t-r Kill in reverse order (pid-wise)\n\n"
}

if [ $# -lt 1 ]; then
    Usage
    exit 0
fi

name=""
mod=""
if [ $# -eq 1 ]; then
    name="$1"
else
    mod=$(echo "$1" | cut -c2)
    name="$2"
fi

#   Check if name is alphanumeeric only
#   Pending
#regex="[a-zA-Z]"
#expr match "$name" "$regex"


list=$(ps -A | grep -i "$name" | awk '{print $1}' | sort -n"$mod")

for svar in $list
do
    kill -s SIGKILL "$svar"
    echo "Killed $svar"
done
