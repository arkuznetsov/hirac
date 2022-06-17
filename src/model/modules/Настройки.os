// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/hirac/
// ----------------------------------------------------------

#Использовать irac

Перем ХэшНастроек;                         // - Строка    - хеш макета настроек
Перем ОбновлениеНастроекПриИзменении;      // - Булево    - Истина - при изменении макета настроек,
                                           //                        настройки будут считаны заново;
Перем ВыполняетсяОбновлениеНастроек;       // - Булево    - Истина - на текущий момент выполняется
                                           //               обновление настроек в другом потоке;

Перем ПараметрыПодключения;                // - Структура - прочитанные параметры подключения к
                                           //               сервису администрирования и авторизации кластеров и ИБ

Перем КэшПараметровСУБДИБ;                 // - Соответствие   - кэш параметров подключения к СУБД информационных баз

Перем ИспользоватьКоманды;                 // - Булево    - Истина - включена возможность выполнения
                                           //                        команд управления кластером
                                           //               Ложь -возможность отключена
Перем КаталогСтруктурыХраненияИБ;          // - Строка    - путь к каталогу с файлами описаний
                                           //               структуры хранения данных информационных баз 1С
Перем РазмерПулаПодключений;               // - Число     - число одновременных подключений к сервису администрирования
Перем МаксПопытокИнициализацииКластера;    // - Число     - количество попыток инициализации кластера 1С
                                           //               обход проблемы с пусты выводом команды `rac cluster list`
Перем ИнтервалПовторнойИнициализации;      // - Число     - задержка перед повторным подключением (мсек.)
                                           //               умножается на номер попытки подключения
Перем ВремяОжиданияСвободногоПодключения;  // - Число     - время ожидания свободного подключения (мсек.),
                                           //               после которого будет сообщено об ошибке подключения
Перем МаксВремяБлокировкиПодключения;      // - Число     - максимальное время блокировки подключения (мсек.)
                                           //               после которого подключение будет принудительно освобождено

Перем ЛогироватьЗамерыВремени;             // - Булево    - Истина - будет выполняться логирование
                                           //               времени выполнения запросов в файл
Перем ФайлЛогаЗамеровВремени;              // - Строка    - путь к файлу лога замеров времени

#Область ПрограммныйИнтерфейс

// Процедура - инициализирует модуль и читает переданные настройки или настройки из файла "racsettings.json"
//
// Параметры:
//   НовыеНастройкиПодключения   - Соответствие  - настройки из которых будут заполняться параметры
//
Процедура Инициализация(Знач НовыеНастройкиПодключения = Неопределено) Экспорт

	ВыполняетсяОбновлениеНастроек = Истина;

	Если ТипЗнч(НовыеНастройкиПодключения) = Тип("Структура")
	 ИЛИ ТипЗнч(НовыеНастройкиПодключения) = Тип("Соответствие") Тогда
		НастройкиДляУстановки = НовыеНастройкиПодключения;
		ОбновлениеНастроекПриИзменении = Ложь;
	ИначеЕсли ТипЗнч(НовыеНастройкиПодключения) = Тип("Строка") Тогда
		НастройкиДляУстановки = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON(НовыеНастройкиПодключения, Истина);
		ОбновлениеНастроекПриИзменении = Ложь;
	Иначе
		НастройкиДляУстановки = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON("/config/racsettings", Истина);
		ХэшНастроек = ОбщегоНазначения.ХешМакета("/config/racsettings");
		ОбновлениеНастроекПриИзменении = Истина;
	КонецЕсли;
	
	ЗаполнитьПараметрыПодключения(НастройкиДляУстановки);
	
	ЗаполнитьПараметры(НастройкиДляУстановки);

	ВыполняетсяОбновлениеНастроек = Ложь;

КонецПроцедуры // Инициализация()

// Функция - возвращает флаг необходимости обновления настроек при изменении макета настроек
//
// Возвращаемое значение:
//   Булево               - флаг необходимости обновления настроек при изменении макета настроек
//
Функция ОбновлениеНастроекПриИзменении() Экспорт

	Возврат ОбновлениеНастроекПриИзменении;

КонецФункции // ОбновлениеНастроекПриИзменении()

// Процедура - устанавливает флаг необходимости обновления настроек при изменении макета настроек
//
// Параметры:
//   НовоеЗначение     - Булево         - новое значение флага необходимости обновления настроек
//                                        при изменении макета настроек
//
Процедура УстановитьОбновлениеНастроекПриИзменении(Знач НовоеЗначение) Экспорт

	ОбновлениеНастроекПриИзменении = НовоеЗначение;

КонецПроцедуры // ОбновлениеНастроекПриИзменении()

// Функция - возвращает текущее значение хэша макета настроек подключения к сервису администрирования
// и авторизации кластеров и ИБ
//
// Возвращаемое значение:
//   Строка    - текущее значение хэша макета настроек
//
Функция ХэшНастроек() Экспорт

	Возврат ХэшНастроек;

КонецФункции // ХэшНастроек()

