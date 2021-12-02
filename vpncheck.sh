#!/bin/bash
## Script designed to check if OpenVPN has failed and re-run the connection script
## Frog / Domenico Costanzo
## Possible CRON Job: */1 * * * * /bin/bash $HOME/VPNCheck/vpncheck.sh > $HOME/VPNCheck/logs/cron.log

## Define Variables
## The Date (Year-Month-Day / Hour-Minute-Second)
Date=`date "+%a %b %d %H:%M:%S %Y %Z"`
## Grep to verify if tun0 is found -cs outputs a 0 or 1 depending on if match is found
TunnelStatus=$(ifconfig|grep -cs tun0)
## PID / LOCK File
PIDFILE=$HOME/VPNCheck/vpncheck.pid
## COLORS
reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

## Cleanup TPUT From Logs
## When TPUT is outputted in the logs, the color cods are present
## In addition to this, sgr0 output is also displayed, the below SED command will clear this from the                           logs
cleanup_tput() {
  sed -i 's/\x1b\[[0-9;]*m\|\x1b[(]B\x1b\[m//g' ./logs/vpncheck.log
}

## Trap to Cleanup if manually terminated
## When manually terminated if there is no TRAP the PID file does not always get cleaned up.
trap "{ rm $PIDFILE > /dev/null 2>&1; }" SIGINT

if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo $Date "| ${yellow}WARN:${reset} VPNCheck Process already running"| tee -a ./logs/vpncheck.log                           && $(cleanup_tput)
        if [[ $TunnelStatus == 1 ]]
        then
                        ## Catpured the number of dropped packets and assign it to a variable
                        ## Using GREP and Regex to filter ifconfig on tun0
                        dpc=`ifconfig|grep -i tun0 -A 8|grep -i TX|grep -oP "dropped [\d]+"|grep -oP "                          [\d]+"`
            if [[ $dpc -ge 100 ]]; then
                                echo $Date "| ${red}ERROR:${reset} Dropped packets are currently at ${                          red}$dpc${reset}"| tee -a ./logs/vpncheck.log && $(cleanup_tput)
                                echo $Date "| ${yellow}WARN:${reset} Attempting reconnect to VPN" | te                          e -a ./logs/vpncheck.log && $(cleanup_tput)
                                echo $Date "| ${yellow}WARN:${reset} Killing OpenVPN connections" | te                          e -a ./logs/vpncheck.log && $(cleanup_tput)
                                sudo killall openvpn
                                $HOME/VPNCheck/connect.sh | tee -a ./logs/vpncheck.log
                        else
                                echo $Date "| ${green}SUCCESS:${reset} OpenVPN Tunnel on tun0 is conne                          cted! =D Huzzah!" | tee -a ./logs/vpncheck.log && $(cleanup_tput)
                                find $HOME/VPNCheck/logs/vpncheck.log -size +50M -delete > /dev/null 2                          >&1;
                                exit 0
                        fi
        fi
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo $Date "| ${red}ERROR:${reset} Could not create PID file" | tee -a ./logs/vpncheck.log && $(                          cleanup_tput)
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo $Date "| ${red}ERROR:${reset} Could not create PID file" | tee -a ./logs/vpncheck.log && $(cl                          eanup_tput)
    exit 1
  fi
fi

## Check to see if tunnel is running, if not restart the tunnel
## If the tunnel is running log this attempt then review the log, if it's over 50MB remove the log
if [[ $TunnelStatus == 0 ]]
then
        echo $Date "| ${red}ERROR:${reset} tun0 is not connected. ;~ ;" | tee -a ./logs/vpncheck.log &                          & $(cleanup_tput)
        echo $Date "| ${yellow}WARN:${reset} Attempting reconnect to VPN" | tee -a ./logs/vpncheck.log                           && $(cleanup_tput)
        $HOME/VPNCheck/connect.sh | tee -a ./logs/vpncheck.log
else
        echo $Date "| ${green}SUCCESS:${reset} OpenVPN Tunnel on tun0 is connected! =D Huzzah!" | tee                           -a ./logs/vpncheck.log && $(cleanup_tput)
        find $HOME/VPNCheck/logs/vpncheck.log -size +50M -delete > /dev/null 2>&1;
        exit 0
fi

## Cleanup the PID File
## Runs on SIGINT HARD but there is a TRAP above just incase
## When manually terminated if there is no TRAP the PID file does not always get cleaned up.
rm $PIDFILE > /dev/null 2>&1;
