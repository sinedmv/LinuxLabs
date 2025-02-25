## 1
```
fdisk /dev/sdb
n
p

+500M
w
```
## 2
```
blkid /dev/sdb1 > /root/SecondTask.txt
```
## 3
```
mke2fs -t ext4 -b 4096 /dev/sdb1
```
## 4
```
dumpe2fs /dev/sdb1 > /root/FourthTask.txt
```
## 5
```
tune2fs -c 2 -i 2m /dev/sdb1
```
## 6
```
mkdir /mnt/newdisk
mount /dev/sdb1 /mnt/newdisk
```
## 7
```
ln -s /mnt/newdisk /root/newdiskSymbolicLink
```
## 8
```
mkdir /mnt/newdisk/abas
```
## 9
https://losst.pro/avtomaticheskoe-montirovanie-fstab-i-systemd
```
# Заходим в /etc/fstab
nano /etc/fstab

# Вставляем следующее:
/dev/sdb1 /mnt/newdisk ext4 noexec,noatime 0 2
# (см. ссылку)

# Проверим с помощью того, что создадим .sh-файл и попытаемся его выполнить

stat <file> оставляет поле "Доступ" таким же
```

## 10
https://www.dmosk.ru/miniinstruktions.php?mini=expand-linux-disk
```
# Отмонтируем раздел
umount /dev/sdb1

# Могут остаться процессы

lsof -w /dev/sdb1
# Убиваем

fdisk /dev/sdb
: p
: d # Удаляем. Но данные сохранятся
: 1

: n
: p
: 1
: 1G
```

## 11
```
e2fsck -n /dev/sdb1

# Ошибки есть. Разнящиеся значения в суперблоке
```
## 12
https://man.archlinux.org/man/tune2fs.8.en
```
fdisk /dev/sdb
: n
: 2
:
: +12M
: w

mkfs.ext4 /dev/sdb2
tune2fs -J device=/dev/sdb2 /dev/sdb1
```
## 13
https://habr.com/ru/articles/67283/
```
apt install lvm2

fdisk /dev/sdc
fdisk /dev/sdd # Соглашаемся на всё, так автоматом создастся партиция, которая занимает всё пространство

pvcrate /dev/sdc1 /dev/sdd1 # Создаем физические тома
```

# 14
```
vgcreate newVolumeGroup /dev/sdc1 /dev/sdd1
lvcreate -i 2 -l 100%FREE -n newLogicalVolume newVolumeGroup
mkfs.ext4 /dev/newVolumeGroup/newLogicalVolume
```
## 15
```
mkdir /mnt/vol01
mount /dev/newVolumeGroup/newLogicalVolume /mnt/vol01

# в /etc/fstab
/dev/newVolumeGroup/newLogicalVolume  /mnt/vol01 ext4 defaults 0 2
```

## 16
```
pvdisplay
vgdisplay
lvdisplay
```
![Первая](Pasted%20image%2020250222184425.png)

![Вторая](Pasted%20image%2020250222184450.png)

![Третья](Pasted%20image%2020250222184506.png)
## 17
https://www.sim-networks.com/ru/kb/add-disk-space-linux-server-lvm-debian
```
fdisk /dev/sde

vgextend newVolumeGroup /dev/sde1
lvextend -l +511 /dev/newVolumeGroup/newLogicalVolume --stripes 1 # добавляем кол-во свободных PE (Physical Extend) из vgdisplay 
```
## 18
```
# чтобы не отмонтировать всё, надо через другую команду, чем ранее

resize2fs /dev/newVolumeGroup/newLogicalVolume
```

## 19
```
pvdisplay
vgdisplay
lvdisplay 
```

## 20
https://help.ubuntu.ru/wiki/nfs
```
# качаем Network File System
apt install nfs-kernel-server 
systemctl enable nfs-server 
systemctl start nfs-server
```

## 21
```
# нужно дать доступ в /etc/exports
/mnt/vol01 10.0.2.0/24(rw,sync)

systemctl restart nfs-server
```

## 22
```
# На стороне Client

apt install nfs-common
mkdir /var/remotenfs
mount -t nfs 10.0.2.15:/mnt/vol01 /var/remotenfs
```

## 23
```
echo "Abas" > /mnt/vol01/test.txt

ls /var/remotenfs
cat /var/remotenfs/test.txt # и проверить
```

## 24
```
stat /var/remotenfs/test.txt
```
## 25
```
ln /var/remotenfs/test.txt /var/remotenfs/hardlink.txt

ln -s /var/remotenfs/test.txt /var/remotenfs/softlink.txt

stat /var/remotenfs/test.txt # Кол-во ссылок с hardlink.txt одинаковое, т.к. действительно, ссылается на ту же INode
stat /var/remotenfs/hardlink.txt # INode одинакова с test.txt. 
stat /var/remotenfs/softlink.txt # Создает новую INode
# Заметим, что ссылается на тот же блок
# Но тип файла разный
# SoftLink видим тип файла символьная ссылка
# Также, отличаются размеры файла
```