// Функция - возвращает параметры подключения к сервису администрирования
// и авторизации кластеров и ИБ
//
// Возвращаемое значение:
//   Структура               - параметры подключения
//      *Агенты    - Структура   - параметры подключения к сервисам аднистрирования 1С
//      *Кластеры  - Структура   - параметры авторизации кластеров и ИБ
//
Функция ПараметрыПодключения() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ПараметрыПодключения;

КонецФункции // ПараметрыПодключения()

// Функция - возвращает параметры подключения к СУБД для указанной информационной базы 1С
//
// Параметры:
//   ИБ_Ид    - Строка, ИнформационнаяБаза   - идентификатор ИБ в кластере или объект ИБ
//
// Возвращаемое значение:
//   Структура                                  - параметры подключения к СУБД информационной базы
//     * СУБД_Тип                     - Строка    - тип СУБД (MSSQLServer, PostgreSQL, IBMDB2, OracleDatabase)
//     * СУБД_Сервер                  - Строка    - адрес сервера СУБД
//     * СУБД_Пользователь            - Строка    - имя пользователя СУБД
//     * СУБД_Пароль                  - Строка    - пароль пользователя СУБД
//     * СУБД_База                    - Строка    - имя базы на сервере СУБД
//     * СУБД_ВремяЖизни_Структуры    - Строка    - период актуальности структуры хранения базы данных
//     * СУБД_ВремяЖизни_БД           - Строка    - период актуальности информации о базе данных
//     * СУБД_ВремяЖизни_Таблиц       - Строка    - период актуальности информации о таблицах базы данных
//
Функция ПараметрыСУБДИБ(Знач ИБ_Ид) Экспорт

	Если ТипЗнч(ИБ_Ид) = Тип("ИнформационнаяБаза") Тогда
		ИБ_Ид = ИБ_Ид.Ид();
	КонецЕсли;
	
	Если ТипЗнч(КэшПараметровСУБДИБ) = Тип("Соответствие") Тогда
		Возврат КэшПараметровСУБДИБ.Получить(ИБ_Ид);
	КонецЕсли;

	Возврат СтруктураПараметровИБ();

КонецФункции // ПараметрыСУБДИБ()

// Функция - возвращает флаг возможности использования команд управления кластером
//
// Возвращаемое значение:
//   Число     - флаг возможности использования команд управления кластером
//
Функция ИспользоватьКоманды() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ИспользоватьКоманды;

КонецФункции // ИспользоватьКоманды()

// Функция - возвращает путь к каталогу с файлами описаний структуры хранения данных информационных баз 1С
//
// Возвращаемое значение:
//   Строка    - путь к каталогу с файлами описаний структуры хранения данных информационных баз 1С
//
Функция КаталогСтруктурыХраненияИБ() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат КаталогСтруктурыХраненияИБ;

КонецФункции // КаталогСтруктурыХраненияИБ()

// Функция - возвращает число одновременных подключений к сервису администрирования
//
// Возвращаемое значение:
//   Число     - число одновременных подключений к сервису администрирования
//
Функция РазмерПулаПодключений() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат РазмерПулаПодключений;

КонецФункции // РазмерПулаПодключений()

// Функция - возвращает количество попыток инициализации кластера 1С
// обход проблемы с пусты выводом команды `rac cluster list`
//
// Возвращаемое значение:
//   Число     - количество попыток инициализации кластера 1С
//
Функция МаксПопытокИнициализацииКластера() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат МаксПопытокИнициализацииКластера;

КонецФункции // МаксПопытокИнициализацииКластера()

// Функция - возвращает задержку перед повторным подключением к кластеру 1С (мсек.)
// умножается на номер попытки подключения
//
// Возвращаемое значение:
//   Число     - задержка перед повторным подключением (мсек.)
//
Функция ИнтервалПовторнойИнициализации() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ИнтервалПовторнойИнициализации;

КонецФункции // ИнтервалПовторнойИнициализации()

// Функция - возвращает время ожидания свободного подключения (мсек.),
// после которого будет сообщено об ошибке подключения
//
// Возвращаемое значение:
//   Число     - время ожидания свободного подключения (мсек.)
//
Функция ВремяОжиданияСвободногоПодключения() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ВремяОжиданияСвободногоПодключения;

КонецФункции // ВремяОжиданияСвободногоПодключения()

// Функция - возвращает максимальное время блокировки подключения (мсек.)
// после которого подключение будет принудительно освобождено
//
// Возвращаемое значение:
//   Число     - максимальное время блокировки подключения (мсек.)
//
Функция МаксВремяБлокировкиПодключения() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат МаксВремяБлокировкиПодключения;

КонецФункции // МаксВремяБлокировкиПодключения()

// Функция - возвращает флаг логирования замеров времени
//
// Возвращаемое значение:
//   Булево    - Истина - будет выполняться логирование
//                        времени выполнения запросов в файл
//
Функция ЛогироватьЗамерыВремени() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ЛогироватьЗамерыВремени;

КонецФункции // ЛогироватьЗамерыВрени()

// Функция - возвращает путь к файлу лога замеров времени
//
// Возвращаемое значение:
//   Строка    - путь к файлу лога замеров времени
//
Функция ФайлЛогаЗамеровВремени() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ФайлЛогаЗамеровВремени;

КонецФункции // ФайлЛогаЗамеровВремени()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ЧтениеНастроек

