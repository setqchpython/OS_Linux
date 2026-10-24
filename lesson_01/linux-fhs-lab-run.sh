#!/bin/bash
# Практика занятия 3 (части 1–7) · Debian · ~/linux-fhs-lab
# Запуск: bash linux-fhs-lab-run.sh
# После каждого блока «=== СНИМОК … ===» сделайте скрин окна терминала (или всей ВМ).

set -e

echo "=== 1.5 Создание рабочего каталога ==="
mkdir -p ~/linux-fhs-lab/{config,data,logs,tmp,screenshots}
cd ~/linux-fhs-lab
printf "Linux filesystem\n" > data/info.txt
printf "mode=lab\n" > config/app.conf
find . -maxdepth 2 -type f

echo ""
echo "=== СНИМОК 01-root.png ==="
echo "Команды: pwd; ls -lah /"
pwd
ls -lah /

echo ""
echo "=== СНИМОК 02-home.png ==="
echo "Команды: cd ~; pwd; ls -a"
cd ~
pwd
ls -a

echo ""
echo "=== СНИМОК 03-system.png ==="
echo "Команды: cat /etc/os-release; getent passwd \"\$USER\""
cat /etc/os-release
getent passwd "$USER"

echo ""
echo "=== СНИМОК 04-programs.png ==="
echo "Команды: command -v ls; type cd; echo \"\$PATH\""
command -v ls
type cd
echo "$PATH"

echo ""
echo "=== СНИМОК 05-var.png ==="
echo "Команды: ls /var; findmnt -T /run"
ls /var
findmnt -T /run

echo ""
echo "=== СНИМОК 06-dev.png ==="
echo "Команды: ls -l /dev/null; echo \$?"
ls -l /dev/null
echo $?

cd ~/linux-fhs-lab

echo ""
echo "=== СНИМОК 07-proc.png ==="
echo "Команды: cat /proc/uptime; cp /proc/uptime /tmp/uptime-copy.txt; sleep 5; diff /proc/uptime /tmp/uptime-copy.txt || true"
cat /proc/uptime
cp /proc/uptime /tmp/uptime-copy.txt
sleep 5
diff /proc/uptime /tmp/uptime-copy.txt || true

echo ""
echo "=== СНИМОК 08-sys.png ==="
echo "Команды: ls /sys/class/net"
ls /sys/class/net

echo ""
echo "=== Часть 6: ссылки (перед 09-links.png) ==="
ln -sf data/info.txt info-link.txt 2>/dev/null || true
ln data/info.txt data/info-hard.txt 2>/dev/null || true
ls -li data/info.txt data/info-hard.txt info-link.txt 2>/dev/null || ls -li data/info*

echo ""
echo "=== СНИМОК 09-links.png ==="
echo "Команды: ls -li; rm data/info.txt; cat info-link.txt; cat data/info-hard.txt"
ls -li data/info.txt data/info-hard.txt info-link.txt 2>/dev/null || ls -li
rm -f data/info.txt
cat info-link.txt || true
cat data/info-hard.txt
ln data/info-hard.txt data/info.txt

echo ""
echo "=== СНИМОК 10-space.png ==="
echo "Команды: findmnt /; df -h .; du -sh data"
findmnt /
df -h .
du -sh data

echo ""
echo "=== Часть 7: mount-demo ==="
mkdir -p mount-demo
printf "on original filesystem\n" > mount-demo/before.txt
ls mount-demo

echo ""
echo "=== СНИМОК 11-mount-before.png ==="
echo "После sudo mount — findmnt и ls mount-demo (before.txt не виден)"
sudo mount -t tmpfs -o size=16M tmpfs "$HOME/linux-fhs-lab/mount-demo"
findmnt -T "$HOME/linux-fhs-lab/mount-demo" -o TARGET,SOURCE,FSTYPE
ls -la mount-demo

echo ""
echo "=== СНИМОК 12-mount-after.png ==="
printf "inside tmpfs\n" | sudo tee mount-demo/inside.txt
ls mount-demo
sudo umount "$HOME/linux-fhs-lab/mount-demo"
cat mount-demo/before.txt
ls mount-demo

echo ""
echo "=== Часть 8: model-root shop-api ==="
mkdir -p model-root/{usr/local/bin,etc/shop-api,var/lib/shop-api,var/log/shop-api,run/shop-api}
cp config/app.conf model-root/etc/shop-api/
cp data/info.txt model-root/var/lib/shop-api/
printf "service started\n" > model-root/var/log/shop-api/app.log

echo ""
echo "=== СНИМОК 13-model.png ==="
find model-root -type f

echo ""
echo "Готово. Сохраните 13 снимков в lesson_01/screenshots/ на Windows и допишите report.md."
