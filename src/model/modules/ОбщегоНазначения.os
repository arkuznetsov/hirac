// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/hirac/
// ----------------------------------------------------------

// Функция - читает указанный макет JSON и возвращает содержимое в виде структуры/массива
//
// Параметры:
//	ПутьКМакету    - Строка   - путь к макету json
//
// Возвращаемое значение:
//	Структура, Массив       - прочитанные данные из макета 
//
Функция ПрочитатьДанныеИзМакетаJSON(Знач ПутьКМакету, Знач ВСоответствие = Ложь) Экспорт

	Чтение = Новый ЧтениеJSON();

	ПутьКМакету = ПолучитьМакет(ПутьКМакету);
	
	Чтение.ОткрытьФайл(ПутьКМакету, КодировкаТекста.UTF8);
	
	Возврат ПрочитатьJSON(Чтение, ВСоответствие);

КонецФункции // ПрочитатьДанныеИзМакетаJSON()

// Функция - ситает контрольную сумму указанного макета
//
// Параметры:
//	ПутьКМакету    - Строка   - путь к макету json
//
// Возвращаемое значение:
//	Строка       - строковое представление значениея хеш-функции от файла макета
//
Функция ХешМакета(Знач ПутьКМакету) Экспорт

	ПутьКМакету = ПолучитьМакет(ПутьКМакету);

	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.SHA1);
	ХешированиеДанных.ДобавитьФайл(ПутьКМакету);

	ДанныеХеша = ХешированиеДанных.ХешСумма;

	Возврат Base64Строка(ДанныеХеша);

КонецФункции // ХешМакета()

// Функция - читает данные из тела HTTP-запроса
//
// Параметры:
//	ЗапросHTTP    - ЗапросHTTPВходящий   - HTTP-запрос, тело которого читаем
//
// Возвращаемое значение:
//	Структура, Массив       - прочитанные данные из тела запроса 
//
Функция ПрочитатьДанныеТелаЗапроса(ЗапросHTTP) Экспорт

	Заголовки = ЗапросHTTP.Заголовки;

	ДанныеТелаПоток = ЗапросHTTP.ПолучитьТелоКакПоток();

	Чтение = Новый ЧтениеДанных(ДанныеТелаПоток);
	РезультатЧтения = Чтение.Прочитать();
	Данные = РезультатЧтения.ПолучитьДвоичныеДанные();
	
	Чтение = Новый ЧтениеJSON();
	Чтение.УстановитьСтроку(ПолучитьСтрокуИзДвоичныхДанных(Данные));

	Данные = ПрочитатьJSON(Чтение);

	Чтение.Закрыть();

	Возврат Данные;

КонецФункции // ПрочитатьДанныеТелаЗапроса()

// Функция проверяет, что переданное значение является GUID
//   
// Параметры:
//   Параметр      - Строка, Число     - значение для проверки
//
// Возвращаемое значение:
//    Булево       - Истина - значение является GUID
//
Функция ЭтоGUID(Параметр) Экспорт

	РВ = Новый РегулярноеВыражение("(?i)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}");
	
	Возврат РВ.Совпадает(Параметр);

КонецФункции // ЭтоGUID()

// Функция - возвращает Истина если значение является пустым GUID
//
// Параметры:
//    Значение      - Строка     - проверяемое значение
//
// Возвращаемое значение:
//    Булево     - Истина - значение является пустым GUID
//
Функция ЭтоПустойGUID(Значение) Экспорт

	Возврат (Значение = "00000000-0000-0000-0000-000000000000") ИЛИ НЕ ЗначениеЗаполнено(Значение);

КонецФункции // ЭтоПустойGUID()

// Процедура - убирает в строке начальные и конечные кавычки
//
// Параметры:
//	Значение    - Строка     - строка для обработки
//
// Возвращаемое значение:
//    Строка     - строка без кавычек
//
Процедура УбратьКавычки(Значение) Экспорт

	Если Лев(Значение, 1) = """"  И Прав(Значение, 1) = """" Тогда
		Значение = Сред(Значение, 2, СтрДлина(Значение) - 2);
	КонецЕсли;