// Процедура - заполняет параметры подключения к сервису администрирования 
// и авторизации кластеров из переданных настроек
//
// Параметры:
//   НастройкиДляУстановки   - Соответствие  - настройки из которых будут заполняться параметры
//
Процедура ЗаполнитьПараметрыПодключения(НастройкиДляУстановки)

	НастройкиАгентов   = ПолучитьЗначениеНастройки("ras"    , НастройкиДляУстановки);
	НастройкиКластеров = ПолучитьЗначениеНастройки("cluster", НастройкиДляУстановки);

	ПараметрыАгентов = Новый Соответствие();
	ИдентификаторыАгентов = Новый Массив();

	Для Каждого ТекНастройки Из НастройкиАгентов Цикл
	
		Если ВРег(ТекНастройки.Ключ) = "__DEFAULT" И НЕ НастройкиАгентов.Количество() = 1 Тогда
			Продолжить;
		КонецЕсли;

		ПараметрыАгента = ПараметрыАгента(ТекНастройки.Ключ, НастройкиАгентов);

		ПараметрыАгентов.Вставить(ВРег(ТекНастройки.Ключ), ПараметрыАгента);

		ИдентификаторыАгентов.Добавить(ВРег(ТекНастройки.Ключ));

	КонецЦикла;

	ПараметрыКластеров = Новый Соответствие();

	Для Каждого ТекНастройки Из НастройкиКластеров Цикл
	
		ПараметрыКластера = ПараметрыКластера(ТекНастройки.Ключ, НастройкиКластеров);

		Если ВРег(ТекНастройки.Ключ) = "__DEFAULT" Тогда
			КлючНастроек = "ПОУМОЛЧАНИЮ";
		Иначе
			КлючНастроек = ВРег(ТекНастройки.Ключ);
		КонецЕсли;

		ПараметрыКластеров.Вставить(КлючНастроек, ПараметрыКластера);

	КонецЦикла;

	ПараметрыПодключения = Новый Структура();
	ПараметрыПодключения.Вставить("Агенты"               , ПараметрыАгентов);
	ПараметрыПодключения.Вставить("ИдентификаторыАгентов", ИдентификаторыАгентов);
	ПараметрыПодключения.Вставить("Кластеры"             , ПараметрыКластеров);

КонецПроцедуры // ЗаполнитьПараметрыПодключения()

// Процедура - заполняет параметры подключения к сервису администрирования 
// и авторизации кластеров из переданных настроек
//
// Параметры:
//   НастройкиДляУстановки   - Соответствие  - настройки из которых будут заполняться параметры
//
Процедура ЗаполнитьПараметры(НастройкиДляУстановки)

	ИспользоватьКоманды                = ПолучитьЗначениеНастройки("useCommands"             , НастройкиДляУстановки);
	КаталогСтруктурыХраненияИБ         = ПолучитьЗначениеНастройки("dbStructCache"           , НастройкиДляУстановки);
	РазмерПулаПодключений              = ПолучитьЗначениеНастройки("connectionPoolSize"      , НастройкиДляУстановки);
	МаксПопытокИнициализацииКластера   = ПолучитьЗначениеНастройки("reconnectAtempts"        , НастройкиДляУстановки);
	ИнтервалПовторнойИнициализации     = ПолучитьЗначениеНастройки("reconnectInterval"       , НастройкиДляУстановки);
	ВремяОжиданияСвободногоПодключения = ПолучитьЗначениеНастройки("connectionWait"          , НастройкиДляУстановки);
	МаксВремяБлокировкиПодключения     = ПолучитьЗначениеНастройки("connectionLockInterval"  , НастройкиДляУстановки);
	ЛогироватьЗамерыВремени            = ПолучитьЗначениеНастройки("logQueryDuration"        , НастройкиДляУстановки);
	ФайлЛогаЗамеровВремени             = ПолучитьЗначениеНастройки("queryDurationLogFilename", НастройкиДляУстановки);

	Если ИспользоватьКоманды = Неопределено Тогда
		ИспользоватьКоманды = Ложь;
	КонецЕсли;
	Если РазмерПулаПодключений = Неопределено Тогда
		РазмерПулаПодключений = 10;
	КонецЕсли;
	Если МаксПопытокИнициализацииКластера = Неопределено Тогда
		МаксПопытокИнициализацииКластера = 3;
	КонецЕсли;
	Если ИнтервалПовторнойИнициализации = Неопределено Тогда
		ИнтервалПовторнойИнициализации = 1500;
	КонецЕсли;
	Если ВремяОжиданияСвободногоПодключения = Неопределено Тогда
		ВремяОжиданияСвободногоПодключения = 10000;
	КонецЕсли;
	Если МаксВремяБлокировкиПодключения = Неопределено Тогда
		МаксВремяБлокировкиПодключения = 90000;
	КонецЕсли;
	Если ЛогироватьЗамерыВремени = Неопределено Тогда
		ЛогироватьЗамерыВремени = Ложь;
	КонецЕсли;
	Если КаталогСтруктурыХраненияИБ = Неопределено Тогда
		ВремФайл = Новый Файл("./config/dbmap");
		КаталогСтруктурыХраненияИБ = ВремФайл.ПолноеИмя;
	КонецЕсли;

КонецПроцедуры // ЗаполнитьПараметры()

// Функция - получает описание структуры параметров агента кластера 1С
//
// Возвращаемое значение:
//   Структура                          - параметры агента кластера 1С
//       *АдресСервиса    - Строка          - адрес подключения к сервису администрирования 1С
//       *ВерсияКлиента   - Строка          - версия утилиты RAC
//       *Резервирует     - Строка          - имя резервного сервиса
//       *Администратор   - Строка          - имя администратора
//       *Пароль          - Строка          - пароль администратора
//
Функция СтруктураПараметровАгента()

	СтруктураПараметров = Новый Структура();
	СтруктураПараметров.Вставить("АдресСервиса" , "localhost:1545");
	СтруктураПараметров.Вставить("ВерсияКлиента", "8.3");
	СтруктураПараметров.Вставить("Резервирует"  , "");
	СтруктураПараметров.Вставить("Администратор", "");
	СтруктураПараметров.Вставить("Пароль"       , "");

	Возврат СтруктураПараметров;

КонецФункции // СтруктураПараметровАгента()

// Функция - получает описание структуры параметров кластера 1С
//
// Возвращаемое значение:
//   Структура                          - параметры кластера 1С
//       *Администратор   - Строка          - имя администратора кластера
//       *Пароль          - Строка          - пароль администратора кластера
//       *ИБ              - Соответствие    - параметры информационных баз в кластере
//
Функция СтруктураПараметровКластера()

	СтруктураПараметровИБ = Новый Соответствие();
	СтруктураПараметровИБ.Вставить("ПОУМОЛЧАНИЮ", СтруктураПараметровИБ());

	СтруктураПараметров = Новый Структура();
	СтруктураПараметров.Вставить("Администратор", "");
	СтруктураПараметров.Вставить("Пароль"       , "");
	СтруктураПараметров.Вставить("ИБ"           , СтруктураПараметровИБ);

	Возврат СтруктураПараметров;

КонецФункции // СтруктураПараметровКластера()

// Функция - получает описание структуры параметров информационной базы 1С
//
// Возвращаемое значение:
//   Структура                                - параметры информационной базы 1С
//     * Администратор                - Строка    - имя администратора ИБ
//     * Пароль                       - Строка    - пароль администратора ИБ
//     * СУБД_Тип                     - Строка    - тип СУБД (MSSQLServer, PostgreSQL, IBMDB2, OracleDatabase)
//     * СУБД_Сервер                  - Строка    - адрес сервера СУБД
//     * СУБД_Пользователь            - Строка    - имя пользователя СУБД
//     * СУБД_Пароль                  - Строка    - пароль пользователя СУБД
//     * СУБД_База                    - Строка    - имя базы на сервере СУБД
//     * СУБД_ВремяЖизни_Структуры    - Строка    - период актуальности информации о базе данных
//     * СУБД_ВремяЖизни_БД           - Строка    - период актуальности информации о базе данных
//     * СУБД_ВремяЖизни_Таблиц       - Строка    - период актуальности информации о таблицах базы данных
//
Функция СтруктураПараметровИБ()

	СтруктураПараметров = Новый Структура();
	СтруктураПараметров.Вставить("Администратор"            , "");
	СтруктураПараметров.Вставить("Пароль"                   , "");
	СтруктураПараметров.Вставить("СУБД_Тип"                 , Перечисления.ТипыСУБД.MSSQLServer);
	СтруктураПараметров.Вставить("СУБД_Сервер"              , "localhost");
	СтруктураПараметров.Вставить("СУБД_Пользователь"        , "");
	СтруктураПараметров.Вставить("СУБД_Пароль"              , "");
	СтруктураПараметров.Вставить("СУБД_База"                , "");
	СтруктураПараметров.Вставить("СУБД_ВремяЖизни_Структуры", 3600000);
	СтруктураПараметров.Вставить("СУБД_ВремяЖизни_БД"       , 600000);
	СтруктураПараметров.Вставить("СУБД_ВремяЖизни_Таблиц"   , 600000);

	Возврат СтруктураПараметров;

КонецФункции // СтруктураПараметровИБ()

