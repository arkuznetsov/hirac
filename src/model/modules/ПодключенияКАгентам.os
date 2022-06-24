// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/hirac/
// ----------------------------------------------------------

#Использовать irac

Перем ПулПодключений;            // - Массив Из Структура  - пул подключений к агентам управления кластерами 1С
                                 //                          (см. ОписаниеПодключенияКАгенту())
Перем РазмерПула;                // - Число                - максимальное количество подключений к агентам в пуле
Перем ВремяОжиданияПодключения;  // - Число                - время ожидания подключения к агенту (мс.)
Перем МаксВремяБлокировки;       // - Число                - ограничение времени блокировки подключения к агенту (мс.)

Перем ТипыОбъектовКластера1С;      // - Структура          - перечисление типов объектов кластера

#Область ПрограммныйИнтерфейс

// Процедура - инициализирует пул подключений к агентам управления кластером 1С
//
Процедура Инициализировать() Экспорт

	РазмерПула               = Настройки.РазмерПулаПодключений();
	ВремяОжиданияПодключения = Настройки.ВремяОжиданияСвободногоПодключения();
	МаксВремяБлокировки      = Настройки.МаксВремяБлокировкиПодключения();

	ВремПул = Новый Массив();

	Для й = 1 По РазмерПула Цикл
		ОписаниеПодключения = ОписаниеПодключенияКАгенту(й - 1);
		ВремПул.Добавить(ОписаниеПодключения);
	КонецЦикла;

	ПулПодключений = Новый ФиксированныйМассив(ВремПул);

	ТипыОбъектовКластера1С = Новый Структура(Перечисления.РежимыАдминистрирования);
	ТипыОбъектовКластера1С.Вставить("БазыДанных", "database");
	ТипыОбъектовКластера1С.Вставить("Таблицы"   , "table");

	ТипыОбъектовКластера1С = Новый ФиксированнаяСтруктура(ТипыОбъектовКластера1С);

КонецПроцедуры // Инициализировать()

