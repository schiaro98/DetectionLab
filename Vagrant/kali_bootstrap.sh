#! /usr/bin/env bash
# shellcheck disable=SC1091,SC2129

# Script for a kali linux machine, inspired by logger of Detection Lab
export DEBIAN_FRONTEND=noninteractive
setxkbmap -option grp:alt_shift_toggle it # Set keyboard layout to Italian

# Override existing DNS Settings using netplan, but don't do it for Terraform AWS builds

sudo apt-get install -y netplan.io # Netplan is not installed by default on Kali

if ! curl -s 169.254.169.254 --connect-timeout 2 >/dev/null; then
	#echo -e "network:\n  version: 2\n  renderer: networkd\n  ethernets:\n      eth1:\n          dhcp4: true\n        nameservers:\n            addresses: [8.8.8.8,8.8.4.4]" >> /etc/netplan/01-netcfg.yaml
	netplan apply
fi

# Kill systemd-resolvd, just use plain ol' /etc/resolv.conf
systemctl disable systemd-resolved
systemctl stop systemd-resolved
rm /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
echo 'nameserver 192.168.56.102' >> /etc/resolv.conf

echo "apt-fast apt-fast/maxdownloads string 10" | debconf-set-selections
echo "apt-fast apt-fast/dlflag boolean true" | debconf-set-selections

missing_components() {
  sudo apt install -y software-properties-common # For basic utilities like add-apt-repository and much more...
  sudo touch /etc/apt/sources.list.d/apt-fast.list
  echo "deb http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main " >> /etc/apt/sources.list.d/apt-fast.list
  echo "deb-src http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main " >> /etc/apt/sources.list.d/apt-fast.list
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B
  sudo apt-get update
  #sudo apt-get -y upgrade # (TODO) Impiega parecchio tempo ~ 5 Minuti, valutare utiltà
  echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections; #Altrimenti richiede interattività
  sudo apt-get install -y apt-fast
  echo "apt-fast apt-fast/maxdownloads string 10" | debconf-set-selections
  echo "apt-fast apt-fast/dlflag boolean true" | debconf-set-selections
} 

apt_install_prerequisites() {
  echo "[$(date +%H:%M:%S)]: Adding apt repositories..."
  # Add repository for yq
  add-apt-repository -y ppa:rmescandon/yq 
  # Add repository for suricata
  add-apt-repository -y ppa:oisf/suricata-stable 
  # Install prerequisites and useful tools
  echo "[$(date +%H:%M:%S)]: Running apt-get clean..."
  apt-get clean
  echo "[$(date +%H:%M:%S)]: Running apt-get update..."
  apt-get -qq update
  echo "[$(date +%H:%M:%S)]: Using apt-fast to install packages..."
  apt-fast install -y whois build-essential git unzip htop mysql-server redis-server python3-pip libcairo2-dev  libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libssl-dev libvorbis-dev libwebp-dev tomcat9 tomcat9-admin tomcat9-user tomcat9-common net-tools
}
## jq yq my-sql-server libjpeg-turbo8-dev da reinstallare

test_prerequisites() {
  for package in jq whois build-essential git unzip yq mysql-server redis-server python3-pip; do
    echo "[$(date +%H:%M:%S)]: [TEST] Validating that $package is correctly installed..."
    # Loop through each package using dpkg
    if ! dpkg -S $package >/dev/null; then
      # If which returns a non-zero return code, try to re-install the package
      echo "[-] $package was not found. Attempting to reinstall."
      apt-get -qq update && apt-get install -y $package
      if ! which $package >/dev/null; then
        # If the reinstall fails, give up
        echo "[X] Unable to install $package even after a retry. Exiting."
        exit 1
      fi
    else
      echo "[+] $package was successfully installed!"
    fi
  done
}

fix_eth1_static_ip() {
  USING_KVM=$(sudo lsmod | grep kvm)
  if [ -n "$USING_KVM" ]; then
    echo "[*] Using KVM, no need to fix DHCP for eth1 iface"
    return 0  
  fi
  if [ -f /sys/class/net/eth2/address ]; then
    if [ "$(cat /sys/class/net/eth2/address)" == "00:50:56:a3:b1:c4" ]; then
      echo "[*] Using ESXi, no need to change anything"
      return 0
    fi
  fi
  # There's a fun issue where dhclient keeps messing with eth1 despite the fact
  # that eth1 has a static IP set. We workaround this by setting a static DHCP lease.
  if ! grep 'interface "eth1"' /etc/dhcp/dhclient.conf; then
    echo -e 'interface "eth1" {
      send host-name = gethostname();
      send dhcp-requested-address 192.168.56.110;
    }' >>/etc/dhcp/dhclient.conf
    netplan apply
  fi

  # Fix eth1 if the IP isn't set correctly
  ETH1_IP=$(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
  if [ "$ETH1_IP" != "192.168.56.110" ]; then
    echo "Incorrect IP Address settings detected. Attempting to fix."
    ip link set dev eth1 down
    ip addr flush dev eth1
    ip link set dev eth1 up
    ETH1_IP=$(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    if [ "$ETH1_IP" == "192.168.56.110" ]; then
      echo "[$(date +%H:%M:%S)]: The static IP has been fixed and set to 192.168.56.110"
    else
      echo "[$(date +%H:%M:%S)]: Failed to fix the broken static IP for eth1. Exiting because this will cause problems with other VMs."
      #exit 1
    fi
  fi

  # Make sure we do have a DNS resolution
  while true; do
    if [ "$(dig +short @8.8.8.8 github.com)" ]; then break; fi
    sleep 1
  done
}

postinstall_tasks() {
  # Ping DetectionLab server for usage statistics
  curl -s -A "DetectionLab-logger" "https:/ping.detectionlab.network/logger" || echo "Unable to connect to ping.detectionlab.network"
}



main() {
  missing_components
  apt_install_prerequisites
  test_prerequisites
  fix_eth1_static_ip
  postinstall_tasks
}

# Allow custom modes via CLI args
if [ -n "$1" ]; then
  eval "$1"
else
  main
fi
exit 0
