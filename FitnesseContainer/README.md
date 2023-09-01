Fitnesse Container Create Docker Centos 7.9 container of Fitnesse to run under Systemd

    docker run -d -t -h slave -p 8080:80 --name slave --cap-add=NET_ADMIN --privileged=true centos:centos7.9.2009 /usr/sbin/init

    docker exec -it fitnesse /bin/bash

Download software 
    Fitness_standalone.jar release 20200501 http://fitnesse.org/FitNesseDownload

    Fitnesse Parameters http://fitnesse.org/FitNesse.UserGuide.AdministeringFitNesse.CommandLineArguments

Put the systemd file here

    Download from site http://www.fitnesse.org/FitNesseDownload to ~/downloads

install open JDK

    yum install java-1.8.0-openjdk

Create folders

    mkdir /apps 
    mkdir /apps/fitnesse
    mkdir /apps/fitnesse/logs 
    mkdir /apps/fitnesse/scripts/

create a fitness user and group

    groupadd fitnesse

    useradd -M -s /bin/bash -G fitnesse -d /apps/fitnesse fitnesse_user

Add your current login user to fitness group

    sudo usermod -a -G fitnesse {your user account}

docker cp fitnesse-standalone.jar slave:/apps/fitnesse

docker cp fitnesse.sh slave:/apps/fitnesse/scripts

logout... log back in to get group settings

Set file permissions

    chown -R root:fitnesse /apps/fitnesse

    chmod -R u+rwx,g+rwx /apps/fitnesse

    chmod 755 /apps/fitnesse/scripts/fitnesse.sh

Remove all other permissions

    chmod -R o-rwx /apps/fitnesse

Configure the systemd file
    
    docker cp fitnesse.service slave:/usr/lib/systemd/system/fitnesse.service

    chmod 664 /etc/systemd/system/fitnesse.service

Reboot startup

    systemctl enable fitnesse

    systemctl daemon-reload
