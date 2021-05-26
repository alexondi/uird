# UIRD - Unified Init Ram Disk system

Унифицированная система инициализации для модульных Linux систем. 

[![Join the chat at https://gitter.im/uird/discussion](https://badges.gitter.im/uird/Lobby.svg)](https://gitter.im/uird/discussion)


## Базовое описание основных принципов

**UIRD** - это разновидность _initrd_, его задача собрать из слоёв _aufs/overlayfs_ корневую файловую систему и передать загрузку `/sbin/init (systemd)` с этой корневой файловой системой.
В основе реализации _UIRD_ лежит набор скриптов инициализации _dracut_ (модули _base, kernel-modules_),
сценарий инициализации _uird-init_ и библиотека функций к нему _livekitlib_ (доработанный аналог _liblinuxlive, livekitlib_ проекта _Slax_). 

## Основные отличия от реализаций _initrd_ для модульных систем схожих проектов.
	* Отсутствие привязки к конкретному дистрибутиву
	* Отсутствие привязки к конкретным каталогам для поиска источников
	* Возможность подключения практически любых источников, которые можно смонтировать в linux 
	* Поддержка различных сетевых протоколов для загрузки по сети
	* Адаптация UIRD под вашу ОС сводится к написанию одного конфигурационного файла


# Параметры командной строки

### Ввиду множественности параметров ядра введен префикс параметров '_uird_'  (_Unified Init Ram Disk_): 
    
    * uird.параметр=значение - установить новое значение, которое заменит значение по умолчанию;
    * uird.параметр+=значение - добавить значение к списку значений по умолчанию

### В настоящий момент параметров более двух десятков, большинство из них лишь расширяют базовый функционал дополнительными возможностями.
## Основные параметры

    * uird.ro[+]=                - фильтр для модулей/директорий, которые монтируются в режиме RO
    * uird.rw[+]=                - фильтр для модулей/директорий, которые монтируются в режиме RW
    * uird.cp[+]=                - фильтр для модулей/директорий, содержимое которых копируется в корень
    * uird.copy2ram[+]=          - фильтр для модулей/директорий, которые копируются в RAM
    * uird.load[+]=              - фильтр для модулей/директорий, которые необходимо подключить на этапе загрузки
    * uird.noload[+]=            - фильтр для модулей/директорий, которые необходимо пропустить во время загрузки
    * uird.from[+]=              - источники, где лежат модули/директории для системы
    * uird.home=                 - источник, где хранятся домашние директории пользователей
    * uird.changes=              - источник, где хранить персистентные изменения
    * uird.mode=MODE             - режим работы сохранениями (clean, clear, changes, machines)


## Параметры для более сложных конфигураций    
    * uird.cache[+]=             - источники, в которые стоит синхронизировать модули/директории
    * uird.copy2cache[+]=        - фильтр для модулей/директорий, которые копируются в КЭШ
    * uird.homes[+]=             - источники, где хранятся домашние директории пользователей (объединяются AUFS)
    * uird.mounts=               - источники , которые будут смонтированы в указанные точки монтирования
    * uird.find_params[+]=       - параметры для утилиты find при поиске модулей (например: -maxdepth,2)
    * uird.help                  - печатает подсказку по параметрам UIRD
    * uird.break=STAGE           - остановка загрузки на стадии STAGE и включение режима отладки (debug)
    * uird.scan=                 - поиск установленных OC и компонентов для определения параметров uird
    * uird.swap=                 - список SWAP разделов и/или файлов для подключения, разделитель в списке ";" или ","
    * uird.syscp[+]=             - список файлов (каталогов) для копирования из UIRD в систему /путь/файл::/путь/каталог
    * uird.basecfg=              - расположение базового конфигурационного файла basecfg.ini
    * uird.config=               - расположение конфигурационного файла системы MagOS.ini
    * uird.sgnfiles[+]=          - перечисление файлов-маркеров для поиска источников указанных в uird.from= в соответсвии с их порядком перечисления
    * uird.ramsize=              - размер RAM
    * uird.ip=                   - IP:GW:MASK, если не указан, то используется DHCP
    * uird.netfsopt[+]=          - дополнительные опции монтирования сетевых ФС: sshfs,nfs,curlftpfs,cifs
    * uird.aria2ram=             - список источников, которые нужно скопировать из сети в RAM до начала поиска uird.from
    * uird.freemedia             - освободить (размонтировать) источники, используется совместно с uird.copy2ram
    * uird.force                 - продолжать загрузку, не задавая вопросов, если источник не найден
    * uird.parallel              - подключение модулей в параллельном режиме
    * uird.run[+]=               - запуск внешних исполняемых файлов
    * uird.zram                  - использовать zram вместо tmpfs
    * uird.union=overlay         - использовать overlayfs вместо aufs
    * uird.shutdown              - создать каталог /run/initramfs, который использует systemd при выключении системы, передавая туда управление
    * uird.preinit               - включить обработку ini файла, заданного в uird.config
    * uird.hide			 - включить режим сокрытия точки монтирования MEMORY (полезно для режима kiosk)
    * quickshell, qs             - консоль на начальном этапе работы uird-init
    * qse                        - консоль в конце работы uird-init
    * debug                      - подробный вывод и приостановка uird-init на нескольких этапах работы


### В качестве значений параметров могут быть использованы команды _shell_:

    * uird.from="/MagOS;$( eval [ $(date +%u) -gt 5 ] && echo /MagOS-Data)" - подключать MagOS-Data только по выходным
    * uird.changes="$(mkdir -p /MagOS-Data/changes && echo /MagOS-Data/changes)"
    * $(udhcpc)  - поднять сеть (eth0 dhcp)


Для более подробного описания параметров смотрите встроенную [подсказку](https://github.com/neobht/uird/tree/master/initrd/usr/share/uird.help)

## Типы источников

    /path/dir                 - директория на любом доступном носителе
    /dev/[..]/path/dir        - директория на заданном носителе
    LABEL@/path/dir           - директория на носителе с меткой LABEL
    UUID@/path/dir            - директория на носителе с uuid UUID
    file-dvd.iso, file.img    - образ диска (ISO, образ блочного устройства, VDI, VHDD и др.)
    http://server/path/...    - источник, доступный по HTTP (используется httpfs) 
    ssh://server/path/...     - источник, доступный по SSH (используется sshfs)
    ftp://server/path/...     - источник, доступный по FTP (используется curlftpfs)
    nfs://server/path/...     - источник, доступный по NFS 
    cifs://server/path/...    - источник, доступный по CIFS 

## Порядок инициализации системы
_Упрощенная схема, не учитывающая параметры `uird.cache, uird.mounts, uird.homes` и проч._
_Более подробную информацию ищите во встроенной справке по конкретным параметрам._

1. Осуществляется поиск конфигурационного файла по пути, указанному в параметре `uird.basecfg=` (дефолтное значение задаётся при сборке _uird_)
2. Устанавливаются параметры из конфигурационного файла, которые ещё не установлены в параметрах ядра
3. Происходит монтирование источников **base**-уровня в порядке, указанном в параметре `uird.from=`
4. Происходит монтирование источников **home**-уровня, согласно параметру `uird.home=` 
5. Происходит подключение в самый _верхний_ уровень _AUFS_ источника персистентных изменений, указанного в параметрами `uird.changes=, uird.mode=`
7. Осуществляется синхронизация base уровня в ОЗУ с учётом параметра `uird.copy2ram=`
8. Осуществляется поиск модулей/директорий в ОЗУ и base-уровне и подключение их на _[верхний-1]_ уровень _AUFS_ или копирование в корень (с учётом фильтров, указанных в параметрах `uird.load=, uird.noload=,uird.ro=,uird.rw=,uird.cp=`) со следующим приоритетом:

                           uird.load --> uird.noload
                           uird.cp --> uird.rw --> uird.ro
9. Выполняются скрипты _rc.preinit_

## Структура системной директории 

      /memory/
      ├── bundles                   - точка монтирования модулей
      │   ├── 00-kernel.xzm
      │   ├── 01-firmware.xzm
      │   ├── 10-core.xzm
      │   ├── 80-eepm-1.5.2.xzm
      │   └── ...                   - и т.д.
      ├── changes                   - точка монтирования для хранения изменений
      │   ├── etc
      │   ├── home
      │   ├── memory
      │   ├── run
      │   ├── var
      │   └── ...                   - и т.д.
      ├── data                      - точка монтирования источников
      │   ├── cache                     - кеш уровня
      │   ├── homes                     - homes уровня
      │   ├── mounts                    - mounts уровня
      │   ├── machines                  - машинно-зависимых изменений
      │   └── from                      - базового уровня
      ├── copy2ram                  - точка монтирования для синхронизации модулей/директорий в ОЗУ
      ├── ovl                       - точка монтирования вспомогательных каталогов OverlayFS
      │   ├── lowerdir                  - lowerdir
      │   └── workdir                   - workdir
      ├── layer-base                - точка монтирования базового уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.from=)
      │   └── ...                       - и т.д.
      ├── layer-cache               - точка монтирования кеш уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.cache=)
      │   └── ...                       - и т.д.
      ├── layer-homes               - точка монтирования homes уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.homes=)
      │   └── ...                       - и т.д.
      ├── layer-mounts              - точка монтирования mounts уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.mounts=)
      │   └── ...                       - и т.д.
      ├── cmdline                   - системный файл для хранения дополнительных параметров командной строки
      └── MagOS.ini.gz              - системный файл для хранения конфигурационного файла