КонецПроцедуры // УбратьКавычки()

// Процедура - выполняет преобразование переданных данных в JSON
//
// Параметры:
//    Данные       - Произвольный     - данные для преобразования
//
// Возвращаемое значение:
//    Строка     - результат преобразованияданные для преобразования
//
Функция ДанныеВJSON(Знач Данные) Экспорт
	
	Запись = Новый ЗаписьJSON();
	
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix, Символы.Таб));

	Попытка
		ЗаписатьJSON(Запись, Данные);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
	Возврат Запись.Закрыть();
	
КонецФункции // ДанныеВJSON()

// Функция возвращает структуру операторов сравнения
//
// Возвращаемое значение:
//    ФиксированнаяСтруктура - операторы сравнения
//
Функция ОператорыСравнения() Экспорт

	ОператорыСравнения = Новый Структура();

	ОператорыСравнения.Вставить("Равно"         , "EQ");
	ОператорыСравнения.Вставить("НеРавно"       , "NEQ");
	ОператорыСравнения.Вставить("Больше"        , "GT");
	ОператорыСравнения.Вставить("БольшеИлиРавно", "GTE");
	ОператорыСравнения.Вставить("Меньше"        , "LT");
	ОператорыСравнения.Вставить("МеньшеИлиРавно", "LTE");

	Возврат Новый ФиксированнаяСтруктура(ОператорыСравнения);

КонецФункции // ОператорыСравнения()

// Функция возвращает соответствия псевдонимов операторам сравнения
//
// Возвращаемое значение:
//    ФиксированноеСоответствие - псевдонимы операторов сравнения
//
Функция ПсевдонимыОператоровСравнения() Экспорт

	ОператорыСравнения = ОператорыСравнения();

	ПсевдонимыОператоров = Новый Соответствие();

	Для Каждого ТекЭлемент Из ОператорыСравнения Цикл
		ПсевдонимыОператоров.Вставить(ТекЭлемент.Значение, ТекЭлемент.Значение);
	КонецЦикла;

	ПсевдонимыОператоров.Вставить("EQUAL"             , ОператорыСравнения.Равно);
	ПсевдонимыОператоров.Вставить("NOTEQUAL"          , ОператорыСравнения.НеРавно);
	ПсевдонимыОператоров.Вставить("GREATERTHEN"       , ОператорыСравнения.Больше);
	ПсевдонимыОператоров.Вставить("GREATERTHENOREQUAL", ОператорыСравнения.БольшеИлиРавно);
	ПсевдонимыОператоров.Вставить("LESSTHEN"          , ОператорыСравнения.Меньше);
	ПсевдонимыОператоров.Вставить("LESSTHENOREQUAL"   , ОператорыСравнения.МеньшеИлиРавно);

	Возврат Новый ФиксированноеСоответствие(ПсевдонимыОператоров);

КонецФункции // ПсевдонимыОператоровСравнения()

// Функция получает список полей из строки или массива
//   
// Параметры:
//   Поля                - Массив, Строка  - список полей
//   ВсеПоля             - Строка          - строковое представления добавления всех полей
//
// Возвращаемое значение:
//    Массив из Строка   - список полей, если параметр не Массив или Строка,
//                         то результат содержит единственный элемент со значением параметра "ВсеПоля"
//
Функция СписокПолей(Знач Поля, Знач ВсеПоля = "_ALL") Экспорт

	Если ТипЗнч(Поля) = Тип("Строка") Тогда
		СписокПолей = СтрРазделить(Поля, ",", Ложь);
		Для й = 0 По СписокПолей.ВГраница() Цикл
			СписокПолей[й] = ВРег(СокрЛП(СписокПолей[й]));
		КонецЦикла;
	ИначеЕсли ТипЗнч(Поля) = Тип("Массив") Тогда
		СписокПолей = Новый Массив();
		Для й = 0 По Поля.ВГраница() Цикл
			СписокПолей.Добавить(ВРег(СокрЛП(Поля[й])));
		КонецЦикла;
	Иначе
		СписокПолей = Новый Массив();
		СписокПолей.Добавить(ВРег(ВсеПоля));
	КонецЕсли;

	Возврат СписокПолей;

