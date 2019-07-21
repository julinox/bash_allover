#! /bin/sh
### BEGIN INIT INFO
# Provides:             wifi
# Required-Start:       $syslog $remote_fs
# Required-Stop:        $syslog $remote_fs
# Default-Start:        2 3 4 5
# Default-Stop:	        0 1 6
# Short-Description:    Starts and stops a wifi connection
# Description:          Starts and stops a wifi connection.
### END INIT INFO

# Author: Julio Garroz <jcgr@protonmail.com>
#
# A very simple replace (kind of) for network-manager, wicd and even
# the standar 'networking' script.

# PATH should only include /usr/* if it runs after the mountnfs.sh script
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# Script Variables
Ifname="wlan0"
Wsupplicant="wpa_supplicant"
Dhcpcli="dhclient"
Thiscript=/etc/init.d/wifi

# Load the VERBOSE setting and other rcS variables
[ -f /etc/default/rcS ] && . /etc/default/rcS

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

#
# Utils functions
#
assert()
{
    ERR_PARAMS=11
    ERR_ASSERT=13
	
    if [ $# -ne 1 ] && [ $# -ne 2 ]; then
        echo "MAL"
        return $ERR_PARAMS
    fi

    if [ ! $1 ]; then
        if [ $# -eq 2 ]; then
            log_failure_msg "$2"
        else
            log_failure_msg "Assert($1) failed"
        fi
        exit $ERR_ASSERT
    fi
}

set_ifname()
{
    # Default wlan interface (to connect) is wlan0
    # Enviroment variable 'WLAN_IFNAME' can be used
    # to overwrite the default interface name
    [ ! -z "$WLAN_IFNAME" ] && Ifname=$WLAN_IFNAME

    # Checking if interface exist 
    cat /proc/net/dev | grep -wq $Ifname
    assert "$? -eq 0" "Interface '$Ifname' unknow"
}

#
# Function that starts the daemon/service
#
do_start()
{
    set_ifname
    
    # Checking if wpa_supplicant is running
    ps aux | grep -i wpa_supplicant | grep -vq grep

    if [ $? -eq 0 ]; then
        log_warning_msg "wpa_supplicant allready running"
        return 1
    fi

    # Checking if wpa_supplicant is working
    $Wsupplicant -v 1> /dev/null
    assert "$? -eq 0" "wpa_supplicant missing"

    # Checking if dhclient is working
    $Dhcpcli --version 2> /dev/null
    assert "$? -eq 0" "dhclient missing"

    # launch it
    $Wsupplicant -i $Ifname -c /etc/wpa_supplicant.conf -B
    if [ $? -ne 0 ]; then
		log_failure_msg "Error starting wifi.sh"
		return 2
    fi
    dhclient $Ifname
    if [ $? -ne 0 ]; then
		log_failure_msg "dhclient error"
		return 3
    fi
    log_success_msg "Wifi Started"
}

#
# Function that stops the daemon/service
#
do_stop()
{
    $Dhcpcli -r $Ifname
    pkill wpa_supplicant
    log_success_msg "Wifi Stopped"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload()
{
	do_stop
	do_start
}

do_status()
{
	ps aux | grep -i wpa_supplicant | grep -vq grep
    if [ $? -ne 0 ]; then
        log_warning_msg "Wifi not running"
        return 1
    fi
    ps axo command | grep dhcl | grep -wq $Ifname
	if [ $? -ne 0 ]; then
        log_warning_msg "Wifi not running"
        return 1
    fi
    log_success_msg "Wifi Running"
}

case "$1" in
  start)
    do_start
    ;;
  stop)
    do_stop
    ;;
  restart|reload)
    do_reload
    ;;
  status)
	do_status
	;;
  *)
    echo "Usage: $Thiscript {start|stop|restart|force-reload|status}" >&2
    exit 3
    ;;
esac

:
