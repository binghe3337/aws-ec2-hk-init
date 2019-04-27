#!/bin/bash

if [ $UID -ne 0 ]; then
    echo 'Error: Please run as root user.'
    exit 1
fi
if [ ! -f "/etc/debian_version" ]; then
    echo 'Error: Just support for debian.'
    exit 1
fi

dpkg-reconfigure tzdata
dpkg-reconfigure locales

rm -rf /etc/apt/sources.list
cat <<EOF >/etc/apt/sources.list
deb http://cdn-aws.deb.debian.org/debian stretch main
deb http://security.debian.org/debian-security stretch/updates main
deb http://cdn-aws.deb.debian.org/debian stretch-updates main
EOF
chmod 644 /etc/apt/sources.list

apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove
apt-get -y install coreutils
apt-get -y install net-tools
apt-get -y install dnsutils
apt-get -y install xz-utils
apt-get -y install wget
apt-get -y install curl
apt-get -y install ca-certificates
apt-get -y install file
apt-get -y install grep
apt-get -y install gawk
apt-get -y install sed
apt-get -y install gzip
apt-get -y install libc-bin
apt-get -y install cpio
apt-get -y install openssl
apt-get -y install screen
apt-get -y install python python2.7 python-dev python-setuptools openssl libssl-dev curl wget unzip gcc automake autoconf make libtool
apt-get -y install locales
apt-get -y install git
apt-get -y install ethtool

Enable_Rc_Local()
{
systemctl stop rc-local
rm -rf /etc/rc.local
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
/bin/bash /root/custom_scripts/iptables/restore.sh
exit 0
EOF
chmod +x /etc/rc.local
systemctl start rc-local
systemctl status rc-local | grep -i active
echo "Success"
}
Enable_Rc_Local

mkdir -p /root/custom_scripts/iptables
cat <<EOF >/root/custom_scripts/iptables/save.sh
#!/bin/bash
iptables-save > /root/custom_scripts/iptables/ipt.save
EOF
chmod +x /root/custom_scripts/iptables/save.sh
cat <<EOF >/root/custom_scripts/iptables/restore.sh
#!/bin/bash
cat /root/custom_scripts/iptables/ipt.save | iptables-restore
EOF
chmod +x /root/custom_scripts/iptables/restore.sh
/bin/bash /root/custom_scripts/iptables/save.sh

wget --no-check-certificate -O /root/setup_sv.sh https://raw.githubusercontent.com/binghe3337/install-supervisor-new/master/setup_sv.sh
chmod +x /root/setup_sv.sh
/root/setup_sv.sh
rm -rf /root/setup_sv.sh

mkdir -p /root/custom_scripts/liuliang
wget --no-check-certificate -O /root/custom_scripts/liuliang/liuliang.py https://raw.githubusercontent.com/binghe3337/aws-ec2-hk-init/master/liuliang.py
echo '[program:liuliang]' > /etc/supervisor/relative/directory/liuliang.ini
echo 'command=/usr/bin/python /root/custom_scripts/liuliang/liuliang.py' >> /etc/supervisor/relative/directory/liuliang.ini
echo 'startsecs=1' >> /etc/supervisor/relative/directory/liuliang.ini
echo 'autostart=true' >> /etc/supervisor/relative/directory/liuliang.ini
echo 'user=root' >> /etc/supervisor/relative/directory/liuliang.ini
echo 'directory=/root/custom_scripts/liuliang' >> /etc/supervisor/relative/directory/liuliang.ini
echo ';environment=A="1",B="2"' >> /etc/supervisor/relative/directory/liuliang.ini
echo ';redirect_stderr=true' >> /etc/supervisor/relative/directory/liuliang.ini
echo ';stdout_logfile=/var/log/theprogramname.log' >> /etc/supervisor/relative/directory/liuliang.ini
service supervisord restart