КонецФункции // СписокПолей()

// Функция выполняет сравнение значений
//   
// Параметры:
//   ЛевоеЗначение      - Произвольный  - левое значение сравнения
//   Оператор           - Строка        - оператор сравнения
//   ПравоеЗначение     - Произвольный  - правое значение сравнения
//   РегистроНезависимо - Булево        - Истина - при сравнении на (не)равенство
//                                        не будет учитываться регистр сравниваемых значений
//
// Возвращаемое значение:
//    Булево            - Истина - сравнение истино
//
Функция СравнитьЗначения(Знач ЛевоеЗначение,
	                     Знач Оператор,
	                     Знач ПравоеЗначение,
	                     Знач РегистроНезависимо = Истина) Экспорт

	ОператорыСравнения = ОператорыСравнения();

	Результат = Ложь;

	Если РегистроНезависимо И (Оператор = ОператорыСравнения.Равно ИЛИ Оператор = ОператорыСравнения.НеРавно) Тогда
		ЛевоеЗначение  = ВРег(ЛевоеЗначение);
		ПравоеЗначение = ВРег(ПравоеЗначение);
	КонецЕсли;

	Если НЕ ТипЗнч(ЛевоеЗначение) = ТипЗнч(ПравоеЗначение) Тогда
		Если ТипЗнч(ЛевоеЗначение) = Тип("Число") Тогда
			ПравоеЗначение = Число(ПравоеЗначение);
		ИначеЕсли ТипЗнч(ЛевоеЗначение) = Тип("Дата") Тогда
			ПравоеЗначение = ПрочитатьДатуJSON(ПравоеЗначение, ФорматДатыJSON.ISO);
		ИначеЕсли ТипЗнч(ЛевоеЗначение) = Тип("Булево") Тогда
			ПравоеЗначение = ?(ВРег(ПравоеЗначение) = "TRUE" ИЛИ ВРег(ПравоеЗначение) = "ИСТИНА", Истина, Ложь);
		Иначе
			ЛевоеЗначение  = Строка(ЛевоеЗначение);
			ПравоеЗначение = Строка(ПравоеЗначение);
		КонецЕсли;
	КонецЕсли;
			
	
	Если Оператор = ОператорыСравнения.Равно И ЛевоеЗначение = ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.НеРавно И НЕ ЛевоеЗначение = ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.Больше И ЛевоеЗначение > ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.БольшеИлиРавно И ЛевоеЗначение >= ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.Меньше И ЛевоеЗначение < ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.МеньшеИлиРавно И ЛевоеЗначение <= ПравоеЗначение Тогда
		Результат = Истина;
	КонецЕсли;

	Возврат Результат;

КонецФункции // СравнитьЗначения()

