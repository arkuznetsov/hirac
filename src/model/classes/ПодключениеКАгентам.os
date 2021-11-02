﻿// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/hirac/
// ----------------------------------------------------------

#Использовать irac

Перем Агенты;                     // - Соответствие   - доступные агенты подключения к RAS
Перем ОписанияКластеров;          // - Соответствие   - кэш описаний кластеров
Перем ОписанияСерверов;           // - Соответствие   - кэш описаний рабочих серверов
Перем ОписанияРабочихПроцессов;   // - Соответствие   - кэш описаний рабочих процессов
Перем ОписанияИнформационныхБаз;  // - Соответствие   - кэш описаний информационных баз
Перем ОписанияСеансов;            // - Соответствие   - кэш описаний сеансов
Перем ОписанияСоединений;         // - Соответствие   - кэш описаний соединений

#Область ОбработчикиСобытийОбъекта

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// Параметры:
//   НастройкиПодключения     - Строка,     - путь к файлу настроек управления кластерами
//                              Структура     или структура настроек управления кластерами
//
Процедура ПриСозданииОбъекта(Знач НастройкиПодключения = Неопределено)

	ИнициализироватьАгентыУправленияКластерами(НастройкиПодключения);

КонецПроцедуры // ПриСозданииОбъекта()

#КонецОбласти // ОбработчикиСобытийОбъекта

#Область ПрограммныйИнтерфейс

// Функция - возвращает структуру с подключениями к агентам управления кластерами
//
// Возвращаемое значение:
//   Структура     - структура с подключениями к агентам управления кластерами
//
Функция Агенты() Экспорт
	
	Возврат Агенты;

КонецФункции // Агенты()

// Процедура инициализирует подключения к агентам управления кластерами
//
// Параметры:
//   НастройкиПодключения     - Строка,     - путь к файлу настроек управления кластерами
//                              Структура     или структура настроек управления кластерами
//
Процедура ИнициализироватьАгентыУправленияКластерами(Знач НастройкиПодключения = Неопределено) Экспорт
	
	Если ТипЗнч(НастройкиПодключения) = Тип("Структура")
	 ИЛИ ТипЗнч(НастройкиПодключения) = Тип("Строка") Тогда
		Настройки.Инициализация(НастройкиПодключения);
	КонецЕсли;

	ПараметрыПодключения = Настройки.ПараметрыПодключения();

	Агенты = Новый Соответствие();

	Для Каждого ТекИд Из ПараметрыПодключения.ИдентификаторыАгентов Цикл
	
		ПараметрыАгента = ПараметрыПодключения.Агенты[ТекИд];

		АвторизацияАгента = Новый Структура("Администратор, Пароль");
		АвторизацияАгента.Вставить("Администратор", ПараметрыАгента.Администратор);
		АвторизацияАгента.Вставить("Пароль"       , ПараметрыАгента.Пароль);

		УправлениеКластером = Новый УправлениеКластером1С(ПараметрыАгента.ВерсияКлиента,
		                                                  ПараметрыАгента.АдресСервиса,
		                                                  АвторизацияАгента);

		ОписаниеАгента = Новый Структура();
		ОписаниеАгента.Вставить("Имя"        , ТекИд);
		ОписаниеАгента.Вставить("Резервирует", ВРег(ПараметрыАгента.Резервирует));
		ОписаниеАгента.Вставить("Агент"      , УправлениеКластером);

		Агенты.Вставить(ВРег(ТекИд), ОписаниеАгента);

		ИнициализироватьКластерыАгента(ОписаниеАгента);

	КонецЦикла;

КонецПроцедуры // ИнициализироватьАгентыУправленияКластерами()

Функция ОписанияОбъектовКластера(Знач ТипОбъекта, Знач Обновить = Ложь,
	                             Знач Поля = "_all", Знач Фильтр = Неопределено) Экспорт

	ОбновитьКэшОписанийОбъектовКластеров(ТипОбъекта, Обновить);

	КэшОписанийОбъектов = КэшОписанийОбъектовКластера(ТипОбъекта);

	Результат = Новый Массив();

	ОбновленныеОписания = Новый Соответствие();

	Для Каждого ТекОписаниеОбъекта Из КэшОписанийОбъектов Цикл

		// При необходимости получаем полное описание ИБ или соединения и сохраняем в кэш
		ЗаполнитьРасширенноеОписаниеОбъекта(ТипОбъекта, ТекОписаниеОбъекта.Значение, Поля, ОбновленныеОписания);

		ОписаниеОбъектаДляВывода = ОбновленныеОписания[ТекОписаниеОбъекта.Значение["_thisObject"].Ид()];
		Если ОписаниеОбъектаДляВывода = Неопределено Тогда
			ОписаниеОбъектаДляВывода = ТекОписаниеОбъекта.Значение;
		КонецЕсли;

		Если НЕ ОбщегоНазначения.ОбъектСоответствуетФильтру(ОписаниеОбъектаДляВывода, Фильтр) Тогда
			Продолжить;
		КонецЕсли;

		ОписаниеОбъекта = ОписаниеОбъектаКластера(ТипОбъекта, ОписаниеОбъектаДляВывода, Поля);

		Результат.Добавить(ОписаниеОбъекта);

	КонецЦикла;

	Для Каждого ТекОписаниеОбъекта Из ОбновленныеОписания Цикл
		КэшОписанийОбъектов.Вставить(ТекОписаниеОбъекта.Ключ, ТекОписаниеОбъекта.Значение);
	КонецЦикла;

	Возврат Результат;

