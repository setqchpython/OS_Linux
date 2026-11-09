#!/bin/bash
# provision.sh — выкладка helpdesk 2.4.1 на стенд, развёрнутый заново.
# Запуск из каталога репозитория: sudo bash provision.sh
# Повторный запуск не падает: учётки, права и служба приводятся к одному состоянию.
set -eu

[ "$(id -u)" = 0 ] || { echo "Запустите через sudo: sudo bash $0"; exit 1; }

R=/tmp/helpdesk-release-2.4.1
step() { echo; echo "== $*"; }

if [ -x /usr/sbin/nologin ]; then
  NOLOGIN=/usr/sbin/nologin
elif [ -x /sbin/nologin ]; then
  NOLOGIN=/sbin/nologin
else
  NOLOGIN=/bin/false
fi

ensure_group() {
  local name="$1"
  shift
  getent group "$name" >/dev/null || groupadd "$@" "$name"
}

ensure_human() {
  local name="$1"
  local groups="$2"
  if id "$name" >/dev/null 2>&1; then
    usermod --shell /bin/bash --append --groups "$groups" "$name"
  else
    useradd --create-home --shell /bin/bash --groups "$groups" "$name"
  fi
  gpasswd --delete "$name" sudo >/dev/null 2>&1 || true
}

step "1. Учётные записи и группы (2.1.1–2.1.3)"
ensure_group helpdesk --system
ensure_group helpdesk-dev
ensure_group helpdesk-support
# Обе роли читают журнал, но ни одна не должна его менять.
# У файла одна группа, поэтому читатели собраны в отдельную группу.
ensure_group helpdesk-readers

if id helpdesk >/dev/null 2>&1; then
  usermod --home /var/lib/helpdesk --shell "$NOLOGIN" --gid helpdesk helpdesk
else
  useradd --system --no-create-home --home-dir /var/lib/helpdesk --shell "$NOLOGIN" --gid helpdesk helpdesk
fi

ensure_human ivanov "helpdesk-dev,helpdesk-readers"
ensure_human petrova "helpdesk-dev,helpdesk-readers"
ensure_human smirnova "helpdesk-support,helpdesk-readers"

printf '%s\n' \
  'ivanov:Ivanov-2026' \
  'petrova:Petrova-2026' \
  'smirnova:Smirnova-2026' | chpasswd

step "2. Каталоги по FHS (2.2.1)"
install -d -o root -g root -m 755 /srv/helpdesk
install -d -o helpdesk -g helpdesk -m 700 /var/lib/helpdesk
install -d -o helpdesk -g helpdesk-dev -m 550 /etc/helpdesk
install -d -o helpdesk -g helpdesk-readers -m 2750 /var/log/helpdesk
install -d -o helpdesk -g helpdesk-dev -m 2570 /srv/helpdesk/static
install -d -o helpdesk -g helpdesk-dev -m 2570 /srv/helpdesk/static/css
install -d -o helpdesk -g helpdesk -m 755 /run/helpdesk

step "3. Файлы релиза, владельцы и права (2.2.1, 2.3.1, 2.3.2)"
if [ -d "$R" ]; then
  install -o root -g root -m 755 "$R/bin/helpdesk-api" /usr/local/bin/helpdesk-api
  install -o root -g root -m 755 "$R/bin/helpdesk-ctl" /usr/local/bin/helpdesk-ctl
  install -o helpdesk -g helpdesk-dev -m 440 "$R/conf/helpdesk.conf" /etc/helpdesk/helpdesk.conf
  install -o helpdesk -g helpdesk -m 400 "$R/conf/secrets.env" /etc/helpdesk/secrets.env
  install -o helpdesk -g helpdesk -m 600 "$R/data/tickets.db" /var/lib/helpdesk/tickets.db
  install -o helpdesk -g helpdesk-dev -m 460 "$R/static/index.html" /srv/helpdesk/static/index.html
  install -o helpdesk -g helpdesk-dev -m 460 "$R/static/css/app.css" /srv/helpdesk/static/css/app.css
  rm -rf "$R"
elif [ ! -x /usr/local/bin/helpdesk-api ]; then
  echo "Нет релиза в $R и служба ещё не установлена. Сначала: sudo bash helpdesk-stand.sh" >&2
  exit 1
fi

# 0002 из поставки оставляет группу запись, а остальным чтение.
# 0027: новые файлы службы без записи группе и без доступа остальным (2.3.3).
sed -i 's/^UMASK=.*/UMASK=0027/' /etc/helpdesk/helpdesk.conf

chown helpdesk:helpdesk-dev /etc/helpdesk /etc/helpdesk/helpdesk.conf
chown helpdesk:helpdesk /etc/helpdesk/secrets.env /var/lib/helpdesk /var/lib/helpdesk/tickets.db /run/helpdesk
chown helpdesk:helpdesk-readers /var/log/helpdesk
chown helpdesk:helpdesk-dev /srv/helpdesk/static /srv/helpdesk/static/css \
  /srv/helpdesk/static/index.html /srv/helpdesk/static/css/app.css
chmod 550 /etc/helpdesk
chmod 440 /etc/helpdesk/helpdesk.conf
chmod 400 /etc/helpdesk/secrets.env
chmod 700 /var/lib/helpdesk
chmod 600 /var/lib/helpdesk/tickets.db
chmod 2750 /var/log/helpdesk
chmod 2570 /srv/helpdesk/static /srv/helpdesk/static/css
chmod 460 /srv/helpdesk/static/index.html /srv/helpdesk/static/css/app.css
chmod 755 /usr/local/bin/helpdesk-api /usr/local/bin/helpdesk-ctl /run/helpdesk

step "4. Правило sudo (2.1.4)"
tmp=$(mktemp)
cat > "$tmp" << 'EOF'
# ПД-02: разработчики управляют только службой helpdesk, пароль не спрашивается.
%helpdesk-dev ALL=(helpdesk) NOPASSWD: /usr/local/bin/helpdesk-ctl
EOF
visudo -cf "$tmp"
install -o root -g root -m 440 "$tmp" /etc/sudoers.d/helpdesk
rm -f "$tmp"
visudo -cf /etc/sudoers.d/helpdesk

step "5. Остановить 2.3 и запустить 2.4.1 (2.4.1, 2.4.2)"
if pgrep -f 'helpdesk-2.3/bin/helpdesk-api' >/dev/null 2>&1; then
  pkill -KILL -f 'helpdesk-2.3/bin/helpdesk-api' || true
  sleep 1
fi

if [ -s /run/helpdesk/api.pid ] && kill -0 "$(cat /run/helpdesk/api.pid)" 2>/dev/null; then
  echo "helpdesk-api уже работает, pid $(cat /run/helpdesk/api.pid)"
else
  rm -f /run/helpdesk/api.pid /var/log/helpdesk/api.log
  runuser -u helpdesk -- /usr/local/bin/helpdesk-ctl start
fi

# Журнал создаёт сама служба. Группа и режим фиксируются после создания:
# владелец пишет, helpdesk-readers только читает, остальные не входят.
if [ -f /var/log/helpdesk/api.log ]; then
  chown helpdesk:helpdesk-readers /var/log/helpdesk/api.log
  chmod 640 /var/log/helpdesk/api.log
fi

step "Готово"
echo "Проверка: sudo bash ~/Downloads/helpdesk-acceptance.sh"
