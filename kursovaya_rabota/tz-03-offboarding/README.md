# ТЗ № 3 · закрытие доступа уволенного администратора на ops-03

Курсовая работа по дисциплине ОП.05 «Операционные системы и среды».
Компания «Пятый склад», группа эксплуатации. Заявка SEC-2026-0088, регламент РД-05.

| | |
|---|---|
| Автор | Селезнев Александр, группа РПО25/1, GitHub @setqchpython |
| Кто выполнил | все разделы: учётная запись, группы, sudo, процессы, файлы, копия, setuid, приёмка |
| Сервер | ops-03. Приёмка снята 2026-11-09 на Debian 13 (ядро 6.12.113), не на образе Ubuntu 24.04 |
| Итог приёмки | 17 из 17 |

## Состав репозитория

| Файл | Что в нём |
|---|---|
| [`server-passport.md`](server-passport.md) | паспорт до блокировки |
| [`runbook.md`](runbook.md) | журнал работ |
| [`audit.md`](audit.md) | акт аудита |
| [`audit-user.sh`](audit-user.sh) | группы, sudo, процессы и файлы пользователя, без изменений |
| [`acceptance.txt`](acceptance.txt) | вывод приёмки |
| [`tools/offboard.sh`](tools/offboard.sh) | те же действия, что в журнале |
| [`optional/lock-user.sh`](optional/lock-user.sh) | три замка входа и снятие дополнительных групп, +2 |
| [`optional/access-review.md`](optional/access-review.md) | пересмотр доступа остальных, +2 |
| [`screenshots/`](screenshots/) | процессы до завершения, файлы и setuid, приёмка |

## Как воспроизвести

Только в виртуальной машине Ubuntu 24.04. Учётную запись `kozlov` не удалять.

```bash
cd ~/Downloads
wget -O offboarding-stand.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/offboarding-stand.sh
wget -O offboarding-acceptance.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/offboarding-acceptance.sh

cd ~/tz-03-offboarding
sudo bash ~/Downloads/offboarding-stand.sh
sudo bash audit-user.sh kozlov
sudo bash tools/collect-passport.sh | tee server-passport.md
sudo bash tools/offboard.sh
sudo bash ~/Downloads/offboarding-acceptance.sh | tee acceptance.txt
sudo bash optional/lock-user.sh --check kozlov
su - kozlov
```

Последняя команда должна отказать во входе. Для испытания И-02 стенд разворачивают заново и снова запускают только `sudo bash audit-user.sh kozlov`: скрипт снова находит группы, правило sudo, процессы и файлы.

Не получилось: приёмка снята на Debian 13, а в задании указан образ Ubuntu 24.04. На этом прогоне `audit-user.sh` не напечатал новый setuid, хотя копия `kbash` без бита setuid потом легла в резервный каталог.
Нейросеть использовалась для: черновика скриптов и текста акта. Вывод команд снят с виртуальной машины 2026-11-09. Значения паролей, токенов и ключей в репозиторий не записывались.
