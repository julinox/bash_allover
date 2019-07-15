#! /bin/sh
### BEGIN INIT INFO
# Provides:          	wifi
# Required-Start:	$network
# Required-Stop:	$network
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	Starts and stops a wifi connection
# Description:       	Starts and stops a wifi connection.
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
	#WLAN_IFNAME="ve"
	# Default wlan interface (to connect) is wlan0
	# Enviroment variable 'WLAN_IFNAME' can be used
	# used to overwrite default interface name
	[ ! -z "$WLAN_IFNAME" ] && Ifname=$WLAN_IFNAME
	
	# Checking if interface exist | Also assuming /sys
	# directory is mounted
	ls /sys/class/net | grep -wq $Ifname
	assert "$? -eq 0" "Interface '$Ifname' unknow"
}

#
# Function that starts the daemon/service
#
do_start()
{
	set_ifname
	# Checking if wpa_supplicant is runnuing
	ps aux | grep -i wpa_supplicant | grep -vq grep
	
	if [ $? -eq 0 ]; then
		log_warning_msg "wpa_supplicant allready running"
		#return 1
	fi
	
	# Checking if wpa_supplicant is working
	$Wsupplicant -v 1> /dev/null
	assert "$? -eq 0" "wpa_supplicant missing"
	
	# Checking if dhclient is working
	$Dhcpcli --version 2> /dev/null
	assert "$? -eq 0" "dhclient missing"

	# launch it
	echo "Conecta a: $Ifname"
}

#
# Function that stops the daemon/service
#
do_stop()
{
	Return 0
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	#start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
	#RETVAL="$?"
	#[ "$RETVAL" = 2 ] && return 2
	# Wait for children to finish too if this is a daemon that forks
	# and if the daemon is only ever run from this initscript.
	# If the above conditions are not satisfied then add some other code
	# that waits for the process to drop all resources that could be
	# needed by services started subsequently.  A last resort is to
	# sleep for some time.
	#start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
	#[ "$?" = 2 ] && return 2
	# Many daemons don't delete their pidfiles when they exit.
	#rm -f $PIDFILE
	#return "$RETVAL"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
	#
	# If the daemon can reload its configuration without
	# restarting (for example, when it is sent a SIGHUP),
	# then implement that here.
	#
	#start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
	return 0
}

case "$1" in
  start)
	do_start
	;;
  stop)
	echo "Case Stop"
	#do_stop
	;;
  restart|reload)
	#log_daemon_msg "Restarting $DESC" "$NAME"
	#do_stop
	echo "Case Restart/Reload"
	;;
  status)
	#status_of_proc -p $PIDFILE $DAEMON $NAME && exit 0 || exit $?
	echo "Caxse Status"
	;;
  *)
	echo "Usage: $Thiscript {start|stop|restart|force-reload|status}" >&2
	exit 3
	;;
esac

:
