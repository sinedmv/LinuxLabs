#!/bin/bash

./deleteResultOfTheFirstLab.sh

# 1
echo '1)' >> work3.log

echo 'Users and UIDs:' >> work3.log
awk -F":" '{print "user " $1 " has id " $3}' /etc/passwd >> work3.log


# 2
echo '2)' >> work3.log

echo 'Last time when root`s password was changed:' >> work3.log
passwd root -S | awk '{print $3}' >> work3.log

# 3
echo '3)' >> work3.log

echo 'All groups:' >> work3.log
awk -F":" '{print $3}' /etc/group | paste -s -d',' >> work3.log

# 4
echo 'Be careful!!!!' > /etc/skel/readme.txt

# 5
u1='u1'
u1Passwd='12345678'
sudo useradd $u1
echo $u1':'$u1Passwd | sudo chpasswd 

# 6
g1='g1'
sudo groupadd $g1

# 7
sudo usermod -a -G $g1 $u1

# 8
echo '8)' >> work3.log
id $u1 >> work3.log

# 9
myUser='myuser'
sudo usermod -a -G $g1 $myUser

# 10
echo '10)' >> work3.log
grep 'g1' /etc/group | awk -F":" '{print $4}' >> work3.log

# 11

# 12
u2='u2'
u2Passwd='87654321'
sudo useradd $u2
echo $u2':'$u2Passwd | sudo chpasswd 

# 13
mkdir /home/test13
cp work3.log /home/test13/work3-1.log
cp work3.log /home/test13/work3-2.log

