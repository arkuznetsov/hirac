﻿#Использовать irac

Перем ПодключениеКАгентам;
Перем ИнформационныеБазы;

#Область ПрограммныйИнтерфейс

// Процедура инициализирует подключение к агентам управления кластерами
//
// Параметры:
//   НастройкиПодключения     - Строка,     - путь к файлу настроек управления кластерами
//                              Структура     или структура настроек управления кластерами
//
Процедура Инициализировать(Знач НастройкиПодключения = Неопределено) Экспорт

	ПодключениеКАгентам = Новый ПодключениеКАгентам(НастройкиПодключения);

КонецПроцедуры // Инициализировать()

// Функция - возвращает объект-подключение к агентам кластера 1С
//
// Возвращаемое значение:
//   ПодключениеКАгентам     - объект-подключение к агентам кластера 1С
//
Функция ПодключениеКАгентам() Экспорт
	
	Возврат ПодключениеКАгентам;

КонецФункции // ПодключениеКАгентам()

Процедура ОбновитьИБ(Знач Поля = "_all", Знач Фильтр = Неопределено) Экспорт

	Если ТипЗнч(Поля) = Тип("Строка") Тогда
		Поля = СтрРазделить(Поля, ",", Ложь);
		Для й = 0 По Поля.ВГраница() Цикл
			Поля[й] = ВРег(СокрЛП(Поля[й]));
		КонецЦикла;
	ИначеЕсли НЕ ТипЗнч(Поля) = Тип("Массив") Тогда
		Поля = Новый Массив();
		Поля.Добавить("_ALL");
	КонецЕсли;

	ИнформационныеБазы = Новый Массив();

	Для Каждого ТекАгент Из ПодключениеКАгентам.Агенты() Цикл

		ИБАгента = ИБАгента(ТекАгент.Значение, Поля);

		Для Каждого ТекИБ Из ИБАгента Цикл
			Если НЕ ОбщегоНазначения.ОбъектСоответствуетФильтру(ТекИБ, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			ИнформационныеБазы.Добавить(ТекИБ);
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры // ОбновитьИБ()

Функция ИнформационныеБазы(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьИБ(Поля, Фильтр);
	КонецЕсли;

	Возврат ИнформационныеБазы;

КонецФункции // ИнформационныеБазы()

Функция ИнформационнаяБаза(ИБ, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьИБ(Поля);
	КонецЕсли;

	Для Каждого ТекИБ Из ИнформационныеБазы Цикл
		Если ТекИБ["infobase"] = ИБ Тогда
			Возврат ТекИБ;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // ИнформационнаяБаза()

Функция Список() Экспорт

	Возврат ОбщегоНазначения.ДанныеВJSON(ИнформационныеБазы(Истина));
	
КонецФункции // Список()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПолучениеДанныхИБ

Функция ИБАгента(Знач Агент, Знач Поля)

	ИБАгента = Новый Массив();

	Кластеры = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		ИБКластера = ИБКластера(ТекКластер, Поля);

		Для Каждого ТекИБ Из ИБКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекИБ.Вставить("agent", СтрШаблон("%1:%2",
				                                  Агент.АдресСервераАдминистрирования(),
				                                  Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если НЕ (Поля.Найти("CLUSTER") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекИБ.Вставить("cluster" , ТекКластер.Ид());
				ТекИБ.Вставить("cluster_label",
				               СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекИБ.Вставить("count"   , 1);
			КонецЕсли;
	
			ИБАгента.Добавить(ТекИБ);

		КонецЦикла;

	КонецЦикла;

	Возврат ИБАгента;

КонецФункции // ИБАгента()

Функция ИБКластера(Знач Кластер, Знач Поля)

	ИБКластера = Новый Массив();
	
	СписокИБ = Кластер.ИнформационныеБазы().Список(, , Истина);

	ПоляИБ = Кластер.ИнформационныеБазы().ПараметрыОбъекта("ИмяРАК");

	Для Каждого ТекИБ Из СписокИБ Цикл

		ОписаниеИБ = Новый Соответствие();

		Для Каждого ТекЭлемент Из ПоляИБ Цикл
			Если Поля.Найти(ВРег(ТекЭлемент.Ключ)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекИБ[ТекЭлемент.Значение.Имя];
			ОписаниеИБ.Вставить(ТекЭлемент.Ключ, ЗначениеЭлемента);
		КонецЦикла;

		ИБКластера.Добавить(ОписаниеИБ);

	КонецЦикла;

	Возврат ИБКластера;
	
КонецФункции // ИБКластера()

#КонецОбласти // ПолучениеДанныхИБ

Инициализировать();
