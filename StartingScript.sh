#!/bin/bash
# disable the selinux
setenforce 0;

# turn up the nat port
ifup ens33;
echo "IP Address Status: " `ens`
ip a | grep ens

# stop the firewall service
systemctl stop firewalld; systemctl disable firewalld; systemctl status firewalld | grep Active;

echo "Firewall Status : " `systemctl status firewalld | grep Active`
# disable the selinux at policy level
sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config;

echo " SELINUX Status : " `getenforce`
# Change Hostname SetHostname
read -p "Enter your Hostname: " Hostname
hostnamectl set-hostname "$Hostname";
su
