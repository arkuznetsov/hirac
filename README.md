# HTTP interface for RAC (HiRAC)

## Сеансы

### Получение списка сеансов

```

http://localhost:5005/sessions/list

```
## Счетчики

### Получение списка счетчиков


```

http://localhost:5005/counters/list

```

### Получение всех счетчиков сеансов

#### Развернуто по всем измерениям

```

http://localhost:5005/counters/session

или

http://localhost:5005/counters/session?dim=_all

```

В формате Prometheus

```

http://localhost:5005/counters/session?format=prometheus

```

#### Свернуто по всем измерениям

Агрегатная функция по умолчанию (`count`)

```

http://localhost:5005/counters/session?dim=_no

```

Агрегатная функция СУММА (`sum`)

```

http://localhost:5005/counters/session?dim=_no&agregate=sum

```

### Получение конкретного счетчика сеансов

#### Развернуто по всем измерениям

```

http://localhost:5005/counters/session/count?dim=_all

```

#### С отбором по типу клиента

```

http://localhost:5005/counters/session/count?filter_app_id=Designer

```

#### Свернуто по хосту и ИБ

Агрегатная функция СУММА (`sum`)

```

http://localhost:5005/counters/session/count?dim=host&dim=infobase&agregate=sum

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