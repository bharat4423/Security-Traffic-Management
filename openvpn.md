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

</details>