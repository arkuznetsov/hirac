# HTTP interface for RAC (HiRAC)

## Кластеры

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

http://localhost:5005/counter/session?dim=_no&agregate=sum

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

http://localhost:5005/counter/session/count?dim=host&dim=infobase&agregate=sum

```

## Доступные агрегатные функции

  - **count** - количество значений счетчика
  - **distinct** - количество **различных** значений счетчика
  - **sum** - сумма значений счетчика
  - **min** - минимальное значение счетчика
  - **max** - максимальное значение счетчика
  - **avg** - среднее значение счетчика

## Доступные форматы

  - **json** - (по умолчанию) JSON-текст собственной структуры
  - **prometheus** - формат Prometheus
  - **plain** - плоский текстовый формат без указания значений измерений


  # Запуск в docker

  ## Сборка образа с hirac

  1. Так как для работы приложения необходима консольнв=ая утилита `rac`. а ее распространение ограниченно лицензией 1С, то для сборки образа нам необходима актуальная учетная запись на https://users.v8.1c.ru/. В момент сборки будет скачан необходимый нам дистрибутив платформы.

  Для этого необходимо создать файл переменных `.env` в корне репозитария, по примеру `env.example` и заполнить его правильными значениями

  ```markdown
  ONEC_USERNAME=<ПОЛЬЗОВАТЕЛЬ_USERS.1C.V8.RU>
  ONEC_PASSWORD=<ПАРОЛЬ_ОТ_USERS.1C.V8.RU>
  ONEC_VERSION=8.3.14.1993
  ```

2.Запустить скрипт сборки образов. При необходимости первым параметром можно указать тег собираемого образа. Тег по умолчанию - `oscript/hirac:latest`

```
bash build_images.sh
```


## Запуск контейнера hirac


Пример конфигурационного файла hirac лежит в каталоге src/config/racsettings.json, он же применяется по умолчанию при запуске контейнера.
При необходимости использовать свои параметры необходимо переопределить конфигурационный файл, через подключеннный volume:

```
docker run -d -p 5000:5000 -v $(pwd)/src/config/racsettings.json:/app/sconfig/racsettings.json demoncat/hirac:latest
```

