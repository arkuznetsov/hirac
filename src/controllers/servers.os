
&HTTPMethod("GET")
Функция list() Экспорт

	Результат = ДанныеСерверов.Список();

	Возврат Содержимое(Результат);

КонецФункции // list()

&HTTPMethod("GET")
Функция get() Экспорт

	АдресСервера = Неопределено;
	ПортСервера  = Неопределено;
	ИмяПараметра = Неопределено;

	Если ТипЗнч(ЗначенияМаршрута) = Тип("Соответствие") Тогда
		АдресСервера = ЗначенияМаршрута.Получить("agent-host");
		ПортСервера  = Число(ЗначенияМаршрута.Получить("agent-port"));
		ИмяПараметра = ЗначенияМаршрута.Получить("parameter");
	КонецЕсли;
	
	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Формат = "json";
	Если НЕ ПараметрыЗапроса["format"] = Неопределено Тогда
		Формат = ПараметрыЗапроса["format"];
	КонецЕсли;

	Данные = ДанныеСерверов.Сервер(АдресСервера, ПортСервера, Истина);
	
	Если ЗначениеЗаполнено(ИмяПараметра) Тогда
		Результат = СтрШаблон("%1=%2", ИмяПараметра, Данные[ИмяПараметра]);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(Данные);
	КонецЕсли;

	Возврат Содержимое(Результат);

КонецФункции // get()