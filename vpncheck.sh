#!/bin/sh

# Define the name of the OpenVPN interface and the connection script
INTERFACE="tun0"
CONNECTSCRIPT="/path/to/connection/script.sh"

# Define the log file and maximum log size in MB
LOGFILE="./vpncheck.log"
MAXLOGSIZE=50

# Define date format
DATE_FORMAT='+%Y-%m-%d %H:%M:%S'

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Check if another instance of this script is already running
PIDFILE=./vpncheck.pid
if [ -f "$PIDFILE" ] && ps -p $(cat $PIDFILE) > /dev/null; then
    echo "Another instance of this script is already running, exiting..."
    exit 1
else
    echo $$ > $PIDFILE
fi

# Function to remove the PID file on exit
cleanup() {
    rm -f $PIDFILE
    exit
}
trap cleanup EXIT

# Check if OpenVPN is running on the specified interface
if ifconfig $INTERFACE &> /dev/null ; then
    # OpenVPN is running on the interface
    echo -e "${YELLOW}$(date "$DATE_FORMAT") [${GREEN}SUCCESS${RESET}${YELLOW}]${GREEN} - OpenVPN is running on $INTERFACE!${RESET}"
    echo "$(date "$DATE_FORMAT") [SUCCESS] - OpenVPN is running on $INTERFACE!" >> $LOGFILE
else
    # OpenVPN is not running on the interface
    echo -e "${YELLOW}$(date "$DATE_FORMAT") [${RED}FAILED${RESET}${YELLOW}]${RED} - OpenVPN is not running on $INTERFACE!${RESET}"
    echo "$(date "$DATE_FORMAT") [FAILED] - OpenVPN is not running on $INTERFACE!" >> $LOGFILE

    # Restart the connection
    echo "Restarting OpenVPN connection..."
    $CONNECTSCRIPT
fi

# Check the size of the log file and reset it if necessary
LOGSIZE=$(du -m $LOGFILE | cut -f1)
if [ $LOGSIZE -gt $MAXLOGSIZE ]; then
    echo "Resetting log file..."
    echo "" > $LOGFILE
fi
