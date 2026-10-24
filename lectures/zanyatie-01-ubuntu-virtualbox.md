# Занятие 1 · Установка Ubuntu в VirtualBox

**Презентация:** https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/lessons/01-ustanovka-ubuntu-v-virtualbox/index.html

**Файлы занятия:** [materials/zanyatie-01-ubuntu-virtualbox](../materials/zanyatie-01-ubuntu-virtualbox/)

## Содержание лекции

### Хост, гипервизор, гостевая ОС

**Хост** — компьютер и операционная система, на которых всё запускается.
**Гипервизор** (здесь VirtualBox) — программа, которая создаёт виртуальные
машины и делит между ними ресурсы хоста: процессор, память, диск.
**Гостевая ОС** (здесь Ubuntu) работает внутри виртуальной машины и видит
виртуальное оборудование. Всё, что происходит в гостевой системе, не касается
файлов хоста.

### Архитектура образа

Образ установки должен совпадать с архитектурой процессора хоста:

| Хост | Образ Ubuntu |
|---|---|
| Windows x64, Mac с процессором Intel | `amd64` |
| Mac с Apple Silicon | `arm64` |

VirtualBox на ARM не запускает гостевые системы для x86.

### Виртуальная машина

При создании задаются объём оперативной памяти, число процессоров и размер
виртуального диска. Пункт установщика «Стереть диск и установить Ubuntu»
внутри виртуальной машины относится к виртуальному диску, диск хоста он
не затрагивает.

### Снимок состояния

**Снимок** (snapshot) сохраняет состояние виртуальной машины. Если в системе
что-то сломано, машину возвращают к снимку. Первый снимок делают сразу после
установки и обновления: `clean-install`.

## Что делали на занятии

1. Проверили архитектуру хоста и выбрали образ Ubuntu.
2. Установили VirtualBox на Windows или macOS.
3. Создали виртуальную машину и настроили память, процессоры, диск.
4. Установили Ubuntu Desktop вручную, по шагам.
5. Обновили пакеты в терминале, сделали снимок `clean-install`, корректно
   выключили машину.

## Что вошло в проект

- Виртуальная машина Ubuntu, в которой выполняются все следующие практики.
- Снимок `clean-install` для возврата к исходному состоянию.

## Документация

- [VirtualBox: загрузка](https://www.virtualbox.org/wiki/Downloads)
- [VirtualBox: установка](https://www.virtualbox.org/manual/ch02.html)
- [VirtualBox: известные ограничения](https://www.virtualbox.org/manual/topics/KnownIssues.html)
- [Ubuntu Desktop: загрузка](https://ubuntu.com/download/desktop)
- [Ubuntu в VirtualBox](https://ubuntu.com/tutorials/how-to-run-ubuntu-desktop-on-a-virtual-machine-using-virtualbox)
