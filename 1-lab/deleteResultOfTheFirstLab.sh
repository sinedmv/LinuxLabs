#!/bin/bash


if id -u u1 &>/dev/null; then # черная дыра
    sudo pkill -u u1
    sudo userdel -r u1 # удаляем также домашний каталог
    echo "Deleted user u1 and their home directory"
else
    echo "User u1 does not exist"
fi

if id -u u2 &>/dev/null; then
    sudo pkill -u u2
    sudo userdel -r u2
    echo "Deleted user u2 and their home directory"
else
    echo "User u2 does not exist"
fi

if grep -q "g1:" /etc/group; then # Нашли или нет
    sudo groupdel g1
    echo "Deleted group g1"
else
    echo "Group g1 does not exist"
fi

if grep -q "g14:" /etc/group; then # Нашли или нет
    sudo groupdel g14
    echo "Deleted group g14"
else
    echo "Group g1 does not exist"
fi

if [ -d "/home/test13" ]; then
    sudo rm -rf /home/test13 # recursive-force
    echo "Deleted directory /home/test13"
else
    echo "Directory /home/test13 does not exist"
fi

if [ -d "/home/test14" ]; then
    sudo rm -rf /home/test14
    echo "Deleted directory /home/test14"
else
    echo "Directory /home/test14 does not exist"
fi

if [ -d "/home/test15" ]; then
    sudo rm -rf /home/test15
    echo "Deleted directory /home/test15"
else
    echo "Directory /home/test15 does not exist"
fi

if [ -f "work3.log" ]; then
    sudo rm work3.log
    echo "Deleted file work3.log"
else
    echo "File work3.log does not exist"
fi

if [ -f "/etc/sudoers.d/u1" ]; then
    sudo rm /etc/sudoers.d/u1
    echo "Deleted sudo configuration file for u1"
else
    echo "Sudo configuration file for u1 does not exist"
fi

if [ -f "sudo_u1_backup" ]; then
    sudo rm sudo_u1_backup
    echo "Deleted backup sudo configuration file for u1"
else
    echo "Backup sudo configuration file for u1 does not exist"
fi