КонецФункции // ОписанияОбъектовКластера()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПолучениеДанныхСервисаАдминистрирования

Функция ПолныеОписанияКластеровАгента(Знач Агент)

	ОписанияОбъектовАгента = Новый Соответствие();

	СписокКластеров = Агент.Кластеры().Список(, , Истина);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипыОбъектовКластера().Кластеры);

	Для Каждого ТекКластер Из СписокКластеров Цикл

		ПолноеОписаниеОбъекта = Новый Соответствие();
		ПолноеОписаниеОбъекта.Вставить("_thisObject", ТекКластер["_thisObject"]);

		Для й = 0 По ПоляОбъекта.ВГраница() Цикл
			
			ТекПолеОбъекта = ПоляОбъекта[й];

			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			ЗначениеЭлемента = ТекКластер[ТекПолеОбъекта.Имя];

			ПолноеОписаниеОбъекта.Вставить(ИмяПоля, ЗначениеЭлемента);

			РасширитьПолеОбъектаКластера(ПолноеОписаниеОбъекта, ИмяПоля, ТипыОбъектовКластера().Кластеры, ТекКластер);

		КонецЦикла;

		ДополнитьОписаниеОбъектаКластера(ПолноеОписаниеОбъекта, ТипыОбъектовКластера().Кластеры, Агент, ТекКластер);

		ОписанияОбъектовАгента.Вставить(ПолноеОписаниеОбъекта["cluster"], ПолноеОписаниеОбъекта);

	КонецЦикла;

	Возврат ОписанияОбъектовАгента;

КонецФункции // ПолныеОписанияКластеровАгента()

Функция ПолныеОписанияОбъектовАгента(Знач Агент, Знач ТипОбъекта)

	Если ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Кластеры) Тогда
		Возврат ПолныеОписанияКластеровАгента(Агент);
	КонецЕсли;

	ПолныеОписанияОбъектов = Новый Соответствие();

	СписокКластеров = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из СписокКластеров Цикл

		ПолныеОписанияОбъектовКластера = ПолныеОписанияОбъектовКластера(ТекКластер, ТипОбъекта, Агент);

		Для Каждого ТекОписаниеОбъекта Из ПолныеОписанияОбъектовКластера Цикл
		
			ПолныеОписанияОбъектов.Вставить(ТекОписаниеОбъекта[ТипОбъекта], ТекОписаниеОбъекта);

		КонецЦикла;

	КонецЦикла;

	Возврат ПолныеОписанияОбъектов;

КонецФункции // ПолныеОписанияОбъектовАгента()

Функция ПолныеОписанияОбъектовКластера(Знач Кластер, Знач ТипОбъекта, Знач Агент)

	ПолныеОписанияОбъектов = Новый Массив();
	
	СписокОбъектовКластера = Кластер.Получить(ТипОбъекта).Список(, , Истина);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипОбъекта);

	Для Каждого ТекОбъектКластера Из СписокОбъектовКластера Цикл

		ПолноеОписаниеОбъекта = Новый Соответствие();
		ПолноеОписаниеОбъекта.Вставить("_thisObject", ТекОбъектКластера["_thisObject"]);

		Для й = 0 По ПоляОбъекта.ВГраница() Цикл
			
			ТекПолеОбъекта = ПоляОбъекта[й];

			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			ЗначениеЭлемента = ТекОбъектКластера[ТекПолеОбъекта.Имя];
			
			ПолноеОписаниеОбъекта.Вставить(ИмяПоля, ЗначениеЭлемента);

			РасширитьПолеОбъектаКластера(ПолноеОписаниеОбъекта,
			                             ИмяПоля,
			                             ТипОбъекта,
			                             ТекОбъектКластера);

		КонецЦикла;

		ДополнитьОписаниеОбъектаКластера(ПолноеОписаниеОбъекта, ТипОбъекта, Агент, Кластер);

		ПолныеОписанияОбъектов.Добавить(ПолноеОписаниеОбъекта);

	КонецЦикла;

	Возврат ПолныеОписанияОбъектов;
	
КонецФункции // ПолныеОписанияОбъектовКластера()