// Функция - получает параметры агента кластера 1С
//
// Параметры:
//   Сервис                  - Строка        - идентификатор агента
//   НастройкиДляУстановки   - Соответствие  - настройки для чтения
//
// Возвращаемое значение:
//   Структура                          - параметры авторизации
//       *АдресСервиса    - Строка          - адрес подключения к сервису администрирования 1С
//       *ВерсияКлиента   - Строка          - версия утилиты RAC
//       *Резервирует     - Строка          - имя резервного сервиса
//       *Администратор   - Строка          - имя администратора
//       *Пароль          - Строка          - пароль администратора
//
Функция ПараметрыАгента(Сервис, НастройкиДляУстановки)

	ПараметрыПоУмолчанию = ПолучитьЗначениеНастройки("__default", НастройкиДляУстановки);
	ПараметрыПоИмени     = ПолучитьЗначениеНастройки(Сервис     , НастройкиДляУстановки);

	АдресСервисаПоУмолчанию  = ПолучитьЗначениеНастройки("ras"       , ПараметрыПоУмолчанию, "localhost:1545");
	ВерсияКлиентаПоУмолчанию = ПолучитьЗначениеНастройки("rac"       , ПараметрыПоУмолчанию, "8.3");
	
	АдресСервиса  = ПолучитьЗначениеНастройки("ras"       , ПараметрыПоИмени, АдресСервисаПоУмолчанию);
	ВерсияКлиента = ПолучитьЗначениеНастройки("rac"       , ПараметрыПоИмени, ВерсияКлиентаПоУмолчанию);
	Резервирует   = ПолучитьЗначениеНастройки("reserves"  , ПараметрыПоИмени, "");

	ПараметрыАвторизации = ПараметрыАвторизации(Сервис, НастройкиДляУстановки);

	ПараметрыСервиса = СтруктураПараметровАгента();
	ПараметрыСервиса.АдресСервиса  = АдресСервиса;
	ПараметрыСервиса.ВерсияКлиента = ВерсияКлиента;
	ПараметрыСервиса.Резервирует   = Резервирует;
	ПараметрыСервиса.Администратор = ПараметрыАвторизации.Администратор;
	ПараметрыСервиса.Пароль        = ПараметрыАвторизации.Пароль;

	Возврат ПараметрыСервиса;

КонецФункции // ПараметрыАгента()

// Функция - получает параметры для кластера
//
// Параметры:
//   МеткаКластера           - Строка        - ключ набора параметров
//   НастройкиДляУстановки   - Соответствие  - настройки для чтения
//
// Возвращаемое значение:
//   Структура                          - параметры авторизации
//       *Администратор   - Строка          - имя администратора
//       *Пароль          - Строка          - пароль администратора
//       *ИБ              - Соответствие    - параметры информационных баз в кластере
//
Функция ПараметрыКластера(МеткаКластера, НастройкиДляУстановки)
	
	ПараметрыПоУмолчанию = ПолучитьЗначениеНастройки("__default", НастройкиДляУстановки);
	ПараметрыПоИмени     = ПолучитьЗначениеНастройки(МеткаКластера, НастройкиДляУстановки);
	НастройкиИБ          = ПолучитьЗначениеНастройки("infobase"   , ПараметрыПоИмени);

	ПараметрыАвторизации = ПараметрыАвторизации(МеткаКластера, НастройкиДляУстановки);

	ПараметрыКластера = СтруктураПараметровКластера();
	ПараметрыКластера.Вставить("Администратор", ПараметрыАвторизации.Администратор);
	ПараметрыКластера.Вставить("Пароль"       , ПараметрыАвторизации.Пароль);

	ТолькоИБИзСпискаПоУмолчанию  = ПолучитьЗначениеНастройки("selected_infobases_only", ПараметрыПоУмолчанию, Ложь);
	ТолькоИБИзСписка             = ПолучитьЗначениеНастройки("selected_infobases_only",
	                                                         ПараметрыПоИмени,
	                                                         ТолькоИБИзСпискаПоУмолчанию);
	ПараметрыКластера.Вставить("ТолькоИБИзСписка", ТолькоИБИзСписка);

	Если ТипЗнч(НастройкиИБ) = Тип("Соответствие") Тогда
		
		Для Каждого ТекНастройки Из НастройкиИБ Цикл
		
			ПараметрыИБ = СтруктураПараметровИБ();

			ПараметрыАвторизации = ПараметрыАвторизации(ТекНастройки.Ключ, НастройкиИБ);

			ЗаполнитьЗначенияСвойств(ПараметрыИБ, ПараметрыАвторизации);

			ПараметрыСУБД = ПараметрыПодключенияКСУБД(ТекНастройки.Ключ, НастройкиИБ);

			ЗаполнитьЗначенияСвойств(ПараметрыИБ, ПараметрыСУБД);

			Если ВРег(ТекНастройки.Ключ) = "__DEFAULT" Тогда
				КлючНастроек = "ПОУМОЛЧАНИЮ";
			Иначе
				КлючНастроек = ВРег(ТекНастройки.Ключ);
			КонецЕсли;

			ПараметрыКластера.ИБ.Вставить(КлючНастроек, ПараметрыИБ);

		КонецЦикла;

	КонецЕсли;

	Возврат ПараметрыКластера;

КонецФункции // ПараметрыКластера()

// Функция - получает параметры авторизации из переданных настроек
//
// Параметры:
//   КлючПараметров          - Строка        - ключ набора параметров
//   НастройкиДляУстановки   - Соответствие  - настройки для чтения
//
// Возвращаемое значение:
//   Структура                       - параметры авторизации
//       *Администратор   - Строка        - имя администратора
//       *Пароль          - Строка        - пароль администратора
//
Функция ПараметрыАвторизации(КлючПараметров, НастройкиДляУстановки)
	
	ПараметрыПоУмолчанию = ПолучитьЗначениеНастройки("__default", НастройкиДляУстановки);
	ПараметрыПоИмени     = ПолучитьЗначениеНастройки(КлючПараметров, НастройкиДляУстановки);

	АдминистраторПоУмолчанию = ПолучитьЗначениеНастройки("admin_name", ПараметрыПоУмолчанию, "");
	ПарольПоУмолчанию        = ПолучитьЗначениеНастройки("admin_pwd" , ПараметрыПоУмолчанию, "");
	
	Администратор = ПолучитьЗначениеНастройки("admin_name", ПараметрыПоИмени, АдминистраторПоУмолчанию);
	Пароль        = ПолучитьЗначениеНастройки("admin_pwd" , ПараметрыПоИмени, ПарольПоУмолчанию);

	ПараметрыАвторизации = Новый Структура();
	ПараметрыАвторизации.Вставить("Администратор", Администратор);
	ПараметрыАвторизации.Вставить("Пароль"       , Пароль);

	Возврат ПараметрыАвторизации;