// Функция проверяет соответствие значения указанному набору сравнений (фильтру)
// результаты сравнений объединяются по "И"
//   
// Параметры:
//   Значение           - Произвольный         - проверяемое значение
//   Фильтр             - Массив из Структура  - набор сравнений (фильтр)
//       * Оператор         - Строка               - оператор сравнения
//       * Значение         - Произвольный         - значение для сравнения
//   РегистроНезависимо - Булево               - Истина - при сравнении на (не)равенство
//   
// Возвращаемое значение:
//    Булево            - Истина - значение соответствует фильтру
//
Функция ЗначениеСоответствуетФильтру(Знач Значение, Знач Фильтр, Знач РегистроНезависимо = Истина) Экспорт

	Результат = Истина;

	Если НЕ (ЗначениеЗаполнено(Фильтр) И ТипЗнч(Фильтр) = Тип("Массив")) Тогда
		Возврат Результат;
	КонецЕсли;

	Для Каждого ТекСравнение Из Фильтр Цикл
		Если ТипЗнч(ТекСравнение.Значение) = Тип("Массив") Тогда
			Для Каждого ТекЗначение Из ТекСравнение.Значение Цикл
				Результат = СравнитьЗначения(Значение, ТекСравнение.Оператор, ТекЗначение, РегистроНезависимо);
				Если ТекСравнение.Оператор = ОператорыСравнения().Равно И Результат Тогда
					Прервать;
				ИначеЕсли НЕ ТекСравнение.Оператор = ОператорыСравнения().Равно И НЕ Результат Тогда
					Прервать;
				КонецЕсли;
			КонецЦикла;
		Иначе
			Результат = СравнитьЗначения(Значение, ТекСравнение.Оператор, ТекСравнение.Значение, РегистроНезависимо);
		КонецЕсли;
		Если НЕ Результат Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции // ЗначениеСоответствуетЭлементуФильтра()

// Функция проверяет соответствие значений полей объекта указанному набору сравнений (фильтру)
// результаты сравнений объединяются по "И"
//   
// Параметры:
//   Объект             - Соответствие         - проверяемый объект
//   Фильтр             - Массив из Структура  - набор сравнений (фильтр)
//       * Оператор         - Строка               - оператор сравнения
//       * Значение         - Произвольный         - значение для сравнения
//   РегистроНезависимо - Булево               - Истина - при сравнении на (не)равенство
//   
// Возвращаемое значение:
//    Булево            - Истина - значения полей объекта соответствует фильтру
//
Функция ОбъектСоответствуетФильтру(Объект, Фильтр, РегистроНезависимо = Истина) Экспорт

	Результат = Истина;

	Если НЕ (ЗначениеЗаполнено(Фильтр) И ТипЗнч(Фильтр) = Тип("Соответствие")) Тогда
		Возврат Результат;
	КонецЕсли;

	Для Каждого ТекЭлементФильтра Из Фильтр Цикл
		Если Объект[ТекЭлементФильтра.Ключ] = Неопределено Тогда
			Результат = Ложь;
			Прервать;
		КонецЕсли;
		Результат = ЗначениеСоответствуетФильтру(Объект[ТекЭлементФильтра.Ключ],
		                                         ТекЭлементФильтра.Значение,
		                                         РегистроНезависимо);
		Если НЕ Результат Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции // ОбъектСоответствуетФильтру()

// Функция выделяет фильтр из параметров запроса
//   
// Параметры:
//   ПараметрыЗапроса       - Соответствие       - параметры HTTP-запроса
//   
// Возвращаемое значение:
//    Соответствие                                   - фильтр
//        <имя поля>      - Массив из Структура      - фильтр для поля <имя поля>
//           * Оператор         - Строка                 - оператор сравнения
//           * Значение         - Произвольный           - значение для сравнения
//
Функция ФильтрИзПараметровЗапроса(ПараметрыЗапроса) Экспорт

	Фильтр = Новый Соответствие();
	ОператорыСравнения = ОператорыСравнения();
	ПсевдонимыОператоровСравнения = ПсевдонимыОператоровСравнения();

	Для Каждого ТекЭлемент Из ПараметрыЗапроса Цикл
		Если Лев(ВРег(ТекЭлемент.Ключ), 7) = ВРег("filter_") Тогда
			ИмяПоля = Сред(ТекЭлемент.Ключ, 8);
			Оператор = ОператорыСравнения().Равно;
			НачалоОператора = СтрНайти(ИмяПоля, "_", НаправлениеПоиска.СКонца);
			Если НачалоОператора > 0 Тогда
				ПсевдонимОператора = ВРег(Сред(ИмяПоля, НачалоОператора + 1));
				Если НЕ ПсевдонимыОператоровСравнения.Получить(ПсевдонимОператора) = Неопределено Тогда
					Оператор = ПсевдонимыОператоровСравнения[ПсевдонимОператора];
					ИмяПоля = Лев(ИмяПоля, НачалоОператора - 1);
				КонецЕсли;
			КонецЕсли;
	
			Если Фильтр[ИмяПоля] = Неопределено Тогда
				Фильтр.Вставить(ИмяПоля, Новый Массив());
			КонецЕсли;

			Фильтр[ИмяПоля].Добавить(Новый Структура("Оператор, Значение", Оператор, ТекЭлемент.Значение));
		КонецЕсли;
	КонецЦикла;

	Возврат Фильтр;