Процедура РасширитьПолеОбъектаКластера(ПолноеОписаниеОбъекта, ИмяПоля, ТипОбъекта, ОбъектКластера)

	Если ТипОбъекта = ТипыОбъектовКластера().Кластеры
	   И ВРег(ИмяПоля) = "CLUSTER" Тогда
		АдресСервера = ОбъектКластера.Получить("АдресСервера");
		ПортСервера  = ОбъектКластера.Получить("ПортСервера");
		МеткаКластера = СтрШаблон("%1:%2", АдресСервера, ПортСервера);
		ПолноеОписаниеОбъекта.Вставить("cluster-label", МеткаКластера);
	КонецЕсли;

	Если ТипОбъекта = ТипыОбъектовКластера().Серверы
	   И ВРег(ИмяПоля) = "SERVER" Тогда
		АдресСервера = ОбъектКластера.Получить("АдресАгента");
		ПортСервера  = ОбъектКластера.Получить("ПортАгента");
		МеткаСервера = СтрШаблон("%1:%2", АдресСервера, ПортСервера);
		ПолноеОписаниеОбъекта.Вставить("server-host" , АдресСервера);
		ПолноеОписаниеОбъекта.Вставить("server-label", МеткаСервера);
	КонецЕсли;

	Если ТипОбъекта = ТипыОбъектовКластера().РабочиеПроцессы
	   И ВРег(ИмяПоля) = "PROCESS" Тогда
		АдресСервера = ОбъектКластера.Получить("АдресСервера");
		ПортСервера  = ОбъектКластера.Получить("ПортСервера");
		МеткаПроцесса = СтрШаблон("%1:%2", АдресСервера, ПортСервера);
		ПолноеОписаниеОбъекта.Вставить("process-host" , АдресСервера);
		ПолноеОписаниеОбъекта.Вставить("process-label", МеткаПроцесса);
	КонецЕсли;

	Если ТипОбъекта = ТипыОбъектовКластера().Сеансы 
	 ИЛИ ТипОбъекта = ТипыОбъектовКластера().Соединения Тогда
		Если ВРег(ИмяПоля) = "INFOBASE" Тогда
			ПолноеОписаниеОбъекта.Вставить("infobase-label", "_none");
			ОписаниеИБ = ПолучитьОписаниеОбъектаИзКэша(ПолноеОписаниеОбъекта[ИмяПоля],
			                                           ТипыОбъектовКластера().ИнформационныеБазы);
			Если НЕ ОписаниеИБ = Неопределено Тогда
				ПолноеОписаниеОбъекта.Вставить("infobase-label", ОписаниеИБ["name"]);
			КонецЕсли;
		ИначеЕсли ВРег(ИмяПоля) = "PROCESS" Тогда
			ПолноеОписаниеОбъекта.Вставить("process-label", "_none");
			ПолноеОписаниеОбъекта.Вставить("process-host" , "_none");
			ОписаниеПроцесса = ПолучитьОписаниеОбъектаИзКэша(ПолноеОписаниеОбъекта[ИмяПоля],
			                                                 ТипыОбъектовКластера().РабочиеПроцессы);
			Если НЕ ОписаниеПроцесса = Неопределено Тогда
				МеткаПроцесса = СтрШаблон("%1:%2", ОписаниеПроцесса["host"], ОписаниеПроцесса["port"]);
				ПолноеОписаниеОбъекта.Вставить("process-label", МеткаПроцесса);
				ПолноеОписаниеОбъекта.Вставить("process-host" , ОписаниеПроцесса["host"]);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
		
	Если ВРег(ИмяПоля) = "NAME"
	 ИЛИ ВРег(ИмяПоля) = "APPLICATION"
	 ИЛИ ВРег(ИмяПоля) = "DESCR" Тогда
		ОбщегоНазначения.УбратьКавычки(ПолноеОписаниеОбъекта[ИмяПоля]);
	ИначеЕсли ВРег(ИмяПоля) = "STARTED-AT"
	      ИЛИ ВРег(ИмяПоля) = "CONNECTED-AT" Тогда
		Попытка
			ПолноеОписаниеОбъекта.Вставить("duration", ТекущаяДата() - ПолноеОписаниеОбъекта[ИмяПоля]);
		Исключение
			ПолноеОписаниеОбъекта.Вставить("duration", 0);
		КонецПопытки;
	КонецЕсли;
 
КонецПроцедуры // РасширитьПолеОбъектаКластера()

Функция ПолучитьОписаниеОбъектаИзКэша(ИдОбъекта, ТипОбъекта)

	КэшОбъектов = КэшОписанийОбъектовКластера(ТипОбъекта);

	ОписаниеОбъекта = Неопределено;
	Если ТипЗнч(КэшОбъектов) = Тип("Соответствие") Тогда
		ОписаниеОбъекта = КэшОбъектов[ИдОбъекта];
	КонецЕсли;
	Если ОписаниеОбъекта = Неопределено И НЕ ОбщегоНазначения.ЭтоПустойGUID(ИдОбъекта) Тогда
		ОбновитьКэшОписанийОбъектовКластеров(ТипОбъекта);
		ОписаниеОбъекта = КэшОбъектов[ИдОбъекта];
	КонецЕсли;

	Возврат ОписаниеОбъекта;

