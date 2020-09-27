#!/bin/bash

function dec_to_bin
{
    #   decimal to binary
    #   Returns string
    #
    #   n numero, d dividendo, c cociente, r resto
    #   q = max { z E N | zq <= n }
    #   bin array
    
    #   Input Checking:
    #   - $1 >= 0
    #
    #   Returns a string

    case "$1" in
        ''|*[!0-9]*) return 1;;
    esac

    #   Euclidean Division
    local \
    n="$1"
    d=2
    bin=()

    c=$(($n/$d))
    r=$(($n%$d))
    bin+=("$r")

    while [ $c -gt 0 ]
    do
        n=$c
        c=$(($n/$d))
        r=$(($n%$d))
        bin+=("$r")
    done
    echo "${bin[@]}" | rev | tr -d ' '
    return 0
}

function bin_to_dec
{
    #   binary to decimal
    #   $1  string of bits (may be separated by blank spaces)
    #   Returns an integer
    
    #   Input checking:
    #   - string of bits

    case "$1" in
        (''|*[!0-1]*) return 1;;
    esac
    
    local bin=$(echo "$1" | tr -d ' ')
    echo "$((2#$bin))"
    return 0
}

function cidr_to_bitmask
{
    #   cidr notation to bitmask
    #   Input Checking:
    #   - 0 <= $1 <= 32
    #
    #   Returns a string

    case "$1" in
        (''|*[!0-9]*) return 1;;
    esac
    [[ $1 -gt 32 ]] && return 2
    
    local i=1
    local bin=()
    
    for i in {1..32};
    do
        if [ $i -le $1 ]; then
            bin+=("1")
        else
            bin+=("0")
        fi
    done
    echo "${bin[@]}" | tr -d ' '
    return 0
}

function bin_to_dot_decimal
{
    #   binary IP to dot-decimal notation
    #   Input checking:
    #   - string of bits
    #
    #   Returns a string

    local str=$(echo "$1" | tr -d ' ')
    case "$str" in
        (''|*[!0-1]*) return 1;;
    esac
    
    local size=${#str}
    if [ $size -ne 32 ]; then
        return 2
    fi

    local \
    byte1=$(bin_to_dec "${str::8}")
    byte2=$(bin_to_dec "${str:8:8}")
    byte3=$(bin_to_dec "${str:16:8}")
    byte4=$(bin_to_dec "${str:24:8}")
    
    echo "$byte1.$byte2.$byte3.$byte4"
    return 0
}

function dot_decimal_to_bin
{
    #   dot-decimal IP to binary
    #   Input checking:
    #   - dot-decimal IP notation
    #
    #   Returns a string
    
    local str="$1"
    [[ "$str" == '' ]] && return 1
    [[ ! "$str" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]] && return 2
    
    local \
    b1=$(dec_to_bin $(echo "$str" | cut -d . -f1 ))
    b2=$(dec_to_bin $(echo "$str" | cut -d . -f2 ))
    b3=$(dec_to_bin $(echo "$str" | cut -d . -f3 ))
    b4=$(dec_to_bin $(echo "$str" | cut -d . -f4 ))    
    printf "%08d%08d%08d%08d\n" "$b1" "$b2" "$b3" "$b4"
    return 0
}

function get_net_addr
{
    #   Calculate network addres given an IP/cidr
    #   Input checking:
    #   - dot-decimal IP notation
    #   - cidr notation
    
    local bin_ip="$(dot_decimal_to_bin $(echo $1 | cut -d '/' -f1))"
    local net_mask="$(echo "$1" | cut -d '/' -f2)"
    local bin_mask="$( cidr_to_bitmask $net_mask)"
    
    if [ -z "$bin_ip" ] || [ -z "$bin_mask" ]; then
        return 1
    fi

    local i=0
    local bin=()
    
    for i in {0..31};
    do
        r=$(( "${bin_ip:$i:1}" & "${bin_mask:$i:1}"))
        bin+=("$r")
    done
    
    local net_addr=$(bin_to_dot_decimal $(echo "${bin[@]}" | tr -d ' '))
    echo "$net_addr/$net_mask"
    return 0
}

function get_net_addr_first
{
    #   Calculate first address of given network
    #   Input checking:
    #   - dot-decimal IP notation
    #   - cidr notation
    
    local net=$(echo "$1" | cut -d '/' -f1)
    local cidr=$(echo "$1" | cut -d '/' -f2)

    local bin_ip="$(dot_decimal_to_bin $net)"
    if [ -z "$bin_ip" ]; then
        return 1
    fi
    
    local b1=$(echo "$net" | cut -d '.' -f4)
    local b2=$(echo "$net" | cut -d '.' -f4)
    local b3=$(echo "$net" | cut -d '.' -f4)
    local b4=$(echo "$net" | cut -d '.' -f4)
    local new_b4="$(( $b4 + 1 ))"
    echo "$b1.$b2.$b3.$new_b4"
}