КонецФункции // ПараметрыАвторизации()

// Функция - получает параметры подключения к СУБД
//
// Параметры:
//   КлючПараметров           - Строка          - ключ набора параметров
//   НастройкиДляУстановки    - Соответствие    - настройки для чтения
//
// Возвращаемое значение:
//   Структура                                 - параметры авторизации
//     * СУБД_Тип                     - Строка    - тип СУБД (MSSQLServer, PostgreSQL, IBMDB2, OracleDatabase)
//     * СУБД_Сервер                  - Строка    - адрес сервера СУБД
//     * СУБД_Пользователь            - Строка    - имя пользователя СУБД
//     * СУБД_Пароль                  - Строка    - пароль пользователя СУБД
//     * СУБД_База                    - Строка    - имя базы на сервере СУБД
//     * СУБД_ВремяЖизни_Структуры    - Строка    - период актуальности структуры хранения базы данных
//     * СУБД_ВремяЖизни_БД           - Строка    - период актуальности информации о базе данных
//     * СУБД_ВремяЖизни_Таблиц       - Строка    - период актуальности информации о таблицах базы данных
//
Функция ПараметрыПодключенияКСУБД(КлючПараметров, НастройкиДляУстановки)
	
	ПараметрыПоУмолчанию = ПолучитьЗначениеНастройки("__default", НастройкиДляУстановки);
	ПараметрыПоИмени     = ПолучитьЗначениеНастройки(КлючПараметров, НастройкиДляУстановки);

	СУБД_ТипПоУмолчанию          = ПолучитьЗначениеНастройки("dbms_type",
	                                                        ПараметрыПоУмолчанию,
	                                                        Перечисления.ТипыСУБД.MSSQLServer);
	СУБД_СерверПоУмолчанию       = ПолучитьЗначениеНастройки("dbms_server", ПараметрыПоУмолчанию, "localhost");
	СУБД_ПользовательПоУмолчанию = ПолучитьЗначениеНастройки("dbms_user"  , ПараметрыПоУмолчанию);
	СУБД_ПарольПоУмолчанию       = ПолучитьЗначениеНастройки("dbms_pwd"   , ПараметрыПоУмолчанию);
	СУБД_БазаПоУмолчанию         = ПолучитьЗначениеНастройки("dbms_base"  , ПараметрыПоУмолчанию);
	
	СУБД_ВремяЖизни_СтруктурыПоУмолчанию = ПолучитьЗначениеНастройки("dbms_dbstruct_lifetime",
	                                                                 ПараметрыПоУмолчанию,
	                                                                 600000);
	СУБД_ВремяЖизни_БДПоУмолчанию        = ПолучитьЗначениеНастройки("dbms_db_lifetime",
	                                                                 ПараметрыПоУмолчанию,
	                                                                 600000);
	СУБД_ВремяЖизни_ТаблицПоУмолчанию    = ПолучитьЗначениеНастройки("dbms_tables_lifetime",
	                                                                 ПараметрыПоУмолчанию,
	                                                                 600000);

	СУБД_Тип               = ПолучитьЗначениеНастройки("dbms_type"  , ПараметрыПоИмени, СУБД_ТипПоУмолчанию);
	СУБД_Сервер            = ПолучитьЗначениеНастройки("dbms_server", ПараметрыПоИмени, СУБД_СерверПоУмолчанию);
	СУБД_Пользователь      = ПолучитьЗначениеНастройки("dbms_user"  , ПараметрыПоИмени, СУБД_ПользовательПоУмолчанию);
	СУБД_Пароль            = ПолучитьЗначениеНастройки("dbms_pwd"   , ПараметрыПоИмени, СУБД_ПарольПоУмолчанию);
	СУБД_База              = ПолучитьЗначениеНастройки("dbms_base"  , ПараметрыПоИмени, СУБД_БазаПоУмолчанию);
	
	СУБД_ВремяЖизни_Структуры = ПолучитьЗначениеНастройки("dbms_dbstruct_lifetime",
	                                                      ПараметрыПоИмени,
	                                                      СУБД_ВремяЖизни_СтруктурыПоУмолчанию);
	СУБД_ВремяЖизни_БД        = ПолучитьЗначениеНастройки("dbms_db_lifetime",
	                                                      ПараметрыПоИмени,
	                                                      СУБД_ВремяЖизни_БДПоУмолчанию);
	СУБД_ВремяЖизни_Таблиц    = ПолучитьЗначениеНастройки("dbms_tables_lifetime",
	                                                      ПараметрыПоИмени,
	                                                      СУБД_ВремяЖизни_ТаблицПоУмолчанию);

	ПараметрыПодключенияКСУБД = Новый Структура();
	ПараметрыПодключенияКСУБД.Вставить("СУБД_Тип"                 , СУБД_Тип);
	ПараметрыПодключенияКСУБД.Вставить("СУБД_Сервер"              , СУБД_Сервер);
	ПараметрыПодключенияКСУБД.Вставить("СУБД_Пользователь"        , СУБД_Пользователь);
	ПараметрыПодключенияКСУБД.Вставить("СУБД_Пароль"              , СУБД_Пароль);
	ПараметрыПодключенияКСУБД.Вставить("СУБД_База"                , СУБД_База);
	ПараметрыПодключенияКСУБД.Вставить("СУБД_ВремяЖизни_Структуры", СУБД_ВремяЖизни_Структуры);
	ПараметрыПодключенияКСУБД.Вставить("СУБД_ВремяЖизни_БД"       , СУБД_ВремяЖизни_БД);
	ПараметрыПодключенияКСУБД.Вставить("СУБД_ВремяЖизни_Таблиц"   , СУБД_ВремяЖизни_Таблиц);

	Возврат ПараметрыПодключенияКСУБД;

