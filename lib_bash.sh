#!/bin/bash

#####################################################
#   This is a bash wanna-be bash library            #
#   ... more to come
#####################################################

#
#   Forget about a "two-spaces" tab. That almost
#   makes me puke.
#
#   Also forget about global variables
#

function _LB_Init()
{
    #
    #   Set default values to all
    #   the enviroment variables used
    #   by this script
    #
    
    declare -a _STDOUT_ARR_="/dev/stdout"
    export _LB_STDOUT_=$_STDOUT_ARR_
    export _LB_LOGLEVEL_="INFO"
    export _LB_LOGFACILITY_="DAEMON"
}

function _LB_Write_Log()
{
    #   where to?
    #   Who?
    
    #   The where:
    #   Default: STDOUT
    #   Variable: LB_WRITELOG

    local msg="DEBUG ${FUNCNAME[1]}"
    
    if [ ! -z $1 ]; then
        msg="$1"
    fi
    echo $(date +%F.%H:%M)" [$_LB_LOGFACILITY_][$_LB_LOGLEVEL_]: $msg" > $_LB_STDOUT_
}


function ok()
{
    if [ $# -ne 1 ]; then
        return 0
    fi
    

    echo "$_LB_STDOUT_"
    for l in "$1"
    do
        echo "$l"
    done
}

_LB_Init

ok "a b c"
