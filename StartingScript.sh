#!/bin/bash

# disable the selinux
setenforce 0;
# turn up the nat port
ifup ens33;
# stop the firewall service
systemctl stop firewalld; systemctl disable firewalld; systemctl status firewalld | grep Active;
# disable the selinux at policy level
sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config;
getenforce
# Change Hostname SetHostname
read -p "Enter your Hostname: " Hostname
hostnamectl set-hostname "$Hostname";
su