## Пример конфигурационного файла MagOS (используется при сборке UIRD для MagOS-linux)

      uird.config=MagOS.ini
      uird.ramsize=70%
      uird.ro=*.xzm;*.rom;*.rom.enc;*.pfs
      uird.rw=*.rwm;*.rwm.enc
      uird.cp=*.xzm.cp,*/rootcopy
      uird.load=/base/,/modules/,rootcopy
      uird.noload=/MagOS-Data/changes,/MagOS-Data/homes
      uird.from=/MagOS;/MagOS-Data
      uird.find_params=-maxdepth_3
      uird.mode=clean
      uird.changes=/MagOS-Data/changes
      uird.syscp=/livekitlib::/usr/lib/magos/scripts;/uird.scan::/usr/lib/magos/scripts;/liblinuxlive::/mnt/live/liblinuxlive
  
Расширения поддерживаемые в MagOS Linux с этим конфигом:

    *.ROM - RO слой
    *.RWM - RW слой
    *.XZM - RO слой с squashfs
    *.XZM.CP - распаковывается в корень системы
    *.RWM.ENC - RW слой криптованый
    *.ROM.ENC - RO слой криптованый

Другие примеры конфигурационных файлов смотрите [тут](https://github.com/neobht/uird/tree/master/configs/uird_configs)

### Реализация

В основе реализации лежит набор скриптов инициализации [dracut](https://cdn.kernel.org/pub/linux/utils/boot/dracut/dracut.html) (модули base, kernel-modules ) и скрипты uird (livekitlib+uird-init).

    cmdline-hook: parse-root-uird.sh (заглушка)
    mount-hook: mount-uird.sh (выполняет скрипт uird-init)

* [livekitlib](https://github.com/neobht/uird/blob/master/modules.d/00uird/livekit/livekitlib) - содержит библиотеку функций системы инициализации.
* [uird-init](https://github.com/neobht/uird/blob/master/modules.d/00uird/livekit/uird-init) - последовательно выполняет набор функций из livekitlib и осуществляет каскадно-блочное монтирование модулей системы в единый корень AUFS в директорию, указанную в переменной dracut $NEWROOT.

### Установка и сборка

Смотрите описание процесса: [uird_build.md](https://github.com/neobht/uird/blob/master/UIRD_BUILD.md)