// Функция - возвращает пустое описание объекта кластера
//
// Параметры:
//   ТипОбъекта    - Строка    - тип объекта кластера
//   Поля          - Строка    - список получаемых полей, разделенный ","
//                               спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//
// Возвращаемое значение:
//   Соответствие    - пустое описание объекта кластера
//
Функция ПустойОбъектКластера(Знач ТипОбъекта, Знач Поля = "_all") Экспорт

	Поля = ОбщегоНазначения.СписокПолей(Поля);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипОбъекта);
	ПолеКоличество = Новый Структура();
	ПолеКоличество.Вставить("Имя"        , "Количество");
	ПолеКоличество.Вставить("ИмяРАК"     , "count");
	ПолеКоличество.Вставить("Основное"   , Истина);
	ПолеКоличество.Вставить("Тип"        , "Число");
	ПолеКоличество.Вставить("ПоУмолчанию", 0);
	ПоляОбъекта.Добавить(ПолеКоличество);

	Если ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера1С.РабочиеПроцессы)
	 ИЛИ ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера1С.Сеансы)
	 ИЛИ ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера1С.Соединения) Тогда
		ПолеДлительность = Новый Структура();
		ПолеДлительность.Вставить("Имя"        , "Длительность");
		ПолеДлительность.Вставить("ИмяРАК"     , "duration");
		ПолеДлительность.Вставить("Основное"   , Истина);
		ПолеДлительность.Вставить("Тип"        , "Число");
		ПолеДлительность.Вставить("ПоУмолчанию", 0);
		ПоляОбъекта.Добавить(ПолеДлительность);
	КонецЕсли;

	ПустойОбъект = Новый Соответствие();
	ПустойОбъект.Вставить("empty", Истина);

	Для й = 0 По ПоляОбъекта.ВГраница() Цикл
			
		ТекПолеОбъекта = ПоляОбъекта[й];

		Если Поля.Найти(ВРег(ТекПолеОбъекта.ИмяРАК)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		ЗначениеПоля = Неопределено;

		Если ВРег(ТекПолеОбъекта.Тип) = "ЧИСЛО" Тогда
			ЗначениеПоля = 0;
		ИначеЕсли ВРег(ТекПолеОбъекта.Тип) = "ДАТА" Тогда
			ЗначениеПоля = Дата(1, 1, 1, 0, 0, 0);
		КонецЕсли;

		ПустойОбъект.Вставить(ТекПолеОбъекта.ИмяРАК, ЗначениеПоля);
	КонецЦикла;

	Возврат ПустойОбъект;

КонецФункции // ПустойОбъектКластера()

// Функция - возвращает описание кластера
//
// Параметры:
//   АдресСервера    - Строка    - адрес менеджера кластера
//   ПортСервера     - Число     - порт менеджера кластера
//   Поля            - Строка    - список получаемых полей, разделенный ","
//                                 спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//   Обновить        - Булево    - флаг принудительного обновления данных от сервиса RAS
//
// Возвращаемое значение:
//   Соответствие    - описание кластера
//
Функция Кластер(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Кластеры = ОбъектыКластера(ТипыОбъектовКластера1С.Кластеры, Обновить, Поля);

	Для Каждого ТекКластер Из Кластеры Цикл
		Если ТекКластер["host"] = АдресСервера И ТекКластер["port"] = ПортСервера Тогда
			Возврат ТекКластер;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Кластер()

// Функция - возвращает описание рабочего сервера
//
// Параметры:
//   АдресСервера    - Строка    - адрес рабочего сервера
//   ПортСервера     - Число     - порт рабочего сервера
//   Поля            - Строка    - список получаемых полей, разделенный ","
//                                 спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//   Обновить        - Булево    - флаг принудительного обновления данных от сервиса RAS
//
// Возвращаемое значение:
//   Соответствие    - описание рабочего сервера
//
Функция Сервер(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Серверы = ОбъектыКластера(ТипыОбъектовКластера1С.Серверы, Обновить, Поля);

	Для Каждого ТекСервер Из Серверы Цикл
		Если ТекСервер["agent-host"] = АдресСервера И ТекСервер["agent-port"] = ПортСервера Тогда
			Возврат ТекСервер;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сервер()

// Функция - возвращает описание рабочего процесса
//
// Параметры:
//   АдресСервера    - Строка    - адрес рабочего процесса
//   ПортСервера     - Число     - порт рабочего процесса
//   Поля            - Строка    - список получаемых полей, разделенный ","
//                                 спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//   Обновить        - Булево    - флаг принудительного обновления данных от сервиса RAS
//
// Возвращаемое значение:
//   Соответствие    - описание рабочего процесса
//
Функция Процесс(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Процессы = ОбъектыКластера(ТипыОбъектовКластера1С.РабочиеПроцессы, Обновить, Поля);

	Для Каждого ТекПроцесс Из Процессы Цикл
		Если ТекПроцесс["host"] = АдресСервера И ТекПроцесс["port"] = ПортСервера Тогда
			Возврат ТекПроцесс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Процесс()

// Функция - возвращает описание информационной базы
//
// Параметры:
//   ИБ          - Строка    - имя информационной базы
//   Поля        - Строка    - список получаемых полей, разделенный ","
//                             спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//   Обновить    - Булево    - флаг принудительного обновления данных от сервиса RAS
//
// Возвращаемое значение:
//   Соответствие    - описание информационной базы
//
Функция ИнформационнаяБаза(ИБ, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	ИнформационныеБазы = ОбъектыКластера(ТипыОбъектовКластера1С.ИнформационныеБазы, Обновить, Поля);

	Для Каждого ТекИБ Из ИнформационныеБазы Цикл
		Если ТекИБ["infobase-label"] = ИБ Тогда
			Возврат ТекИБ;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // ИнформационнаяБаза()

// Функция - возвращает описание сеанса
//
// Параметры:
//   ИБ          - Строка    - имя информационной базы
//   Сеанс       - Число     - номер сеанса
//   Поля        - Строка    - список получаемых полей, разделенный ","
//                             спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//   Обновить    - Булево    - флаг принудительного обновления данных от сервиса RAS
//
// Возвращаемое значение:
//   Соответствие    - описание сеанса
//
Функция Сеанс(ИБ, Сеанс, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Сеансы = ОбъектыКластера(ТипыОбъектовКластера1С.Сеансы, Обновить, Поля);

	Для Каждого ТекСеанс Из Сеансы Цикл
		Если ТекСеанс["infobase-label"] = ИБ И ТекСеанс["session-id"] = Сеанс Тогда
			Возврат ТекСеанс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сеанс()

// Функция - возвращает описание соединения
//
// Параметры:
//   ИБ            - Строка    - имя информационной базы
//   Соединение    - Число     - номер соединения
//   Поля          - Строка    - список получаемых полей, разделенный ","
//                               спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//   Обновить      - Булево    - флаг принудительного обновления данных от сервиса RAS
//
// Возвращаемое значение:
//   Соответствие    - описание соединения
//
Функция Соединение(ИБ, Соединение, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Соединения = ОбъектыКластера(ТипыОбъектовКластера1С.Соединения, Обновить, Поля);

	Для Каждого ТекСоединение Из Соединения Цикл
		Если ТекСоединение["infobase-label"] = ИБ И ТекСоединение["conn-id"] = Соединение Тогда
			Возврат ТекСоединение;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Соединение()

// Функция - возвращает список объектов кластера
//
// Параметры:
//   ТипОбъекта    - Строка    - тип объекта кластера
//   Обновить        - Булево    - флаг принудительного обновления данных от сервиса RAS
//   Поля            - Строка    - список получаемых полей, разделенный ","
//                                 спец. значения: "_all" - все поля, "_summary" - основные поля для ИБ и соединений
//   Фильтр        - Соответствие         - набор фильтров для значений полей объекта
//     <Ключ>        - Строка               - имя поля
//     <Значение>    - Массив из Структура    - набор сравнений (фильтр для поля)
//       * Оператор    - Строка                 - оператор сравнения
//       * Значение    - Произвольный           - значение для сравнения
//
// Возвращаемое значение:
//   Соответствие    - описание соединения
//
Функция ОбъектыКластера(Знач ТипОбъекта, Знач Обновить = Ложь, Знач Поля = "_all", Знач Фильтр = Неопределено) Экспорт

	ОписаниеПодключения = ЗанятьСвободноеПодключениеКАгенту();

	ОбъектыКластера = Неопределено;

	Попытка
		ОбъектыКластера = ОписаниеПодключения.Подключение.ОписанияОбъектовКластера(ТипОбъекта, Обновить, Поля, Фильтр);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		Сообщить(СтрШаблон("При обновлении объектов ""%1"" возникла ошибка: %2%3", ТипОбъекта, Символы.ПС, ТекстОшибки),
		         СтатусСообщения.ОченьВажное);
	КонецПопытки;

	ОсвободитьПодключениеКАгенту(ОписаниеПодключения);

	Возврат ОбъектыКластера;

КонецФункции // ОбъектыКластера()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Функция - получает описание подключения к агенту управления кластерами 1С
//
// Параметры:
//   Ид    - Число    - номер подключения
//
// Возвращаемое значение:
//   Структура                                   - описание подключения к агенту управления кластерами 1С
//     *Ид                  - Число                - номер подключения
//     *Подключение         - ПодключениеКАгентам  - объект подключения к агенту
//     *Заблокировано       - Булево               - флаг блокировки подключения
//     *НачалоБлокировки    - Число                - момент времени начала блокировки
//
Функция ОписаниеПодключенияКАгенту(Ид)
	
	ОписаниеПодключения = Новый Структура();
	ОписаниеПодключения.Вставить("Ид"              , Ид);
	ОписаниеПодключения.Вставить("Подключение"     , Неопределено);
	ОписаниеПодключения.Вставить("Заблокировано"   , Ложь);
	ОписаниеПодключения.Вставить("НачалоБлокировки", 0);

	Возврат ОписаниеПодключения;

КонецФункции // ОписаниеПодключенияКАгенту()

// Функция - находит и занимает свободное подключение к агенту управления кластерами 1С
//
// Возвращаемое значение:
//   Структура    - описание подключения к агенту управления кластерами 1С
//                  (см. ОписаниеПодключенияКАгенту())
//
Функция ЗанятьСвободноеПодключениеКАгенту()

	Если НЕ ТипЗнч(ПулПодключений) = Тип("ФиксированныйМассив") Тогда
		Инициализировать();
	КонецЕсли;

	ВремяНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Пока ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяНачала <= ВремяОжиданияПодключения Цикл

		Для й = 0 По РазмерПула - 1 Цикл
			
			ТекОписание = ПулПодключений[й];

			Если ТекОписание.Заблокировано
			   И ТекущаяУниверсальнаяДатаВМиллисекундах() - ТекОписание.НачалоБлокировки < МаксВремяБлокировки Тогда
				Продолжить;
			КонецЕсли;

			ТекОписание.Заблокировано    = Истина;
			ТекОписание.НачалоБлокировки = ТекущаяУниверсальнаяДатаВМиллисекундах();

			Если ТекОписание.Подключение = Неопределено Тогда
				ТекОписание.Подключение = Новый ПодключениеКАгентам();
			КонецЕсли;

			Сообщить(СтрШаблон("Занимаем подключение: %1", й), СтатусСообщения.ОченьВажное);

			Возврат ТекОписание;

		КонецЦикла;

	КонецЦикла;

	ВызватьИсключение "Истекло время ожидания свободного подключения";

КонецФункции // ЗанятьСвободноеПодключениеКАгенту()

// Функция - освобождает указанное подключение к агенту управления кластерами 1С
//
// Параметры:
//   ОписаниеПодключения    - Структура    - описание подключения к агенту управления кластерами 1С
//                                           (см. ОписаниеПодключенияКАгенту())
//
Процедура ОсвободитьПодключениеКАгенту(ОписаниеПодключения)

	ОписаниеПодключения.Заблокировано    = Ложь;
	ОписаниеПодключения.НачалоБлокировки = 0;

	Сообщить(СтрШаблон("Освободили подключение: %1", ОписаниеПодключения.Ид), СтатусСообщения.ОченьВажное);

КонецПроцедуры // ОсвободитьПодключениеКАгенту()

#КонецОбласти // СлужебныеПроцедурыИФункции

Инициализировать();