
# OpenVPN Installation Process
<details>
<summary>Step 1: Install OpenVpn </summary> 

### Disable the selinux
```bash
setenforce 0;
sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config
```

### Change the Hostname
```bash
hostnamectl set-hostname openvpn
```
### Enable Ip_forwarding
```bash
# policy level
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
# run level using sysctl
sysctl -w net.ipv4.ip_forward=1
# using proc file system
echo 1 > /proc/sys/net/ipv4/ip_forward
# restart sysctl
sysctl -p
```

### Install the openvpn package
```bash
yum install -y epel-release
yum install -y openvpn
```
</details>

<details>
<summary>Step 2: Config OpenVpn </summary> 

### Nagivate to openvpn directory
```bash
cd /etc/openvpn
```

### Download EasyRSA package
```bash
wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz
```

### Extract EasyRSA package
```bash
tar -xvzf EasyRSA-unix-v3.0.6.tgz
```
### Rename EasyRSA directory
```bash
mv EasyRSA-v3.0.6 easy-rsa
```
### Navigate to easy-rsa repository 
```bash
cd /etc/openvpn/easy-rsa
```
### Then edit vars file using 
 vim vars
```bash
set_var EASYRSA                 "$PWD"
set_var EASYRSA_PKI             "$EASYRSA/pki"
set_var EASYRSA_DN              "cn_only"
set_var EASYRSA_REQ_COUNTRY     "INDIA"
set_var EASYRSA_REQ_PROVINCE    "Maharashtra"
set_var EASYRSA_REQ_CITY        "Pune"
set_var EASYRSA_REQ_ORG         "Vihaan Enterprises"
set_var EASYRSA_REQ_EMAIL       "admin@demo.lab"
set_var EASYRSA_REQ_OU          "Vihaan"
set_var EASYRSA_KEY_SIZE        2048
set_var EASYRSA_ALGO            rsa
set_var EASYRSA_CA_EXPIRE       7500
set_var EASYRSA_CERT_EXPIRE     365
set_var EASYRSA_NS_SUPPORT      "no"
set_var EASYRSA_NS_COMMENT      "Vihaan Enterprises"
set_var EASYRSA_EXT_DIR         "$EASYRSA/x509-types"
set_var EASYRSA_SSL_CONF        "$EASYRSA/openssl-easyrsa.cnf"
set_var EASYRSA_DIGEST          "sha256"
```
### command to initiate the PKI directory.
```bash
./easyrsa init-pki 
```
### build the CA certificates with the following command:
```bash
./easyrsa build-ca 

password: redhat 

client2
```
</details>
<details>
<summary> Step 3: Generate Server Certificate Files </summary>

### command to generate the server key named actsvpn :
```bash
./easyrsa gen-req actsvpn nopass
```
### Sign the Server Key Using CA
```bash
./easyrsa sign-req server actsvpn
```
### Verify the generated certificate file
```bash
openssl verify -CAfile pki/ca.crt pki/issued/actsvpn.crt
```
### Run the following command to generate a strong Diffie-Hellman key to use for the key exchange:
```bash
./easyrsa gen-dh
```
### After creating all certificate files, copy them to the 
/etc/openvpn/server/ directory:

```bash
cp pki/ca.crt /etc/openvpn/server/
cp pki/dh.pem /etc/openvpn/server/
cp pki/private/actsvpn.key /etc/openvpn/server/
cp pki/issued/actsvpn.crt /etc/openvpn/server/
```
## Generate Client Certificate and Key File 
### First,run the following command to build the client key file:
```bash
./easyrsa gen-req client nopass
```
### Next, sign the client key using your CA certificate:
```bash
./easyrsa sign-req client client
```
* yes
* password: redhat
```bash
# We create nopassword vihaan key
./easyrsa gen-req Vihaan nopass
```
```bash
./easyrsa sign-req client client
```
### Copy all client certificate and key file to the /etc/openvpn/client/ directory:
```bash
cp pki/ca.crt /etc/openvpn/client/
cp pki/issued/client.crt /etc/openvpn/client/
cp pki/private/client.key /etc/openvpn/client/
```
### Configure OpenVPN Server
vim /etc/openvpn/server/server.conf
```bash
port 1194
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/actsvpn.crt
key /etc/openvpn/server/actsvpn.key
dh /etc/openvpn/server/dh.pem
server 10.8.0.0 255.255.255.0
#push "redirect-gateway def1"
#push "dhcp-option DNS 208.67.222.222"
#push "dhcp-option DNS 208.67.220.220"
duplicate-cn
cipher AES-256-CBC
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256
auth SHA512
auth-nocache
keepalive 20 60
persist-keyi
persist-tun
compress lz4
daemon
user nobody
group nobody
log-append /var/log/openvpn.log
verb 3
```


### Start OpenVPN Service and 
```bash
systemctl start openvpn-server@server
systemctl status openvpn-server@server
```
### Configure Routing using Firewalld
```bash
firewall-cmd --permanent --add-service=openvpn
firewall-cmd --permanent --zone=trusted --add-service=openvpn
firewall-cmd --permanent --zone=trusted --add-interface=tun0
```
### For add the MASQUERADE on the default zone:
```bash
firewall-cmd --add-masquerade
firewall-cmd --permanent --add-masquerade
```
### Run the following command to masquerade the internet traffic coming from VPN network (10.8.0.0/24) to systems local network interface (eth0).
```bash
tecadmin=$(ip route get 8.8.8.8 | awk 'NR==1 {print   $(NF-2)}')
```
```bash
ip route get 8.8.8.8
```
```bash
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens33 -j MASQUERADE
firewall-cmd --reload
```
## Client Configuration on server machine 

#### Next, create a new OpenVPN client configuration file named client.ovpn. You will require this file to connect your OpenVPN server from the client system.
> `vim /etc/openvpn/client/client.ovpn`

```bash
client
dev tun
proto udp
remote 192.168.20.151 1194
ca ca.crt
cert client.crt
key client.key
cipher AES-256-CBC
auth SHA512
auth-nocache
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256
resolv-retry infinite
compress lz4
nobind
persist-key
persist-tun
mute-replay-warnings
verb 3
```
### To download config file from server:
```bash
scp -r /etc/openvpn/client/ root@192.168.20.170:/root
```
</details>
<details>
<summary> Step 4: Connect OpenVPN from Clients Machine </summary>

* First, log in to the client machine and install the OpenVPN package with the following command:

```bash
yum install epel-release -y
yum install openvpn -y
```
* Then go the window machine(host only adapter) and check machine Ip and ping centos client to windows hostonly IP.
### After Downloading run these commands to run OpenVPN server:
```bash
cd client
openvpn --config client.ovpn
```
### Then open new terminal on client mahcine do the folloing process
```bash
ip a
```


</details>



