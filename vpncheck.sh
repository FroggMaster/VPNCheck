#!/bin/sh

# Define the name of the OpenVPN interface
INTERFACE="tun0"

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

# Define config file path
CONFIG_FILE="./config.ini"

# Get the connection script path from command line argument if provided
while getopts "c:" opt; do
    case ${opt} in
        c )
            CONNECTSCRIPT="$OPTARG"
            printf 'CONNECTSCRIPT="%s"\n' "$OPTARG" >> "$CONFIG_FILE"
            ;;
        \? )
            echo "Usage: $0 -c /path/to/connect.sh"
            exit 1
            ;;
    esac
done

# If no connection script is provided via command line argument, check the config file
if [ -z "$CONNECTSCRIPT" ]; then
    # Check if config file exists and read the connection script path from it
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
    fi
fi

# Prompt user for connection script path if not defined in config file or command line argument
if [ -z "$CONNECTSCRIPT" ]; then
    read -p "Please enter the path to the OpenVPN connection script: " CONNECTSCRIPT
    printf '%s\n' "CONNECTSCRIPT=$CONNECTSCRIPT" >> "$CONFIG_FILE"
fi

# Check if the OpenVPN connection script is executable
if ! [ -x "$CONNECTSCRIPT" ]; then
    echo -e "${YELLOW}$(date "$DATE_FORMAT") [${RED}ERROR${RESET}${YELLOW}]${RED} - The OpenVPN connection script at $CONNECTSCRIPT is not executable, please make it executable and try again.${RESET}"
    echo "$(date "$DATE_FORMAT") [ERROR] - The OpenVPN connection script at $CONNECTSCRIPT is not executable, please make it executable and try again." >> $LOGFILE

    exit 1
fi

# Check if another instance of this script is already running
if [ -f "$PIDFILE" ]; then
    echo -e "${YELLOW}$(date "$DATE_FORMAT") [${RED}ERROR${RESET}${YELLOW}]${RED} - Another instance of this script is already running, exiting...${RESET}"
    echo "$(date "$DATE_FORMAT") [ERROR] - Another instance of this script is already running, exiting..." >> $LOGFILE
    exit 1
fi

# Save the current process ID to a file
PIDFILE="./vpncheck.pid"
echo "$$" > "$PIDFILE"

# Check if OpenVPN is running on the specified interface
if ifconfig $INTERFACE &> /dev/null ; then
    # OpenVPN is running on the interface
    echo -e "${YELLOW}$(date "$DATE_FORMAT") [${GREEN}SUCCESS${RESET}${YELLOW}]${GREEN} - OpenVPN is running on $INTERFACE!${RESET}"
    echo "$(date "$DATE_FORMAT") [SUCCESS] - OpenVPN is running on $INTERFACE!" >> $LOGFILE
else
    # OpenVPN is not running on the interface
    echo -e "${YELLOW}$(date "$DATE_FORMAT") [${RED}ERROR${RESET}${YELLOW}]${RED} - OpenVPN is not running on $INTERFACE!${RESET}"
    echo "$(date "$DATE_FORMAT") [ERROR] - OpenVPN is not running on $INTERFACE!" >> $LOGFILE

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

# Remove PID file
rm "$PIDFILE"
