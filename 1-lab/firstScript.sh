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
sudo useradd -m -d /home/u1 $u1
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
sudo usermod -s /usr/bin/mc $u1

# 12
u2='u2'
u2Passwd='87654321'
sudo useradd -m -d /home/u2 $u2
echo $u2':'$u2Passwd | sudo chpasswd 

# 13
mkdir /home/test13
cp work3.log /home/test13/work3-1.log
cp work3.log /home/test13/work3-2.log

# 14
g14='g14'
sudo groupadd $g14
sudo usermod -a -G $g14 $u1
sudo usermod -a -G $g14 $u2

chown u1:g14 /home/test13
chmod 770 /home/test13 # даем все права только u1, u2
chown u1:g14 /home/test13/*
chmod 640 /home/test13/* # u1, u2 должны уметь просматривать

# 15
mkdir /home/test14
# sticky-bit (см. лекцию Маятина)
chmod 1777 /home/test14

# 16
cp /usr/bin/nano /home/test14
chmod 777 /home/test14/nano # Если нет доступа к директории
# то мы всё ещё можем обратиться к файлам, зная их полный путь

# 17
mkdir /home/test15
touch /home/test15/secret_file
echo "Abas" > /home/test15/secret_file
chmod 666 /home/test15/secret_file

# 18
cat /etc/sudoers.d/u1 > sudo_u1_backup # файла нет
echo "u1 ALL=(root) /usr/bin/passwd" > /etc/sudoers.d/u1
# даем доступ только в /passwd