КонецФункции // ПараметрыПодключенияКСУБД()

// Функция - получает значение настройки из соответствия или структуры по ключу без учета регистра ключа
//   
// Параметры:
//   Настройка      - Строка                    - ключ (имя) настройки
//   ВсеНастройки   - Структура, Соответствие   - контейнер настроек
//   ПоУмолчанию    - Произвольный              - значение настройки по умолчанию
//                                                возвращается если контейнер не содержит указанную настройку
//   
// Возвращаемое значение:
//    Произвольный   - значение настройки или значение по умолчанию
//
Функция ПолучитьЗначениеНастройки(Настройка, ВсеНастройки, ПоУмолчанию = Неопределено)
	
	ЭтоНастройки = (ТипЗнч(ВсеНастройки) = Тип("Соответствие")
	            ИЛИ ТипЗнч(ВсеНастройки) = Тип("ФиксированноеСоответствие")
	            ИЛИ ТипЗнч(ВсеНастройки) = Тип("Структура")
	            ИЛИ ТипЗнч(ВсеНастройки) = Тип("ФиксированнаяСтруктура"));

	Если НЕ ЭтоНастройки Тогда
		Возврат ПоУмолчанию;
	КонецЕсли;

	Для Каждого ТекНастройка Из ВсеНастройки Цикл
		Если НРег(ТекНастройка.Ключ) = НРег(Настройка) Тогда
			Возврат ТекНастройка.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ПоУмолчанию;
	
КонецФункции // ПолучитьЗначениеНастройки()

#КонецОбласти // ЧтениеНастроек

#Область УстановкаПараметровОбъектовКластера

// Процедура - устанавливает параметры кластера из настроек
//
// Параметры:
//   Кластер         - Кластер        - объект кластера 1С
//
Процедура УстановитьПараметрыКластера(Кластер) Экспорт
	
	МеткаКластера = ВРег(СтрШаблон("%1:%2", Кластер.АдресСервера(), Кластер.ПортСервера()));

	ПараметрыКластера = ПараметрыПодключения.Кластеры[МеткаКластера];
	Если НЕ ТипЗнч(ПараметрыКластера) = Тип("Структура") Тогда
		ПараметрыКластера = Новый Структура();
	КонецЕсли;
	ПараметрыКластераПоУмолчанию = ПараметрыПодключения.Кластеры["ПОУМОЛЧАНИЮ"];
	Если НЕ ТипЗнч(ПараметрыКластераПоУмолчанию) = Тип("Структура") Тогда
		ПараметрыКластераПоУмолчанию = Новый Структура();
	КонецЕсли;

	Администратор = "";
	Пароль = "";
	Если НЕ ПараметрыКластера.Свойство("Администратор", Администратор) Тогда
		ПараметрыКластераПоУмолчанию.Свойство("Администратор", Администратор);
	КонецЕсли;
	Если НЕ ПараметрыКластера.Свойство("Пароль", Пароль) Тогда
		ПараметрыКластераПоУмолчанию.Свойство("Пароль", Пароль);
	КонецЕсли;
	ТолькоИБИзСписка = Ложь;
	Если НЕ ПараметрыКластера.Свойство("ТолькоИБИзСписка", ТолькоИБИзСписка) Тогда
		ПараметрыКластераПоУмолчанию.Свойство("ТолькоИБИзСписка", ТолькоИБИзСписка);
	КонецЕсли;

	Кластер.УстановитьАдминистратора(Администратор, Пароль);

	СписокИБ = Кластер.ИнформационныеБазы().Список(, Истина);
	Для Каждого ТекИБ Из СписокИБ Цикл
		УстановитьПараметрыИБ(ТекИБ, ПараметрыКластера);
	КонецЦикла;

КонецПроцедуры // УстановитьПараметрыКластера()

