Номер ИСУ заканчивается на 69.
## Литература
- [cgroups и namespaces в Linux: как это работает?](https://habr.com/ru/companies/otus/articles/858780/)
- [Control Group v2, Kernel Documentations](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html)
- [Как работают файловые системы Linux-контейнеров](https://habr.com/ru/companies/flant/articles/862252/)
- [Overlay Filesystem](https://docs.kernel.org/filesystems/overlayfs.html#whiteouts-and-opaque-directories)
- [Taskset](https://man.archlinux.org/man/taskset.1)
## 1. Квоты на процессор для конкретного пользователя (cgroups v2)
### Создайте пользователя: user-ID
```
useradd user-69
```
### Назначьте квоту процессора на основе номера пользователя
```
mkdir /sys/fs/cgroup/task1 # Создаем cgroup под пользователя

echo "50000 100000" | tee /sys/fs/cgroup/task1/cpu.max # Даем квоту в микросекундах для группы

# И тут я не нашел, как сделать так, чтобы именно процессы пользователя автоматом вставлялись в группу
```

### Решение через systemctl
```
systemctl set-proprerty user-"(id user-69)".slice CPUQuota=50%
# Перед этим нужно запустить какой-то процесс. Иначе не создастся slice
https://unix.stackexchange.com/questions/466335/systemctl-set-property-user-1009-slice-cpuquota-50-failed-to-set-unit-prope
```
### Решение через "демона"
```
#!/bin/bash

CGROUP_PATH="/sys/fs/cgroup/user-69"
USERNAME="user-69"

while true; do
    PROCESSES=$(ps -u "$USERNAME" -o pid=)
    for PID in $PROCESSES; do
        if [ -d "/proc/$PID" ]; then
            echo "$PID" | tee "$CGROUP_PATH/cgroup.procs" > /dev/null
        fi
    done
done
```

## 2. Ограничение памяти для процесса (cgroups)
### Создайте cgroup для ограничения памяти, потребляемой процессом.
```
mkdir /sys/fs/cgroup/task2
```
### Ограничьте потребление памяти следующим образом: ID * 10 + 500 МБ
```
69 * 10 + 500
echo $((1190*1024*1024)) | tee /sys/fs/cgroup/task2/memory.max
```
### Запустите процесс и переместите его в созданную вами группу.
```
# будем использовать cgexec -g <контроллеры>:<группа> <команда>

cgexec -g memory:task2 tail /dev/zero
```
### Проверьте, что при исчерпании памяти процессом он прерывается ОС.
```
Смотрим journalctl -e (смотрим с конца)
мар 22 10:00:55 d12 kernel: Out of memory: Killed process 2039 (tail) 
```

## 3. Ограничение дискового ввода-вывода для сценария резервного копирования (cgroups)
```
apt-get install fio # Качаем для теста

mkdir /sys/fs/cgroup/task3 # Создаем группу для ограничения I/O
# Можно сделать через cgcreate, указав определенные контроллеры. Нужен только io

echo "+io" | tee /sys/fs/cgroup/cgroup.subtree_control # Добавляем контроллер I/O (у меня его не было)

echo "8:0 riops=1690 wiops=1190" | tee /sys/fs/cgroup/task3/io.max # см. Литература 2, найти riops, wiops

# Проверка
# Создаем backup.sh
#!/bin/bash

fio --name=backup --filename=./testfile --rw=randrw --bs=4k --size=100M --runtime=10 --time_based --ioengine=libaio --direct=1

cgexec -g io:task3 ./backup.sh
Видим, какую статистику показывает программа за свою жизнь. И дим, что IOPS не превышает назначенных
```

## 4. Закрепление к определенному ядру процессора для приложения
```
mkdir /sys/fs/cgroup/task4
echo "+cpuset" | tee /sys/fs/cgroup/cgroup.subtree_control # Добавляем cpuset (см. вторая литература)

echo "0" | tee /sys/fs/cgroup/task4/cpuset.cpus

# Проверка
top &
taskset -p 4106 # Можно также через cgexec
pid 4106's current affinity mask: 1 # Почему 1? Написано, что 1 -> процессор #0 https://man.archlinux.org/man/taskset.1

```
## 5. Динамическая корректировка ресурсов
```
mkdir /sys/fs/cgroup/task5
echo "+cpu" | tee /sys/fs/cgroup/cgroup.subtree_control

cpuСhange.sh

# (как извлекать нагрузку: https://stackoverflow.com/questions/43808069/how-to-extract-cpu-load-of-cores-from-htop-command)

#!/bin/bash

while true; do
    cpuStat=$(awk '$1~/cpu[0-9]/{usage=($2+$4)*100/($2+$4+$5); print usage}' /proc/stat)

    if (( $(echo "$cpuStat < 20" | bc -l) )); then
        echo "80000 100000" > /sys/fs/cgroup/task5/cpu.max
    elif (( $(echo "$cpuStat > 60" | bc -l) )); then
        echo "30000 100000" > /sys/fs/cgroup/task5/cpu.max
    fi

    sleep 10
done
```

## 6. Создание изолированного имени хоста (пространство имен UTS)
```
unshare --uts bash # Создаем UTS Namespace Bash
hostname isolated-student69

Вводим hostname. В текущем терминале должны увидеть isolated-student69
В новом терминале видим d12
```

## 7. Изоляция процессов (пространство имен PID)
```
unshare --pid --fork bash # Форкаем процесс после создания namespace
mount -t proc proc /proc
ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.3   7196  3876 pts/4    S    12:45   0:00 bash
root           3  0.0  0.4  11084  4484 pts/4    R+   12:46   0:00 ps aux

В новом терминале видим все процессы
```
## 8. Изолированная файловая система (пространство имен Mount)
```
unshare --mount bash
mkdir /tmp/private_$(whoami) # root
mount -t tmpfs tmpfs /tmp/private_$(whoami)

# Проверка
root@d12:~# df -h | grep private_$(whoami)
tmpfs              481M            0  481M            0% /tmp/private_root # Из того же namespace

# При проверке с нового терминала видим пустоту. Ничего не выдает
```

## 9. Отключение доступа к сети (пространство имен Network
```
unshare --net bash # Создаем Network namespace
ip addr # Видим только lo - loopback. Позволяет общаться устройству с самим собой
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

ping google.com
ping: google.com: Временный сбой в разрешении имен

ping google.com
PING google.com (209.85.233.101) 56(84) bytes of data.
64 bytes from lr-in-f101.1e100.net (209.85.233.101): icmp_seq=1 ttl=107 time=42.8 ms

```
## 10. Создайте и проанализируйте монтирование OverlayFS
### a. Первоначальная настройка:
```
mkdir -p ~/overlay_69/{lower,upper,work,merged}
echo "Оригинальный текст из LOWER" > ~/overlay_69/lower/69_original.txt

mount -t overlay overlay -o lowerdir=/root/overlay_69/lower,upperdir=/root/overlay_69/upper,workdir=/root/overlay_69/work /root/overlay_69/merged # Монтируем и назначем, какие директории являются какими (см. про то, как устроены OverlayFS)

# Видим сразу изменения. Подтянулись в Merged original.txt, что логично
```
### b. Имитация неполадки и отладка:
```
rm /root/overlay_69/merged/69_original.txt # Файл удалился
Посмотрим tree:

.
├── lower
│   └── 69_original.txt
├── merged
├── upper
│   └── 69_original.txt
└── work
    └── work
        └── #3

stat 69_original.txt 
  Файл: 69_original.txt
  Размер: 0             Блоков: 0          Блок В/В: 4096   символьный специальный файл
Устройство: 8/1 Инода: 788915      Ссылки: 2     Тип устройства: 0,0

Далее, удалеям file в upper и видим в Merged:

~/overlay_69/merged# ls
69_original.txt

# В целом, если появляются какие-то неконсистентности, можно просто перемонтировать
```
### c. Разработайте скрипт, который:
- Обнаруживает все whiteout файлы в верхнем каталоге upper. 
- Сравнивает содержимое нижнего и объединенного для выявления несоответствий.
- Выводит отчет с именем _audit.log.
```
touch finder.sh
chmod 777 finder.sh

#!/bin/bash

lowerDir=~/overlay_69/lower
upperDir=~/overlay_69/upper
mergedDir=~/overlay_69/merged
auditLog=~/overlay_69/69_audit.log 

> "$auditLog"
  
echo "Whiteouts:" >> "$auditLog"
find "$upperDir" -type f | while read -r upperFile; do
    relativePath=${upperFile#$upperDir/}
    if [ -f "$lowerDir/$relativePath" ]; then
        if [ ! -f "$mergedDir/$relativePath" ]; then
            echo "$relativePath" >> "$auditLog"
        fi
    fi
done
 
echo "Diff:" >> "$auditLog"
diff -r "$lowerDir" "$mergedDir" >> "$auditLog"
```
### d. Ответьте на вопросы:
-  **Как OverlayFS скрывает файлы из нижнего слоя при удалении в объединенном?**
	- Создает Whiteout-файлы. Это указывает, что файлы нижнего слоя должны быть скрыты
- **Если вы удалите рабочий каталог `work`, сможете ли вы перемонтировать оверлей?**
	- Данная директория является очень важной. Через него проходят все операции
	- Получим ошибку: mount: /root/overlay_69/merged: special device overlay does not exist.
- **Что произойдет с объединенным слоем, если верхний каталог будет пуст?**
	- Будут видны лишь файлы из нижнего слоя. Т.е., будет содержать лишь файлы из нижнего слоя, т.к. верхний пуст. Всё просто

## 11. Оптимизируйте Dockerfile для приведенного ниже приложения app.py
```
# установка Docker (https://losst.pro/ustanovka-docker-na-ubuntu-16-04)

# Создаем .dockerignore, Dockerfile. Впихиваем туда текст из задачи

# Улучшаем Dockerfile

FROM python:3.9-slim # Уменьшаем образ, фиксируем вверсию
RUN useradd -m appuser # Создаем пользователя
WORKDIR /app
COPY requirements.txt .
COPY app.py .
RUN pip install --no-cache-dir -r requirements.txt
USER appuser
CMD ["python", "app.py"]

Мы копируем только requirements.txt и устанавливаем зависимости до копирования остальных файлов. Это позволяет кэшировать слой с зависимостями
Флаг --no-cache-dir предотвращает кэширование зависимостей внутри контейнера

# .dockerignore

__pycache__
.git
.venv

# requirements.txt
Flask==2.3.2
Werkzeug==2.3.7

# docker build, docker run и вперед смотреть браузер на localhost:5000
Container IP: 172.17.0.2 Student: Rincewind
```

## 12. Установка платформы публикации WordPress с помощью Docker Compose
```
# Качаем docker-compose.yml также
docker-compose.yml

version: '3.3'

services:
  db:
    image: mysql:latest
    container_name: mysql_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: denis_db_pass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: denis
      MYSQL_PASSWORD: denis_pass
    volumes:
      - denis-mysql-data:/var/lib/mysql
  
  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    restart: always
    ports:
      - "2069:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: denis
      WORDPRESS_DB_PASSWORD: denis_pass
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - denis-wp-data:/var/www/html
    depends_on:
      - db

volumes:
  denis-mysql-data:
  denis-wp-data:
```