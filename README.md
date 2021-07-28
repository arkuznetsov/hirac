# HTTP interface for RAC (HiRAC)

[![GitHub release](https://img.shields.io/github/release/ArKuznetsov/hirac.svg?style=flat-square)](https://github.com/ArKuznetsov/hirac/releases)
[![GitHub license](https://img.shields.io/github/license/ArKuznetsov/hirac.svg?style=flat-square)](https://github.com/ArKuznetsov/hirac/blob/develop/LICENSE)
[![Build Status](https://img.shields.io/github/workflow/status/ArKuznetsov/hirac/%D0%9A%D0%BE%D0%BD%D1%82%D1%80%D0%BE%D0%BB%D1%8C%20%D0%BA%D0%B0%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%B0)](https://github.com/arkuznetsov/hirac/actions/)
[![Quality Gate](https://open.checkbsl.org/api/project_badges/measure?project=hirac&metric=alert_status)](https://open.checkbsl.org/dashboard/index/hirac)
[![Coverage](https://open.checkbsl.org/api/project_badges/measure?project=hirac&metric=coverage)](https://open.checkbsl.org/dashboard/index/hirac)
[![Tech debt](https://open.checkbsl.org/api/project_badges/measure?project=hirac&metric=sqale_index)](https://open.checkbsl.org/dashboard/index/hirac)

REST API для получения информации о кластере сервера 1С и управления объектами кластера.

## Требования

Требуются следующие библиотеки и инструменты:
- [OneScript.Web](https://github.com/EvilBeaver/OneScript.Web) - MVC фреймворк для разработки веб-сайтов с использованием [OneScript](https://github.com/EvilBeaver/OneScript)
- [irac](https://github.com/oscript-library/irac) - если установлен [OneScript](https://github.com/EvilBeaver/OneScript) устанавливается командой `opm install -l`
- [1C RAC](https://releases.1c.ru/project/Platform83) - утилита RAC из состава платформы 1С:Предприятие 8.3

## Запуск

Перейти в подкаталог src и запустить OneScript.Web:

```bat
cd <путь к hirac>\src
<путь к OneScript.Web>\OneScript.WebHost.exe
```

Запуск будет выполнен на 5005 порту. Изменить порт можно в файле настроек [appsettings.json](./src/appsettings.json)

## Конфигурация HiRAC (`./src/config/racsettings.json`)

  - **ras** - параметры сервера администрирования RAS
    - **<имя сервера администрирования>** - параметры конкретного сервера администрирования RAS (`__default` для значений по умолчанию)
      - **admin_name** - имя администратора агента кластера
      - **admin_pwd** - пароль администратора агента кластера
      - **ras** - адрес сервера администрирования RAS
      - **rac** - версия утилиты администрирования RAC
      - **reserves** - резервируемый сервер администрирования
  - **cluster** -  параметры кластеров 1С
    - **<имя кластера:порт>** - параметры кластера (rmngr) по указанному адресу:порту (`__default` для значений по умолчанию)
      - **admin_name** - имя администратора кластера
      - **admin_pwd** - пароль администратора кластера
        - **infobase** - параметры информационных баз в кластере
          - **<Имя ИБ>** - параметры информационной базы (`__default` для значений по умолчанию)
            - **admin_name** - имя администратора ИБ
            - **admin_pwd** - пароль администратора ИБ
  - **useCommands** - true - включена возможность выполнения команд управления кластером; false -возможность отключена
  - **connectionPoolSize** - число одновременных подключений к сервису администрирования
  - **reconnectAtempts** - количество попыток инициализации кластера 1С
  - **reconnectInterval** - задержка перед повторным подключением (мсек.) умножается на номер попытки подключения
  - **connectionWait** - время ожидания свободного подключения (мсек.), после которого будет сообщено об ошибке подключения
  - **connectionLockInterval** - максимальное время блокировки подключения (мсек.), после которого подключение будет принудительно освобождено
  - **logQueryDuration**- Истина - будет выполняться логирование времени выполнения запросов в файл
  - **QueryDurationLogFilename** - путь к файлу лога замеров времени

## Регистрация в качестве службы

В командный файл [reg_os_web_as_service.cmd](./reg_os_web_as_service.cmd) регистрации HiRAC в качестве сервиса Windows. Запуск:

```bat
reg_os_web_as_service.cmd <путь к OneScript.Web>\OneScript.WebHost.exe <адрес>:<порт> <путь к hirac>\src

```

## Варианты запросов

  - **<тип объектов>/list** - список объектов
  - **<тип объектов>/<путь к объекту>** - содержимое объекта по указанному пути
  - **<тип объектов>/<путь к объекту>/<свойство>** - значение свойства <свойство> объекта по указанному пути
  - **counter/list** - описания доступных счетчиков
  - **counter/<тип объектов>/list** - описания доступных счетчиков для <тип объектов>
  - **counter/<тип объектов>/<счетчик>** - значения счетчика <счетчик> для <тип объектов>

### Используемые имена объектов (`<тип объектов>`)

  - **cluster** - информация о кластерах
  - **server** - информация о рабочих серверах
  - **process** - информация о рабочих процессах
  - **infobase** - информация об информационных базах
  - **session** - информация о сеансах
  - **connection** - информация о соединениях

### Используемые типы объектов (`<путь к объекту>`)

  - **cluster** - cluster/<адрес сервера>/<порт сервера> или cluster/<идентификатор>
  - **server** - server/<адрес сервера>/<порт сервера> или server/<идентификатор>
  - **process** - process/<адрес сервера>/<порт процесса> или process/<идентификатор>
  - **infobase** - infobase/<имя информационной базы> или infobase/<идентификатор>
  - **session** - session/<имя информационной базы>/<номер сеанса> или session/<идентификатор>
  - **connection** - connection/<имя информационной базы>/<номер сеанса> или connection/<идентификатор>

## Доступные поля запросов

### Доступные поля запроса списка (`<имя объекта>/list`)

  - **field** - имя поля запрашиваемого объекта, которое попадет в результат (`field=_all` - попадут все поля)
  - **filter_<поле объекта>_<операция сравнения>** - условие (фильтр) по значению поля
  - **order** - сортировка по значениям полей
  - **top** - отбор указанного количества первых результатов с учетом порядка сортировки `order`

### Доступные поля запроса счетчиков (`counter/<имя объекта>`)

  - **filter_<поле объекта>_<операция сравнения>** - условие (фильтр) по значению поля
  - **dim** - имя измерения счетчика по которым выполняется свертка значения счетчика (`dim=_all` - попадут все измерения счетчика)
  - **top** - отбор указанного количества первых значений счетчика с максимальным значением
  - **aggregate** - агрегатная функция свертки значений счетчика
  - **format** - формат вывода результата

### Доступные операции сравнения фильтров

  - **eq** - равно (может не указываться), для строк выполняется без учета регистра
  - **neq** - не равно, для строк выполняется без учета регистра
  - **gt** - больше
  - **gte** - больше или равно
  - **lt** - меньше
  - **lte** - меньше или равно

### Доступные агрегатные функции свертки значений счетчиков

  - **count** - количество значений счетчика
  - **distinct** - количество **различных** значений счетчика
  - **sum** - сумма значений счетчика
  - **min** - минимальное значение счетчика
  - **max** - максимальное значение счетчика
  - **avg** - среднее значение счетчика

### Доступные форматы

  - **json** - (по умолчанию) JSON-текст собственной структуры
  - **prometheus** - формат Prometheus
  - **plain** - плоский текстовый формат без указания значений измерений

## Примеры запросов:

### Получение списка кластеров

```

http://localhost:5005/cluster/list

```

## Серверы

### Получение списка серверов

```

http://localhost:5005/server/list

```

## Информационные базы

### Получение списка ИБ

```

http://localhost:5005/infobase/list

```

## Сеансы

### Получение списка сеансов

```

http://localhost:5005/session/list

```
## Счетчики

### Получение списка счетчиков


```

http://localhost:5005/counter/list

```

### Получение всех счетчиков сеансов

#### Развернуто по всем измерениям

```

http://localhost:5005/counter/session

или

http://localhost:5005/counter/session?dim=_all

```

В формате Prometheus

```

http://localhost:5005/counter/session?format=prometheus

```

#### Свернуто по всем измерениям

Агрегатная функция по умолчанию (`count`)

```

http://localhost:5005/counter/session?dim=_no

```

Агрегатная функция СУММА (`sum`)

```

http://localhost:5005/counter/session?dim=_no&aggregate=sum

```

### Получение конкретного счетчика сеансов

#### Развернуто по всем измерениям

```

http://localhost:5005/counter/session/count?dim=_all

```

#### С отбором по типу клиента

```

http://localhost:5005/counter/session/count?filter_app_id=Designer

```

#### Свернуто по хосту и ИБ

Агрегатная функция СУММА (`sum`)

```

http://localhost:5005/counter/session/count?dim=host&dim=infobase&aggregate=sum

```

## Запуск в docker

### Сборка образа с hirac

1. Так как для работы приложения необходима консольная утилита `rac`. а ее распространение ограниченно лицензией 1С, то для сборки образа нам необходима актуальная учетная запись на https://users.v8.1c.ru/. В момент сборки будет скачан необходимый нам дистрибутив платформы.

Для этого необходимо создать файл переменных `.env` в корне репозитария, по примеру `env.example` и заполнить его правильными значениями

```

ONEC_USERNAME=<ПОЛЬЗОВАТЕЛЬ_USERS.1C.V8.RU>
ONEC_PASSWORD=<ПАРОЛЬ_ОТ_USERS.1C.V8.RU>
ONEC_VERSION=8.3.14.1993
OSCRIPT_VERSION=1.5.0

```

2. Запустить скрипт сборки образов. При необходимости первым параметром можно указать тег собираемого образа. Тег по умолчанию - `oscript/hirac:latest`

```

bash build_images.sh

```

### Запуск контейнера hirac

Пример конфигурационного файла hirac лежит в каталоге src/config/racsettings.json, он же применяется по умолчанию при запуске контейнера.
При необходимости использовать свои параметры необходимо переопределить конфигурационный файл, через подключеннный volume:

```

docker run -d -p 5000:5000 -v $(pwd)/src/config/racsettings.json:/app/config/racsettings.json demoncat/hirac:latest

```

