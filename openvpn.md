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

</details>



