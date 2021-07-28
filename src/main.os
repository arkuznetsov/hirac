// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/hirac/
// ----------------------------------------------------------

#Использовать "model"

Процедура ПриНачалеРаботыСистемы()

	ИспользоватьМаршруты("ОпределениеМаршрутов");

КонецПроцедуры // ПриНачалеРаботыСистемы()

Процедура ОпределениеМаршрутов(КоллекцияМаршрутов)

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "counter");
	ПараметрыМаршрута.Вставить("action", "list");
	
	КоллекцияМаршрутов.Добавить("counter_list", "counter/list", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("counter_type_list", "counter/{type}/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "counter");
	ПараметрыМаршрута.Вставить("action", "get");
	
	КоллекцияМаршрутов.Добавить("counter", "counter/{type}/{counter?}", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "clusterObject");
	ПараметрыМаршрута.Вставить("action", "list");

	КоллекцияМаршрутов.Добавить("cluster", "cluster/list", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("server", "server/list", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("process", "process/list", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("infobase", "infobase/list", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("session", "session/list", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("connection", "connection/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "clusterObject");
	ПараметрыМаршрута.Вставить("action", "get");

	КоллекцияМаршрутов.Добавить("cluster_params", "cluster/{id}/{property?}", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("server_params", "server/{id}/{property?}", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("process_params", "process/{id}/{property?}", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("infobase_params", "infobase/{id}/{property?}", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("session_params", "session/{id}/{property?}", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("connection_params", "connection/{id}/{property?}", ПараметрыМаршрута);

	КоллекцияМаршрутов.Добавить("default", "{controller=command}/{action=state}");

КонецПроцедуры // ОпределениеМаршрутов()