КонецФункции // ПолучитьОписаниеОбъектаИзКэша()

Процедура ДополнитьОписаниеОбъектаКластера(ПолноеОписаниеОбъекта, ТипОбъекта, Агент, Кластер)

	МеткаАгента = СтрШаблон("%1:%2", Агент.АдресСервераАдминистрирования(), Агент.ПортСервераАдминистрирования());

	ПолноеОписаниеОбъекта.Вставить("agent", МеткаАгента);
	ПолноеОписаниеОбъекта.Вставить("_clusterObject", Кластер);
	ПолноеОписаниеОбъекта.Вставить("_type", ТипОбъекта);

	Если НЕ ТипОбъекта = ТипыОбъектовКластера().Кластеры Тогда
		ПолноеОписаниеОбъекта.Вставить("cluster"      , Кластер.Ид());
		ПолноеОписаниеОбъекта.Вставить("cluster-host" , Кластер.АдресСервера());
		ПолноеОписаниеОбъекта.Вставить("cluster-port" , Кластер.ПортСервера());
		ПолноеОписаниеОбъекта.Вставить("cluster-label",
		                               СтрШаблон("%1:%2", Кластер.АдресСервера(), Кластер.ПортСервера()));
	КонецЕсли;

	Если ТипОбъекта = ТипыОбъектовКластера().ИнформационныеБазы Тогда
		
		ПараметрыСУБД = ПолноеОписаниеОбъекта["_thisObject"].ПараметрыСУБД();

		СоединениеСУБД = ОбщегоНазначения.СоединениеСУБД(ПараметрыСУБД.ТипСУБД,
		                                                 ПараметрыСУБД.Сервер,
		                                                 ПараметрыСУБД.Пользователь,
		                                                 ПараметрыСУБД.Пароль);
		
		ЗанимаемоеМесто = СоединениеСУБД.ЗанимаемоеМесто(ПараметрыСУБД.База);
	
		ПолноеОписаниеОбъекта.Вставить("dbms-size-on-disk"     , ЗанимаемоеМесто.РазмерБазы);
		ПолноеОписаниеОбъекта.Вставить("dbms-unallocated-space", ЗанимаемоеМесто.Свободно);
		ПолноеОписаниеОбъекта.Вставить("dbms-reserved-space"   , ЗанимаемоеМесто.Зарезервировано);
		ПолноеОписаниеОбъекта.Вставить("dbms-data-size"        , ЗанимаемоеМесто.Данные);
		ПолноеОписаниеОбъекта.Вставить("dbms-index-size"       , ЗанимаемоеМесто.Индексы);
		ПолноеОписаниеОбъекта.Вставить("dbms-unused-space"     , ЗанимаемоеМесто.НеИспользуется);
	КонецЕсли;

	ПолноеОписаниеОбъекта.Вставить("id", ПолноеОписаниеОбъекта[ТипОбъекта]);

	ДобавитьМеткуОбъектаКластера(ПолноеОписаниеОбъекта);

	ПолноеОписаниеОбъекта.Вставить("count", 1);

КонецПроцедуры // ДополнитьОписаниеОбъектаКластера()

Процедура ДобавитьМеткуОбъектаКластера(ПолноеОписаниеОбъекта)

	Метка = "";

	Если ПолноеОписаниеОбъекта["_type"] = ТипыОбъектовКластера().Кластеры
	 ИЛИ ПолноеОписаниеОбъекта["_type"] = ТипыОбъектовКластера().РабочиеПроцессы Тогда
		Метка = СтрШаблон("%1:%2",
		                  ПолноеОписаниеОбъекта["host"],
		                  ПолноеОписаниеОбъекта["port"]);
	ИначеЕсли ПолноеОписаниеОбъекта["_type"] = ТипыОбъектовКластера().Серверы Тогда
		Метка = СтрШаблон("%1:%2",
		                  ПолноеОписаниеОбъекта["agent-host"],
		                  ПолноеОписаниеОбъекта["agent-port"]);
	ИначеЕсли ПолноеОписаниеОбъекта["_type"] = ТипыОбъектовКластера().ИнформационныеБазы Тогда
		Метка = ПолноеОписаниеОбъекта["name"];
	ИначеЕсли ПолноеОписаниеОбъекта["_type"] = ТипыОбъектовКластера().Сеансы Тогда
		Метка = СтрШаблон("%1:%2",
		                  ПолноеОписаниеОбъекта["infobase-label"],
		                  ПолноеОписаниеОбъекта["session-id"]);
	ИначеЕсли ПолноеОписаниеОбъекта["_type"] = ТипыОбъектовКластера().Соединения Тогда
		ИдСоединения = ПолноеОписаниеОбъекта["conn-id"];
		Если ИдСоединения = 0 Тогда
			ИдСоединения = ПолноеОписаниеОбъекта["application"];
		КонецЕсли;
		Метка = СтрШаблон("%1:%2",
		                  ПолноеОписаниеОбъекта["process-label"],
		                  ИдСоединения);
	КонецЕсли;
		
	ПолноеОписаниеОбъекта.Вставить("label", Метка);

