### 1. Выведите список всех подключенных репозитариев
https://stackoverflow.com/questions/8647454/how-can-i-get-a-list-of-repositories-apt-get-is-checking
```
apt-cache policy |grep http |awk '{print $2 "/" $3}'

http://deb.debian.org/debian/bookworm-updates/non-free-firmware
http://deb.debian.org/debian/bookworm-updates/main
http://security.debian.org/debian-security/bookworm-security/non-free-firmware
http://security.debian.org/debian-security/bookworm-security/main
http://deb.debian.org/debian/bookworm/non-free-firmware
http://deb.debian.org/debian/bookworm/main
```

### 2. Обновите локальные индексы пакетов в менеджере пакетов
```
apt update
```

### 3. Выведите информацию о метапакете build-essential
```
apt show build-essential
```

### 4. Установите метапакет build-essential, при этом определите какие компоненты будут установлены, а какие обновлены.
```
apt install build-essential

Будут установлены следующие дополнительные пакеты:
  binutils binutils-common binutils-x86-64-linux-gnu cpp cpp-12 dirmngr dpkg-dev
  fakeroot fontconfig-config fonts-dejavu-core g++ g++-12 gcc gcc-12 gnupg
  gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm
  libabsl20220623 libalgorithm-diff-perl libalgorithm-diff-xs-perl
  libalgorithm-merge-perl libaom3 libasan8 libassuan0 libatomic1 libavif15
  libbinutils libc-bin libc-dev-bin libc-devtools libc-l10n libc6 libc6-dev
  libcc1-0 libcrypt-dev libctf-nobfd0 libctf0 libdav1d6 libde265-0 libdeflate0
  libdpkg-perl libfakeroot libfile-fcntllock-perl libfontconfig1 libgav1-1
  libgcc-12-dev libgd3 libgomp1 libgprofng0 libheif1 libisl23 libitm1 libjbig0
  libjpeg62-turbo libksba8 liblerc4 liblsan0 libmpc3 libmpfr6 libnpth0 libnsl-dev
  libnuma1 libquadmath0 librav1e0 libstdc++-12-dev libsvtav1enc1 libtiff6
  libtirpc-dev libtsan2 libubsan1 libwebp7 libx265-199 libxpm4 libyuv0
  linux-libc-dev locales make manpages-dev patch pinentry-curses rpcsvc-proto
Предлагаемые пакеты:
  binutils-doc cpp-doc gcc-12-locales cpp-12-doc pinentry-gnome3 tor
  debian-keyring g++-multilib g++-12-multilib gcc-12-doc gcc-multilib autoconf
  automake libtool flex bison gdb gcc-doc gcc-12-multilib parcimonie xloadimage
  scdaemon glibc-doc libnss-nis libnss-nisplus git bzr libgd-tools
  libstdc++-12-doc make-doc ed diffutils-doc pinentry-doc
Следующие НОВЫЕ пакеты будут установлены:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential cpp cpp-12
  dirmngr dpkg-dev fakeroot fontconfig-config fonts-dejavu-core g++ g++-12 gcc
  gcc-12 gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server
  gpgconf gpgsm libabsl20220623 libalgorithm-diff-perl libalgorithm-diff-xs-perl
  libalgorithm-merge-perl libaom3 libasan8 libassuan0 libatomic1 libavif15
  libbinutils libc-dev-bin libc-devtools libc6-dev libcc1-0 libcrypt-dev
  libctf-nobfd0 libctf0 libdav1d6 libde265-0 libdeflate0 libdpkg-perl libfakeroot
  libfile-fcntllock-perl libfontconfig1 libgav1-1 libgcc-12-dev libgd3 libgomp1
  libgprofng0 libheif1 libisl23 libitm1 libjbig0 libjpeg62-turbo libksba8 liblerc4
  liblsan0 libmpc3 libmpfr6 libnpth0 libnsl-dev libnuma1 libquadmath0 librav1e0
  libstdc++-12-dev libsvtav1enc1 libtiff6 libtirpc-dev libtsan2 libubsan1 libwebp7
  libx265-199 libxpm4 libyuv0 linux-libc-dev make manpages-dev patch
  pinentry-curses rpcsvc-proto
Следующие пакеты будут обновлены:
  libc-bin libc-l10n libc6 locales
```

