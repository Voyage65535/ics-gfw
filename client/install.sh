#!/bin/bash

read -p 'Enter your shadowsocks and kcptun password: ' pwd
read -p 'Enter your server address: ' addr
sed -i "s/\"key\": \"\"/\"key\": \"${pwd}\"/g" dat/client-config.json
sed -i "s/\"password\": \"\"/\"password\": \"${pwd}\"/g" dat/config.json
sed -i "s/\"remoteaddr\": \":29900\"/\"remoteaddr\": \"${addr}:29900\"/g" dat/client-config.json

hash 'pip' >/dev/null 2>&1
if [ $? != 0 ]; then
    pkgmgr=('pacman' 'emerge' 'apt-get' 'dnf' 'yum' 'zypper' 'brew')
    pkgnam='python python-pip' # PACKAGE NAME UNTESTED!!!
    for i in ${pkgmgr[@]}; do
        hash $i >/dev/null 2>&1
        if [ $? == 0 ]; then
            case $i in #Ensure the pkgname is correct in your distro, or modify it.
                'pacman')
                    $i -S $pkgnam
                    ;;
                'emerge')
                    $i $pkgnam
                    ;;
                'apt-get' | 'dnf' | 'yum' | 'zypper' | 'brew')
                    $i install $pkgnam
                ;;
            esac
        fi
    done
fi
pip install shadowsocks

kcptun_ver='20170525'
ikrnl=`uname -s`
iarch=`uname -m`
case $ikrnl in
    'Linux')
        krnl='linux'
        ;;
    'FreeBSD' | 'GNU/kFreeBSD')
        krnl='freebsd'
        ;;
    'Darwin')
        krnl='darwin'
        ;;
    *)
        echo 'Unsupported platform!'
        exit 1
        ;;
esac
case $iarch in
    'i386' | 'i686')
        arch='386'
        ;;
    'amd64' | 'x86_64')
        arch='amd64'
        ;;
    'armv6l' | 'armv7l')
        if [ '$krnl' != 'linux' ]; then
            echo 'Unsupported platform!'
            exit 1
        fi
        arch='arm'
        ;;
    'mips')
        if [ '$krnl' != 'linux' ]; then
            echo 'Unsupported platform!'
            exit 1
        fi
        arch='mips'
        ;;
    'mipsel')
        if [ '$krnl' != 'linux' ]; then
            echo 'Unsupported platform!'
            exit 1
        fi
        arch='mipsle'
        ;;
    *)
        echo 'Unsupported platform!'
        exit 1
        ;;
esac
fname=kcptun-${krnl}-${arch}-${kcptun_ver}.tar.gz
uri=https://github.com/xtaci/kcptun/releases/download/v${kcptun_ver}/${fname}
wget $uri
mkdir tmp
tar zxf $fname -C tmp
mv tmp/client_${krnl}_${arch} /usr/bin/kcptun_client
rm -r tmp $fname
mkdir /etc/ics-gfw
cp dat/client-config.json /etc/ics-gfw
cp dat/config.json /etc/ics-gfw

mkdir -p /usr/lib/systemd/system
cp dat/shadowsocks.service /usr/lib/systemd/system
cp dat/kcptun.service /usr/lib/systemd/system
systemctl enable shadowsocks
systemctl enable kcptun
systemctl start shadowsocks
systemctl start kcptun