КонецПроцедуры // ДобавитьМеткуОбъектаКластера()

Функция ЭтоПолеОсновногоОписанияОбъекта(ТипОбъекта, ИмяПоля)

	ПоляОсновнойИнформации = Новый Соответствие();

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипОбъекта, Истина);

	Для Каждого ТекПоле Из ПоляОбъекта Цикл
		ПоляОсновнойИнформации.Вставить(ВРег(ТекПоле.ИмяРАК), Истина);
		Если ВРег(ТекПоле.ИмяРАК) = "PROCESS" Тогда
			ПоляОсновнойИнформации.Вставить("PROCESS-LABEL", Истина);
			ПоляОсновнойИнформации.Вставить("PROCESS-HOST" , Истина);
		ИначеЕсли ВРег(ТекПоле.ИмяРАК) = "INFOBASE" Тогда
			ПоляОсновнойИнформации.Вставить("INFOBASE-LABEL", Истина);
			ПоляОсновнойИнформации.Вставить("DBMS-SIZE-ON-DISK", Истина);
			ПоляОсновнойИнформации.Вставить("DBMS-UNALLOCATED-SPACE", Истина);
			ПоляОсновнойИнформации.Вставить("DBMS-RESERVED-SPACE", Истина);
			ПоляОсновнойИнформации.Вставить("DBMS-DATA-SIZE", Истина);
			ПоляОсновнойИнформации.Вставить("DBMS-INDEX-SIZE", Истина);
			ПоляОсновнойИнформации.Вставить("DBMS-UNUSED-SPACE", Истина);
		КонецЕсли;
	КонецЦикла;
	ПоляОсновнойИнформации.Вставить("ID"           , Истина);
	ПоляОсновнойИнформации.Вставить("LABEL"        , Истина);
	ПоляОсновнойИнформации.Вставить("AGENT"        , Истина);
	ПоляОсновнойИнформации.Вставить("CLUSTER"      , Истина);
	ПоляОсновнойИнформации.Вставить("CLUSTER-LABEL", Истина);
	ПоляОсновнойИнформации.Вставить("CLUSTER-HOST" , Истина);
	ПоляОсновнойИнформации.Вставить("CLUSTER-PORT" , Истина);
	ПоляОсновнойИнформации.Вставить("_NO"          , Истина);
	ПоляОсновнойИнформации.Вставить("_SUMMARY"     , Истина);
	ПоляОсновнойИнформации.Вставить("COUNT"        , Истина);
	ПоляОсновнойИнформации.Вставить("DURATION"     , Истина);

	Если ПоляОсновнойИнформации[ВРег(ИмяПоля)] = Истина Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;

КонецФункции // ЭтоПолеОсновногоОписанияОбъекта()

Функция ПолучатьРасширенноеОписаниеОбъекта(ТипОбъекта, Поля = "_all")

	Если НЕ (ТипОбъекта = ТипыОбъектовКластера().ИнформационныеБазы
	 ИЛИ ТипОбъекта = ТипыОбъектовКластера().Соединения) Тогда
		Возврат Ложь;
	КонецЕсли;

	ДобавляемыеПоля = ОбщегоНазначения.СписокПолей(Поля);

	Если НЕ ДобавляемыеПоля.Найти("_ALL") = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Для Каждого ТекПоле Из ДобавляемыеПоля Цикл
		Если НЕ ЭтоПолеОсновногоОписанияОбъекта(ТипОбъекта, ТекПоле) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;

КонецФункции // ПолучатьРасширенноеОписаниеОбъекта()

Процедура ЗаполнитьРасширенноеОписаниеОбъекта(ТипОбъекта, ПолноеОписаниеОбъекта, Поля = "_all", ОбновленныеОписания)

	Если НЕ ПолучатьРасширенноеОписаниеОбъекта(ТипОбъекта, Поля) Тогда
		Возврат;
	КонецЕсли;

	Кластер        = ПолноеОписаниеОбъекта["_clusterObject"];
	ОбъектКластера = ПолноеОписаниеОбъекта["_thisObject"];

	ИдИБ = ПолноеОписаниеОбъекта["infobase"];
	
	Если ОбщегоНазначения.ЭтоПустойGUID(ИдИБ) Тогда
		Возврат;
	КонецЕсли;

	ИБОбъекта = Кластер.ИнформационныеБазы().Получить(ИдИБ, -1);
	
	Если ИБОбъекта.ОшибкаАвторизации() Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ОбъектКластера.ПолноеОписание() Тогда
		ОбъектКластера.ОбновитьДанные(1);
	КонецЕсли;

	Если НЕ ТипЗнч(ОбновленныеОписания) = Тип("Соответствие") Тогда
		ОбновленныеОписания = Новый Соответствие();
	КонецЕсли;

	Если ОбъектКластера.ПолноеОписание() Тогда

		ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипОбъекта);

		ОбновленноеОписаниеОбъекта = Новый Соответствие();
		Для Каждого ТекСвойство Из ПолноеОписаниеОбъекта Цикл
			ОбновленноеОписаниеОбъекта.Вставить(ТекСвойство.Ключ, ТекСвойство.Значение);
		КонецЦикла;
		
		Для й = 0 По ПоляОбъекта.ВГраница() Цикл
			Если ПоляОбъекта[й].Основное Тогда
				Продолжить;
			КонецЕсли;
			ОбновленноеОписаниеОбъекта.Вставить(ПоляОбъекта[й].ИмяРАК,
			                                    ОбъектКластера.Получить(ПоляОбъекта[й].Имя, -1));
		КонецЦикла;
		
		ОбновленныеОписания.Вставить(ОбъектКластера.Ид(), ОбновленноеОписаниеОбъекта);
	КонецЕсли;

