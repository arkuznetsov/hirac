// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/hirac/
// ----------------------------------------------------------

// Обработчик действия state - проверка что сервис отзывается
//
&HTTPMethod("GET")
Функция state() Экспорт

	Возврат Содержимое("OK");

КонецФункции // state()

// Обработчик действия version - возвращает версию сервиса
//
&HTTPMethod("GET")
Функция version() Экспорт

	Параметры = Новый Соответствие();
	Параметры.Вставить("cmd", "--version");

	РезультатКоманды = ОбработкаКоманд.ВызватьУтилитуАдминистрирования(Параметры);

	Результат = Новый Структура();
	Результат.Вставить("hirac_version", ОбщегоНазначения.Версия());
	Результат.Вставить("rac_version"  , РезультатКоманды.version);
	Результат.Вставить("ras_version"  , РезультатКоманды.version); // TODO: Заменить на получение версии RAS

	Результат = ОбщегоНазначения.ДанныеВJSON(Результат);

	Возврат Содержимое(Результат);

КонецФункции // version()

// Обработчик действия run - выполняет переданную команду
//
&HTTPMethod("POST")
Функция run() Экспорт

	Если Настройки.ИспользоватьКоманды() Тогда
		Параметры = ОбщегоНазначения.ПрочитатьДанныеТелаЗапроса(ЗапросHTTP);

		РезультатКоманды = ОбработкаКоманд.ВызватьУтилитуАдминистрирования(Параметры);

		Если НЕ Параметры["pretty"] = Неопределено Тогда
			РезультатКоманды.output = ОбработкаКоманд.РазобратьВыводКоманды(РезультатКоманды.output);
		КонецЕсли;

		Результат = ОбщегоНазначения.ДанныеВJSON(РезультатКоманды);
	Иначе
		Результат = "Использование команд управления кластером отключено";
	КонецЕсли;

	Возврат Содержимое(Результат);

КонецФункции // run()
