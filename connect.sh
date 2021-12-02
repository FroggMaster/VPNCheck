#!/bin/sh
sudo openvpn --config $HOME/VPNCheck/Connection.ovpn --ping-restart 60