КонецПроцедуры // ЗаполнитьРасширенноеОписаниеОбъекта()

Функция НужноДобавлятьПоле(ТипОбъекта, ДобавляемыеПоля, ИмяПоля)

	Если ВРег(ИмяПоля) = "_CLUSTEROBJECT"
	 ИЛИ ВРег(ИмяПоля) = "_THISOBJECT" Тогда
		Возврат Ложь;
	КонецЕсли;

	Если НЕ ДобавляемыеПоля.Найти("_ALL") = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Если ТипОбъекта = ТипыОбъектовКластера().ИнформационныеБазы
	 ИЛИ ТипОбъекта = ТипыОбъектовКластера().Соединения Тогда
		Если НЕ ДобавляемыеПоля.Найти("_SUMMARY") = Неопределено И ЭтоПолеОсновногоОписанияОбъекта(ТипОбъекта, ИмяПоля) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;

	Если НЕ ДобавляемыеПоля.Найти(ВРег(ИмяПоля)) = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;

КонецФункции // НужноДобавлятьПоле()

Процедура ОбновитьКэшОписанийОбъектовКластеров(Знач ТипОбъекта, Знач Обновить = Ложь)

	Если НЕ НужноОбновитьОписанияОбъектовКластера(ТипОбъекта, Обновить) Тогда
		Возврат;
	КонецЕсли;

	ОписанияОбъектовКластеров = КэшОписанийОбъектовКластера(ТипОбъекта, Истина);
	Если ТипЗнч(ОписанияОбъектовКластеров) = Тип("Соответствие") Тогда
		ОписанияОбъектовКластеров.Очистить();
	КонецЕсли;

	Для Каждого ТекАгент Из Агенты Цикл

		Если НЕ ИспользоватьАгент(ТекАгент.Значение) Тогда
			Продолжить;
		КонецЕсли;

		ОписанияОбъектовАгента = ПолныеОписанияОбъектовАгента(ТекАгент.Значение.Агент, ТипОбъекта);
		
		Для Каждого ТекОписаниеОбъекта Из ОписанияОбъектовАгента Цикл
			Если ОписанияОбъектовКластеров[ТекОписаниеОбъекта.Значение[ТипОбъекта]] = Неопределено Тогда
				ОписанияОбъектовКластеров.Вставить(ТекОписаниеОбъекта.Значение[ТипОбъекта], ТекОписаниеОбъекта.Значение);
			КонецЕсли;
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры // ОбновитьКэшОписанийОбъектовКластеров()

Функция ОписаниеОбъектаКластера(ТипОбъекта,
	                            ПолноеОписаниеОбъекта,
	                            Знач Поля = "_all")

	Поля = ОбщегоНазначения.СписокПолей(Поля);

	ОписаниеОбъекта = Новый Соответствие();

	ПолноеОписаниеОтсутствует = Ложь;

	Для Каждого ТекПолеОписанияОбъекта Из ПолноеОписаниеОбъекта Цикл

		ИмяПоля = ТекПолеОписанияОбъекта.Ключ;
		ЗначениеПоля = ТекПолеОписанияОбъекта.Значение;

		Если НЕ НужноДобавлятьПоле(ТипОбъекта, Поля, ИмяПоля) Тогда
			Продолжить;
		КонецЕсли;

		ОписаниеОбъекта.Вставить(ИмяПоля, ЗначениеПоля);

	КонецЦикла;

	Возврат ОписаниеОбъекта;

КонецФункции // ОписаниеОбъектаКластера()