// Процедура - устанавливает параметры информационной базы из настроек
//
// Параметры:
//   ИБ                  - ИнформационнаяБаза  - объект информационной базы 1С
//   ПараметрыКластера   - Соответствие        - параметры кластера
//
Процедура УстановитьПараметрыИБ(ИБ, ПараметрыКластера)
	
	Если НЕ (ПараметрыКластера.Свойство("ИБ") И ТипЗнч(ПараметрыКластера.ИБ) = Тип("Соответствие")) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыИБ = ПараметрыКластера.ИБ[ВРег(ИБ.Имя())];
	Если НЕ ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ = Новый Структура();
	КонецЕсли;
	ПараметрыИБПоУмолчанию = ПараметрыКластера.ИБ["ПОУМОЛЧАНИЮ"];
	Если НЕ ТипЗнч(ПараметрыИБПоУмолчанию) = Тип("Структура") Тогда
		ПараметрыИБПоУмолчанию = Новый Структура();
	КонецЕсли;

	Администратор     = "";
	Пароль            = "";
	ПараметрыСУБДИБ = Новый Структура("СУБД_Тип,
	                                  |СУБД_Сервер,
	                                  |СУБД_Пользователь,
	                                  |СУБД_Пароль,
	                                  |СУБД_База,
	                                  |СУБД_ВремяЖизни_Структуры,
	                                  |СУБД_ВремяЖизни_БД,
	                                  |СУБД_ВремяЖизни_Таблиц");
	ПараметрыСУБДИБ.СУБД_База = ИБ.Имя();

	Если НЕ ПараметрыИБ.Свойство("Администратор", Администратор) Тогда
		ПараметрыИБПоУмолчанию.Свойство("Администратор", Администратор);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("Пароль", Пароль) Тогда
		ПараметрыИБПоУмолчанию.Свойство("Пароль", Пароль);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("СУБД_Тип", ПараметрыСУБДИБ.СУБД_Тип) Тогда
		ПараметрыИБПоУмолчанию.Свойство("СУБД_Тип", ПараметрыСУБДИБ.СУБД_Тип);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("СУБД_Сервер", ПараметрыСУБДИБ.СУБД_Сервер) Тогда
		ПараметрыИБПоУмолчанию.Свойство("СУБД_Сервер", ПараметрыСУБДИБ.СУБД_Сервер);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("СУБД_Пользователь", ПараметрыСУБДИБ.СУБД_Пользователь) Тогда
		ПараметрыИБПоУмолчанию.Свойство("СУБД_Пользователь", ПараметрыСУБДИБ.СУБД_Пользователь);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("СУБД_Пароль", ПараметрыСУБДИБ.СУБД_Пароль) Тогда
		ПараметрыИБПоУмолчанию.Свойство("СУБД_Пароль", ПараметрыСУБДИБ.СУБД_Пароль);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("СУБД_ВремяЖизни_Структуры", ПараметрыСУБДИБ.СУБД_ВремяЖизни_Структуры) Тогда
		ПараметрыИБПоУмолчанию.Свойство("СУБД_ВремяЖизни_Структуры", ПараметрыСУБДИБ.СУБД_ВремяЖизни_Структуры);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("СУБД_ВремяЖизни_БД", ПараметрыСУБДИБ.СУБД_ВремяЖизни_БД) Тогда
		ПараметрыИБПоУмолчанию.Свойство("СУБД_ВремяЖизни_БД", ПараметрыСУБДИБ.СУБД_ВремяЖизни_БД);
	КонецЕсли;
	Если НЕ ПараметрыИБ.Свойство("СУБД_ВремяЖизни_Таблиц", ПараметрыСУБДИБ.СУБД_ВремяЖизни_Таблиц) Тогда
		ПараметрыИБПоУмолчанию.Свойство("СУБД_ВремяЖизни_Таблиц", ПараметрыСУБДИБ.СУБД_ВремяЖизни_Таблиц);
	КонецЕсли;
	Если ПараметрыИБ.Свойство("СУБД_База") И ЗначениеЗаполнено(ПараметрыИБ.СУБД_База) Тогда
		ПараметрыСУБДИБ.СУБД_База = ПараметрыИБ.СУБД_База;
	КонецЕсли;

	ИБ.УстановитьАдминистратора(Администратор, Пароль);
	
	Если НЕ ТипЗнч(КэшПараметровСУБДИБ) = Тип("Соответствие") Тогда
		КэшПараметровСУБДИБ = Новый Соответствие();
	КонецЕсли;
	
	КэшПараметровСУБДИБ.Вставить(ИБ.Ид(), ПараметрыСУБДИБ);

КонецПроцедуры // УстановитьПараметрыИБ()

#КонецОбласти // УстановкаПараметровКластера

#Область СлужебныеПроцедурыИФункции

Процедура ПеречитатьИзмененияНастроек()

	Если ВыполняетсяОбновлениеНастроек Тогда
		Возврат;
	КонецЕсли;
	
	НовыйХэшНастроек = ОбщегоНазначения.ХешМакета("/config/racsettings");

	Если НЕ ОбновлениеНастроекПриИзменении ИЛИ ХэшНастроек = НовыйХэшНастроек Тогда
		Возврат;
	КонецЕсли;

	Инициализация();

КонецПроцедуры // ПеречитатьИзмененияНастроек()

#КонецОбласти // СлужебныеПроцедурыИФункции

Инициализация();