### 5. Найдите пакет, в описании которого присутствует строка «clone with a bastard algorithm»
```
apt search "clone with a bastard algorithm"

Им оказался bastet/stable
```

### 6. Скачайте в отдельную директорию в домашнем каталоге архив с исходными кодами найденного в п.5 пакета
```
mkdir /root/bastetSourceCode
cd /root/bastetSourceCode

apt-get source baster

# попросило скачать apt install dpkg-dev
```

### 7. Установите пакет из исходных кодов, скаченных в п.6
```
# Читаем README. Находим, что гайд на скачивание находится в файле INSTALL
# Скачиваем Prerequisites

apt install libboost-dev
apt install libncurses-dev
apt install libboost-program-options-dev # получал ошибку, что не хватает его

# make создаст исполняемый файл bastet, которого в принципе будет достаточно
# в инструкции также есть следующее:

make
cp bastet /usr/local/bin
chgrp games /usr/local/bin/bastet
chmod ugo+s /usr/local/bin/bastet
touch /var/games/bastet.scores2
chgrp games /var/games/bastet.scores2
chmod 664 /var/games/bastet.scores2
```
### 8. Если в конфигурационном файле пакета нет параметров установки пакета в систему, то добавьте их, так, чтобы пакет устанавливался в /usr/local/bin и на него назначались права ---rwxr-xr-x. Проверьте выполнения этих директив.
https://stackoverflow.com/questions/41645207/how-to-write-install-target-in-makefile

```
# добавляем в Makefile

install: $(PROGNAME)
    install -d /usr/local/bin
    install -m 0755 $(PROGNAME) /usr/local/bin/$(PROGNAME)

Далее:

make # Сбилдили
make install

root@d12:~/bastetSourceCode/bastet-0.43# ls -l /usr/local/bin/bastet 
-rwxr-xr-x 1 root root 693120 мар  1 13:36 /usr/local/bin/bastet
```

### 9. Проверьте, что любой пользователь может запускать установленный пакет, но не тратьте на это более 5 минут.
```
root@d12:~/bastetSourceCode/bastet-0.43# ls -l /usr/local/bin/bastet 
-rwxr-xr-x 1 root root 693120 мар  1 13:36 /usr/local/bin/bastet

# видим, что у всех лиц имеется x - Execute
```
### 10. Создайте файл task10.log, в который выведите список всех установленных пакетов.
https://losst.pro/spisok-ustanovlennyh-paketov-debian
```
dpkg --get-selections | grep -v deinstall > task10.log # берем non-matchin lines
```
### 11. Создайте файл task11.log, в который выведите список всех пакетов (зависимостей), необходимых для установки и работы компилятора gcc.
https://www.baeldung.com/linux/list-dependent-packages
```
apt install apt-rdepends

apt-rdepends gcc > task11.log
```

### 12. Создайте файл task12.log, в который выведите список всех пакетов (зависимостей), установка которых требует установленного пакета libgpm2.
```
apt-cache rdepends libgpm2 > task12.log
```

### 13. Создайте каталог localrepo в домашнем каталоге пользователя root и скопируйте в него c сайта http://snapshot.debian.org/package/htop/ пять разных версий пакета htop. Это можно сделать с помощью wget или просто передав файлы на виртуальную машину используя протокол ssh и утилиту scp.

