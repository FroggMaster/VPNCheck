# VPNCheck

VPNCheck is designed to initiate an OpenVPN connection and maintain that connection.

Well I would love to rely on the built-in OpenVPN method to maintain a connection I've found it to be unreliable; This is my solution to that problem. 

## Installation

```bash
git clone https://github.com/FroggMaster/VPNCheck.git
```

## Usage
1) Define your OVPN connection file in the CONNECTSCRIPT variable.
2) Configure a Crontab schedule to run VPNCheck
3) Wait for Crontab to initialize VPNCheck 

#### Crontab Schedule (Every 1 Minute)
```python
*/1 * * * * /bin/bash $HOME/VPNCheck/vpncheck.sh
```
#### Debug Crontab Schedule (Every 1 Minute + STDERR and STDOUT)
```python
*/1 * * * * cd $HOME/VPNCheck ; $HOME/VPNCheck/vpncheck.sh >> $HOME/VPNCheck/cronlog.log 2>&1
```

# Example OVPN
```
# Linux Open VPN Connection File
# Example Connection File

# Configuration Settings
client
dev tun
proto udp4
remote <IP> <PORT>
nobind
persist-key
persist-tun
remote-cert-tls server
auth-nocache
verb 4
float
tun-mtu 1500
auth SHA256
cipher AES-256-CBC


# Certificates
<ca>
-----BEGIN CERTIFICATE-----
<Insert Your CA CERT>
-----END CERTIFICATE-----
</ca>

<cert>
-----BEGIN CERTIFICATE-----
<Insert Your Client CERT>
-----END CERTIFICATE-----
</cert>

<key>
-----BEGIN PRIVATE KEY-----
<Insert Your Client Private Key>
-----END PRIVATE KEY-----
</key>
```