КонецФункции // ФильтрИзПараметровЗапроса()

Процедура СортироватьДанные(Данные, Знач НастройкаСортировки) Экспорт

	ПоляСортировки = Новый Массив();
	СтрокаСортировки = НастройкаСортировки;
	Если ТипЗнч(НастройкаСортировки) = Тип("Строка") Тогда
		ПоляСортировки = СтрРазделить(НастройкаСортировки, ",", Ложь);
	ИначеЕсли ТипЗнч(НастройкаСортировки) = Тип("Массив") Тогда
		Для Каждого ТекЭлемент Из НастройкаСортировки Цикл
			ПоляСортировки.Добавить(ТекЭлемент);
		КонецЦикла;
		СтрокаСортировки = СтрСоединить(НастройкаСортировки, ",");
	КонецЕсли;

	ТабСортировки = Новый ТаблицаЗначений();

	Для й = 0 По ПоляСортировки.ВГраница() Цикл
		ПолеСортировки = СокрЛП(ПоляСортировки[й]);
		ПозицияРазделителя = Найти(ПолеСортировки, " ");
		Если ПозицияРазделителя > 0 Тогда
			ПолеСортировки = Лев(ПолеСортировки, ПозицияРазделителя - 1);
		КонецЕсли;
		ПоляСортировки[й] = ПолеСортировки;
		ТабСортировки.Колонки.Добавить(ПолеСортировки);
	КонецЦикла;

	ТабСортировки.Колонки.Добавить("Элемент");

	Для Каждого ТекЭлемент Из Данные Цикл
		НоваяСтрока = ТабСортировки.Добавить();
		Для Каждого ТекПоле Из ПоляСортировки Цикл
			НоваяСтрока[ТекПоле] = ТекЭлемент.Получить(ТекПоле);
		КонецЦикла;
		НоваяСтрока.Элемент = ТекЭлемент;
	КонецЦикла;

	ТабСортировки.Сортировать(СтрокаСортировки);

	Данные = Новый Массив();

	Для Каждого ТекСтрока Из ТабСортировки Цикл
		Данные.Добавить(ТекСтрока.Элемент);
	КонецЦикла;

КонецПроцедуры // СортироватьДанные()

Функция Первые(Знач Элементы, Знач Количество) Экспорт

	Количество = Мин(Количество, Элементы.Количество());

	Результат = Новый Массив();

	Для й = 0 По Количество - 1 Цикл
		Результат.Добавить(Элементы[й]);
	КонецЦикла;

	Возврат Результат;

КонецФункции // Первые()

// Функция - возвращает коллекцию возможных форматов результата
//
// Возвращаемое значение:
//   ФиксированнаяСтруктура     - возможные форматы результата
//
Функция ФорматыРезультата() Экспорт

	Значения = Новый Структура();
	Значения.Вставить("Json"      , "JSON");
	Значения.Вставить("Prometheus", "PROMETHEUS");
	Значения.Вставить("Plain"     , "PLAIN");

	Возврат Новый ФиксированнаяСтруктура(Значения);

КонецФункции // ФорматыРезультата()

Функция Версия() Экспорт
	
	Возврат "0.5.0";

КонецФункции // Версия()