Функция КэшОписанийОбъектовКластера(Знач ТипОбъекта, Знач Очистить = Ложь)

	Если ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Кластеры) Тогда
		Если НЕ ТипЗнч(ОписанияКластеров) = Тип("Соответствие") Тогда
			ОписанияКластеров = Новый Соответствие();
		КонецЕсли;
		КэшОписанийОбъектов = ОписанияКластеров;
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Серверы) Тогда
		Если НЕ ТипЗнч(ОписанияСерверов) = Тип("Соответствие") Тогда
			ОписанияСерверов = Новый Соответствие();
		КонецЕсли;
		КэшОписанийОбъектов = ОписанияСерверов;
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().РабочиеПроцессы) Тогда
		Если НЕ ТипЗнч(ОписанияРабочихПроцессов) = Тип("Соответствие") Тогда
			ОписанияРабочихПроцессов = Новый Соответствие();
		КонецЕсли;
		КэшОписанийОбъектов = ОписанияРабочихПроцессов;
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().ИнформационныеБазы) Тогда
		Если НЕ ТипЗнч(ОписанияИнформационныхБаз) = Тип("Соответствие") Тогда
			ОписанияИнформационныхБаз = Новый Соответствие();
		КонецЕсли;
		КэшОписанийОбъектов = ОписанияИнформационныхБаз;
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Сеансы) Тогда
		Если НЕ ТипЗнч(ОписанияСеансов) = Тип("Соответствие") Тогда
			ОписанияСеансов = Новый Соответствие();
		КонецЕсли;
		КэшОписанийОбъектов = ОписанияСеансов;
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Соединения) Тогда
		Если НЕ ТипЗнч(ОписанияСоединений) = Тип("Соответствие") Тогда
			ОписанияСоединений = Новый Соответствие();
		КонецЕсли;
		КэшОписанийОбъектов = ОписанияСоединений;
	Иначе
		КэшОписанийОбъектов = Новый Соответствие();
	КонецЕсли;

	Если Очистить Тогда
		КэшОписанийОбъектов.Очистить();
	КонецЕсли;

	Возврат КэшОписанийОбъектов;

КонецФункции // КэшОписанийОбъектовКластера()

#КонецОбласти // ПолучениеДанныхСервисаАдминистрирования

#Область СлужебныеПроцедурыИФункции

Функция АгентДоступен(ОписаниеАгента)

	КластерыАгента = ПолучитьКластерыАгента(ОписаниеАгента);

	Если КластерыАгента = Неопределено Тогда
		КоличествоКластеров = 0;
	Иначе
		Попытка
			КоличествоКластеров = КластерыАгента.Количество();
		Исключение
			КоличествоКластеров = 0;
		КонецПопытки;
	КонецЕсли;

	Если КоличествоКластеров = 0 Тогда
		ТекстОшибки = СтрШаблон("При проверке доступности агента
		                        |не удалось получить список кластеров у сервиса администрирования ""%1"":%2%3",
		                        ОписаниеАгента.Агент.СтрокаПодключения());
		Сообщить(ТекстОшибки, СтатусСообщения.ОченьВажное);
		Возврат Ложь;
	КонецЕсли;

	Возврат Истина;

КонецФункции // АгентДоступен()

Функция ИспользоватьАгент(ОписаниеАгента, ПроверятьДоступность = Истина)

	// Если агент не доступен, то он не может использоваться
	Если ПроверятьДоступность И НЕ АгентДоступен(ОписаниеАгента) Тогда
		Возврат Ложь;
	КонецЕсли;

	// Если резервируемый агент не указан, то это основной агент и используется всегда
	Если НЕ ЗначениеЗаполнено(ОписаниеАгента.Резервирует) Тогда
		Возврат Истина;
	КонецЕсли;

	// Если резервируемый агент не обнаружен, то используем текущий
	Если НЕ (ТипЗнч(Агенты[ОписаниеАгента.Резервирует]) = Тип("Структура")
	   И Агенты[ОписаниеАгента.Резервирует].Свойство("Агент")) Тогда
		Возврат Истина;
	КонецЕсли;

	// Если не удалось получить кластеры резервируемого агента
	// или других резервных агентов того же кластера, то используем текущий
	Для Каждого ТекАгент Из Агенты Цикл
		
		Если ОписаниеАгента.Имя = ТекАгент.Значение.Имя Тогда
			Продолжить;
		КонецЕсли;
		
		Если ТекАгент.Значение.Имя = ОписаниеАгента.Резервирует
		 ИЛИ ТекАгент.Значение.Резервирует = ОписаниеАгента.Резервирует Тогда
			Если АгентДоступен(ТекАгент.Значение) Тогда
				Возврат Ложь;
			КонецЕсли;
		КонецЕсли;

	КонецЦикла;

	Возврат Истина;

КонецФункции // ИспользоватьАгент()

// Процедура - получает список кластеров агента и устанавливает параметры из настроек
//
// Параметры:
//   ОписаниеАгента   - Структура               - описание агента управления кластером 1С
//       *Имя             - Строка                 - имя агента управления кластером 1С
//       *Резервирует     - Строка                 - имя резервируемого агента управления кластером 1С
//       *Агент           - УправлениеКластером1С  - объект управления кластером 1С
//
Процедура ИнициализироватьКластерыАгента(ОписаниеАгента)
	
	Если НЕ ИспользоватьАгент(ОписаниеАгента, Ложь) Тогда
		Возврат;
	КонецЕсли;

	КластерыАгента = ПолучитьКластерыАгента(ОписаниеАгента);

	Если КластерыАгента = Неопределено Тогда
		ТекстОшибки = СтрШаблон("При инициализации кластеров
		                        |не удалось получить список кластеров у сервиса администрирования ""%1"".",
		                        ОписаниеАгента.Агент.СтрокаПодключения());
		Сообщить(ТекстОшибки, СтатусСообщения.ОченьВажное);
		Возврат;
	КонецЕсли;

	Для Каждого ТекКластер Из КластерыАгента Цикл
		Настройки.УстановитьПараметрыКластера(ТекКластер);
	КонецЦикла;

