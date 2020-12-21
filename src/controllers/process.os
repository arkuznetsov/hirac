
&HTTPMethod("GET")
Функция list() Экспорт

	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Поля = "_all";
	Если НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	Фильтр = ОбщегоНазначения.ФильтрИзПараметровЗапроса(ПараметрыЗапроса);

	Результат = ОбщегоНазначения.ДанныеВJSON(ДанныеПроцессов.Процессы(Поля, Фильтр, Истина));

	Возврат Содержимое(Результат);

КонецФункции // list()

&HTTPMethod("GET")
Функция get() Экспорт

	АдресСервера = Неопределено;
	ПортСервера  = Неопределено;
	ИмяПараметра = Неопределено;

	Если ТипЗнч(ЗначенияМаршрута) = Тип("Соответствие") Тогда
		АдресСервера = ЗначенияМаршрута.Получить("host");
		ПортСервера  = ЗначенияМаршрута.Получить("port");
		ИмяПараметра = ЗначенияМаршрута.Получить("parameter");
	КонецЕсли;
	
	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Формат = "json";
	Если НЕ ПараметрыЗапроса["format"] = Неопределено Тогда
		Формат = ПараметрыЗапроса["format"];
	КонецЕсли;

	Поля = "_all";
	Если НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	Данные = ДанныеПроцессов.Процесс(АдресСервера, ПортСервера, Поля, Истина);
	
	Если ЗначениеЗаполнено(ИмяПараметра) Тогда
		Результат = СтрШаблон("%1=%2", ИмяПараметра, Данные[ИмяПараметра]);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(Данные);
	КонецЕсли;

	Возврат Содержимое(Результат);

КонецФункции // get()