```
mkdir /root/localrepo
cd /root/localrepo

wget https://snapshot.debian.org/archive/debian/20250209T210016Z/pool/main/h/htop/htop_3.3.0-5_amd64.deb
wget https://snapshot.debian.org/archive/debian/20250209T210016Z/pool/main/h/htop/htop_3.3.0-4_amd64.deb
wget https://snapshot.debian.org/archive/debian/20240117T150534Z/pool/main/h/htop/htop_3.3.0-3_arm64.deb
wget https://snapshot.debian.org/archive/debian/20240113T150425Z/pool/main/h/htop/htop_3.3.0-2_arm64.deb
wget https://snapshot.debian.org/archive/debian/20240110T210829Z/pool/main/h/htop/htop_3.3.0-1_arm64.deb
```
### 14. Сгенерируйте в каталоге репозитория файл Packages, который будет содержать информацию о доступных пакетах в репозитории и файл Создайте файл Release, содержащий описание репозитория.
https://www.baeldung.com/linux/apt-set-up-make-local-repository
```
apt-get install dpkg-dev

dpkg-scanpackages --multiversion . /dev/null > Packages # Делаем так, чтобы не игнорировали из-за того, что скачали уже самую новую версию

touch Release
chmoud 777 Release
nano Release

Origin: My Local Repo
Label: My Local Repo
Suite: stable
Version: 1.0
Codename: myrepo
Architectures: amd64
Components: main
Description: My local APT repository
```
### 15. Обновите кэш apt
```
echo "deb [trusted=yes] file:/root/localrepo ./" | tee /etc/apt/sources.list.d/localrepo.list
```
### 16. Выведите список подключенных репозитариях и краткую информацию о них.
```
apt-cache policy

file:/root/localrepo ./ Packages
     release v=1.0,o=My Local Repo,a=stable,n=myrepo,l=My Local Repo,c=
```
### 17. Создайте файл task16.log в который выведите список всех доступных версий htop
```
apt-cache policy htop > task16.log

Кандидат:   3.3.0-5
  Таблица версий:
     3.3.0-5 500
        500 file:/root/localrepo ./ Packages
     3.3.0-4 500
        500 file:/root/localrepo ./ Packages
```
### 18. Установите предпоследнюю версию пакета
```
apt install htop=3.3.0-4

Пол:1 file:/root/localrepo ./ htop 3.3.0-4 [163 kB] # Скачивает из localrepo
```
### 19. Скачайте из сетевого репозитория пакет nano. Пересоберите пакет таким образом, чтобы после его установки, появлялась возможность запустить редактор nano из любого каталога, введя команду newnano. Для работы с пакетом следует использовать dpkg-deb, а для установки dpkg. В файле протокола работы опишите использованные команды.
https://www.baeldung.com/linux/package-deb-change-repack
https://losst.pro/sozdanie-deb-paketov
https://man.archlinux.org/man/dpkg.1.en

```
apt download nano
mkdir newnanoSource

# распаковываем скачанный deb-пакет
dpkg-deb -R nano_7.2-1+deb12u1_amd64.deb newnanoSource

# Далее, нужно будет сделать так, чтобы после того, как мы установили данный пакет, создлось /usr/bin/newnano, которая является лишь софт-ссылкой на nano

nano DEBIAN/postinst
# Добавить строку ln -s /usr/bin/nano /usr/bin/newnano

# Билдим пакет
dpkg-deb -b newnanoSource newnano.deb

# Качаем
dpkg -i newnano.deb
```
### 20. Бонусный вопрос с подвохом - что есть в APT?
https://www.baeldung.com/linux/package-deb-change-repack
```
# По приколу сделаем так:

apt download apt
dpkg-deb -R apt_2.6.1_amd64.deb aptCheck

# Там можно изучить, зная из чего состоит пакет, что происходит при его установке (см. линку и инет, из чего состоит разархивированный пакет)

И еще, в APT есть коровья суперсила!!!
Смотрим apt-get
https://unix.stackexchange.com/questions/92185/whats-the-story-behind-super-cow-powers

root@d12:/# apt-get moo
                 (__) 
                 (oo) 
           /------\/ 
          / |    ||   
         *  /\---/\ 
            ~~   ~~   
..."Have you mooed today?"...
```
