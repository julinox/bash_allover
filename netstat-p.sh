#!/bin/bash

#################################################
#                                               #
#   Given a socket, check the pidd associated   #
#   i.e. do what 'netstat -p does               #
#                                               #
#################################################


#
#   Return codes
#   
#   -1      ->  Bad usage
#   -2      ->  Port is not a number
#   -3      ->  Port is not open
#   -4      ->  No sudo
#   x > 0   ->  pid
#

function IsSudo()
{
    uid=$(id -u)
    if [ $uid -ne 0 ]; then
        echo 1
        return
    fi
    echo 0
}

function IsNumber()
{
    # Check if given parameter is an actual
    # number (not a string)

    ret=0
    if [ $# -ne 1 ]; then
        echo 1
        return
    fi

    case $1 in
        '' | *[!0-9]*)
            ret=1 ;;
    esac
    echo $ret
}

function HexToInt()
{
    #
    #   Hexadecimal to Integer. No parameter checking
    #
    
    echo $((16#$1))
}

function LookPortInode()
{
    #
    #   Look if a specific port is open
    #   by checking the /proc/net/tcpX file
    #   and then get back its associated inode fd
    #
    #   $1  ->  Port wanted
    #   $2  ->  6 (to look for in /proc/net/tcp6)
    #
    
    i=0
    inode=-3
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo -1
        return
    fi

    if [ $# -eq 2 ] && [ $2 -ne 6 ]; then
        echo -1
        return
    fi

    #   $1 is number ?
    if [ $(IsNumber $1) -ne 0 ]; then
        echo -2
        return
    fi
    
    #   Looping throufh /proc/net/tcpX
    while read line
    do
        if [ $i -eq 0 ]; then
            i=1
            continue
        fi

        hexPort=$(echo $line | awk '{print $2}' | cut -d ":" -f 2)
        port=$(HexToInt $hexPort)
        
        if [ $port -eq $1 ]; then
            inode=$(echo $line | awk '{print $10}')
            break
        fi
    done <<< "$(cat /proc/net/tcp$2)"
    echo $inode
}

function GetPid()
{
    #
    #   Given an inode, find the 
    #   process associated to the inode
    #
    
    pid=-5
    inode=$1
    if [ $(IsSudo) -ne 0 ]; then
        echo -4
        return
    fi
    
    for i in $(ps axo pid); do
        ls -l /proc/$i/fd 2> /dev/null | grep -q ":\[$inode\]" \
        && pid=$i && break
    done
    echo $pid
}

inode=$(LookPortInode $@)
pid=$inode
if [ $inode -gt 0 ]; then
    pid=$(GetPid $inode)
fi
echo $pid