КонецПроцедуры // ИнициализироватьКластерыАгента()

// Функция - получает список кластеров агента
//
// Параметры:
//   ОписаниеАгента   - Структура               - описание агента управления кластером 1С
//       *Имя             - Строка                 - имя агента управления кластером 1С
//       *Резервирует     - Строка                 - имя резервируемого агента управления кластером 1С
//       *Агент           - УправлениеКластером1С  - объект управления кластером 1С
//
Функция ПолучитьКластерыАгента(ОписаниеАгента)
	
	КластерыАгента = Неопределено;

	// TODO: Обход проблемы отсутствия вывода команды rac cluster list
	КоличествоПопыток = Настройки.МаксПопытокИнициализацииКластера();
	ПопыткаПолучения = 1;
	ИнтервалПовторнойИнициализации = Настройки.ИнтервалПовторнойИнициализации();
	НачалоПопыткиПолучения = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Пока КластерыАгента = Неопределено И ПопыткаПолучения <= КоличествоПопыток Цикл
		ТекстОшибки = "";
		Попытка
			КластерыАгента = ОписаниеАгента.Агент.Кластеры().Список();
		Исключение
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			КластерыАгента = Неопределено;
		КонецПопытки;
		Если КластерыАгента = Неопределено И ПопыткаПолучения < КоличествоПопыток Тогда
			ТекстСообщения = СтрШаблон("Неудачная попытка (%1) получить список кластеров
			                           |у сервиса администрирования ""%2"", ожидаем %3:%4%5",
			                           ПопыткаПолучения,
			                           ОписаниеАгента.Агент.СтрокаПодключения(),
			                           ИнтервалПовторнойИнициализации * ПопыткаПолучения,
			                           Символы.ПС,
			                           ТекстОшибки);
			Сообщить(ТекстСообщения, СтатусСообщения.ОченьВажное);
			Приостановить(ИнтервалПовторнойИнициализации * ПопыткаПолучения);
		Иначе
			Прервать;
		КонецЕсли;
		ПопыткаПолучения = ПопыткаПолучения + 1;
	КонецЦикла;

	Возврат КластерыАгента;

КонецФункции // ПолучитьКластерыАгента()

Функция НужноОбновитьОписанияОбъектовКластера(Знач ТипОбъекта, Знач ОбновитьПринудительно = Ложь)

	Если ОбновитьПринудительно Тогда
		Возврат Истина;
	КонецЕсли;

	Результат = Ложь;
	
	Если ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Кластеры) Тогда
		Результат = НЕ ЗначениеЗаполнено(ОписанияКластеров);
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Серверы) Тогда
		Результат = НЕ ЗначениеЗаполнено(ОписанияСерверов);
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().РабочиеПроцессы) Тогда
		Результат = НЕ ЗначениеЗаполнено(ОписанияРабочихПроцессов);
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().ИнформационныеБазы) Тогда
		Результат = НЕ ЗначениеЗаполнено(ОписанияИнформационныхБаз);
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Сеансы) Тогда
		Результат = НЕ ЗначениеЗаполнено(ОписанияСеансов);
	ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Соединения) Тогда
		Результат = НЕ ЗначениеЗаполнено(ОписанияСоединений);
	Иначе
		Результат = Ложь;
	КонецЕсли;

	Если Результат Тогда
		Возврат Результат;
	КонецЕсли;

	Для Каждого ТекАгент Из Агенты Цикл

		Если НЕ ИспользоватьАгент(ТекАгент.Значение) Тогда
			Продолжить;
		КонецЕсли;

		Если ТипОбъекта = ТипыОбъектовКластера().Кластеры Тогда
			Если ТекАгент.Значение.Агент.Кластеры().ТребуетсяОбновление(0) Тогда
				Возврат Истина;
			КонецЕсли;
		Иначе
			СписокКластеров = ТекАгент.Значение.Агент.Кластеры().Список();
			Для Каждого ТекКластер Из СписокКластеров Цикл
				Если ТекКластер.Получить(ТипОбъекта).ТребуетсяОбновление(0) Тогда
					Возврат Истина;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;

	КонецЦикла;

	Возврат Результат;

КонецФункции // НужноОбновитьОписанияОбъектовКластера()

Функция ТипыОбъектовКластера()

	Возврат Перечисления.РежимыАдминистрирования;

КонецФункции // ТипыОбъектовКластера()

#КонецОбласти // СлужебныеПроцедурыИФункции
