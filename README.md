# VPNCheck

VPNCheck is designed to initiate an OpenVPN connection and maintain that connection. 

## Installation

```bash
git clone https://github.com/FroggMaster/VPNCheck.git
```

## Usage
1) Defined your OVPN connection file in the CONNECTSCRIPT variable.
2) Configure a Crontab schedule to run VPNCheck
3) Wait for Crontab to initialize VPNCheck 

#### Crontab Schedule (Every 1 Minute)
```python
*/1 * * * * /bin/bash $HOME/VPNCheck/vpncheck.sh
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
